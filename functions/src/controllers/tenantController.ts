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

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import * as admin from "firebase-admin";
import { requireAdmin, extractTenantContext } from "../middleware/tenantAuth";
import {
  createTenantDoc,
  seedTenantDefaults,
  getTenantConfig,
  assertTenantActive,
  checkFeature,
  Paths,
  DEFAULT_FEATURES,
} from "../repositories/tenantRepository";
import {
  setUserDoc,
  setUserClaims,
  revokeUserSessions,
} from "../repositories/userRepository";
import {
  createSubscriptionDoc,
  activateSubscription,
} from "../repositories/subscriptionRepository";
import { tenantLogger } from "../services/logger";
import { getSecret } from "../config/secrets";
import {
  CreateTenantInput,
  TenantPlan,
  TenantFeatures,
  UserRole,
} from "../types";

// ─────────────────────────────────────────────────────────────────────────────
// Secrets
// ─────────────────────────────────────────────────────────────────────────────

const SUPER_ADMIN_UID = defineSecret("SUPER_ADMIN_UID");

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
export const createTenant = onCall(
  { secrets: [SUPER_ADMIN_UID] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication required.");
    }

    // ── Super-admin gate ─────────────────────────────────────────────────
    const superAdminUid = getSecret(SUPER_ADMIN_UID, "SUPER_ADMIN_UID");
    if (!superAdminUid || request.auth.uid !== superAdminUid) {
      throw new HttpsError(
        "permission-denied",
        "Only the platform super-admin can create tenants."
      );
    }

    const input = request.data as CreateTenantInput;

    if (!input.name?.trim() || !input.ownerUid?.trim()) {
      throw new HttpsError(
        "invalid-argument",
        "Missing required fields: name, ownerUid."
      );
    }

    // ── Generate tenantId ────────────────────────────────────────────────
    const tenantId = admin.firestore().collection("tenants").doc().id;

    console.log(`[CreateTenant] Creating tenant "${input.name}" → ${tenantId}`);

    try {
      // ── Verify Firebase Auth user ────────────────────────────────────────
      try {
        await admin.auth().getUser(input.ownerUid);
      } catch {
        throw new HttpsError(
          "not-found",
          `Firebase Auth user "${input.ownerUid}" not found. Create the Auth user first.`
        );
      }

      // ── Build feature flags (merge input with defaults) ─────────────────
      const features: TenantFeatures = {
        ...DEFAULT_FEATURES,
        ...(input.features ?? {}),
      };

      // ── Create tenant root document (NO asaasApiKey) ─────────────────────
      await createTenantDoc(tenantId, {
        name: input.name.trim(),
        plan: (input.plan ?? "starter") as TenantPlan,
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
      await setUserDoc(tenantId, input.ownerUid, {
        tenantId,
        displayName: input.ownerDisplayName ?? "",
        email: input.ownerEmail ?? "",
        role: "admin",
        status: "active",
      });

      // ── Set custom claims + force token refresh ──────────────────────────
      await setUserClaims(input.ownerUid, tenantId, "admin");
      await revokeUserSessions(input.ownerUid);

      // ── Seed defaults ────────────────────────────────────────────────────
      await seedTenantDefaults(tenantId);

      // ── Audit log ────────────────────────────────────────────────────────
      const log = tenantLogger(tenantId, "createTenant");
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
        message:
          `Tenant "${input.name}" criado com sucesso. ` +
          `Adicione a chave Asaas ao secret ASAAS_API_KEY_POOL com a chave: "${tenantId}".`,
      };
    } catch (err: unknown) {
      if (err instanceof HttpsError) throw err;
      console.error("[CreateTenant] Error:", err);
      throw new HttpsError(
        "internal",
        `Failed to create tenant: ${(err as Error).message}`
      );
    }
  }
);

// ─────────────────────────────────────────────────────────────────────────────
// setUserTenantClaim
// ─────────────────────────────────────────────────────────────────────────────

