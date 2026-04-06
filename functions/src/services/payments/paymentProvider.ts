/**
 * @file services/payments/paymentProvider.ts
 * Abstract interface for payment providers.
 * This allows swapping Asaas ↔ Stripe without changing controller logic.
 *
 * Architecture Decision:
 * - Controllers depend only on IPaymentProvider
 * - Concrete implementations (AsaasService, StripeService) are injected
 * - Tenant-level configuration determines which provider is used
 */

import {
  CreateCustomerInput,
  CreateSubscriptionInput,
  ProviderCustomer,
  ProviderSubscription,
  WebhookEvent,
} from "../../types";

// ─────────────────────────────────────────────────────────────────────────────
// Core interface
// ─────────────────────────────────────────────────────────────────────────────

export interface IPaymentProvider {
  /**
   * Creates a customer record in the payment provider.
   * Returns the provider's customer ID to be stored in Firestore.
   */
  createCustomer(data: CreateCustomerInput): Promise<ProviderCustomer>;

  /**
   * Creates a recurring subscription for the customer.
   * The `externalReference` in the input MUST be set to "{tenantId}:{userId}"
   * so the webhook can later identify which tenant and user to update.
   */
  createSubscription(
    data: CreateSubscriptionInput
  ): Promise<ProviderSubscription>;

  /**
   * Cancels an active subscription by its provider-side ID.
   */
  cancelSubscription(subscriptionId: string): Promise<void>;

  /**
   * Parses and validates an incoming webhook payload.
   * Validates the signature/token and returns a normalized WebhookEvent.
   *
   * @param rawBody - The raw request body as a Buffer
   * @param signature - Provider-specific signature header value
   * @throws Error if signature is invalid
   */
  handleWebhook(rawBody: Buffer, signature: string): Promise<WebhookEvent>;
}

// ─────────────────────────────────────────────────────────────────────────────
// Factory helper
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Payment provider type discriminator.
 * Add new providers here as the platform grows.
 */
export type PaymentProviderType = "asaas" | "stripe";

/**
 * Provider configuration passed to the factory.
 */
export interface ProviderConfig {
  type: PaymentProviderType;
  apiKey: string;
  webhookSecret?: string;
  sandbox?: boolean;
}
