"use strict";
/**
 * @file controllers/tenantController.ts
 * Tenant onboarding and user management — hardened v2.
 *
 * Breaking changes from v1:
 *  - createTenant no longer accepts or writes asaasApiKey to Firestore
 *    → API key must be added to ASAAS_API_KEY_POOL secret separately
 *  - createTenant now writes: status, features, paymentProvider, defaultBillingType
 *  - adminActivateManualSubscriptionV2 now checks tenant status + subscriptions feature flag
 *
 * Security:
 *  - Super-admin gate: SUPER_ADMIN_UID must match request.auth.uid
 *  - All operations validate tenantId from claims, not request body
 *  - db.FieldValue shorthand bug fixed (was: db.FieldValue?.serverTimestamp())
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
exports.updateTenantFeatures = exports.reactivateTenant = exports.suspendTenant = exports.adminActivateManualSubscriptionV2 = exports.setUserTenantClaim = exports.createTenant = void 0;
const https_1 = require("firebase-functions/v2/https");
const params_1 = require("firebase-functions/params");
const admin = __importStar(require("firebase-admin"));
const tenantAuth_1 = require("../middleware/tenantAuth");
const tenantRepository_1 = require("../repositories/tenantRepository");
const userRepository_1 = require("../repositories/userRepository");
const subscriptionRepository_1 = require("../repositories/subscriptionRepository");
const logger_1 = require("../services/logger");
const secrets_1 = require("../config/secrets");
// ─────────────────────────────────────────────────────────────────────────────
// Secrets
// ─────────────────────────────────────────────────────────────────────────────
const SUPER_ADMIN_UID = (0, params_1.defineSecret)("SUPER_ADMIN_UID");
// ─────────────────────────────────────────────────────────────────────────────
// createTenant
// ─────────────────────────────────────────────────────────────────────────────
/**
 * Creates a new tenant on the platform.
 * Only callable by the platform super-admin (SUPER_ADMIN_UID).
 *
 * IMPORTANT — API key handling:
 *   This function does NOT accept or store the Asaas API key.
 *   After calling createTenant, the super-admin must:
 *   1. Obtain the new tenantId from the response
 *   2. Add the tenant's API key to the ASAAS_API_KEY_POOL secret:
 *      { ..existing.., "[tenantId]": "aact_..." }
 *
 * Steps:
 *  1. Validate super-admin
 *  2. Validate input fields
 *  3. Verify Firebase Auth user exists for owner
 *  4. Create /tenants/{tenantId} with status:"active", features, paymentProvider
 *  5. Create /tenants/{tenantId}/users/{ownerUid}
 *  6. Set custom claims { tenantId, role: "admin" }
 *  7. Revoke sessions (force token refresh)
 *  8. Seed default services, plans, config
 */