export const setUserTenantClaim = onCall(async (request) => {
  const ctx = requireAdmin(request);

  const { targetUid, role } = request.data as {
    targetUid: string;
    role: UserRole;
  };

  if (!targetUid?.trim() || !role) {
    throw new HttpsError("invalid-argument", "Missing required fields: targetUid, role.");
  }

  const validRoles: UserRole[] = ["admin", "staff", "customer"];
  if (!validRoles.includes(role)) {
    throw new HttpsError(
      "invalid-argument",
      `Invalid role. Must be one of: ${validRoles.join(", ")}.`
    );
  }

  const log = tenantLogger(ctx.tenantId, "setUserTenantClaim");

  try {
    const userRef = Paths.user(ctx.tenantId, targetUid);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      await setUserDoc(ctx.tenantId, targetUid, {
        tenantId: ctx.tenantId,
        displayName: "",
        email: "",
        role,
        status: "active",
      });
    } else {
      await userRef.update({
        role,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    await setUserClaims(targetUid, ctx.tenantId, role);
    await revokeUserSessions(targetUid);

    log.info("User role updated", { targetUid, role }, ctx.userId);

    return {
      success: true,
      message: `Usuário ${targetUid} agora tem perfil "${role}".`,
    };
  } catch (err: unknown) {
    if (err instanceof HttpsError) throw err;
    throw new HttpsError("internal", `Failed to set user claim: ${(err as Error).message}`);
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// adminActivateManualSubscriptionV2
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Allows a tenant admin to manually activate a subscription.
 * Hardened: checks tenant status + subscriptions feature flag.
 */
export const adminActivateManualSubscriptionV2 = onCall(async (request) => {
  const ctx = requireAdmin(request);
  const log = tenantLogger(ctx.tenantId, "adminActivateManualSubscriptionV2");

  const {
    userId,
    planId,
    durationDays = 30,
    vehicleId,
    vehiclePlate,
  } = request.data as {
    userId: string;
    planId: string;
    durationDays?: number;
    vehicleId?: string;
    vehiclePlate?: string;
  };

  if (!userId?.trim() || !planId?.trim()) {
    throw new HttpsError("invalid-argument", "Missing required fields: userId, planId.");
  }

  // ── Tenant status check ────────────────────────────────────────────────
  const tenantConfig = await getTenantConfig(ctx.tenantId);
  assertTenantActive(tenantConfig, ctx.tenantId);
  checkFeature(tenantConfig, "subscriptions", ctx.tenantId);

  try {
    // ── Verify plan exists ────────────────────────────────────────────────
    const planDoc = await Paths.plan(ctx.tenantId, planId).get();
    if (!planDoc.exists) {
      throw new HttpsError("not-found", `Plano "${planId}" não encontrado neste tenant.`);
    }
    const planData = planDoc.data()!;

    // ── Check no duplicate active subscription ────────────────────────────
    const existingSnap = await Paths.tenantCollection(ctx.tenantId, "subscriptions")
      .where("userId", "==", userId)
      .where("status", "in", ["active", "trialing"])
      .limit(1)
      .get();

    if (!existingSnap.empty) {
      throw new HttpsError("already-exists", "Usuário já possui uma assinatura ativa.");
    }

    // ── Calculate period ──────────────────────────────────────────────────
    const startDate = new Date();
    const endDate = new Date();
    endDate.setDate(endDate.getDate() + durationDays);

    // ── Create + immediately activate subscription ────────────────────────
    const subId = await createSubscriptionDoc(ctx.tenantId, {
      tenantId: ctx.tenantId,
      userId,
      planId,
      status: "pending",
      isManual: true,
      paymentMethod: "pix_presencial",
      vehicleId: vehicleId ?? "",
      linkedPlate: vehiclePlate ?? "",
      value: planData.price as number,
      startDate,
      endDate,
      createdBy: ctx.userId,
    });

    await activateSubscription(ctx.tenantId, subId);

    // ── Notify user ───────────────────────────────────────────────────────
    const userDoc = await Paths.user(ctx.tenantId, userId).get();
    const userName = (userDoc.data()?.displayName as string) || "Cliente";

    await Paths.notification(ctx.tenantId, userId).add({
      title: "Assinatura Ativada! 🎉",
      body: `Seu ${planData.name as string} foi ativado por ${durationDays} dias.`,
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
  } catch (err: unknown) {
    if (err instanceof HttpsError) throw err;
    log.error("Failed to activate manual subscription", { error: (err as Error).message }, ctx.userId);
    throw new HttpsError("internal", `Failed to activate subscription: ${(err as Error).message}`);
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// suspendTenant / activateTenant (super-admin operations)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Suspends a tenant — all their users will be blocked from using the platform.
 * Only callable by the platform super-admin.
 */
export const suspendTenant = onCall(
  { secrets: [SUPER_ADMIN_UID] },
  async (request) => {
    if (!request.auth) throw new HttpsError("unauthenticated", "Auth required.");

    const superAdminUid = getSecret(SUPER_ADMIN_UID, "SUPER_ADMIN_UID");
    if (!superAdminUid || request.auth.uid !== superAdminUid) {
      throw new HttpsError("permission-denied", "Super-admin only.");
    }

    const { tenantId, reason } = request.data as { tenantId: string; reason?: string };
    if (!tenantId) throw new HttpsError("invalid-argument", "tenantId required.");

    await Paths.tenant(tenantId).update({
      status: "suspended",
      suspendedAt: admin.firestore.FieldValue.serverTimestamp(),
      suspendedBy: request.auth.uid,
      suspendReason: reason ?? "",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const log = tenantLogger(tenantId, "suspendTenant");
    log.warn("Tenant suspended", { reason, suspendedBy: request.auth.uid });

    return { success: true, message: `Tenant "${tenantId}" suspenso.` };
  }
);

/**
 * Reactivates a suspended tenant.
 */
export const reactivateTenant = onCall(
  { secrets: [SUPER_ADMIN_UID] },
  async (request) => {
    if (!request.auth) throw new HttpsError("unauthenticated", "Auth required.");

    const superAdminUid = getSecret(SUPER_ADMIN_UID, "SUPER_ADMIN_UID");
    if (!superAdminUid || request.auth.uid !== superAdminUid) {
      throw new HttpsError("permission-denied", "Super-admin only.");
    }

    const { tenantId } = request.data as { tenantId: string };
    if (!tenantId) throw new HttpsError("invalid-argument", "tenantId required.");

    await Paths.tenant(tenantId).update({
      status: "active",
      reactivatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const log = tenantLogger(tenantId, "reactivateTenant");
    log.info("Tenant reactivated", { reactivatedBy: request.auth.uid });

    return { success: true, message: `Tenant "${tenantId}" reativado.` };
  }
);

// ─────────────────────────────────────────────────────────────────────────────
// updateTenantFeatures (super-admin or tenant admin)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Updates feature flags for a tenant.
 * Super-admin: can update any tenant.
 * Tenant admin: can only update their own tenant's features.
 */
export const updateTenantFeatures = onCall(
  { secrets: [SUPER_ADMIN_UID] },
  async (request) => {
    if (!request.auth) throw new HttpsError("unauthenticated", "Auth required.");

    const { tenantId, features } = request.data as {
      tenantId?: string;
      features: Partial<TenantFeatures>;
    };

    const superAdminUid = getSecret(SUPER_ADMIN_UID, "SUPER_ADMIN_UID");
    const isSuperAdmin = superAdminUid && request.auth.uid === superAdminUid;


    // Determine which tenantId to update
    let targetTenantId: string;
    if (isSuperAdmin && tenantId) {
      targetTenantId = tenantId;
    } else {
      // Must be a tenant admin updating their own
      const ctx = extractTenantContext(request);
      if (ctx.role !== "admin") {
        throw new HttpsError("permission-denied", "Tenant admin role required.");
      }
      targetTenantId = ctx.tenantId;
    }

    if (!features || typeof features !== "object") {
      throw new HttpsError("invalid-argument", "features must be an object.");
    }

    await Paths.tenant(targetTenantId).update({
      features,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const log = tenantLogger(targetTenantId, "updateTenantFeatures");
    log.info("Features updated", { features, updatedBy: request.auth.uid });

    return { success: true };
  }
);
