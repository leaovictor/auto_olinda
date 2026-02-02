import * as admin from 'firebase-admin';

// Initialize Admin SDK First
if (!admin.apps.length) {
  admin.initializeApp();
}

/**
 * AUTH DOMAIN
 */
export { onCreateUser as auth_onCreateUser } from './domains/auth/onCreateUser';

/**
 * TENANT DOMAIN
 */
export { createTenant as tenant_createTenant } from './domains/tenant/createTenant';

/**
 * BILLING DOMAIN
 */
// Checkout & Payment IO
export { createCheckoutSession as billing_createCheckoutSession } from './domains/billing/api/checkout';
export { createPaymentSheet as billing_createPaymentSheet } from './domains/billing/api/paymentSheet';
export { createPortalSession as billing_createPortalSession } from './domains/billing/api/portal';

// PIX
export { createPixPaymentIntent as billing_createPixPaymentIntent } from './domains/billing/api/pix';
export { createSubscriptionPixPayment as billing_createSubscriptionPixPayment } from './domains/billing/api/pix';
export { createServicePaymentIntent as billing_createServicePaymentIntent } from './domains/billing/api/pix';

// Subscriptions Management
export { cancelSubscription as billing_cancelSubscription } from './domains/billing/api/subscriptions';
export { reactivateSubscription as billing_reactivateSubscription } from './domains/billing/api/subscriptions';
export { syncSubscriptionStatus as billing_syncSubscriptionStatus } from './domains/billing/api/subscriptions';
export { changeSubscriptionPlan as billing_changeSubscriptionPlan } from './domains/billing/api/subscriptions';
export { getSubscriptionDetails as billing_getSubscriptionDetails } from './domains/billing/api/subscriptions';
export { getSubscriptionInvoices as billing_getSubscriptionInvoices } from './domains/billing/api/subscriptions';

// Admin Features
export { adminPauseSubscription as billing_adminPauseSubscription } from './domains/billing/api/admin';
export { adminCancelSubscription as billing_adminCancelSubscription } from './domains/billing/api/admin';
export { adminResumeSubscription as billing_adminResumeSubscription } from './domains/billing/api/admin';
export { getStripeSubscriptions as billing_getStripeSubscriptions } from './domains/billing/api/admin';
export { getStripeTransactions as billing_getStripeTransactions } from './domains/billing/api/admin';
export { adminAdjustBonusWashes as billing_adminAdjustBonusWashes } from './domains/billing/api/admin';
export { adminGrantPremiumDays as billing_adminGrantPremiumDays } from './domains/billing/api/admin';
export { adminCreateSubscription as billing_adminCreateSubscription } from './domains/billing/api/admin';
export { syncPlanWithStripe as billing_syncPlanWithStripe } from './domains/billing/api/admin';
export { getPublicStripeConfig as billing_getPublicStripeConfig } from './domains/billing/api/admin';

// Webhooks
export { stripeWebhook as billing_stripeWebhook } from './domains/billing/webhooks/webhook';
