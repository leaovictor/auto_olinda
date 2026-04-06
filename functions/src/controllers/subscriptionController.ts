/**
 * @file controllers/subscriptionController.ts
 * Subscription lifecycle — hardened v2.
 *
 * Changes from v1:
 *  - Uses getPaymentProvider() factory (no direct AsaasService instantiation)
 *  - asaasApiKey removed — factory reads from ASAAS_API_KEY_POOL secret
 *  - Tenant status check (assertTenantActive) at entry
 *  - Feature flag check (checkFeature: "subscriptions") at entry
 *  - Structured externalReference JSON (AsaasExternalRef)
 *  - Renamed CreateSubscriptionInput_Callable → CreateSubscriptionCallableInput
 *  - Full audit logging via tenantLogger
 */

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import * as admin from "firebase-admin";
import { getSecret, getSecretOrDefault } from "../config/secrets";
import { extractTenantContext } from "../middleware/tenantAuth";
import {
  getTenantConfig,
  assertTenantActive,
  checkFeature,
  Paths,
} from "../repositories/tenantRepository";
import {
  getUserDoc,
  saveAsaasCustomerId,
} from "../repositories/userRepository";
import {
  createSubscriptionDoc,
  getActiveSubscription,
  cancelSubscriptionDoc,
  logSubscriptionEvent,
} from "../repositories/subscriptionRepository";
import { getPaymentProvider } from "../services/payments/paymentProviderFactory";
import { buildExternalRef, formatAsaasDate } from "../services/payments/asaasService";
import { tenantLogger } from "../services/logger";
import { AsaasBillingType, CreateSubscriptionCallableInput } from "../types";

// ─────────────────────────────────────────────────────────────────────────────
// Secrets (declared statically so Cloud Functions registers them)
// ─────────────────────────────────────────────────────────────────────────────

const ASAAS_WEBHOOK_TOKEN = defineSecret("ASAAS_WEBHOOK_TOKEN");
const ASAAS_API_KEY_POOL = defineSecret("ASAAS_API_KEY_POOL");
const STRIPE_SECRET = defineSecret("STRIPE_SECRET");
const STRIPE_WEBHOOK_SECRET = defineSecret("STRIPE_WEBHOOK_SECRET");

// ─────────────────────────────────────────────────────────────────────────────
// createAsaasSubscription
// ─────────────────────────────────────────────────────────────────────────────