exports.createTenant = (0, https_1.onCall)({ secrets: [SUPER_ADMIN_UID] }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Authentication required.");
    }
    // ── Super-admin gate ─────────────────────────────────────────────────
    const superAdminUid = (0, secrets_1.getSecret)(SUPER_ADMIN_UID, "SUPER_ADMIN_UID");
    if (!superAdminUid || request.auth.uid !== superAdminUid) {
        throw new https_1.HttpsError("permission-denied", "Only the platform super-admin can create tenants.");
    }
    const input = request.data;
    if (!input.name?.trim() || !input.ownerUid?.trim()) {
        throw new https_1.HttpsError("invalid-argument", "Missing required fields: name, ownerUid.");
    }
    // ── Generate tenantId ────────────────────────────────────────────────
    const tenantId = admin.firestore().collection("tenants").doc().id;
    console.log(`[CreateTenant] Creating tenant "${input.name}" → ${tenantId}`);
    try {
        // ── Verify Firebase Auth user ────────────────────────────────────────
        try {
            await admin.auth().getUser(input.ownerUid);
        }
        catch {
            throw new https_1.HttpsError("not-found", `Firebase Auth user "${input.ownerUid}" not found. Create the Auth user first.`);
        }
        // ── Build feature flags (merge input with defaults) ─────────────────
        const features = {
            ...tenantRepository_1.DEFAULT_FEATURES,
            ...(input.features ?? {}),
        };
        // ── Create tenant root document (NO asaasApiKey) ─────────────────────
        await (0, tenantRepository_1.createTenantDoc)(tenantId, {
            name: input.name.trim(),
            plan: (input.plan ?? "starter"),
            asaasAccountId: input.asaasAccountId,
            asaasSandbox: input.asaasSandbox ?? false,
            defaultBillingType: "PIX",
            paymentProvider: "asaas",
            ownerUid: input.ownerUid,
            email: input.ownerEmail,
            status: "active",
            features,
        });
        // ── Create owner user record ─────────────────────────────────────────
        await (0, userRepository_1.setUserDoc)(tenantId, input.ownerUid, {
            tenantId,
            displayName: input.ownerDisplayName ?? "",
            email: input.ownerEmail ?? "",
            role: "admin",
            status: "active",
        });
        // ── Set custom claims + force token refresh ──────────────────────────
        await (0, userRepository_1.setUserClaims)(input.ownerUid, tenantId, "admin");
        await (0, userRepository_1.revokeUserSessions)(input.ownerUid);
        // ── Seed defaults ────────────────────────────────────────────────────
        await (0, tenantRepository_1.seedTenantDefaults)(tenantId);
        // ── Audit log ────────────────────────────────────────────────────────
        const log = (0, logger_1.tenantLogger)(tenantId, "createTenant");
        log.info("Tenant created", {
            name: input.name,
            ownerUid: input.ownerUid,
            plan: input.plan ?? "starter",
            createdBy: request.auth.uid,
        });
        console.log(`[CreateTenant] ✅ Tenant ${tenantId} created for "${input.name}"`);
        return {
            success: true,
            tenantId,
            ownerUid: input.ownerUid,
            message: `Tenant "${input.name}" criado com sucesso. ` +
                `Adicione a chave Asaas ao secret ASAAS_API_KEY_POOL com a chave: "${tenantId}".`,
        };
    }
    catch (err) {
        if (err instanceof https_1.HttpsError)
            throw err;
        console.error("[CreateTenant] Error:", err);
        throw new https_1.HttpsError("internal", `Failed to create tenant: ${err.message}`);
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// setUserTenantClaim
// ─────────────────────────────────────────────────────────────────────────────
exports.setUserTenantClaim = (0, https_1.onCall)(async (request) => {
    const ctx = (0, tenantAuth_1.requireAdmin)(request);
    const { targetUid, role } = request.data;
    if (!targetUid?.trim() || !role) {
        throw new https_1.HttpsError("invalid-argument", "Missing required fields: targetUid, role.");
    }
    const validRoles = ["admin", "staff", "customer"];
    if (!validRoles.includes(role)) {
        throw new https_1.HttpsError("invalid-argument", `Invalid role. Must be one of: ${validRoles.join(", ")}.`);
    }
    const log = (0, logger_1.tenantLogger)(ctx.tenantId, "setUserTenantClaim");
    try {
        const userRef = tenantRepository_1.Paths.user(ctx.tenantId, targetUid);
        const userDoc = await userRef.get();
        if (!userDoc.exists) {
            await (0, userRepository_1.setUserDoc)(ctx.tenantId, targetUid, {
                tenantId: ctx.tenantId,
                displayName: "",
                email: "",
                role,
                status: "active",
            });
        }
        else {
            await userRef.update({
                role,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
        await (0, userRepository_1.setUserClaims)(targetUid, ctx.tenantId, role);
        await (0, userRepository_1.revokeUserSessions)(targetUid);
        log.info("User role updated", { targetUid, role }, ctx.userId);
        return {
            success: true,
            message: `Usuário ${targetUid} agora tem perfil "${role}".`,
        };
    }
    catch (err) {
        if (err instanceof https_1.HttpsError)
            throw err;
        throw new https_1.HttpsError("internal", `Failed to set user claim: ${err.message}`);
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// adminActivateManualSubscriptionV2
// ─────────────────────────────────────────────────────────────────────────────
/**
 * Allows a tenant admin to manually activate a subscription.
 * Hardened: checks tenant status + subscriptions feature flag.
 */
exports.adminActivateManualSubscriptionV2 = (0, https_1.onCall)(async (request) => {
    const ctx = (0, tenantAuth_1.requireAdmin)(request);
    const log = (0, logger_1.tenantLogger)(ctx.tenantId, "adminActivateManualSubscriptionV2");
    const { userId, planId, durationDays = 30, vehicleId, vehiclePlate, } = request.data;
    if (!userId?.trim() || !planId?.trim()) {
        throw new https_1.HttpsError("invalid-argument", "Missing required fields: userId, planId.");
    }
    // ── Tenant status check ────────────────────────────────────────────────
    const tenantConfig = await (0, tenantRepository_1.getTenantConfig)(ctx.tenantId);
    (0, tenantRepository_1.assertTenantActive)(tenantConfig, ctx.tenantId);
    (0, tenantRepository_1.checkFeature)(tenantConfig, "subscriptions", ctx.tenantId);
    try {
        // ── Verify plan exists ────────────────────────────────────────────────
        const planDoc = await tenantRepository_1.Paths.plan(ctx.tenantId, planId).get();
        if (!planDoc.exists) {
            throw new https_1.HttpsError("not-found", `Plano "${planId}" não encontrado neste tenant.`);
        }
        const planData = planDoc.data();
        // ── Check no duplicate active subscription ────────────────────────────
        const existingSnap = await tenantRepository_1.Paths.tenantCollection(ctx.tenantId, "subscriptions")
            .where("userId", "==", userId)
            .where("status", "in", ["active", "trialing"])
            .limit(1)
            .get();
        if (!existingSnap.empty) {
            throw new https_1.HttpsError("already-exists", "Usuário já possui uma assinatura ativa.");
        }
        // ── Calculate period ──────────────────────────────────────────────────
        const startDate = new Date();
        const endDate = new Date();
        endDate.setDate(endDate.getDate() + durationDays);
        // ── Create + immediately activate subscription ────────────────────────
        const subId = await (0, subscriptionRepository_1.createSubscriptionDoc)(ctx.tenantId, {
            tenantId: ctx.tenantId,
            userId,
            planId,
            status: "pending",
            isManual: true,
            paymentMethod: "pix_presencial",
            vehicleId: vehicleId ?? "",
            linkedPlate: vehiclePlate ?? "",
            value: planData.price,
            startDate,
            endDate,
            createdBy: ctx.userId,
        });
        await (0, subscriptionRepository_1.activateSubscription)(ctx.tenantId, subId);
        // ── Notify user ───────────────────────────────────────────────────────
        const userDoc = await tenantRepository_1.Paths.user(ctx.tenantId, userId).get();
        const userName = userDoc.data()?.displayName || "Cliente";
        await tenantRepository_1.Paths.notification(ctx.tenantId, userId).add({
            title: "Assinatura Ativada! 🎉",
            body: `Seu ${planData.name} foi ativado por ${durationDays} dias.`,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            isRead: false,
            type: "subscription_activated",
        });
        log.info("Manual subscription activated", {
            userId,
            planId,
            subId,
            durationDays,
        }, ctx.userId);
        return {
            success: true,
            subscriptionId: subId,
            message: `Assinatura ativada para ${userName} por ${durationDays} dias.`,
            endDate: endDate.toISOString(),
        };
    }
    catch (err) {
        if (err instanceof https_1.HttpsError)
            throw err;
        log.error("Failed to activate manual subscription", { error: err.message }, ctx.userId);
        throw new https_1.HttpsError("internal", `Failed to activate subscription: ${err.message}`);
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// suspendTenant / activateTenant (super-admin operations)
// ─────────────────────────────────────────────────────────────────────────────
/**
 * Suspends a tenant — all their users will be blocked from using the platform.
 * Only callable by the platform super-admin.
 */
exports.suspendTenant = (0, https_1.onCall)({ secrets: [SUPER_ADMIN_UID] }, async (request) => {
    if (!request.auth)
        throw new https_1.HttpsError("unauthenticated", "Auth required.");
    const superAdminUid = (0, secrets_1.getSecret)(SUPER_ADMIN_UID, "SUPER_ADMIN_UID");
    if (!superAdminUid || request.auth.uid !== superAdminUid) {
        throw new https_1.HttpsError("permission-denied", "Super-admin only.");
    }
    const { tenantId, reason } = request.data;
    if (!tenantId)
        throw new https_1.HttpsError("invalid-argument", "tenantId required.");
    await tenantRepository_1.Paths.tenant(tenantId).update({
        status: "suspended",
        suspendedAt: admin.firestore.FieldValue.serverTimestamp(),
        suspendedBy: request.auth.uid,
        suspendReason: reason ?? "",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    const log = (0, logger_1.tenantLogger)(tenantId, "suspendTenant");
    log.warn("Tenant suspended", { reason, suspendedBy: request.auth.uid });
    return { success: true, message: `Tenant "${tenantId}" suspenso.` };
});
/**
 * Reactivates a suspended tenant.
 */
exports.reactivateTenant = (0, https_1.onCall)({ secrets: [SUPER_ADMIN_UID] }, async (request) => {
    if (!request.auth)
        throw new https_1.HttpsError("unauthenticated", "Auth required.");
    const superAdminUid = (0, secrets_1.getSecret)(SUPER_ADMIN_UID, "SUPER_ADMIN_UID");
    if (!superAdminUid || request.auth.uid !== superAdminUid) {
        throw new https_1.HttpsError("permission-denied", "Super-admin only.");
    }
    const { tenantId } = request.data;
    if (!tenantId)
        throw new https_1.HttpsError("invalid-argument", "tenantId required.");
    await tenantRepository_1.Paths.tenant(tenantId).update({
        status: "active",
        reactivatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    const log = (0, logger_1.tenantLogger)(tenantId, "reactivateTenant");
    log.info("Tenant reactivated", { reactivatedBy: request.auth.uid });
    return { success: true, message: `Tenant "${tenantId}" reativado.` };
});
// ─────────────────────────────────────────────────────────────────────────────
// updateTenantFeatures (super-admin or tenant admin)
// ─────────────────────────────────────────────────────────────────────────────
/**
 * Updates feature flags for a tenant.
 * Super-admin: can update any tenant.
 * Tenant admin: can only update their own tenant's features.
 */
exports.updateTenantFeatures = (0, https_1.onCall)({ secrets: [SUPER_ADMIN_UID] }, async (request) => {
    if (!request.auth)
        throw new https_1.HttpsError("unauthenticated", "Auth required.");
    const { tenantId, features } = request.data;
    const superAdminUid = (0, secrets_1.getSecret)(SUPER_ADMIN_UID, "SUPER_ADMIN_UID");
    const isSuperAdmin = superAdminUid && request.auth.uid === superAdminUid;
    // Determine which tenantId to update
    let targetTenantId;
    if (isSuperAdmin && tenantId) {
        targetTenantId = tenantId;
    }
    else {
        // Must be a tenant admin updating their own
        const ctx = (0, tenantAuth_1.extractTenantContext)(request);
        if (ctx.role !== "admin") {
            throw new https_1.HttpsError("permission-denied", "Tenant admin role required.");
        }
        targetTenantId = ctx.tenantId;
    }
    if (!features || typeof features !== "object") {
        throw new https_1.HttpsError("invalid-argument", "features must be an object.");
    }
    await tenantRepository_1.Paths.tenant(targetTenantId).update({
        features,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    const log = (0, logger_1.tenantLogger)(targetTenantId, "updateTenantFeatures");
    log.info("Features updated", { features, updatedBy: request.auth.uid });
    return { success: true };
});
//# sourceMappingURL=tenantController.js.map