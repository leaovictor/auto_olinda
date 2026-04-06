"use strict";
/**
 * @file repositories/subscriptionRepository.ts
 * Tenant-scoped subscription data access.
 *
 * Key design:
 * - Subscriptions live at tenants/{tenantId}/subscriptions/{subId}
 * - Webhook resolution: find subscription by asaasSubscriptionId across tenants
 *   is avoided by embedding tenantId in the externalReference field instead.
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
exports.getSubscription = getSubscription;
exports.getActiveSubscription = getActiveSubscription;
exports.findSubscriptionByAsaasId = findSubscriptionByAsaasId;
exports.getAnySubscriptionByUserId = getAnySubscriptionByUserId;
exports.createSubscriptionDoc = createSubscriptionDoc;
exports.updateSubscriptionStatus = updateSubscriptionStatus;
exports.activateSubscription = activateSubscription;
exports.cancelSubscriptionDoc = cancelSubscriptionDoc;
exports.markSubscriptionDelinquent = markSubscriptionDelinquent;
exports.logSubscriptionEvent = logSubscriptionEvent;
const admin = __importStar(require("firebase-admin"));
const tenantRepository_1 = require("./tenantRepository");
// ─────────────────────────────────────────────────────────────────────────────
// Read operations
// ─────────────────────────────────────────────────────────────────────────────
/**
 * Gets a specific subscription document.
 */
async function getSubscription(tenantId, subId) {
    const doc = await tenantRepository_1.Paths.subscription(tenantId, subId).get();
    if (!doc.exists)
        return null;
    return doc.data();
}
/**
 * Finds the active subscription for a specific user within a tenant.
 * Returns null if no active subscription exists.
 */
async function getActiveSubscription(tenantId, userId) {
    const snap = await tenantRepository_1.Paths.tenantCollection(tenantId, "subscriptions")
        .where("userId", "==", userId)
        .where("status", "in", ["active", "trialing"])
        .limit(1)
        .get();
    if (snap.empty)
        return null;
    return {
        id: snap.docs[0].id,
        data: snap.docs[0].data(),
    };
}
/**
 * Finds a subscription by the Asaas subscription ID within a tenant.
 * Used in the webhook handler after the tenantId is resolved from externalReference.
 */
async function findSubscriptionByAsaasId(tenantId, asaasSubscriptionId) {
    const snap = await tenantRepository_1.Paths.tenantCollection(tenantId, "subscriptions")
        .where("asaasSubscriptionId", "==", asaasSubscriptionId)
        .limit(1)
        .get();
    if (snap.empty)
        return null;
    return {
        id: snap.docs[0].id,
        data: snap.docs[0].data(),
    };
}
/**
 * Finds a subscription by userId (any status).
 * Useful for checking if a user already has any subscription record.
 */
async function getAnySubscriptionByUserId(tenantId, userId) {
    const snap = await tenantRepository_1.Paths.tenantCollection(tenantId, "subscriptions")
        .where("userId", "==", userId)
        .orderBy("createdAt", "desc")
        .limit(1)
        .get();
    if (snap.empty)
        return null;
    return {
        id: snap.docs[0].id,
        data: snap.docs[0].data(),
    };
}
// ─────────────────────────────────────────────────────────────────────────────
// Write operations
// ─────────────────────────────────────────────────────────────────────────────
/**
 * Creates a new subscription document.
 */
async function createSubscriptionDoc(tenantId, data) {
    const ref = await tenantRepository_1.Paths.tenantCollection(tenantId, "subscriptions").add({
        ...data,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return ref.id;
}
/**
 * Updates the status of a subscription.
 * This is the most common operation, called by the webhook handler.
 */
async function updateSubscriptionStatus(tenantId, subId, status, extraFields) {
    await tenantRepository_1.Paths.subscription(tenantId, subId).update({
        status,
        ...(extraFields ?? {}),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}
/**
 * Activates a subscription after payment confirmation.
 * Sets status to 'active' and records the activatedAt timestamp.
 */
async function activateSubscription(tenantId, subId) {
    await updateSubscriptionStatus(tenantId, subId, "active", {
        activatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}
/**
 * Cancels a subscription in Firestore.
 */
async function cancelSubscriptionDoc(tenantId, subId) {
    await updateSubscriptionStatus(tenantId, subId, "cancelled", {
        cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}
/**
 * Marks a subscription as delinquent due to payment overdue.
 */
async function markSubscriptionDelinquent(tenantId, subId) {
    await updateSubscriptionStatus(tenantId, subId, "delinquent");
}
/**
 * Writes an audit log entry in the tenant's subscription_status_logs collection.
 */
async function logSubscriptionEvent(tenantId, subId, event, metadata) {
    await tenantRepository_1.Paths.tenantCollection(tenantId, "subscription_status_logs").add({
        subscriptionId: subId,
        event,
        metadata: metadata ?? {},
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}
//# sourceMappingURL=subscriptionRepository.js.map