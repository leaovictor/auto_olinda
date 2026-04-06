"use strict";
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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.StripeService = void 0;
const stripe_1 = __importDefault(require("stripe"));
const asaasService_1 = require("./asaasService");
class StripeService {
    constructor(secretKey, webhookSecret) {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        this.stripe = new stripe_1.default(secretKey, { apiVersion: "2023-10-16" });
        this.webhookSecret = webhookSecret;
    }
    async createCustomer(data) {
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
    async createSubscription(data) {
        // NOTE: Stripe uses price IDs, not raw amounts.
        // For multi-tenant SaaS, each tenant needs their own Stripe Price objects.
        throw new Error("StripeService.createSubscription: Not implemented for multi-tenant mode. " +
            "Use AsaasService for Brazilian tenants or implement Stripe Connect.");
    }
    async cancelSubscription(subscriptionId) {
        await this.stripe.subscriptions.cancel(subscriptionId);
    }
    async handleWebhook(rawBody, signature) {
        let event;
        try {
            event = this.stripe.webhooks.constructEvent(rawBody, signature, this.webhookSecret);
        }
        catch (err) {
            throw new Error(`Stripe webhook signature verification failed: ${err}`);
        }
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const obj = event.data.object;
        // Try to parse structured externalReference from metadata (new JSON format)
        // If not present, construct from individual metadata fields (old format compat)
        let externalRef;
        const rawExternalRef = obj?.metadata?.externalReference;
        if (rawExternalRef) {
            try {
                externalRef = (0, asaasService_1.parseExternalRef)(rawExternalRef);
            }
            catch {
                // Fallback: build from individual fields
                externalRef = {
                    tenantId: obj?.metadata?.tenantId ?? "unknown",
                    userId: obj?.metadata?.firebaseUID ?? obj?.metadata?.userId ?? "unknown",
                    type: "subscription",
                    v: 1,
                };
            }
        }
        else {
            externalRef = {
                tenantId: obj?.metadata?.tenantId ?? "unknown",
                userId: obj?.metadata?.firebaseUID ?? obj?.metadata?.userId ?? "unknown",
                type: "subscription",
                v: 1,
            };
        }
        return {
            type: this.mapStripeEventType(event.type),
            externalRef,
            subscriptionId: obj?.subscription ?? (obj?.object === "subscription" ? obj.id : undefined),
            paymentId: obj?.object === "payment_intent" ? obj.id : undefined,
            value: obj?.amount ? obj.amount / 100 : undefined, // Stripe uses cents
            rawPayload: event,
        };
    }
    mapStripeEventType(stripeEvent) {
        const map = {
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
exports.StripeService = StripeService;
//# sourceMappingURL=stripeService.js.map