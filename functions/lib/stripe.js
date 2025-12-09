"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.syncPlanWithStripe = exports.changeSubscriptionPlan = exports.syncSubscriptionStatus = exports.reactivateSubscription = exports.cancelSubscription = exports.stripeWebhook = exports.createPaymentSheet = exports.createCheckoutSession = exports.getStripe = exports.stripeWebhookSecret = exports.stripeSecret = void 0;
const https_1 = require("firebase-functions/v2/https");
const params_1 = require("firebase-functions/params");
const admin = require("firebase-admin");
const stripe_1 = require("stripe");
exports.stripeSecret = (0, params_1.defineSecret)("STRIPE_SECRET");
exports.stripeWebhookSecret = (0, params_1.defineSecret)("STRIPE_WEBHOOK_SECRET");
const getStripe = () => {
    return new stripe_1.default(exports.stripeSecret.value(), {
        apiVersion: "2023-10-16",
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
        let shouldCreateCustomer = !customerId;
        if (customerId) {
            try {
                const customer = await stripe.customers.retrieve(customerId);
                if (customer.deleted) {
                    console.log(`Customer ${customerId} is deleted in Stripe. Creating new one.`);
                    shouldCreateCustomer = true;
                }
            }
            catch (error) {
                if (error.code === "resource_missing") {
                    console.log(`Customer ${customerId} not found in Stripe. Creating new one.`);
                    shouldCreateCustomer = true;
                }
                else {
                    throw error;
                }
            }
        }
        if (shouldCreateCustomer) {
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
        let shouldCreateCustomer = !customerId;
        if (customerId) {
            try {
                const customer = await stripe.customers.retrieve(customerId);
                if (customer.deleted) {
                    console.log(`Customer ${customerId} is deleted in Stripe. Creating new one.`);
                    shouldCreateCustomer = true;
                }
            }
            catch (error) {
                if (error.code === "resource_missing") {
                    console.log(`Customer ${customerId} not found in Stripe. Creating new one.`);
                    shouldCreateCustomer = true;
                }
                else {
                    throw error;
                }
            }
        }
        if (shouldCreateCustomer) {
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
        // CRITICAL: Immediately create/update Firestore subscription document
        // This ensures stripeSubscriptionId is available for sync polling
        // before the webhook fires (which can be delayed)
        const subscriptionsSnapshot = await admin.firestore()
            .collection("subscriptions")
            .where("userId", "==", userId)
            .limit(1)
            .get();
        const subData = {
            userId: userId,
            planId: priceId,
            status: "incomplete",
            stripeSubscriptionId: subscription.id,
            stripeCustomerId: customerId,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };
        if (!subscriptionsSnapshot.empty) {
            const existingDoc = subscriptionsSnapshot.docs[0];
            await existingDoc.ref.update(subData);
            console.log(`Updated existing subscription doc for user ${userId}`);
        }
        else {
            await admin.firestore().collection("subscriptions").add(Object.assign(Object.assign({}, subData), { startDate: new Date(), createdAt: admin.firestore.FieldValue.serverTimestamp() }));
            console.log(`Created new subscription doc for user ${userId}`);
        }
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
                        publishableKey: "pk_test_51SYcoM5uVLC6EX3m78P74UhblBFyRfK4kilvUS8rO94CbvXrQYmsg1ApO9r3Sf0YuCELV3TcKE06b3HOfvCJkN7I00reQwOwau",
                        subscriptionId: subscription.id,
                    };
                }
            }
            throw new https_1.HttpsError("internal", "Failed to get client_secret from subscription. " +
                "This can happen if the plan has a free trial and " +
                "requires no immediate payment.");
        }
        return {
            paymentIntent: paymentIntent === null || paymentIntent === void 0 ? void 0 : paymentIntent.client_secret,
            setupIntent: setupIntent === null || setupIntent === void 0 ? void 0 : setupIntent.client_secret,
            ephemeralKey: ephemeralKey.secret,
            customer: customerId,
            // TODO: Use env var or config
            // Key updated to pk_test_51SYcoM...
            publishableKey: "pk_test_51SYcoM5uVLC6EX3m78P74UhblBFyRfK4kilvUS8rO94CbvXrQYmsg1ApO9r3Sf0YuCELV3TcKE06b3HOfvCJkN7I00reQwOwau",
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
 * Stripe Webhook to handle events like subscription updates.
 */
exports.stripeWebhook = (0, https_1.onRequest)({ secrets: [exports.stripeSecret, exports.stripeWebhookSecret], maxInstances: 1, cpu: 1 }, async (req, res) => {
    const sig = req.headers["stripe-signature"];
    // Debug logging for webhook (using error to ensure visibility)
    console.error("DEBUG: Webhook called");
    console.error("DEBUG: Signature:", sig);
    console.error("DEBUG: RawBody type:", typeof req.rawBody);
    if (req.rawBody) {
        console.error("DEBUG: RawBody length:", req.rawBody.length);
        console.error("DEBUG: RawBody is Buffer:", Buffer.isBuffer(req.rawBody));
    }
    else {
        console.error("DEBUG: req.rawBody is UNDEFINED");
    }
    console.error("DEBUG: Secret configured:", !!exports.stripeWebhookSecret.value());
    if (exports.stripeWebhookSecret.value()) {
        console.error("DEBUG: Secret prefix:", exports.stripeWebhookSecret.value().substring(0, 5));
    }
    let event;
    try {
        const stripe = (0, exports.getStripe)();
        event = stripe.webhooks.constructEvent(req.rawBody, sig, exports.stripeWebhookSecret.value());
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
            case "checkout.session.completed": {
                const session = event.data.object;
                if (session.mode === "subscription" && session.subscription) {
                    const subscriptionId = typeof session.subscription === "string" ?
                        session.subscription :
                        session.subscription.id;
                    const stripe = (0, exports.getStripe)();
                    const sub = await stripe.subscriptions.retrieve(subscriptionId);
                    await handleSubscriptionUpdate(sub);
                }
                break;
            }
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
 * Updates user subscription status in Firestore.
 * @param {Stripe.Subscription} subscription - The subscription object
 * from Stripe.
 */
/**
 * Updates user subscription status in Firestore.
 * @param {Stripe.Subscription} subscription - The subscription object
 * from Stripe.
 */
/**
 * Interface extending Stripe.Subscription to include missing properties.
 */
/**
 * Handles subscription updates from Stripe webhooks.
 * @param {Stripe.Subscription} subscription - The subscription object.
 */
async function handleSubscriptionUpdate(subscription) {
    // Adicionamos um log para ver o conteúdo que chega do Stripe
    console.log("--- Conteúdo do Webhook de Assinatura ---");
    console.log(JSON.stringify(subscription, null, 2));
    const customerId = subscription.customer;
    const status = subscription.status;
    const priceId = subscription.items.data[0].price.id;
    const userId = subscription.metadata.firebaseUID;
    const sub = subscription; // Apenas para manter a consistência do código original
    if (!userId) {
        console.error("No firebaseUID found in subscription metadata for subscription:", sub.id);
        return;
    }
    // --- INÍCIO DA CORREÇÃO ---
    // Verificação de segurança para garantir que as datas existem e são válidas
    let currentPeriodStart = sub.current_period_start;
    let currentPeriodEnd = sub.current_period_end;
    // Se as datas estiverem faltando ou inválidas, usamos fallback
    if (typeof currentPeriodStart !== 'number' || typeof currentPeriodEnd !== 'number') {
        console.log(`Datas faltando no objeto do webhook para a assinatura ${sub.id}. Usando fallbacks.`);
        // Fallback 1: Tentar buscar do Stripe
        try {
            const stripe = (0, exports.getStripe)();
            const freshSub = await stripe.subscriptions.retrieve(sub.id);
            currentPeriodStart = freshSub.current_period_start;
            currentPeriodEnd = freshSub.current_period_end;
        }
        catch (error) {
            console.error("Erro ao buscar assinatura atualizada:", error);
        }
    }
    // Fallback 2: Se ainda inválido, usar data atual e +30 dias
    if (typeof currentPeriodStart !== 'number' || isNaN(currentPeriodStart)) {
        console.warn("Usando data atual como fallback para start date");
        currentPeriodStart = Math.floor(Date.now() / 1000);
    }
    if (typeof currentPeriodEnd !== 'number' || isNaN(currentPeriodEnd)) {
        console.warn("Usando data +30 dias como fallback para end date");
        currentPeriodEnd = currentPeriodStart + (30 * 24 * 60 * 60);
    }
    const startDate = new Date(currentPeriodStart * 1000);
    const endDate = new Date(currentPeriodEnd * 1000);
    // --- FIM DA CORREÇÃO ---
    let appStatus = "inactive";
    if (status === "active" || status === "trialing") {
        appStatus = "active";
    }
    else if (status === "past_due") {
        appStatus = "past_due";
    }
    else if (status === "canceled" || status === "unpaid" || status === "incomplete_expired") {
        appStatus = "canceled";
    }
    else if (status === "incomplete") {
        appStatus = "incomplete";
    }
    else if (status === "paused") {
        appStatus = "paused";
    }
    const subscriptionsSnapshot = await admin.firestore()
        .collection("subscriptions")
        .where("userId", "==", userId)
        .limit(1)
        .get();
    if (!subscriptionsSnapshot.empty) {
        const subscriptionDoc = subscriptionsSnapshot.docs[0];
        await subscriptionDoc.ref.update({
            status: appStatus,
            planId: priceId,
            stripeSubscriptionId: sub.id,
            stripeCustomerId: customerId,
            endDate: endDate,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`Assinatura ATUALIZADA para o usuário ${userId}`);
    }
    else {
        await admin.firestore().collection("subscriptions").add({
            userId: userId,
            planId: priceId,
            status: appStatus,
            startDate: startDate,
            endDate: endDate,
            stripeSubscriptionId: sub.id,
            stripeCustomerId: customerId,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`Nova assinatura CRIADA para o usuário ${userId}`);
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
 * Useful when webhook events are delayed or fail.
 */
exports.syncSubscriptionStatus = (0, https_1.onCall)({ secrets: [exports.stripeSecret], cors: true }, async (request) => {
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
        const stripe = (0, exports.getStripe)();
        // Fetch fresh subscription from Stripe
        const subscription = await stripe.subscriptions.retrieve(subscriptionId);
        console.log("Retrieved subscription from Stripe:", JSON.stringify(subscription, null, 2));
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
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            console.log(`Subscription SYNCED for user ${userId}: status=${appStatus}`);
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
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            console.log(`NEW subscription CREATED for user ${userId}: status=${appStatus}`);
        }
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
exports.changeSubscriptionPlan = (0, https_1.onCall)({ secrets: [exports.stripeSecret], cors: true }, async (request) => {
    var _a;
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
        const currentPriceId = subscription.items.data[0].price.id;
        // Get price info to determine if it's an upgrade or downgrade
        const currentPrice = await stripe.prices.retrieve(currentPriceId);
        const newPrice = await stripe.prices.retrieve(newPriceId);
        const currentAmount = currentPrice.unit_amount || 0;
        const newAmount = newPrice.unit_amount || 0;
        const isDowngrade = newAmount < currentAmount;
        const isUpgrade = newAmount > currentAmount;
        console.log(`Plan change: current=${currentAmount}, new=${newAmount}, ` +
            `isUpgrade=${isUpgrade}, isDowngrade=${isDowngrade}`);
        // === ANTI-FRAUD RULES ===
        // Rule 1: Minimum period before downgrade (7 days after last upgrade)
        const MINIMUM_UPGRADE_PERIOD_DAYS = 7;
        if (isDowngrade) {
            const lastUpgradeDate = (_a = subData.lastUpgradeAt) === null || _a === void 0 ? void 0 : _a.toDate();
            if (lastUpgradeDate) {
                const daysSinceUpgrade = Math.floor((Date.now() - lastUpgradeDate.getTime()) / (1000 * 60 * 60 * 24));
                console.log(`Days since last upgrade: ${daysSinceUpgrade}`);
                if (daysSinceUpgrade < MINIMUM_UPGRADE_PERIOD_DAYS) {
                    const remainingDays = MINIMUM_UPGRADE_PERIOD_DAYS - daysSinceUpgrade;
                    throw new https_1.HttpsError("failed-precondition", `Você precisa aguardar mais ${remainingDays} dia(s) antes de ` +
                        `fazer downgrade. Período mínimo: ${MINIMUM_UPGRADE_PERIOD_DAYS} dias.`);
                }
            }
            // Rule 2: Downgrade only takes effect at the end of billing period
            // Update subscription with proration but apply at period end
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
                proration_behavior: "create_prorations", // Charge difference for upgrade
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
            // Update Firestore with lastUpgradeAt to track minimum period
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
        // Build description - Stripe doesn't accept empty strings
        const description = (features === null || features === void 0 ? void 0 : features.length) > 0
            ? features.join(", ")
            : `Plano ${name}`;
        // Create or update product
        if (!productId) {
            // Create new product
            const product = await stripe.products.create({
                name: name,
                description: description,
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
                description: description,
            });
            console.log(`Updated Stripe product: ${productId}`);
        }
        // Check if price has changed
        let priceChanged = true;
        if (priceId) {
            try {
                const currentPrice = await stripe.prices.retrieve(priceId);
                const currentAmount = currentPrice.unit_amount;
                const newAmount = Math.round(price * 100);
                if (currentAmount === newAmount && currentPrice.active) {
                    priceChanged = false;
                    console.log(`Price amount unchanged (${newAmount}), skipping price creation.`);
                }
            }
            catch (error) {
                console.warn("Error retrieving current price, will create new one:", error);
            }
        }
        if (priceChanged) {
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
        }
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