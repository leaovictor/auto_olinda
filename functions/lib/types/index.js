"use strict";
/**
 * @file types/index.ts
 * Central TypeScript type definitions for the multi-tenant SaaS platform.
 *
 * Hardening changes (v2):
 *  - REMOVED asaasApiKey from TenantDoc (security: moved to Secret Manager pool)
 *  - ADDED TenantStatus: "active" | "suspended" | "trial"
 *  - ADDED TenantFeatures: per-tenant feature flags
 *  - ADDED AsaasExternalRef: structured JSON type for webhook attribution
 *  - ADDED TenantLog: per-tenant audit log document
 *  - ADDED PaymentProviderType to TenantDoc
 *  - Eliminated remaining `any` usages in shared types
 *  - CreateSubscriptionInput.externalReference is now typed as string (JSON-serialized)
 */
Object.defineProperty(exports, "__esModule", { value: true });
//# sourceMappingURL=index.js.map