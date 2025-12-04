"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.syncPlanWithStripe = exports.changeSubscriptionPlan = exports.reactivateSubscription = exports.cancelSubscription = exports.stripeWebhook = exports.createSubscriptionPaymentSheet = exports.createPaymentSheet = exports.createCheckoutSession = exports.getStripe = exports.stripeSecret = void 0;
const https_1 = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const stripe_1 = require("stripe");
const params_1 = require("firebase-functions/params");
exports.stripeSecret = (0, params_1.defineSecret)("STRIPE_SECRET");
const getStripe = () => {
    return new stripe_1.default(exports.stripeSecret.value(), {
    // apiVersion: "2023-10-16", // Let SDK choose default or configured version
    });
};
exports.getStripe = getStripe;
/**
 * Creates a Stripe Checkout Session for a subscription.
 */
exports.createCheckoutSession = (0, https_1.onCall)({ secrets: [exports.stripeSecret], cors: true }, async (request) => {
    var _a;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const { priceId, successUrl, cancelUrl } = request.data;
    const userId = request.auth.uid;
    const userEmail = request.auth.token.email;
    if (!priceId) {
        throw new https_1.HttpsError("invalid-argument", "The function must be called with a priceId.");
    }
    try {
        const stripe = (0, exports.getStripe)();
        // 1. Get or Create Stripe Customer
        const userDoc = await admin.firestore()
            .collection("users")
            .doc(userId)
            .get();
        let customerId = (_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a.stripeCustomerId;
        if (!customerId) {
            const customer = await stripe.customers.create({
                email: userEmail,
                metadata: { firebaseUID: userId },
            });
            customerId = customer.id;
            await userDoc.ref.update({ stripeCustomerId: customerId });
        }
        // 2. Create Checkout Session
        const session = await stripe.checkout.sessions.create({
            mode: "subscription",
            payment_method_types: ["card"],
            customer: customerId,
            line_items: [
                {
                    price: priceId,
                    quantity: 1,
                },
            ],
            success_url: successUrl || "https://aquaclean.app/success",
            cancel_url: cancelUrl || "https://aquaclean.app/cancel",
            metadata: {
                firebaseUID: userId,
            },
        });
        return { url: session.url, sessionId: session.id };
    }
    catch (error) {
        console.error("Error creating checkout session:", error);
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const message = error.message || "Unknown error";
        throw new https_1.HttpsError("internal", message);
    }
});
/**
 * Creates a Payment Sheet for a subscription.
 */
/**
 * Creates a Payment Sheet for a subscription.
 */
exports.createPaymentSheet = (0, https_1.onCall)({ secrets: [exports.stripeSecret], cors: true }, async (request) => {
    var _a, _b;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const { priceId, couponId } = request.data;
    const userId = request.auth.uid;
    const userEmail = request.auth.token.email;
    if (!priceId) {
        throw new https_1.HttpsError("invalid-argument", "The function must be called with a priceId.");
    }
    try {
        if (!exports.stripeSecret || !exports.stripeSecret.value()) {
            console.error("Stripe secret is missing or empty.");
            throw new https_1.HttpsError("internal", "Server configuration error: Stripe secret missing.");
        }
        const stripe = (0, exports.getStripe)();
        // 1. Get or Create Stripe Customer
        const userDoc = await admin.firestore()
            .collection("users")
            .doc(userId)
            .get();
        let customerId = (_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a.stripeCustomerId;
        if (!customerId) {
            const customer = await stripe.customers.create({
                email: userEmail,
                metadata: { firebaseUID: userId },
            });
            customerId = customer.id;
            await userDoc.ref.update({ stripeCustomerId: customerId });
        }
        // 2. Create Ephemeral Key
        const ephemeralKey = await stripe.ephemeralKeys.create({ customer: customerId }, { apiVersion: "2023-10-16" });
        // 3. Fetch Stripe Coupon if couponId provided
        let stripeCouponId = null;
        if (couponId) {
            const couponDoc = await admin.firestore()
                .collection("coupons")
                .doc(couponId)
                .get();
            if (couponDoc.exists) {
                stripeCouponId = (_b = couponDoc.data()) === null || _b === void 0 ? void 0 : _b.stripeCouponId;
            }
        }
        // 4. Create Subscription with Payment Intent
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const subscriptionParams = {
            customer: customerId,
            items: [{ price: priceId }],
            payment_behavior: "default_incomplete",
            payment_settings: { save_default_payment_method: "on_subscription" },
            expand: ["latest_invoice.payment_intent", "pending_setup_intent"],
            metadata: { firebaseUID: userId },
        };
        // Apply coupon if available
        if (stripeCouponId) {
            subscriptionParams.discounts = [{ coupon: stripeCouponId }];
            // Increment coupon usage count
            if (couponId) {
                await admin.firestore()
                    .collection("coupons")
                    .doc(couponId)
                    .update({
                    usedCount: admin.firestore.FieldValue.increment(1),
                });
            }
        }
        const subscription = await stripe.subscriptions.create(subscriptionParams);
        console.log("Stripe subscription created:", JSON.stringify(subscription, null, 2));
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        let latestInvoice = subscription.latest_invoice;
        // If latest_invoice is a string (expansion failed), retrieve it
        if (typeof latestInvoice === "string") {
            console.log("latest_invoice is a string, retrieving...");
            latestInvoice = await stripe.invoices.retrieve(latestInvoice);
            console.log("Retrieved invoice:", JSON.stringify(latestInvoice, null, 2));
        }
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const paymentIntent = latestInvoice === null || latestInvoice === void 0 ? void 0 : latestInvoice.payment_intent;
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const setupIntent = subscription.pending_setup_intent;
        if (!(paymentIntent === null || paymentIntent === void 0 ? void 0 : paymentIntent.client_secret) && !(setupIntent === null || setupIntent === void 0 ? void 0 : setupIntent.client_secret)) {
            // Try to retrieve payment intent if it's a string
            if (typeof paymentIntent === "string") {
                console.log("payment_intent is a string, retrieving...");
                const pi = await stripe.paymentIntents.retrieve(paymentIntent);
                if (pi.client_secret) {
                    return {
                        paymentIntent: pi.client_secret,
                        setupIntent: setupIntent === null || setupIntent === void 0 ? void 0 : setupIntent.client_secret,
                        ephemeralKey: ephemeralKey.secret,
                        customer: customerId,
                        publishableKey: "pk_test_51QSJ64G4kXo5c7q5XjXjXjXjXjXjXjXjXjXjXjXjXjXjXjXjXj",
                        subscriptionId: subscription.id,
                    };
                }
            }
            throw new https_1.HttpsError("internal", "Failed to get client_secret from subscription. This can happen if the plan has a free trial and requires no immediate payment.");
        }
        return {
            paymentIntent: paymentIntent === null || paymentIntent === void 0 ? void 0 : paymentIntent.client_secret,
            setupIntent: setupIntent === null || setupIntent === void 0 ? void 0 : setupIntent.client_secret,
            ephemeralKey: ephemeralKey.secret,
            customer: customerId,
            // TODO: Use env var or config
            publishableKey: "pk_test_51QSJ64G4kXo5c7q5XjXjXjXjXjXjXjXjXjXjXjXjXjXjXjXjXj",
            subscriptionId: subscription.id,
        };
    }
    catch (error) {
        console.error("Error creating payment sheet:", error);
        if (error instanceof Error) {
            console.error("Stack trace:", error.stack);
        }
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const message = error.message || "Unknown error";
        throw new https_1.HttpsError("internal", `Unable to create payment sheet: ${message}`, message);
    }
});
/**
 * Creates a Payment Sheet for a subscription
 * (Alias for backward compatibility if needed).
 * @deprecated Use createPaymentSheet instead.
 */
exports.createSubscriptionPaymentSheet = exports.createPaymentSheet;
/**
 * Stripe Webhook to handle events like subscription updates.
 */
exports.stripeWebhook = (0, https_1.onRequest)({ secrets: [exports.stripeSecret] }, async (req, res) => {
    const sig = req.headers["stripe-signature"];
    let event;
    try {
        const stripe = (0, exports.getStripe)();
        event = stripe.webhooks.constructEvent(req.rawBody, sig, exports.stripeSecret.value());
    }
    catch (err) {
        console.error("Webhook signature verification failed.", err);
        res.status(400).send(`Webhook Error: ${err}`);
        return;
    }
    try {
        switch (event.type) {
            case "customer.subscription.created":
            case "customer.subscription.updated":
            case "customer.subscription.deleted":
                await handleSubscriptionUpdate(event.data.object);
                break;
            case "invoice.payment_succeeded":
                // Handle successful payment (e.g., renew credits)
                break;
            case "invoice.payment_failed":
                // Handle failed payment (e.g., notify user)
                break;
            default:
                console.log(`Unhandled event type ${event.type}`);
        }
        res.json({ received: true });
    }
    catch (error) {
        console.error("Error handling webhook event:", error);
        res.status(500).send("Internal Server Error");
    }
});
/**
 * Handles subscription updates from Stripe webhooks.
 * @param {Stripe.Subscription} subscription - The subscription object.
 */
async function handleSubscriptionUpdate(subscription) {
    const customerId = subscription.customer;
    const status = subscription.status;
    const priceId = subscription.items.data[0].price.id;
    const userId = subscription.metadata.firebaseUID;
    // Cast to our extended interface to access missing properties
    const sub = subscription;
    if (!userId) {
        console.error("No firebaseUID found in subscription metadata.");
        return;
    }
    // Map Stripe status to app status
    // Stripe statuses: active, past_due, unpaid, canceled, incomplete,
    // incomplete_expired, trialing
    let appStatus = "inactive";
    if (status === "active" || status === "trialing") {
        appStatus = "active";
    }
    else if (status === "canceled" || status === "unpaid") {
        appStatus = "canceled";
    }
    // Check if a subscription document already exists for this user
    const subscriptionsSnapshot = await admin.firestore()
        .collection("subscriptions")
        .where("userId", "==", userId)
        .limit(1)
        .get();
    if (!subscriptionsSnapshot.empty) {
        // Update existing subscription
        const subscriptionDoc = subscriptionsSnapshot.docs[0];
        await subscriptionDoc.ref.update({
            status: appStatus,
            // Assuming priceId maps to planId or we store stripePriceId
            planId: priceId,
            stripeSubscriptionId: sub.id,
            stripeCustomerId: customerId,
            endDate: new Date(sub.current_period_end * 1000),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`Updated subscription for user ${userId}`);
    }
    else {
        // Create new subscription
        await admin.firestore().collection("subscriptions").add({
            userId: userId,
            planId: priceId,
            status: appStatus,
            startDate: new Date(sub.current_period_start * 1000),
            endDate: new Date(sub.current_period_end * 1000),
            stripeSubscriptionId: sub.id,
            stripeCustomerId: customerId,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`Created new subscription for user ${userId}`);
    }
}
/**
 * Cancels a Stripe subscription at the end of the billing period.
 */
exports.cancelSubscription = (0, https_1.onCall)({ secrets: [exports.stripeSecret], cors: true }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const { subscriptionId } = request.data;
    const userId = request.auth.uid;
    console.log("cancelSubscription called");
    console.log("subscriptionId:", subscriptionId);
    console.log("userId:", userId);
    if (!subscriptionId) {
        throw new https_1.HttpsError("invalid-argument", "The function must be called with a subscriptionId.");
    }
    try {
        const stripe = (0, exports.getStripe)();
        // Get subscription from Firestore
        const subDoc = await admin.firestore()
            .collection("subscriptions")
            .doc(subscriptionId)
            .get();
        if (!subDoc.exists) {
            console.error("Subscription not found:", subscriptionId);
            throw new https_1.HttpsError("not-found", "Subscription not found.");
        }
        const subData = subDoc.data();
        console.log("Subscription data:", JSON.stringify(subData));
        if ((subData === null || subData === void 0 ? void 0 : subData.userId) !== userId) {
            throw new https_1.HttpsError("permission-denied", "Not authorized to cancel this subscription.");
        }
        const stripeSubId = subData.stripeSubscriptionId;
        if (!stripeSubId) {
            throw new https_1.HttpsError("failed-precondition", "No Stripe subscription ID found.");
        }
        console.log("Canceling Stripe subscription:", stripeSubId);
        // Cancel at period end in Stripe
        await stripe.subscriptions.update(stripeSubId, {
            cancel_at_period_end: true,
        });
        console.log("Stripe subscription canceled successfully");
        // Update Firestore
        await subDoc.ref.update({
            cancelAtPeriodEnd: true,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log("Firestore updated successfully");
        return { success: true, message: "Subscription will cancel at period end" };
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
exports.reactivateSubscription = (0, https_1.onCall)({ secrets: [exports.stripeSecret], cors: true }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const { subscriptionId } = request.data;
    const userId = request.auth.uid;
    if (!subscriptionId) {
        throw new https_1.HttpsError("invalid-argument", "The function must be called with a subscriptionId.");
    }
    try {
        const stripe = (0, exports.getStripe)();
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
        return { success: true, message: "Subscription reactivated successfully" };
    }
    catch (error) {
        console.error("Error reactivating subscription:", error);
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const message = error.message || "Unknown error";
        throw new https_1.HttpsError("internal", message);
    }
});
/**
 * Changes the plan of an existing Stripe subscription.
 */
exports.changeSubscriptionPlan = (0, https_1.onCall)({ secrets: [exports.stripeSecret], cors: true }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const { subscriptionId, newPriceId } = request.data;
    const userId = request.auth.uid;
    // Debug logging
    console.log("changeSubscriptionPlan called");
    console.log("request.data:", JSON.stringify(request.data));
    console.log("subscriptionId:", subscriptionId);
    console.log("newPriceId:", newPriceId);
    console.log("userId:", userId);
    if (!subscriptionId || !newPriceId) {
        console.error("Missing parameters - subscriptionId:", subscriptionId, "newPriceId:", newPriceId);
        throw new https_1.HttpsError("invalid-argument", "subscriptionId and newPriceId are required.");
    }
    try {
        const stripe = (0, exports.getStripe)();
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
        // Update subscription in Stripe with proration
        await stripe.subscriptions.update(stripeSubId, {
            items: [
                {
                    id: currentItemId,
                    price: newPriceId,
                },
            ],
            proration_behavior: "create_prorations",
        });
        // Update Firestore
        await subDoc.ref.update({
            planId: newPriceId,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return { success: true, message: "Subscription plan changed successfully" };
    }
    catch (error) {
        console.error("Error changing subscription plan:", error);
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const message = error.message || "Unknown error";
        throw new https_1.HttpsError("internal", message);
    }
});
/**
 * Creates or updates a Stripe product and price for a subscription plan.
 * Called when admins create or update plans.
 */
exports.syncPlanWithStripe = (0, https_1.onCall)({ secrets: [exports.stripeSecret], cors: true }, async (request) => {
    var _a, _b;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const { planId, name, price, features } = request.data;
    if (!planId || !name || price === undefined) {
        throw new https_1.HttpsError("invalid-argument", "planId, name, and price are required.");
    }
    try {
        const stripe = (0, exports.getStripe)();
        // Check if plan already has a Stripe product/price
        const planDoc = await admin.firestore()
            .collection("plans")
            .doc(planId)
            .get();
        let productId = (_a = planDoc.data()) === null || _a === void 0 ? void 0 : _a.stripeProductId;
        let priceId = (_b = planDoc.data()) === null || _b === void 0 ? void 0 : _b.stripePriceId;
        // Create or update product
        if (!productId) {
            // Create new product
            const product = await stripe.products.create({
                name: name,
                description: (features === null || features === void 0 ? void 0 : features.join(", ")) || "",
                metadata: {
                    firebasePlanId: planId,
                },
            });
            productId = product.id;
            console.log(`Created Stripe product: ${productId}`);
        }
        else {
            // Update existing product
            await stripe.products.update(productId, {
                name: name,
                description: (features === null || features === void 0 ? void 0 : features.join(", ")) || "",
            });
            console.log(`Updated Stripe product: ${productId}`);
        }
        // Create new price
        // (Stripe prices are immutable, so create new if price changed)
        const newPrice = await stripe.prices.create({
            product: productId,
            unit_amount: Math.round(price * 100),
            currency: "brl",
            recurring: {
                interval: "month",
            },
            metadata: {
                firebasePlanId: planId,
            },
        });
        // Archive old price if it exists and is different
        if (priceId && priceId !== newPrice.id) {
            try {
                await stripe.prices.update(priceId, {
                    active: false,
                });
                console.log(`Archived old price: ${priceId}`);
            }
            catch (error) {
                console.error("Error archiving old price:", error);
            }
        }
        priceId = newPrice.id;
        console.log(`Created new Stripe price: ${priceId}`);
        // Update Firestore plan with Stripe IDs
        await planDoc.ref.update({
            stripeProductId: productId,
            stripePriceId: priceId,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return {
            success: true,
            productId: productId,
            priceId: priceId,
            message: "Plan synced with Stripe successfully",
        };
    }
    catch (error) {
        console.error("Error syncing plan with Stripe:", error);
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const message = error.message || "Unknown error";
        throw new https_1.HttpsError("internal", message);
    }
});
//# sourceMappingURL=stripe.js.map