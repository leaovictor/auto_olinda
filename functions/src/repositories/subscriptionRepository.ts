/**
 * @file repositories/subscriptionRepository.ts
 * Tenant-scoped subscription data access.
 *
 * Key design:
 * - Subscriptions live at tenants/{tenantId}/subscriptions/{subId}
 * - Webhook resolution: find subscription by asaasSubscriptionId across tenants
 *   is avoided by embedding tenantId in the externalReference field instead.
 */

import * as admin from "firebase-admin";
import { SubscriptionDoc, SubscriptionStatus } from "../types";
import { Paths } from "./tenantRepository";

// ─────────────────────────────────────────────────────────────────────────────
// Read operations
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Gets a specific subscription document.
 */
export async function getSubscription(
  tenantId: string,
  subId: string
): Promise<SubscriptionDoc | null> {
  const doc = await Paths.subscription(tenantId, subId).get();
  if (!doc.exists) return null;
  return doc.data() as SubscriptionDoc;
}

/**
 * Finds the active subscription for a specific user within a tenant.
 * Returns null if no active subscription exists.
 */
export async function getActiveSubscription(
  tenantId: string,
  userId: string
): Promise<{ id: string; data: SubscriptionDoc } | null> {
  const snap = await Paths.tenantCollection(tenantId, "subscriptions")
    .where("userId", "==", userId)
    .where("status", "in", ["active", "trialing"])
    .limit(1)
    .get();

  if (snap.empty) return null;

  return {
    id: snap.docs[0].id,
    data: snap.docs[0].data() as SubscriptionDoc,
  };
}

/**
 * Finds a subscription by the Asaas subscription ID within a tenant.
 * Used in the webhook handler after the tenantId is resolved from externalReference.
 */
export async function findSubscriptionByAsaasId(
  tenantId: string,
  asaasSubscriptionId: string
): Promise<{ id: string; data: SubscriptionDoc } | null> {
  const snap = await Paths.tenantCollection(tenantId, "subscriptions")
    .where("asaasSubscriptionId", "==", asaasSubscriptionId)
    .limit(1)
    .get();

  if (snap.empty) return null;

  return {
    id: snap.docs[0].id,
    data: snap.docs[0].data() as SubscriptionDoc,
  };
}

/**
 * Finds a subscription by userId (any status).
 * Useful for checking if a user already has any subscription record.
 */
export async function getAnySubscriptionByUserId(
  tenantId: string,
  userId: string
): Promise<{ id: string; data: SubscriptionDoc } | null> {
  const snap = await Paths.tenantCollection(tenantId, "subscriptions")
    .where("userId", "==", userId)
    .orderBy("createdAt", "desc")
    .limit(1)
    .get();

  if (snap.empty) return null;

  return {
    id: snap.docs[0].id,
    data: snap.docs[0].data() as SubscriptionDoc,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Write operations
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Creates a new subscription document.
 */
export async function createSubscriptionDoc(
  tenantId: string,
  data: Omit<SubscriptionDoc, "createdAt" | "updatedAt">
): Promise<string> {
  const ref = await Paths.tenantCollection(tenantId, "subscriptions").add({
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
export async function updateSubscriptionStatus(
  tenantId: string,
  subId: string,
  status: SubscriptionStatus,
  extraFields?: Partial<SubscriptionDoc>
): Promise<void> {
  await Paths.subscription(tenantId, subId).update({
    status,
    ...(extraFields ?? {}),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Activates a subscription after payment confirmation.
 * Sets status to 'active' and records the activatedAt timestamp.
 */
export async function activateSubscription(
  tenantId: string,
  subId: string
): Promise<void> {
  await updateSubscriptionStatus(tenantId, subId, "active", {
    activatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Cancels a subscription in Firestore.
 */
export async function cancelSubscriptionDoc(
  tenantId: string,
  subId: string
): Promise<void> {
  await updateSubscriptionStatus(tenantId, subId, "cancelled", {
    cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Marks a subscription as delinquent due to payment overdue.
 */
export async function markSubscriptionDelinquent(
  tenantId: string,
  subId: string
): Promise<void> {
  await updateSubscriptionStatus(tenantId, subId, "delinquent");
}

/**
 * Writes an audit log entry in the tenant's subscription_status_logs collection.
 */
export async function logSubscriptionEvent(
  tenantId: string,
  subId: string,
  event: string,
  metadata?: Record<string, unknown>
): Promise<void> {
  await Paths.tenantCollection(tenantId, "subscription_status_logs").add({
    subscriptionId: subId,
    event,
    metadata: metadata ?? {},
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}
