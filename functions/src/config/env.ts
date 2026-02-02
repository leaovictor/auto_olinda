import { defineSecret } from "firebase-functions/params";

export const stripeSecret = defineSecret("STRIPE_SECRET");
export const stripeWebhookSecret = defineSecret("STRIPE_WEBHOOK_SECRET");
export const stripePublishableKey = defineSecret("STRIPE_PUBLISHABLE_KEY");
