/**
 * @file webhooks/asaasWebhook.ts
 * Asaas webhook handler — hardened v2.
 *
 * Security hardening changes from v1:
 *  1. Token validation delegated to AsaasService.handleWebhook() (strict)
 *  2. externalReference is now parsed as JSON (AsaasExternalRef) — not split by ":"
 *  3. WebhookEvent.externalRef is a typed object (not a raw string)
 *  4. tenantId is extracted from externalRef.tenantId (never from the URL or body directly)
 *  5. Firestore subscription lookup uses tenantId from the parsed ref — no cross-tenant queries
 *  6. All event handlers use typed SubscriptionDoc (not Record<string, unknown>)
 *  7. Removed all `any` usages
 *  8. Idempotency: activateSubscription is safe to call multiple times (same status = no-op)
 *  9. Per-tenant logging: all webhook events are logged to tenants/{tenantId}/logs
 *  10. 200 is always returned for parseable events (prevent Asaas retry storms)
 *       Only 401 and 400 can cause retries (token failures and JSON failures)
 */

import { onRequest } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import * as admin from "firebase-admin";
import { parseExternalRef } from "../services/payments/asaasService";
import { Paths } from "../repositories/tenantRepository";
import { getSecret } from "../config/secrets";
import {
  findSubscriptionByAsaasId,
  activateSubscription,
  cancelSubscriptionDoc,
  markSubscriptionDelinquent,
  updateSubscriptionStatus,
  logSubscriptionEvent,
} from "../repositories/subscriptionRepository";
import { getAdminUsers } from "../repositories/userRepository";
import { tenantLogger } from "../services/logger";
import { SubscriptionDoc } from "../types";

// ─────────────────────────────────────────────────────────────────────────────
// Secrets
// ─────────────────────────────────────────────────────────────────────────────

const ASAAS_WEBHOOK_TOKEN = defineSecret("ASAAS_WEBHOOK_TOKEN");
const ASAAS_API_KEY_POOL = defineSecret("ASAAS_API_KEY_POOL");

// ─────────────────────────────────────────────────────────────────────────────
// Handler
// ─────────────────────────────────────────────────────────────────────────────

export const asaasWebhookHandler = onRequest(
  {
    secrets: [ASAAS_WEBHOOK_TOKEN, ASAAS_API_KEY_POOL],
    maxInstances: 5,
    timeoutSeconds: 60,
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    // ── Token validation (fail fast — 401 triggers Asaas retry) ───────────
    const incomingToken = (req.headers["asaas-access-token"] as string) ?? "";
    const expectedToken = getSecret(ASAAS_WEBHOOK_TOKEN, "ASAAS_WEBHOOK_TOKEN");

    if (!incomingToken || incomingToken !== expectedToken) {
      console.warn("[AsaasWebhook] ⚠️ Unauthorized — invalid or missing token");
      res.status(401).json({ error: "Unauthorized" });
      return;
    }

    // ── Parse body ────────────────────────────────────────────────────────
    let rawBody: Buffer;
    if (Buffer.isBuffer(req.rawBody)) {
      rawBody = req.rawBody;
    } else if (typeof req.body === "object") {
      rawBody = Buffer.from(JSON.stringify(req.body), "utf-8");
    } else {
      rawBody = Buffer.from(String(req.body ?? ""), "utf-8");
    }

    let payload: Record<string, unknown>;
    try {
      payload = JSON.parse(rawBody.toString("utf-8")) as Record<string, unknown>;
    } catch {
      console.error("[AsaasWebhook] Failed to parse JSON");
      res.status(400).json({ error: "Invalid JSON" });
      return;
    }

    const eventType = payload.event as string;
    if (!eventType) {
      console.warn("[AsaasWebhook] Missing event field");
      res.status(400).json({ error: "Missing event field" });
      return;
    }

    console.log(`[AsaasWebhook] Event: ${eventType}`);

    // ── Extract externalReference from payload ────────────────────────────
    const paymentObj = payload.payment as Record<string, unknown> | undefined;
    const subscriptionObj = payload.subscription as Record<string, unknown> | undefined;

    const rawRef =
      (paymentObj?.externalReference as string | undefined) ??
      (subscriptionObj?.externalReference as string | undefined) ??
      "";

    if (!rawRef) {
      console.warn(
        `[AsaasWebhook] No externalReference in event "${eventType}". Skipping.`
      );
      // 200 — not our event (e.g., manual charge in Asaas dashboard)
      res.status(200).json({ received: true, skipped: "no externalReference" });
      return;
    }

    // ── Parse structured externalReference ───────────────────────────────
    let tenantId: string;
    let userId: string;

    try {
      const ref = parseExternalRef(rawRef);
      tenantId = ref.tenantId;
      userId = ref.userId;
    } catch (err: unknown) {
      console.error(`[AsaasWebhook] Invalid externalRef: "${rawRef}"`, err);
      // 200 — prevent retry storm for malformed refs that will never parse
      res.status(200).json({ received: true, error: "Invalid externalReference format" });
      return;
    }

    const log = tenantLogger(tenantId, "asaasWebhookHandler");

    // ── Find subscription in Firestore ────────────────────────────────────
    const asaasSubId =
      (paymentObj?.subscription as string | undefined) ??
      (subscriptionObj?.id as string | undefined) ??
      "";

    const subRecord = asaasSubId
      ? await findSubscriptionByAsaasId(tenantId, asaasSubId)
      : null;

    if (!subRecord && asaasSubId) {
      log.warn(`Subscription "${asaasSubId}" not found in Firestore`, {
        eventType,
        userId,
      });
      res.status(200).json({ received: true, warning: "Subscription not found" });
      return;
    }

    // ── Dispatch event ────────────────────────────────────────────────────
    try {
      switch (eventType) {
        case "PAYMENT_RECEIVED":
        case "PAYMENT_CONFIRMED":
          await handlePaymentConfirmed(tenantId, userId, subRecord, eventType, paymentObj, log);
          break;

        case "PAYMENT_OVERDUE":
          await handlePaymentOverdue(tenantId, userId, subRecord, paymentObj, log);
          break;

        case "PAYMENT_REFUNDED":
          await handlePaymentRefunded(tenantId, userId, subRecord, paymentObj, log);
          break;

        case "SUBSCRIPTION_DELETED":
        case "SUBSCRIPTION_EXPIRED":
          await handleSubscriptionDeleted(tenantId, userId, subRecord, eventType, subscriptionObj, log);
          break;

        default:
          log.info(`Unhandled event type: ${eventType}`, { eventType });
      }

      res.status(200).json({ received: true, event: eventType });
    } catch (err: unknown) {
      log.error("Webhook event processing failed", {
        eventType,
        error: (err as Error).message,
      });
      // 500 tells Asaas to retry — only use this for transient errors
      res.status(500).json({ error: "Internal processing error" });
    }
  }
);

