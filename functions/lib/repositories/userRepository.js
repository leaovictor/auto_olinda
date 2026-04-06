"use strict";
/**
 * @file repositories/userRepository.ts
 * Tenant-scoped user data access.
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
exports.getUserDoc = getUserDoc;
exports.getAdminUsers = getAdminUsers;
exports.setUserDoc = setUserDoc;
exports.updateUserDoc = updateUserDoc;
exports.saveAsaasCustomerId = saveAsaasCustomerId;
exports.setUserClaims = setUserClaims;
exports.revokeUserSessions = revokeUserSessions;
const admin = __importStar(require("firebase-admin"));
const tenantRepository_1 = require("./tenantRepository");
// ─────────────────────────────────────────────────────────────────────────────
// Read operations
// ─────────────────────────────────────────────────────────────────────────────
/**
 * Fetches a user document within a tenant.
 * @returns UserDoc or null if not found
 */
async function getUserDoc(tenantId, userId) {
    const doc = await tenantRepository_1.Paths.user(tenantId, userId).get();
    if (!doc.exists)
        return null;
    return doc.data();
}
/**
 * Gets all admin users within a tenant.
 * Used for sending notifications to tenant staff.
 */
async function getAdminUsers(tenantId) {
    const snap = await tenantRepository_1.Paths.tenantCollection(tenantId, "users")
        .where("role", "in", ["admin", "staff"])
        .get();
    return snap.docs.map((doc) => ({
        id: doc.id,
        data: doc.data(),
    }));
}
// ─────────────────────────────────────────────────────────────────────────────
// Write operations
// ─────────────────────────────────────────────────────────────────────────────
/**
 * Creates or overwrites a user document within a tenant.
 */
async function setUserDoc(tenantId, userId, data) {
    await tenantRepository_1.Paths.user(tenantId, userId).set({
        ...data,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true } // merge so we don't overwrite existing fields on re-registration
    );
}
/**
 * Updates specific fields on a user document.
 */
async function updateUserDoc(tenantId, userId, updates) {
    await tenantRepository_1.Paths.user(tenantId, userId).update({
        ...updates,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}
/**
 * Saves a customer ID from the payment provider to the user's profile.
 */
async function saveAsaasCustomerId(tenantId, userId, asaasCustomerId) {
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
async function setUserClaims(userId, tenantId, role) {
    await admin.auth().setCustomUserClaims(userId, { tenantId, role });
    console.log(`[UserRepo] Custom claims set for user ${userId}: tenantId=${tenantId}, role=${role}`);
}
/**
 * Revokes all sessions for a user (forces token refresh).
 * Call after updating custom claims to ensure immediate effect.
 */
async function revokeUserSessions(userId) {
    await admin.auth().revokeRefreshTokens(userId);
}
//# sourceMappingURL=userRepository.js.map