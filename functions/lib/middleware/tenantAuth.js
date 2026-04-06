"use strict";
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
Object.defineProperty(exports, "__esModule", { value: true });
exports.extractTenantContext = extractTenantContext;
exports.requireAdmin = requireAdmin;
exports.requireStaffOrAdmin = requireStaffOrAdmin;
exports.extractTenantFromExternalReference = extractTenantFromExternalReference;
const https_1 = require("firebase-functions/v2/https");
const asaasService_1 = require("../services/payments/asaasService");
// ─────────────────────────────────────────────────────────────────────────────
// Core extractor
// ─────────────────────────────────────────────────────────────────────────────
/**
 * Extracts the TenantContext from a Firebase callable request.
 */
function extractTenantContext(request, requiredRoles) {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Você precisa estar autenticado para realizar esta ação.");
    }
    const { uid, token } = request.auth;
    const tenantId = token.tenantId;
    if (!tenantId) {
        throw new https_1.HttpsError("permission-denied", "Sua conta não está associada a nenhum tenant. Entre em contato com o administrador.");
    }
    const role = token.role ?? "customer";
    if (requiredRoles && requiredRoles.length > 0) {
        if (!requiredRoles.includes(role)) {
            throw new https_1.HttpsError("permission-denied", `Apenas usuários com perfil [${requiredRoles.join(", ")}] podem realizar esta ação.`);
        }
    }
    return {
        tenantId,
        userId: uid,
        role,
        email: token.email,
    };
}
// ─────────────────────────────────────────────────────────────────────────────
// Role guards (convenience wrappers)
// ─────────────────────────────────────────────────────────────────────────────
function requireAdmin(request) {
    return extractTenantContext(request, ["admin"]);
}
function requireStaffOrAdmin(request) {
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
function extractTenantFromExternalReference(externalReference) {
    const ref = (0, asaasService_1.parseExternalRef)(externalReference);
    return { tenantId: ref.tenantId, userId: ref.userId };
}
//# sourceMappingURL=tenantAuth.js.map