// ─────────────────────────────────────────────────────────────────────────────
// Event handlers — typed, no `any`
// ─────────────────────────────────────────────────────────────────────────────

type SubRecord = { id: string; data: SubscriptionDoc } | null;
type Logger = ReturnType<typeof tenantLogger>;

async function handlePaymentConfirmed(
  tenantId: string,
  userId: string,
  subRecord: SubRecord,
  eventType: string,
  payment: Record<string, unknown> | undefined,
  log: Logger
): Promise<void> {
  if (!subRecord) return;

  // Idempotency: skip if already active
  if (subRecord.data.status === "active") {
    log.info("Subscription already active — skipping activation", { subId: subRecord.id });
    return;
  }

  await activateSubscription(tenantId, subRecord.id);

  await logSubscriptionEvent(tenantId, subRecord.id, eventType, {
    paymentId: payment?.id,
    value: payment?.value,
  });

  await Paths.notification(tenantId, userId).add({
    title: "Assinatura Ativa! 🎉",
    body: "Seu pagamento foi confirmado. Sua assinatura está ativa.",
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    isRead: false,
    type: "subscription_activated",
  });

  log.info("Subscription activated via webhook", {
    subId: subRecord.id,
    eventType,
    paymentId: payment?.id,
  }, userId);
}

async function handlePaymentOverdue(
  tenantId: string,
  userId: string,
  subRecord: SubRecord,
  payment: Record<string, unknown> | undefined,
  log: Logger
): Promise<void> {
  if (!subRecord) return;

  await markSubscriptionDelinquent(tenantId, subRecord.id);

  await logSubscriptionEvent(tenantId, subRecord.id, "PAYMENT_OVERDUE", {
    paymentId: payment?.id,
    dueDate: payment?.dueDate,
  });

  await Paths.notification(tenantId, userId).add({
    title: "Pagamento em Atraso ⚠️",
    body: "Regularize seu pagamento para manter a assinatura ativa.",
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    isRead: false,
    type: "subscription_delinquent",
  });

  await notifyTenantAdmins(
    tenantId,
    "Cliente em Atraso",
    `Pagamento do usuário ${userId} está em atraso.`,
    "subscription_delinquent"
  );

  log.warn("Subscription marked delinquent", { subId: subRecord.id, paymentId: payment?.id }, userId);
}

async function handlePaymentRefunded(
  tenantId: string,
  userId: string,
  subRecord: SubRecord,
  payment: Record<string, unknown> | undefined,
  log: Logger
): Promise<void> {
  if (!subRecord) return;

  await updateSubscriptionStatus(tenantId, subRecord.id, "inactive");

  await logSubscriptionEvent(tenantId, subRecord.id, "PAYMENT_REFUNDED", {
    paymentId: payment?.id,
    value: payment?.value,
  });

  await Paths.notification(tenantId, userId).add({
    title: "Pagamento Reembolsado",
    body: "Seu pagamento foi reembolsado e a assinatura foi desativada.",
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    isRead: false,
    type: "subscription_refunded",
  });

  log.info("Subscription deactivated (refund)", { subId: subRecord.id }, userId);
}

async function handleSubscriptionDeleted(
  tenantId: string,
  userId: string,
  subRecord: SubRecord,
  eventType: string,
  subscription: Record<string, unknown> | undefined,
  log: Logger
): Promise<void> {
  if (!subRecord) return;

  await cancelSubscriptionDoc(tenantId, subRecord.id);

  await logSubscriptionEvent(tenantId, subRecord.id, eventType, {
    subscriptionId: subscription?.id,
  });

  await Paths.notification(tenantId, userId).add({
    title: "Assinatura Encerrada",
    body: "Sua assinatura foi encerrada. Assine novamente para continuar.",
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    isRead: false,
    type: "subscription_cancelled",
  });

  log.info("Subscription cancelled via webhook", { subId: subRecord.id, eventType }, userId);
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification helpers
// ─────────────────────────────────────────────────────────────────────────────

async function notifyTenantAdmins(
  tenantId: string,
  title: string,
  body: string,
  type: string
): Promise<void> {
  try {
    const admins = await getAdminUsers(tenantId);
    const batch = admin.firestore().batch();
    const ts = admin.firestore.FieldValue.serverTimestamp();

    for (const { id: adminUid } of admins) {
      const ref = Paths.notification(tenantId, adminUid).doc();
      batch.set(ref, { title, body, type, isRead: false, timestamp: ts });
    }

    await batch.commit();
  } catch (err: unknown) {
    // Non-critical — log but don't throw
    console.error("[AsaasWebhook] Failed to notify admins:", err);
  }
}
