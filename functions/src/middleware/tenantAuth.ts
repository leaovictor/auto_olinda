/**
 * @file middleware/tenantAuth.ts
 * Extracts and validates the tenant context from a Firebase Auth token.
 *
 * Every tenant-scoped callable function must call `extractTenantContext(request)`
 * as its FIRST action. This enforces:
 *   1. Authentication — user must be logged in
 *   2. Tenant binding — user must have a tenantId custom claim
 *   3. Role access — optionally restrict by role
 *
 * Custom claims are set server-side when a user is onboarded (see tenantController.ts).
 * Shape: { tenantId: string, role: 'admin' | 'staff' | 'customer' }
 *
 * Hardening (v2):
 *  - extractTenantFromExternalReference now delegates to parseExternalRef (JSON format)
 */

import { CallableRequest, HttpsError } from "firebase-functions/v2/https";
import { TenantContext, UserRole } from "../types";
import { parseExternalRef } from "../services/payments/asaasService";

// ─────────────────────────────────────────────────────────────────────────────
// Core extractor
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Extracts the TenantContext from a Firebase callable request.
 */
export function extractTenantContext(
  request: CallableRequest,
  requiredRoles?: UserRole[]
): TenantContext {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Você precisa estar autenticado para realizar esta ação."
    );
  }

  const { uid, token } = request.auth;

  const tenantId = token.tenantId as string | undefined;
  if (!tenantId) {
    throw new HttpsError(
      "permission-denied",
      "Sua conta não está associada a nenhum tenant. Entre em contato com o administrador."
    );
  }

  const role = (token.role as UserRole | undefined) ?? "customer";

  if (requiredRoles && requiredRoles.length > 0) {
    if (!requiredRoles.includes(role)) {
      throw new HttpsError(
        "permission-denied",
        `Apenas usuários com perfil [${requiredRoles.join(", ")}] podem realizar esta ação.`
      );
    }
  }

  return {
    tenantId,
    userId: uid,
    role,
    email: token.email as string | undefined,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Role guards (convenience wrappers)
// ─────────────────────────────────────────────────────────────────────────────

export function requireAdmin(request: CallableRequest): TenantContext {
  return extractTenantContext(request, ["admin"]);
}

export function requireStaffOrAdmin(request: CallableRequest): TenantContext {
  return extractTenantContext(request, ["admin", "staff"]);
}

// ─────────────────────────────────────────────────────────────────────────────
// Webhook helper (no Firebase Auth — uses externalReference)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Extracts tenantId + userId from a structured JSON externalReference.
 * Used in webhook handlers where Firebase Auth is not available.
 *
 * Delegates to parseExternalRef() for consistent JSON parsing.
 * Throws a plain Error (not HttpsError) since this runs in onRequest context.
 */
export function extractTenantFromExternalReference(
  externalReference: string
): { tenantId: string; userId: string } {
  const ref = parseExternalRef(externalReference);
  return { tenantId: ref.tenantId, userId: ref.userId };
}
