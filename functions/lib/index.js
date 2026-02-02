"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.billing_stripeWebhook = exports.billing_getPublicStripeConfig = exports.billing_syncPlanWithStripe = exports.billing_adminCreateSubscription = exports.billing_adminGrantPremiumDays = exports.billing_adminAdjustBonusWashes = exports.billing_getStripeTransactions = exports.billing_getStripeSubscriptions = exports.billing_adminResumeSubscription = exports.billing_adminCancelSubscription = exports.billing_adminPauseSubscription = exports.billing_getSubscriptionInvoices = exports.billing_getSubscriptionDetails = exports.billing_changeSubscriptionPlan = exports.billing_syncSubscriptionStatus = exports.billing_reactivateSubscription = exports.billing_cancelSubscription = exports.billing_createServicePaymentIntent = exports.billing_createSubscriptionPixPayment = exports.billing_createPixPaymentIntent = exports.billing_createPortalSession = exports.billing_createPaymentSheet = exports.billing_createCheckoutSession = exports.tenant_createTenant = exports.auth_onCreateUser = void 0;
const admin = require("firebase-admin");
// Initialize Admin SDK First
if (!admin.apps.length) {
    admin.initializeApp();
}
/**
 * AUTH DOMAIN
 */
var onCreateUser_1 = require("./domains/auth/onCreateUser");
Object.defineProperty(exports, "auth_onCreateUser", { enumerable: true, get: function () { return onCreateUser_1.onCreateUser; } });
/**
 * TENANT DOMAIN
 */
var createTenant_1 = require("./domains/tenant/createTenant");
Object.defineProperty(exports, "tenant_createTenant", { enumerable: true, get: function () { return createTenant_1.createTenant; } });
/**
 * BILLING DOMAIN
 */
// Checkout & Payment IO
var checkout_1 = require("./domains/billing/api/checkout");
Object.defineProperty(exports, "billing_createCheckoutSession", { enumerable: true, get: function () { return checkout_1.createCheckoutSession; } });
var paymentSheet_1 = require("./domains/billing/api/paymentSheet");
Object.defineProperty(exports, "billing_createPaymentSheet", { enumerable: true, get: function () { return paymentSheet_1.createPaymentSheet; } });
var portal_1 = require("./domains/billing/api/portal");
Object.defineProperty(exports, "billing_createPortalSession", { enumerable: true, get: function () { return portal_1.createPortalSession; } });
// PIX
var pix_1 = require("./domains/billing/api/pix");
Object.defineProperty(exports, "billing_createPixPaymentIntent", { enumerable: true, get: function () { return pix_1.createPixPaymentIntent; } });
var pix_2 = require("./domains/billing/api/pix");
Object.defineProperty(exports, "billing_createSubscriptionPixPayment", { enumerable: true, get: function () { return pix_2.createSubscriptionPixPayment; } });
var pix_3 = require("./domains/billing/api/pix");
Object.defineProperty(exports, "billing_createServicePaymentIntent", { enumerable: true, get: function () { return pix_3.createServicePaymentIntent; } });
// Subscriptions Management
var subscriptions_1 = require("./domains/billing/api/subscriptions");
Object.defineProperty(exports, "billing_cancelSubscription", { enumerable: true, get: function () { return subscriptions_1.cancelSubscription; } });
var subscriptions_2 = require("./domains/billing/api/subscriptions");
Object.defineProperty(exports, "billing_reactivateSubscription", { enumerable: true, get: function () { return subscriptions_2.reactivateSubscription; } });
var subscriptions_3 = require("./domains/billing/api/subscriptions");
Object.defineProperty(exports, "billing_syncSubscriptionStatus", { enumerable: true, get: function () { return subscriptions_3.syncSubscriptionStatus; } });
var subscriptions_4 = require("./domains/billing/api/subscriptions");
Object.defineProperty(exports, "billing_changeSubscriptionPlan", { enumerable: true, get: function () { return subscriptions_4.changeSubscriptionPlan; } });
var subscriptions_5 = require("./domains/billing/api/subscriptions");
Object.defineProperty(exports, "billing_getSubscriptionDetails", { enumerable: true, get: function () { return subscriptions_5.getSubscriptionDetails; } });
var subscriptions_6 = require("./domains/billing/api/subscriptions");
Object.defineProperty(exports, "billing_getSubscriptionInvoices", { enumerable: true, get: function () { return subscriptions_6.getSubscriptionInvoices; } });
// Admin Features
var admin_1 = require("./domains/billing/api/admin");
Object.defineProperty(exports, "billing_adminPauseSubscription", { enumerable: true, get: function () { return admin_1.adminPauseSubscription; } });
var admin_2 = require("./domains/billing/api/admin");
Object.defineProperty(exports, "billing_adminCancelSubscription", { enumerable: true, get: function () { return admin_2.adminCancelSubscription; } });
var admin_3 = require("./domains/billing/api/admin");
Object.defineProperty(exports, "billing_adminResumeSubscription", { enumerable: true, get: function () { return admin_3.adminResumeSubscription; } });
var admin_4 = require("./domains/billing/api/admin");
Object.defineProperty(exports, "billing_getStripeSubscriptions", { enumerable: true, get: function () { return admin_4.getStripeSubscriptions; } });
var admin_5 = require("./domains/billing/api/admin");
Object.defineProperty(exports, "billing_getStripeTransactions", { enumerable: true, get: function () { return admin_5.getStripeTransactions; } });
var admin_6 = require("./domains/billing/api/admin");
Object.defineProperty(exports, "billing_adminAdjustBonusWashes", { enumerable: true, get: function () { return admin_6.adminAdjustBonusWashes; } });
var admin_7 = require("./domains/billing/api/admin");
Object.defineProperty(exports, "billing_adminGrantPremiumDays", { enumerable: true, get: function () { return admin_7.adminGrantPremiumDays; } });
var admin_8 = require("./domains/billing/api/admin");
Object.defineProperty(exports, "billing_adminCreateSubscription", { enumerable: true, get: function () { return admin_8.adminCreateSubscription; } });
var admin_9 = require("./domains/billing/api/admin");
Object.defineProperty(exports, "billing_syncPlanWithStripe", { enumerable: true, get: function () { return admin_9.syncPlanWithStripe; } });
var admin_10 = require("./domains/billing/api/admin");
Object.defineProperty(exports, "billing_getPublicStripeConfig", { enumerable: true, get: function () { return admin_10.getPublicStripeConfig; } });
// Webhooks
var webhook_1 = require("./domains/billing/webhooks/webhook");
Object.defineProperty(exports, "billing_stripeWebhook", { enumerable: true, get: function () { return webhook_1.stripeWebhook; } });
//# sourceMappingURL=index.js.map