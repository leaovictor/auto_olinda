
import * as admin from 'firebase-admin';

// Initialize Admin SDK First
if (!admin.apps.length) {
  admin.initializeApp();
}

// Export Auth Triggers
export { onCreateUser as auth_onCreateUser } from './modules/auth/triggers/onCreateUser';

// Export Tenant Controllers
export { createTenant as tenant_createTenant } from './modules/tenant/controllers/createTenant';

// Export Billing Controllers & Webhooks
export { createCheckoutSession as billing_createCheckoutSession } from './modules/billing/controllers/createCheckoutSession';
export { createPortalSession as billing_createPortalSession } from './modules/billing/controllers/createPortalSession';
export { stripeWebhook as billing_stripeWebhook } from './modules/billing/webhooks/webhookHandler';
