/**
 * @file repositories/userRepository.ts
 * Tenant-scoped user data access.
 */

import * as admin from "firebase-admin";
import { UserDoc, UserRole } from "../types";
import { Paths } from "./tenantRepository";

// ─────────────────────────────────────────────────────────────────────────────
// Read operations
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Fetches a user document within a tenant.
 * @returns UserDoc or null if not found
 */
export async function getUserDoc(
  tenantId: string,
  userId: string
): Promise<UserDoc | null> {
  const doc = await Paths.user(tenantId, userId).get();
  if (!doc.exists) return null;
  return doc.data() as UserDoc;
}

/**
 * Gets all admin users within a tenant.
 * Used for sending notifications to tenant staff.
 */
export async function getAdminUsers(tenantId: string): Promise<
  Array<{ id: string; data: UserDoc }>
> {
  const snap = await Paths.tenantCollection(tenantId, "users")
    .where("role", "in", ["admin", "staff"])
    .get();

  return snap.docs.map((doc) => ({
    id: doc.id,
    data: doc.data() as UserDoc,
  }));
}

// ─────────────────────────────────────────────────────────────────────────────
// Write operations
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Creates or overwrites a user document within a tenant.
 */
export async function setUserDoc(
  tenantId: string,
  userId: string,
  data: Omit<UserDoc, "createdAt" | "updatedAt">
): Promise<void> {
  await Paths.user(tenantId, userId).set(
    {
      ...data,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true } // merge so we don't overwrite existing fields on re-registration
  );
}

/**
 * Updates specific fields on a user document.
 */
export async function updateUserDoc(
  tenantId: string,
  userId: string,
  updates: Partial<UserDoc>
): Promise<void> {
  await Paths.user(tenantId, userId).update({
    ...updates,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Saves a customer ID from the payment provider to the user's profile.
 */
export async function saveAsaasCustomerId(
  tenantId: string,
  userId: string,
  asaasCustomerId: string
): Promise<void> {
  await updateUserDoc(tenantId, userId, { asaasCustomerId });
}

// ─────────────────────────────────────────────────────────────────────────────
// Firebase Auth custom claims
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Sets the tenant custom claims on a Firebase Auth user.
 * This enables Firestore security rules to enforce tenant isolation
 * via `request.auth.token.tenantId`.
 *
 * IMPORTANT: After setting claims, the user must refresh their ID token
 * (e.g., by calling auth.currentUser.getIdTokenResult(true) in the client).
 */
export async function setUserClaims(
  userId: string,
  tenantId: string,
  role: UserRole
): Promise<void> {
  await admin.auth().setCustomUserClaims(userId, { tenantId, role });
  console.log(
    `[UserRepo] Custom claims set for user ${userId}: tenantId=${tenantId}, role=${role}`
  );
}

/**
 * Revokes all sessions for a user (forces token refresh).
 * Call after updating custom claims to ensure immediate effect.
 */
export async function revokeUserSessions(userId: string): Promise<void> {
  await admin.auth().revokeRefreshTokens(userId);
}
