/**
 * @file services/payments/paymentProviderFactory.ts
 * Payment provider factory — resolves the correct IPaymentProvider for a tenant.
 *
 * Security model:
 *   - Tenant API keys are stored in Secret Manager, NOT Firestore
 *   - ASAAS_API_KEY_POOL is a JSON map: { "tenantId": "apiKey", ... }
 *   - The factory reads the tenant's config from Firestore, then pulls
 *     the API key from the pool secret
 *   - Supports Asaas and Stripe (Stripe stub for now)
 *
 * Usage:
 *   const provider = await getPaymentProvider(tenantId, webhookToken);
 *   const customer = await provider.createCustomer(data);
 *
 * NOTE: The ASAAS_WEBHOOK_TOKEN and ASAAS_API_KEY_POOL secrets MUST be
 *       declared in every Cloud Function that calls getPaymentProvider.
 *       Pass them as params to this factory function.
 */

import { IPaymentProvider } from "./paymentProvider";
import { AsaasService } from "./asaasService";
import { StripeService } from "./stripeService";
import { getTenantConfig } from "../../repositories/tenantRepository";

// ─────────────────────────────────────────────────────────────────────────────
// API Key Pool helpers
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Parses the ASAAS_API_KEY_POOL secret value.
 * Expected format: JSON object mapping tenantId → apiKey
 * Example: { "tenant_abc": "aact_...", "tenant_xyz": "aact_..." }
 */
function parseApiKeyPool(poolSecret: string): Record<string, string> {
  if (!poolSecret) {
    throw new Error(
      "ASAAS_API_KEY_POOL secret is not set. " +
        "Run: firebase functions:secrets:set ASAAS_API_KEY_POOL"
    );
  }

  let pool: unknown;
  try {
    pool = JSON.parse(poolSecret);
  } catch {
    throw new Error(
      "ASAAS_API_KEY_POOL is not valid JSON. " +
        "Expected format: { \"tenantId\": \"apiKey\", ... }"
    );
  }

  if (typeof pool !== "object" || pool === null || Array.isArray(pool)) {
    throw new Error("ASAAS_API_KEY_POOL must be a JSON object.");
  }

  return pool as Record<string, string>;
}

/**
 * Extracts the Asaas API key for a specific tenant from the pool.
 * Throws a descriptive error if the tenant is not in the pool —
 * this prevents silent fallback to a wrong key.
 */
function getApiKeyForTenant(
  pool: Record<string, string>,
  tenantId: string
): string {
  const key = pool[tenantId];
  if (!key) {
    throw new Error(
      `No Asaas API key found for tenant "${tenantId}" in ASAAS_API_KEY_POOL. ` +
        "Add it to the secret: firebase functions:secrets:set ASAAS_API_KEY_POOL"
    );
  }
  return key;
}

// ─────────────────────────────────────────────────────────────────────────────
// Factory
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Resolves and returns the correct IPaymentProvider implementation for a tenant.
 *
 * @param tenantId - The tenant to resolve the provider for
 * @param apiKeyPoolSecret - The raw value of ASAAS_API_KEY_POOL secret
 * @param webhookToken - The raw value of ASAAS_WEBHOOK_TOKEN secret
 * @param stripeSecretKey - Optional Stripe key (for Stripe tenants)
 * @param stripeWebhookSecret - Optional Stripe webhook secret
 */
export async function getPaymentProvider(
  tenantId: string,
  apiKeyPoolSecret: string,
  webhookToken: string,
  stripeSecretKey?: string,
  stripeWebhookSecret?: string
): Promise<IPaymentProvider> {
  // 1. Load tenant config (includes paymentProvider discriminator and sandbox flag)
  const config = await getTenantConfig(tenantId);

  const provider = config.paymentProvider ?? "asaas";

  // 2. Dispatch to correct implementation
  switch (provider) {
    case "asaas": {
      const pool = parseApiKeyPool(apiKeyPoolSecret);
      const apiKey = getApiKeyForTenant(pool, tenantId);
      return new AsaasService(apiKey, webhookToken, config.asaasSandbox ?? false);
    }

    case "stripe": {
      if (!stripeSecretKey || !stripeWebhookSecret) {
        throw new Error(
          `Tenant "${tenantId}" uses Stripe but STRIPE_SECRET or ` +
            "STRIPE_WEBHOOK_SECRET were not provided to getPaymentProvider."
        );
      }
      return new StripeService(stripeSecretKey, stripeWebhookSecret);
    }

    default: {
      throw new Error(
        `Unknown payment provider "${provider as string}" for tenant "${tenantId}".`
      );
    }
  }
}

/**
 * Convenience: get just the Asaas API key for a tenant from the pool.
 * Used in contexts where we only need the key (e.g., direct API calls).
 */
export function resolveAsaasApiKey(
  poolSecret: string,
  tenantId: string
): string {
  const pool = parseApiKeyPool(poolSecret);
  return getApiKeyForTenant(pool, tenantId);
}
