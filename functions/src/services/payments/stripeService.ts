/**
 * @file services/payments/stripeService.ts
 * Stripe stub implementing IPaymentProvider.
 *
 * Status: OPTIONAL — kept for multi-currency / international tenants.
 * Platform defaults to Asaas for Brazilian tenants.
 *
 * Hardened (v2):
 *  - handleWebhook now returns WebhookEvent.externalRef (AsaasExternalRef object)
 *    instead of the old .externalReference (raw string)
 *  - Attempts to parse metadata.externalReference as JSON (new format)
 *  - Falls back to constructing an AsaasExternalRef from metadata.tenantId + firebaseUID
 */

import Stripe from "stripe";
import { IPaymentProvider } from "./paymentProvider";
import {
  AsaasExternalRef,
  AsaasWebhookEventType,
  CreateCustomerInput,
  CreateSubscriptionInput,
  ProviderCustomer,
  ProviderSubscription,
  WebhookEvent,
} from "../../types";
import { parseExternalRef } from "./asaasService";

export class StripeService implements IPaymentProvider {
  private readonly stripe: Stripe;
  private readonly webhookSecret: string;

  constructor(secretKey: string, webhookSecret: string) {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    this.stripe = new Stripe(secretKey, { apiVersion: "2023-10-16" as any });
    this.webhookSecret = webhookSecret;
  }

  async createCustomer(data: CreateCustomerInput): Promise<ProviderCustomer> {
    const customer = await this.stripe.customers.create({
      name: data.name,
      email: data.email,
      phone: data.phone,
      metadata: {
        tenantId: data.tenantId,
        userId: data.userId,
      },
    });
    return {
      id: customer.id,
      name: customer.name ?? data.name,
      email: customer.email ?? undefined,
    };
  }

  async createSubscription(
    data: CreateSubscriptionInput
  ): Promise<ProviderSubscription> {
    // NOTE: Stripe uses price IDs, not raw amounts.
    // For multi-tenant SaaS, each tenant needs their own Stripe Price objects.
    throw new Error(
      "StripeService.createSubscription: Not implemented for multi-tenant mode. " +
        "Use AsaasService for Brazilian tenants or implement Stripe Connect."
    );
  }

  async cancelSubscription(subscriptionId: string): Promise<void> {
    await this.stripe.subscriptions.cancel(subscriptionId);
  }

  async handleWebhook(
    rawBody: Buffer,
    signature: string
  ): Promise<WebhookEvent> {
    let event: Stripe.Event;
    try {
      event = this.stripe.webhooks.constructEvent(
        rawBody,
        signature,
        this.webhookSecret
      );
    } catch (err) {
      throw new Error(`Stripe webhook signature verification failed: ${err}`);
    }

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const obj = event.data.object as Record<string, any>;

    // Try to parse structured externalReference from metadata (new JSON format)
    // If not present, construct from individual metadata fields (old format compat)
    let externalRef: AsaasExternalRef;

    const rawExternalRef = obj?.metadata?.externalReference as string | undefined;
    if (rawExternalRef) {
      try {
        externalRef = parseExternalRef(rawExternalRef);
      } catch {
        // Fallback: build from individual fields
        externalRef = {
          tenantId: (obj?.metadata?.tenantId as string) ?? "unknown",
          userId: (obj?.metadata?.firebaseUID as string) ?? (obj?.metadata?.userId as string) ?? "unknown",
          type: "subscription",
          v: 1,
        };
      }
    } else {
      externalRef = {
        tenantId: (obj?.metadata?.tenantId as string) ?? "unknown",
        userId: (obj?.metadata?.firebaseUID as string) ?? (obj?.metadata?.userId as string) ?? "unknown",
        type: "subscription",
        v: 1,
      };
    }

    return {
      type: this.mapStripeEventType(event.type),
      externalRef,
      subscriptionId:
        obj?.subscription ?? (obj?.object === "subscription" ? obj.id : undefined),
      paymentId: obj?.object === "payment_intent" ? obj.id : undefined,
      value: obj?.amount ? (obj.amount as number) / 100 : undefined, // Stripe uses cents
      rawPayload: event as unknown as Record<string, unknown>,
    };
  }

  private mapStripeEventType(stripeEvent: string): AsaasWebhookEventType {
    const map: Record<string, AsaasWebhookEventType> = {
      "invoice.payment_succeeded": "PAYMENT_CONFIRMED",
      "invoice.payment_failed": "PAYMENT_OVERDUE",
      "customer.subscription.deleted": "SUBSCRIPTION_DELETED",
      "customer.subscription.updated": "SUBSCRIPTION_UPDATED",
      "customer.subscription.created": "SUBSCRIPTION_CREATED",
      "charge.refunded": "PAYMENT_REFUNDED",
    };
    return map[stripeEvent] ?? "PAYMENT_CONFIRMED";
  }
}