export const createAsaasSubscription = onCall(
  { secrets: [ASAAS_WEBHOOK_TOKEN, ASAAS_API_KEY_POOL, STRIPE_SECRET, STRIPE_WEBHOOK_SECRET] },
  async (request) => {
    const ctx = extractTenantContext(request);
    const log = tenantLogger(ctx.tenantId, "createAsaasSubscription");

    const { planId, vehiclePlate, vehicleId, billingType } =
      request.data as CreateSubscriptionCallableInput;

    if (!planId?.trim()) {
      throw new HttpsError("invalid-argument", "planId é obrigatório.");
    }

    // ── Tenant status + feature checks ─────────────────────────────────────
    const tenantConfig = await getTenantConfig(ctx.tenantId);
    assertTenantActive(tenantConfig, ctx.tenantId);
    checkFeature(tenantConfig, "subscriptions", ctx.tenantId);

    // ── PIX feature check ──────────────────────────────────────────────────
    const effectiveBillingType: AsaasBillingType =
      billingType ?? tenantConfig.defaultBillingType ?? "PIX";

    if (effectiveBillingType === "PIX") {
      checkFeature(tenantConfig, "pix", ctx.tenantId);
    }

    try {
      // ── Load plan ──────────────────────────────────────────────────────────
      const planDoc = await Paths.plan(ctx.tenantId, planId).get();
      if (!planDoc.exists) {
        throw new HttpsError("not-found", `Plano "${planId}" não encontrado.`);
      }
      const plan = planDoc.data()!;

      if (!plan.isActive) {
        throw new HttpsError("failed-precondition", "Este plano não está disponível.");
      }

      // ── Check existing active subscription ─────────────────────────────────
      const existingSub = await getActiveSubscription(ctx.tenantId, ctx.userId);
      if (existingSub) {
        throw new HttpsError(
          "already-exists",
          "Você já possui uma assinatura ativa. Cancele-a antes de criar uma nova."
        );
      }

      // ── Load user profile ──────────────────────────────────────────────────
      const userDoc = await getUserDoc(ctx.tenantId, ctx.userId);
      if (!userDoc) {
        throw new HttpsError("not-found", "Perfil de usuário não encontrado neste tenant.");
      }

      // ── Get payment provider via factory (reads API key from Secret pool) ──
      const paymentProvider = await getPaymentProvider(
        ctx.tenantId,
        getSecret(ASAAS_API_KEY_POOL, "ASAAS_API_KEY_POOL"),
        getSecret(ASAAS_WEBHOOK_TOKEN, "ASAAS_WEBHOOK_TOKEN"),
        getSecretOrDefault(STRIPE_SECRET, "STRIPE_SECRET", ""),
        getSecretOrDefault(STRIPE_WEBHOOK_SECRET, "STRIPE_WEBHOOK_SECRET", "")
      );

      // ── Get or create provider customer ───────────────────────────────────
      let asaasCustomerId = userDoc.asaasCustomerId;
      if (!asaasCustomerId) {
        log.info("Creating provider customer", {}, ctx.userId);
        const customer = await paymentProvider.createCustomer({
          name: userDoc.displayName,
          email: userDoc.email,
          phone: userDoc.phone,
          tenantId: ctx.tenantId,
          userId: ctx.userId,
        });
        asaasCustomerId = customer.id;
        await saveAsaasCustomerId(ctx.tenantId, ctx.userId, asaasCustomerId);
      }

      // ── Build structured externalReference ────────────────────────────────
      const externalReference = buildExternalRef(ctx.tenantId, ctx.userId, "subscription");

      // ── Create subscription in payment provider ───────────────────────────
      const nextDueDate = formatAsaasDate(new Date());

      const providerSub = await paymentProvider.createSubscription({
        customerId: asaasCustomerId,
        externalReference,
        billingType: effectiveBillingType,
        value: plan.price as number,
        nextDueDate,
        cycle: "MONTHLY",
        description: `${plan.name as string} — ${ctx.tenantId}`,
      });

      // ── Create Firestore subscription doc (pending until webhook) ─────────
      const subId = await createSubscriptionDoc(ctx.tenantId, {
        tenantId: ctx.tenantId,
        userId: ctx.userId,
        planId,
        status: "pending",
        asaasSubscriptionId: providerSub.id,
        asaasCustomerId,
        linkedPlate: vehiclePlate ?? "",
        vehicleId: vehicleId ?? "",
        billingType: effectiveBillingType,
        value: plan.price as number,
        startDate: admin.firestore.Timestamp.now(),
      });

      await logSubscriptionEvent(ctx.tenantId, subId, "SUBSCRIPTION_CREATED", {
        providerSubId: providerSub.id,
        planId,
        billingType: effectiveBillingType,
      });

      log.info("Subscription created (pending payment)", {
        subId,
        providerSubId: providerSub.id,
        planId,
        billingType: effectiveBillingType,
      }, ctx.userId);

      return {
        success: true,
        subscriptionId: subId,
        asaasSubscriptionId: providerSub.id,
        status: "pending",
        message:
          effectiveBillingType === "PIX"
            ? "Assinatura criada. Aguarde o QR code PIX no seu e-mail."
            : "Assinatura criada. Aguardando confirmação do pagamento.",
      };
    } catch (err: unknown) {
      if (err instanceof HttpsError) throw err;
      log.error("createAsaasSubscription failed", { error: (err as Error).message }, ctx.userId);
      throw new HttpsError("internal", `Falha ao criar assinatura: ${(err as Error).message}`);
    }
  }
);

// ─────────────────────────────────────────────────────────────────────────────
// cancelAsaasSubscription
// ─────────────────────────────────────────────────────────────────────────────

