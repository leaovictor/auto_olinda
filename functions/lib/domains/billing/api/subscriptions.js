"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getSubscriptionInvoices = exports.getSubscriptionDetails = exports.changeSubscriptionPlan = exports.syncSubscriptionStatus = exports.reactivateSubscription = exports.cancelSubscription = void 0;
const admin = require("firebase-admin");
const https_1 = require("firebase-functions/v2/https");
const env_1 = require("../../../config/env");
const stripe_1 = require("../helpers/stripe");
/**
 * Cancels a Stripe subscription at the end of the billing period.
 */
exports.cancelSubscription = (0, https_1.onCall)({ secrets: [env_1.stripeSecret], cors: true }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const { subscriptionId } = request.data;
    const userId = request.auth.uid;
    if (!subscriptionId) {
        throw new https_1.HttpsError("invalid-argument", "The function must be called with a subscriptionId.");
    }
    try {
        const stripe = await (0, stripe_1.getStripe)();
        // Get subscription from Firestore
        const subDoc = await admin.firestore()
            .collection("subscriptions")
            .doc(subscriptionId)
            .get();
        if (!subDoc.exists) {
            throw new https_1.HttpsError("not-found", "Subscription not found.");
        }
        const subData = subDoc.data();
        if ((subData === null || subData === void 0 ? void 0 : subData.userId) !== userId) {
            throw new https_1.HttpsError("permission-denied", "Not authorized to cancel this subscription.");
        }
        const stripeSubId = subData.stripeSubscriptionId;
        if (!stripeSubId) {
            throw new https_1.HttpsError("failed-precondition", "No Stripe subscription ID found.");
        }
        // Cancel at period end in Stripe
        await stripe.subscriptions.update(stripeSubId, {
            cancel_at_period_end: true,
        });
        // Update Firestore
        await subDoc.ref.update({
            cancelAtPeriodEnd: true,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return {
            success: true,
            message: "Subscription will cancel at period end",
        };
    }
    catch (error) {
        console.error("Error canceling subscription:", error);
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const message = error.message || "Unknown error";
        throw new https_1.HttpsError("internal", message);
    }
});
/**
 * Reactivates a canceled Stripe subscription.
 */
exports.reactivateSubscription = (0, https_1.onCall)({ secrets: [env_1.stripeSecret], cors: true }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const { subscriptionId } = request.data;
    const userId = request.auth.uid;
    if (!subscriptionId) {
        throw new https_1.HttpsError("invalid-argument", "The function must be called with a subscriptionId.");
    }
    try {
        const stripe = await (0, stripe_1.getStripe)();
        // Get subscription from Firestore
        const subDoc = await admin.firestore()
            .collection("subscriptions")
            .doc(subscriptionId)
            .get();
        if (!subDoc.exists) {
            throw new https_1.HttpsError("not-found", "Subscription not found.");
        }
        const subData = subDoc.data();
        if ((subData === null || subData === void 0 ? void 0 : subData.userId) !== userId) {
            throw new https_1.HttpsError("permission-denied", "Not authorized to reactivate this subscription.");
        }
        const stripeSubId = subData.stripeSubscriptionId;
        if (!stripeSubId) {
            throw new https_1.HttpsError("failed-precondition", "No Stripe subscription ID found.");
        }
        // Resume in Stripe
        await stripe.subscriptions.update(stripeSubId, {
            cancel_at_period_end: false,
        });
        // Update Firestore
        await subDoc.ref.update({
            cancelAtPeriodEnd: false,
            status: "active",
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return {
            success: true,
            message: "Subscription reactivated successfully",
        };
    }
    catch (error) {
        console.error("Error reactivating subscription:", error);
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const message = error.message || "Unknown error";
        throw new https_1.HttpsError("internal", message);
    }
});
/**
 * Forcefully syncs subscription status from Stripe to Firestore.
 */
exports.syncSubscriptionStatus = (0, https_1.onCall)({ secrets: [env_1.stripeSecret], cors: true }, async (request) => {
    var _a, _b, _c;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const { subscriptionId } = request.data;
    const userId = request.auth.uid;
    if (!subscriptionId) {
        throw new https_1.HttpsError("invalid-argument", "The function must be called with a subscriptionId (Stripe sub ID).");
    }
    console.log(`Syncing subscription ${subscriptionId} for user ${userId}`);
    try {
        const stripe = await (0, stripe_1.getStripe)();
        // Fetch fresh subscription from Stripe
        const subscription = await stripe.subscriptions.retrieve(subscriptionId);
        // Map Stripe status to app status
        const status = subscription.status;
        let appStatus = "inactive";
        if (status === "active" || status === "trialing") {
            appStatus = "active";
        }
        else if (status === "past_due") {
            appStatus = "past_due";
        }
        else if (status === "canceled" ||
            status === "unpaid" ||
            status === "incomplete_expired") {
            appStatus = "canceled";
        }
        else if (status === "incomplete") {
            appStatus = "incomplete";
        }
        else if (status === "paused") {
            appStatus = "paused";
        }
        // Get dates from subscription
        const sub = subscription;
        let currentPeriodStart = sub.current_period_start;
        let currentPeriodEnd = sub.current_period_end;
        // Fallback if dates are missing
        if (typeof currentPeriodStart !== "number" ||
            isNaN(currentPeriodStart)) {
            currentPeriodStart = Math.floor(Date.now() / 1000);
        }
        if (typeof currentPeriodEnd !== "number" || isNaN(currentPeriodEnd)) {
            currentPeriodEnd = currentPeriodStart + 30 * 24 * 60 * 60;
        }
        const startDate = new Date(currentPeriodStart * 1000);
        const endDate = new Date(currentPeriodEnd * 1000);
        const priceId = (_b = (_a = subscription.items.data[0]) === null || _a === void 0 ? void 0 : _a.price) === null || _b === void 0 ? void 0 : _b.id;
        const customerId = typeof subscription.customer === "string"
            ? subscription.customer
            : (_c = subscription.customer) === null || _c === void 0 ? void 0 : _c.id;
        // Find and update Firestore subscription for this user
        const subscriptionsSnapshot = await admin
            .firestore()
            .collection("subscriptions")
            .where("userId", "==", userId)
            .limit(1)
            .get();
        if (!subscriptionsSnapshot.empty) {
            const subscriptionDoc = subscriptionsSnapshot.docs[0];
            await subscriptionDoc.ref.update({
                status: appStatus,
                planId: priceId,
                stripeSubscriptionId: subscriptionId,
                stripeCustomerId: customerId,
                startDate: startDate,
                endDate: endDate,
                cancelAtPeriodEnd: subscription.cancel_at_period_end,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
        else {
            // Create new subscription document if none exists
            await admin.firestore().collection("subscriptions").add({
                userId: userId,
                planId: priceId,
                status: appStatus,
                startDate: startDate,
                endDate: endDate,
                stripeSubscriptionId: subscriptionId,
                stripeCustomerId: customerId,
                cancelAtPeriodEnd: subscription.cancel_at_period_end,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
        // Update User Profile Status
        const userSubscriptionStatus = (status === 'active' || status === 'trialing')
            ? 'active'
            : (status === 'canceled' || status === 'unpaid' || status === 'incomplete_expired')
                ? 'cancelled'
                : 'inactive';
        await admin.firestore().collection('users').doc(userId).update({
            subscriptionStatus: userSubscriptionStatus,
            subscriptionUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return { success: true, status: appStatus };
    }
    catch (error) {
        console.error("Error syncing subscription:", error);
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const message = error.message || "Unknown error";
        throw new https_1.HttpsError("internal", message);
    }
});
/**
 * Changes the plan of an existing Stripe subscription.
 */
exports.changeSubscriptionPlan = (0, https_1.onCall)({ secrets: [env_1.stripeSecret], cors: true }, async (request) => {
    var _a;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const { subscriptionId, newPriceId } = request.data;
    const userId = request.auth.uid;
    if (!subscriptionId || !newPriceId) {
        throw new https_1.HttpsError("invalid-argument", "subscriptionId and newPriceId are required.");
    }
    try {
        const stripe = await (0, stripe_1.getStripe)();
        // Get subscription from Firestore
        const subDoc = await admin.firestore()
            .collection("subscriptions")
            .doc(subscriptionId)
            .get();
        if (!subDoc.exists) {
            throw new https_1.HttpsError("not-found", "Subscription not found.");
        }
        const subData = subDoc.data();
        if ((subData === null || subData === void 0 ? void 0 : subData.userId) !== userId) {
            throw new https_1.HttpsError("permission-denied", "Not authorized to change this subscription.");
        }
        const stripeSubId = subData.stripeSubscriptionId;
        if (!stripeSubId) {
            throw new https_1.HttpsError("failed-precondition", "No Stripe subscription ID found.");
        }
        // Get current subscription from Stripe
        const subscription = await stripe.subscriptions.retrieve(stripeSubId);
        const currentItemId = subscription.items.data[0].id;
        const currentPriceId = subscription.items.data[0].price.id;
        // Get price info to determine if it's an upgrade or downgrade
        const currentPrice = await stripe.prices.retrieve(currentPriceId);
        const newPrice = await stripe.prices.retrieve(newPriceId);
        const currentAmount = currentPrice.unit_amount || 0;
        const newAmount = newPrice.unit_amount || 0;
        const isDowngrade = newAmount < currentAmount;
        const isUpgrade = newAmount > currentAmount;
        // Rule 1: Minimum period before downgrade (30 days after last upgrade)
        const MINIMUM_UPGRADE_PERIOD_DAYS = 30;
        if (isDowngrade) {
            const lastUpgradeDate = (_a = subData.lastUpgradeAt) === null || _a === void 0 ? void 0 : _a.toDate();
            if (lastUpgradeDate) {
                const daysSinceUpgrade = Math.floor((Date.now() - lastUpgradeDate.getTime()) / (1000 * 60 * 60 * 24));
                if (daysSinceUpgrade < MINIMUM_UPGRADE_PERIOD_DAYS) {
                    const remainingDays = MINIMUM_UPGRADE_PERIOD_DAYS - daysSinceUpgrade;
                    throw new https_1.HttpsError("failed-precondition", `Você precisa aguardar mais ${remainingDays} dia(s) antes de ` +
                        `fazer downgrade. Período mínimo: ${MINIMUM_UPGRADE_PERIOD_DAYS} dias.`);
                }
            }
            // Rule 2: Downgrade only takes effect at the end of billing period
            await stripe.subscriptions.update(stripeSubId, {
                items: [
                    {
                        id: currentItemId,
                        price: newPriceId,
                    },
                ],
                proration_behavior: "none",
                billing_cycle_anchor: "unchanged",
            });
            // Record plan change history
            await admin.firestore().collection("plan_changes").add({
                userId,
                subscriptionId,
                fromPriceId: currentPriceId,
                toPriceId: newPriceId,
                changeType: "downgrade",
                effectiveAt: new Date(subscription.current_period_end * 1000),
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            // Update Firestore
            await subDoc.ref.update({
                planId: newPriceId,
                pendingDowngrade: true,
                pendingPlanId: newPriceId,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            return {
                success: true,
                message: "Downgrade agendado para o próximo ciclo de cobrança.",
                effectiveDate: new Date(subscription.current_period_end * 1000)
                    .toISOString(),
            };
        }
        else if (isUpgrade) {
            // Rule 3: Upgrade takes effect immediately with proration
            await stripe.subscriptions.update(stripeSubId, {
                items: [
                    {
                        id: currentItemId,
                        price: newPriceId,
                    },
                ],
                proration_behavior: "create_prorations",
            });
            // Record plan change history
            await admin.firestore().collection("plan_changes").add({
                userId,
                subscriptionId,
                fromPriceId: currentPriceId,
                toPriceId: newPriceId,
                changeType: "upgrade",
                effectiveAt: new Date(),
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            // Update Firestore
            await subDoc.ref.update({
                planId: newPriceId,
                lastUpgradeAt: admin.firestore.FieldValue.serverTimestamp(),
                pendingDowngrade: false,
                pendingPlanId: null,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            return {
                success: true,
                message: "Upgrade realizado com sucesso! Novos benefícios já ativos.",
            };
        }
        else {
            // Same price, just update
            await stripe.subscriptions.update(stripeSubId, {
                items: [
                    {
                        id: currentItemId,
                        price: newPriceId,
                    },
                ],
                proration_behavior: "none",
            });
            await subDoc.ref.update({
                planId: newPriceId,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            return {
                success: true,
                message: "Plano alterado com sucesso.",
            };
        }
    }
    catch (error) {
        console.error("Error changing subscription plan:", error);
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const message = error.message || "Unknown error";
        throw new https_1.HttpsError("internal", message);
    }
});
/**
 * Retrieves detailed subscription information, including payment method.
 */
exports.getSubscriptionDetails = (0, https_1.onCall)({ secrets: [env_1.stripeSecret], cors: true }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const { subscriptionId } = request.data;
    const userId = request.auth.uid;
    if (!subscriptionId) {
        throw new https_1.HttpsError("invalid-argument", "The function must be called with a subscriptionId.");
    }
    try {
        const stripe = await (0, stripe_1.getStripe)();
        // Get subscription from Firestore
        const subDoc = await admin.firestore()
            .collection("subscriptions")
            .doc(subscriptionId)
            .get();
        if (!subDoc.exists) {
            throw new https_1.HttpsError("not-found", "Subscription not found.");
        }
        const subData = subDoc.data();
        if ((subData === null || subData === void 0 ? void 0 : subData.userId) !== userId) {
            throw new https_1.HttpsError("permission-denied", "Not authorized to view this subscription.");
        }
        const stripeSubId = subData.stripeSubscriptionId;
        if (!stripeSubId) {
            throw new https_1.HttpsError("failed-precondition", "No Stripe subscription ID found.");
        }
        // Retrieve from Stripe expanding the payment method
        const subscription = await stripe.subscriptions.retrieve(stripeSubId, {
            expand: ['default_payment_method'],
        });
        let paymentMethodDetails = null;
        if (typeof subscription.default_payment_method === 'object' && subscription.default_payment_method !== null) {
            const pm = subscription.default_payment_method;
            if (pm.card) {
                paymentMethodDetails = {
                    brand: pm.card.brand,
                    last4: pm.card.last4,
                    expMonth: pm.card.exp_month,
                    expYear: pm.card.exp_year,
                };
            }
        }
        return {
            status: subscription.status,
            cancelAtPeriodEnd: subscription.cancel_at_period_end,
            currentPeriodEnd: subscription.current_period_end,
            paymentMethod: paymentMethodDetails,
        };
    }
    catch (error) {
        console.error("Error getting subscription details:", error);
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const message = error.message || "Unknown error";
        throw new https_1.HttpsError("internal", message);
    }
});
/**
 * Fetches subscription invoices for the authenticated user.
 */
exports.getSubscriptionInvoices = (0, https_1.onCall)({ secrets: [env_1.stripeSecret], cors: true }, async (request) => {
    var _a;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const userId = request.auth.uid;
    try {
        const stripe = await (0, stripe_1.getStripe)();
        // 1. Get user's Stripe customer ID
        const userDoc = await admin.firestore()
            .collection("users")
            .doc(userId)
            .get();
        const customerId = (_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a.stripeCustomerId;
        if (!customerId) {
            return { invoices: [] };
        }
        // 2. Verify customer exists in Stripe
        try {
            const customer = await stripe.customers.retrieve(customerId);
            if (customer.deleted) {
                return { invoices: [] };
            }
        }
        catch (error) {
            if (error.code === "resource_missing") {
                return { invoices: [] };
            }
            throw error;
        }
        // 3. Fetch ALL invoices from Stripe
        const invoices = await stripe.invoices.list({
            customer: customerId,
            limit: 24, // Last 24 invoices (2 years of monthly)
            expand: ['data.charge'],
        });
        // 4. Map to simplified format - include paid and open invoices
        const allInvoices = invoices.data.filter(inv => inv.status === 'paid' || inv.status === 'open');
        // Sort by created date descending
        allInvoices.sort((a, b) => b.created - a.created);
        const mappedInvoices = allInvoices.map((invoice) => {
            var _a;
            let paymentMethodBrand = null;
            let paymentMethodLast4 = null;
            const charge = invoice.charge;
            if (charge && ((_a = charge.payment_method_details) === null || _a === void 0 ? void 0 : _a.card)) {
                paymentMethodBrand = charge.payment_method_details.card.brand;
                paymentMethodLast4 = charge.payment_method_details.card.last4;
            }
            return {
                id: invoice.id,
                amountPaid: invoice.amount_paid,
                created: invoice.created,
                status: invoice.status,
                invoicePdf: invoice.invoice_pdf,
                paymentMethodBrand,
                paymentMethodLast4,
            };
        });
        return { invoices: mappedInvoices };
    }
    catch (error) {
        console.error("Error fetching subscription invoices:", error);
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const message = error.message || "Unknown error";
        throw new https_1.HttpsError("internal", message);
    }
});
//# sourceMappingURL=subscriptions.js.map