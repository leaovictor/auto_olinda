"use strict";
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
exports.asaasWebhookHandler = void 0;
const https_1 = require("firebase-functions/v2/https");
const params_1 = require("firebase-functions/params");
const admin = __importStar(require("firebase-admin"));
const asaasService_1 = require("../services/payments/asaasService");
const tenantRepository_1 = require("../repositories/tenantRepository");
const secrets_1 = require("../config/secrets");
const subscriptionRepository_1 = require("../repositories/subscriptionRepository");
const userRepository_1 = require("../repositories/userRepository");
const logger_1 = require("../services/logger");
// ─────────────────────────────────────────────────────────────────────────────
// Secrets
// ─────────────────────────────────────────────────────────────────────────────
const ASAAS_WEBHOOK_TOKEN = (0, params_1.defineSecret)("ASAAS_WEBHOOK_TOKEN");
const ASAAS_API_KEY_POOL = (0, params_1.defineSecret)("ASAAS_API_KEY_POOL");
// ─────────────────────────────────────────────────────────────────────────────
// Handler
// ─────────────────────────────────────────────────────────────────────────────
exports.asaasWebhookHandler = (0, https_1.onRequest)({
    secrets: [ASAAS_WEBHOOK_TOKEN, ASAAS_API_KEY_POOL],
    maxInstances: 5,
    timeoutSeconds: 60,
}, async (req, res) => {
    if (req.method !== "POST") {
        res.status(405).json({ error: "Method not allowed" });
        return;
    }
    // ── Token validation (fail fast — 401 triggers Asaas retry) ───────────
    const incomingToken = req.headers["asaas-access-token"] ?? "";
    const expectedToken = (0, secrets_1.getSecret)(ASAAS_WEBHOOK_TOKEN, "ASAAS_WEBHOOK_TOKEN");
    if (!incomingToken || incomingToken !== expectedToken) {
        console.warn("[AsaasWebhook] ⚠️ Unauthorized — invalid or missing token");
        res.status(401).json({ error: "Unauthorized" });
        return;
    }
    // ── Parse body ────────────────────────────────────────────────────────
    let rawBody;
    if (Buffer.isBuffer(req.rawBody)) {
        rawBody = req.rawBody;
    }
    else if (typeof req.body === "object") {
        rawBody = Buffer.from(JSON.stringify(req.body), "utf-8");
    }
    else {
        rawBody = Buffer.from(String(req.body ?? ""), "utf-8");
    }
    let payload;
    try {
        payload = JSON.parse(rawBody.toString("utf-8"));
    }
    catch {
        console.error("[AsaasWebhook] Failed to parse JSON");
        res.status(400).json({ error: "Invalid JSON" });
        return;
    }
    const eventType = payload.event;
    if (!eventType) {
        console.warn("[AsaasWebhook] Missing event field");
        res.status(400).json({ error: "Missing event field" });
        return;
    }
    console.log(`[AsaasWebhook] Event: ${eventType}`);
    // ── Extract externalReference from payload ────────────────────────────
    const paymentObj = payload.payment;
    const subscriptionObj = payload.subscription;
    const rawRef = paymentObj?.externalReference ??
        subscriptionObj?.externalReference ??
        "";
    if (!rawRef) {
        console.warn(`[AsaasWebhook] No externalReference in event "${eventType}". Skipping.`);
        // 200 — not our event (e.g., manual charge in Asaas dashboard)
        res.status(200).json({ received: true, skipped: "no externalReference" });
        return;
    }
    // ── Parse structured externalReference ───────────────────────────────
    let tenantId;
    let userId;
    try {
        const ref = (0, asaasService_1.parseExternalRef)(rawRef);
        tenantId = ref.tenantId;
        userId = ref.userId;
    }
    catch (err) {
        console.error(`[AsaasWebhook] Invalid externalRef: "${rawRef}"`, err);
        // 200 — prevent retry storm for malformed refs that will never parse
        res.status(200).json({ received: true, error: "Invalid externalReference format" });
        return;
    }
    const log = (0, logger_1.tenantLogger)(tenantId, "asaasWebhookHandler");
    // ── Find subscription in Firestore ────────────────────────────────────
    const asaasSubId = paymentObj?.subscription ??
        subscriptionObj?.id ??
        "";
    const subRecord = asaasSubId
        ? await (0, subscriptionRepository_1.findSubscriptionByAsaasId)(tenantId, asaasSubId)
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
    }
    catch (err) {
        log.error("Webhook event processing failed", {
            eventType,
            error: err.message,
        });
        // 500 tells Asaas to retry — only use this for transient errors
        res.status(500).json({ error: "Internal processing error" });
    }
});
async function handlePaymentConfirmed(tenantId, userId, subRecord, eventType, payment, log) {
    if (!subRecord)
        return;
    // Idempotency: skip if already active
    if (subRecord.data.status === "active") {
        log.info("Subscription already active — skipping activation", { subId: subRecord.id });
        return;
    }
    await (0, subscriptionRepository_1.activateSubscription)(tenantId, subRecord.id);
    await (0, subscriptionRepository_1.logSubscriptionEvent)(tenantId, subRecord.id, eventType, {
        paymentId: payment?.id,
        value: payment?.value,
    });
    await tenantRepository_1.Paths.notification(tenantId, userId).add({
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
async function handlePaymentOverdue(tenantId, userId, subRecord, payment, log) {
    if (!subRecord)
        return;
    await (0, subscriptionRepository_1.markSubscriptionDelinquent)(tenantId, subRecord.id);
    await (0, subscriptionRepository_1.logSubscriptionEvent)(tenantId, subRecord.id, "PAYMENT_OVERDUE", {
        paymentId: payment?.id,
        dueDate: payment?.dueDate,
    });
    await tenantRepository_1.Paths.notification(tenantId, userId).add({
        title: "Pagamento em Atraso ⚠️",
        body: "Regularize seu pagamento para manter a assinatura ativa.",
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        isRead: false,
        type: "subscription_delinquent",
    });
    await notifyTenantAdmins(tenantId, "Cliente em Atraso", `Pagamento do usuário ${userId} está em atraso.`, "subscription_delinquent");
    log.warn("Subscription marked delinquent", { subId: subRecord.id, paymentId: payment?.id }, userId);
}
async function handlePaymentRefunded(tenantId, userId, subRecord, payment, log) {
    if (!subRecord)
        return;
    await (0, subscriptionRepository_1.updateSubscriptionStatus)(tenantId, subRecord.id, "inactive");
    await (0, subscriptionRepository_1.logSubscriptionEvent)(tenantId, subRecord.id, "PAYMENT_REFUNDED", {
        paymentId: payment?.id,
        value: payment?.value,
    });
    await tenantRepository_1.Paths.notification(tenantId, userId).add({
        title: "Pagamento Reembolsado",
        body: "Seu pagamento foi reembolsado e a assinatura foi desativada.",
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        isRead: false,
        type: "subscription_refunded",
    });
    log.info("Subscription deactivated (refund)", { subId: subRecord.id }, userId);
}
async function handleSubscriptionDeleted(tenantId, userId, subRecord, eventType, subscription, log) {
    if (!subRecord)
        return;
    await (0, subscriptionRepository_1.cancelSubscriptionDoc)(tenantId, subRecord.id);
    await (0, subscriptionRepository_1.logSubscriptionEvent)(tenantId, subRecord.id, eventType, {
        subscriptionId: subscription?.id,
    });
    await tenantRepository_1.Paths.notification(tenantId, userId).add({
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
async function notifyTenantAdmins(tenantId, title, body, type) {
    try {
        const admins = await (0, userRepository_1.getAdminUsers)(tenantId);
        const batch = admin.firestore().batch();
        const ts = admin.firestore.FieldValue.serverTimestamp();
        for (const { id: adminUid } of admins) {
            const ref = tenantRepository_1.Paths.notification(tenantId, adminUid).doc();
            batch.set(ref, { title, body, type, isRead: false, timestamp: ts });
        }
        await batch.commit();
    }
    catch (err) {
        // Non-critical — log but don't throw
        console.error("[AsaasWebhook] Failed to notify admins:", err);
    }
}
//# sourceMappingURL=asaasWebhook.js.map