export const cancelAsaasSubscription = onCall(
  { secrets: [ASAAS_WEBHOOK_TOKEN, ASAAS_API_KEY_POOL, STRIPE_SECRET, STRIPE_WEBHOOK_SECRET] },
  async (request) => {
    const ctx = extractTenantContext(request);
    const log = tenantLogger(ctx.tenantId, "cancelAsaasSubscription");

    const { subscriptionId, targetUserId } = request.data as {
      subscriptionId?: string;
      targetUserId?: string;
    };

    const tenantConfig = await getTenantConfig(ctx.tenantId);
    assertTenantActive(tenantConfig, ctx.tenantId);

    const effectiveUserId =
      ctx.role !== "customer" && targetUserId ? targetUserId : ctx.userId;

    try {
      let subRecord: { id: string; data: Record<string, unknown> } | null = null;

      if (subscriptionId) {
        const doc = await Paths.subscription(ctx.tenantId, subscriptionId).get();
        if (!doc.exists) {
          throw new HttpsError("not-found", "Assinatura não encontrada.");
        }
        // ── Tenant isolation guard ─────────────────────────────────────────
        const docData = doc.data()!;
        if (docData.tenantId !== ctx.tenantId) {
          log.warn("Cross-tenant subscription cancel attempt", {
            docTenantId: docData.tenantId,
          }, ctx.userId);
          throw new HttpsError("permission-denied", "Acesso negado.");
        }
        subRecord = { id: doc.id, data: docData };
      } else {
        subRecord = await getActiveSubscription(ctx.tenantId, effectiveUserId);
        if (!subRecord) {
          throw new HttpsError("not-found", "Nenhuma assinatura ativa encontrada.");
        }
      }

      // ── Authorization ──────────────────────────────────────────────────────
      if (ctx.role === "customer" && subRecord.data.userId !== ctx.userId) {
        throw new HttpsError("permission-denied", "Sem permissão para cancelar esta assinatura.");
      }

      if (subRecord.data.status === "cancelled") {
        throw new HttpsError("failed-precondition", "Assinatura já está cancelada.");
      }

      // ── Cancel in payment provider (if not manual) ─────────────────────────
      if (subRecord.data.asaasSubscriptionId && !subRecord.data.isManual) {
        const paymentProvider = await getPaymentProvider(
          ctx.tenantId,
          getSecret(ASAAS_API_KEY_POOL, "ASAAS_API_KEY_POOL"),
          getSecret(ASAAS_WEBHOOK_TOKEN, "ASAAS_WEBHOOK_TOKEN"),
          getSecretOrDefault(STRIPE_SECRET, "STRIPE_SECRET", ""),
          getSecretOrDefault(STRIPE_WEBHOOK_SECRET, "STRIPE_WEBHOOK_SECRET", "")
        );
        await paymentProvider.cancelSubscription(subRecord.data.asaasSubscriptionId as string);
      }

      // ── Update Firestore ──────────────────────────────────────────────────
      await cancelSubscriptionDoc(ctx.tenantId, subRecord.id);
      await logSubscriptionEvent(ctx.tenantId, subRecord.id, "SUBSCRIPTION_CANCELLED", {
        cancelledBy: ctx.userId,
        role: ctx.role,
      });

      // ── Notify user ───────────────────────────────────────────────────────
      const targetUid = (subRecord.data.userId as string) ?? effectiveUserId;
      await Paths.notification(ctx.tenantId, targetUid).add({
        title: "Assinatura Cancelada",
        body: "Sua assinatura foi cancelada com sucesso.",
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        isRead: false,
        type: "subscription_cancelled",
      });

      log.info("Subscription cancelled", { subId: subRecord.id }, ctx.userId);

      return { success: true, message: "Assinatura cancelada com sucesso." };
    } catch (err: unknown) {
      if (err instanceof HttpsError) throw err;
      log.error("cancelAsaasSubscription failed", { error: (err as Error).message }, ctx.userId);
      throw new HttpsError("internal", `Falha ao cancelar: ${(err as Error).message}`);
    }
  }
);
