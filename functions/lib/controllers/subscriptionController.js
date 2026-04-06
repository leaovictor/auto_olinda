"use strict";
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
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.cancelAsaasSubscription = exports.createAsaasSubscription = void 0;
const https_1 = require("firebase-functions/v2/https");
const params_1 = require("firebase-functions/params");
const admin = __importStar(require("firebase-admin"));
const secrets_1 = require("../config/secrets");
const tenantAuth_1 = require("../middleware/tenantAuth");
const tenantRepository_1 = require("../repositories/tenantRepository");
const userRepository_1 = require("../repositories/userRepository");
const subscriptionRepository_1 = require("../repositories/subscriptionRepository");
const paymentProviderFactory_1 = require("../services/payments/paymentProviderFactory");
const asaasService_1 = require("../services/payments/asaasService");
const logger_1 = require("../services/logger");
// ─────────────────────────────────────────────────────────────────────────────
// Secrets (declared statically so Cloud Functions registers them)
// ─────────────────────────────────────────────────────────────────────────────
const ASAAS_WEBHOOK_TOKEN = (0, params_1.defineSecret)("ASAAS_WEBHOOK_TOKEN");
const ASAAS_API_KEY_POOL = (0, params_1.defineSecret)("ASAAS_API_KEY_POOL");
const STRIPE_SECRET = (0, params_1.defineSecret)("STRIPE_SECRET");
const STRIPE_WEBHOOK_SECRET = (0, params_1.defineSecret)("STRIPE_WEBHOOK_SECRET");
// ─────────────────────────────────────────────────────────────────────────────
// createAsaasSubscription
// ─────────────────────────────────────────────────────────────────────────────
exports.createAsaasSubscription = (0, https_1.onCall)({ secrets: [ASAAS_WEBHOOK_TOKEN, ASAAS_API_KEY_POOL, STRIPE_SECRET, STRIPE_WEBHOOK_SECRET] }, async (request) => {
    const ctx = (0, tenantAuth_1.extractTenantContext)(request);
    const log = (0, logger_1.tenantLogger)(ctx.tenantId, "createAsaasSubscription");
    const { planId, vehiclePlate, vehicleId, billingType } = request.data;
    if (!planId?.trim()) {
        throw new https_1.HttpsError("invalid-argument", "planId é obrigatório.");
    }
    // ── Tenant status + feature checks ─────────────────────────────────────
    const tenantConfig = await (0, tenantRepository_1.getTenantConfig)(ctx.tenantId);
    (0, tenantRepository_1.assertTenantActive)(tenantConfig, ctx.tenantId);
    (0, tenantRepository_1.checkFeature)(tenantConfig, "subscriptions", ctx.tenantId);
    // ── PIX feature check ──────────────────────────────────────────────────
    const effectiveBillingType = billingType ?? tenantConfig.defaultBillingType ?? "PIX";
    if (effectiveBillingType === "PIX") {
        (0, tenantRepository_1.checkFeature)(tenantConfig, "pix", ctx.tenantId);
    }
    try {
        // ── Load plan ──────────────────────────────────────────────────────────
        const planDoc = await tenantRepository_1.Paths.plan(ctx.tenantId, planId).get();
        if (!planDoc.exists) {
            throw new https_1.HttpsError("not-found", `Plano "${planId}" não encontrado.`);
        }
        const plan = planDoc.data();
        if (!plan.isActive) {
            throw new https_1.HttpsError("failed-precondition", "Este plano não está disponível.");
        }
        // ── Check existing active subscription ─────────────────────────────────
        const existingSub = await (0, subscriptionRepository_1.getActiveSubscription)(ctx.tenantId, ctx.userId);
        if (existingSub) {
            throw new https_1.HttpsError("already-exists", "Você já possui uma assinatura ativa. Cancele-a antes de criar uma nova.");
        }
        // ── Load user profile ──────────────────────────────────────────────────
        const userDoc = await (0, userRepository_1.getUserDoc)(ctx.tenantId, ctx.userId);
        if (!userDoc) {
            throw new https_1.HttpsError("not-found", "Perfil de usuário não encontrado neste tenant.");
        }
        // ── Get payment provider via factory (reads API key from Secret pool) ──
        const paymentProvider = await (0, paymentProviderFactory_1.getPaymentProvider)(ctx.tenantId, (0, secrets_1.getSecret)(ASAAS_API_KEY_POOL, "ASAAS_API_KEY_POOL"), (0, secrets_1.getSecret)(ASAAS_WEBHOOK_TOKEN, "ASAAS_WEBHOOK_TOKEN"), (0, secrets_1.getSecretOrDefault)(STRIPE_SECRET, "STRIPE_SECRET", ""), (0, secrets_1.getSecretOrDefault)(STRIPE_WEBHOOK_SECRET, "STRIPE_WEBHOOK_SECRET", ""));
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
            await (0, userRepository_1.saveAsaasCustomerId)(ctx.tenantId, ctx.userId, asaasCustomerId);
        }
        // ── Build structured externalReference ────────────────────────────────
        const externalReference = (0, asaasService_1.buildExternalRef)(ctx.tenantId, ctx.userId, "subscription");
        // ── Create subscription in payment provider ───────────────────────────
        const nextDueDate = (0, asaasService_1.formatAsaasDate)(new Date());
        const providerSub = await paymentProvider.createSubscription({
            customerId: asaasCustomerId,
            externalReference,
            billingType: effectiveBillingType,
            value: plan.price,
            nextDueDate,
            cycle: "MONTHLY",
            description: `${plan.name} — ${ctx.tenantId}`,
        });
        // ── Create Firestore subscription doc (pending until webhook) ─────────
        const subId = await (0, subscriptionRepository_1.createSubscriptionDoc)(ctx.tenantId, {
            tenantId: ctx.tenantId,
            userId: ctx.userId,
            planId,
            status: "pending",
            asaasSubscriptionId: providerSub.id,
            asaasCustomerId,
            linkedPlate: vehiclePlate ?? "",
            vehicleId: vehicleId ?? "",
            billingType: effectiveBillingType,
            value: plan.price,
            startDate: admin.firestore.Timestamp.now(),
        });
        await (0, subscriptionRepository_1.logSubscriptionEvent)(ctx.tenantId, subId, "SUBSCRIPTION_CREATED", {
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
            message: effectiveBillingType === "PIX"
                ? "Assinatura criada. Aguarde o QR code PIX no seu e-mail."
                : "Assinatura criada. Aguardando confirmação do pagamento.",
        };
    }
    catch (err) {
        if (err instanceof https_1.HttpsError)
            throw err;
        log.error("createAsaasSubscription failed", { error: err.message }, ctx.userId);
        throw new https_1.HttpsError("internal", `Falha ao criar assinatura: ${err.message}`);
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// cancelAsaasSubscription
// ─────────────────────────────────────────────────────────────────────────────
exports.cancelAsaasSubscription = (0, https_1.onCall)({ secrets: [ASAAS_WEBHOOK_TOKEN, ASAAS_API_KEY_POOL, STRIPE_SECRET, STRIPE_WEBHOOK_SECRET] }, async (request) => {
    const ctx = (0, tenantAuth_1.extractTenantContext)(request);
    const log = (0, logger_1.tenantLogger)(ctx.tenantId, "cancelAsaasSubscription");
    const { subscriptionId, targetUserId } = request.data;
    const tenantConfig = await (0, tenantRepository_1.getTenantConfig)(ctx.tenantId);
    (0, tenantRepository_1.assertTenantActive)(tenantConfig, ctx.tenantId);
    const effectiveUserId = ctx.role !== "customer" && targetUserId ? targetUserId : ctx.userId;
    try {
        let subRecord = null;
        if (subscriptionId) {
            const doc = await tenantRepository_1.Paths.subscription(ctx.tenantId, subscriptionId).get();
            if (!doc.exists) {
                throw new https_1.HttpsError("not-found", "Assinatura não encontrada.");
            }
            // ── Tenant isolation guard ─────────────────────────────────────────
            const docData = doc.data();
            if (docData.tenantId !== ctx.tenantId) {
                log.warn("Cross-tenant subscription cancel attempt", {
                    docTenantId: docData.tenantId,
                }, ctx.userId);
                throw new https_1.HttpsError("permission-denied", "Acesso negado.");
            }
            subRecord = { id: doc.id, data: docData };
        }
        else {
            subRecord = await (0, subscriptionRepository_1.getActiveSubscription)(ctx.tenantId, effectiveUserId);
            if (!subRecord) {
                throw new https_1.HttpsError("not-found", "Nenhuma assinatura ativa encontrada.");
            }
        }
        // ── Authorization ──────────────────────────────────────────────────────
        if (ctx.role === "customer" && subRecord.data.userId !== ctx.userId) {
            throw new https_1.HttpsError("permission-denied", "Sem permissão para cancelar esta assinatura.");
        }
        if (subRecord.data.status === "cancelled") {
            throw new https_1.HttpsError("failed-precondition", "Assinatura já está cancelada.");
        }
        // ── Cancel in payment provider (if not manual) ─────────────────────────
        if (subRecord.data.asaasSubscriptionId && !subRecord.data.isManual) {
            const paymentProvider = await (0, paymentProviderFactory_1.getPaymentProvider)(ctx.tenantId, (0, secrets_1.getSecret)(ASAAS_API_KEY_POOL, "ASAAS_API_KEY_POOL"), (0, secrets_1.getSecret)(ASAAS_WEBHOOK_TOKEN, "ASAAS_WEBHOOK_TOKEN"), (0, secrets_1.getSecretOrDefault)(STRIPE_SECRET, "STRIPE_SECRET", ""), (0, secrets_1.getSecretOrDefault)(STRIPE_WEBHOOK_SECRET, "STRIPE_WEBHOOK_SECRET", ""));
            await paymentProvider.cancelSubscription(subRecord.data.asaasSubscriptionId);
        }
        // ── Update Firestore ──────────────────────────────────────────────────
        await (0, subscriptionRepository_1.cancelSubscriptionDoc)(ctx.tenantId, subRecord.id);
        await (0, subscriptionRepository_1.logSubscriptionEvent)(ctx.tenantId, subRecord.id, "SUBSCRIPTION_CANCELLED", {
            cancelledBy: ctx.userId,
            role: ctx.role,
        });
        // ── Notify user ───────────────────────────────────────────────────────
        const targetUid = subRecord.data.userId ?? effectiveUserId;
        await tenantRepository_1.Paths.notification(ctx.tenantId, targetUid).add({
            title: "Assinatura Cancelada",
            body: "Sua assinatura foi cancelada com sucesso.",
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            isRead: false,
            type: "subscription_cancelled",
        });
        log.info("Subscription cancelled", { subId: subRecord.id }, ctx.userId);
        return { success: true, message: "Assinatura cancelada com sucesso." };
    }
    catch (err) {
        if (err instanceof https_1.HttpsError)
            throw err;
        log.error("cancelAsaasSubscription failed", { error: err.message }, ctx.userId);
        throw new https_1.HttpsError("internal", `Falha ao cancelar: ${err.message}`);
    }
});
//# sourceMappingURL=subscriptionController.js.map