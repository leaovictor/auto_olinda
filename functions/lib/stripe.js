"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getSubscriptionInvoices = exports.getSubscriptionDetails = exports.adminCreateSubscription = exports.createServicePaymentIntent = exports.adminGrantPremiumDays = exports.adminAdjustBonusWashes = exports.getStripeTransactions = exports.getStripeSubscriptions = exports.adminResumeSubscription = exports.adminCancelSubscription = exports.adminPauseSubscription = exports.syncPlanWithStripe = exports.changeSubscriptionPlan = exports.syncSubscriptionStatus = exports.reactivateSubscription = exports.cancelSubscription = exports.stripeWebhook = exports.createPaymentSheet = exports.createSubscriptionPixPayment = exports.createPixPaymentIntent = exports.createCheckoutSession = exports.getStripe = exports.stripePublishableKey = exports.stripeWebhookSecret = exports.stripeSecret = void 0;
const https_1 = require("firebase-functions/v2/https");
const params_1 = require("firebase-functions/params");
const admin = require("firebase-admin");
const stripe_1 = require("stripe");
const orders_1 = require("./orders");
/**
 * Creates a Stripe Checkout Session for a subscription.
 */
// ... (existing imports)
exports.stripeSecret = (0, params_1.defineSecret)("STRIPE_SECRET");
exports.stripeWebhookSecret = (0, params_1.defineSecret)("STRIPE_WEBHOOK_SECRET");
exports.stripePublishableKey = (0, params_1.defineSecret)("STRIPE_PUBLISHABLE_KEY");
const getStripe = () => {
    return new stripe_1.default(exports.stripeSecret.value(), {
        apiVersion: "2023-10-16",
    });
};
exports.getStripe = getStripe;
/**
 * Creates a Stripe Checkout Session for a subscription or one-time payment.
 * Now supports dynamic pricing for services based on active subscription.
 */
/**
 * Creates a Stripe Checkout Session for a subscription or one-time payment.
 * Supports dynamic pricing for services based on active subscription logic.
 */
exports.createCheckoutSession = (0, https_1.onCall)({ secrets: [exports.stripeSecret], cors: true }, async (request) => {
    var _a, _b;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const { priceId, mode = 'subscription', successUrl, cancelUrl, couponId, serviceId, items, vehicleId, scheduledTime } = request.data;
    const userId = request.auth.uid;
    const userEmail = request.auth.token.email;
    if (!priceId && (!items || items.length === 0)) {
        throw new https_1.HttpsError("invalid-argument", "The function must be called with a priceId or a list of items.");
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
        // 2. Prepare Checkout Logic
        let lineItems = [];
        if (items && items.length > 0) {
            // Handle multiple items
            lineItems = items.map((item) => ({
                price: item.priceId,
                quantity: item.quantity || 1,
            }));
        }
        else {
            // Handle single priceId legacy/simple mode
            lineItems = [
                {
                    price: priceId,
                    quantity: 1,
                },
            ];
        }
        let sessionParams = {
            payment_method_types: ["card", "pix"],
            customer: customerId,
            line_items: lineItems,
            success_url: successUrl || "https://aquaclean.app/success",
            cancel_url: cancelUrl || "https://aquaclean.app/cancel",
            metadata: {
                firebaseUID: userId,
            },
        };
        // Apply dynamic discounts based on Coupon ID
        if (couponId) {
            // Verify coupon validity internally or assume ID is sufficient?
            // Safer to look up the Stripe Coupon ID from our internal DB
            const couponDoc = await admin.firestore().collection('coupons').doc(couponId).get();
            if (couponDoc.exists) {
                const stripeCouponId = (_b = couponDoc.data()) === null || _b === void 0 ? void 0 : _b.stripeCouponId;
                if (stripeCouponId) {
                    sessionParams.discounts = [{ coupon: stripeCouponId }];
                }
            }
        }
        if (mode === 'payment') {
            sessionParams.mode = 'payment';
            sessionParams.metadata = Object.assign(Object.assign({}, sessionParams.metadata), { type: 'one_time_service' });
            if (serviceId)
                sessionParams.metadata.serviceId = serviceId;
            if (vehicleId)
                sessionParams.metadata.vehicleId = vehicleId;
            if (scheduledTime)
                sessionParams.metadata.scheduledTime = scheduledTime;
        }
        else {
            sessionParams.mode = 'subscription';
        }
        const session = await stripe.checkout.sessions.create(sessionParams);
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
 * Creates a Payment Intent specifically for Pix payments.
 * Returns the client secret to be used in the frontend.
 */
exports.createPixPaymentIntent = (0, https_1.onCall)({ secrets: [exports.stripeSecret], cors: true }, async (request) => {
    var _a;
    // 1. Authentication Check
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const { amount, description } = request.data;
    const userId = request.auth.uid;
    const userEmail = request.auth.token.email;
    // 2. Input Validation
    if (!amount || isNaN(amount) || amount <= 0) {
        throw new https_1.HttpsError("invalid-argument", "The function must be called with a valid positive amount (in cents).");
    }
    try {
        const stripe = (0, exports.getStripe)();
        // 3. Get or Create Stripe Customer
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
                    shouldCreateCustomer = true;
                }
            }
            catch (error) {
                shouldCreateCustomer = true;
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
        // 4. Create Payment Intent for Pix
        const paymentIntent = await stripe.paymentIntents.create({
            amount: Math.round(amount),
            currency: 'brl',
            payment_method_types: ['pix'],
            customer: customerId,
            description: description || `Pix Payment for user ${userId}`,
            metadata: {
                firebaseUID: userId,
                type: 'pix_payment'
            },
        });
        // 5. Return Client Secret
        return {
            clientSecret: paymentIntent.client_secret,
            id: paymentIntent.id,
        };
    }
    catch (error) {
        console.error("Error creating Pix payment intent:", error);
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const message = error.message || "Unknown error";
        throw new https_1.HttpsError("internal", message);
    }
});
/**
 * Creates a PIX Payment Intent for subscription first payment.
 * This creates a PaymentIntent with PIX method and pre-registers the subscription.
 */
exports.createSubscriptionPixPayment = (0, https_1.onCall)({ secrets: [exports.stripeSecret, exports.stripePublishableKey], cors: true }, async (request) => {
    var _a;
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
                    shouldCreateCustomer = true;
                }
            }
            catch (error) {
                shouldCreateCustomer = true;
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
        // 2. Get price details to determine amount
        const price = await stripe.prices.retrieve(priceId);
        let amount = price.unit_amount || 0;
        // 3. Apply coupon discount if provided
        let discountAmount = 0;
        let stripeCouponId = null;
        if (couponId) {
            const couponDoc = await admin.firestore()
                .collection("coupons")
                .doc(couponId)
                .get();
            if (couponDoc.exists) {
                const couponData = couponDoc.data();
                stripeCouponId = couponData === null || couponData === void 0 ? void 0 : couponData.stripeCouponId;
                // Calculate discount
                if ((couponData === null || couponData === void 0 ? void 0 : couponData.type) === 'percentage') {
                    discountAmount = Math.round(amount * (couponData.value / 100));
                }
                else {
                    discountAmount = Math.round(((couponData === null || couponData === void 0 ? void 0 : couponData.value) || 0) * 100); // Convert to cents
                }
                amount = Math.max(amount - discountAmount, 0);
            }
        }
        // 4. Create Payment Intent for PIX
        const paymentIntent = await stripe.paymentIntents.create({
            amount: amount,
            currency: 'brl',
            payment_method_types: ['pix'],
            customer: customerId,
            description: `Assinatura via PIX`,
            metadata: {
                firebaseUID: userId,
                type: 'pix_subscription',
                priceId: priceId,
                couponId: couponId || '',
            },
        });
        // 5. Pre-register subscription in Firestore as pending
        const subscriptionsSnapshot = await admin.firestore()
            .collection("subscriptions")
            .where("userId", "==", userId)
            .limit(1)
            .get();
        const subData = {
            userId: userId,
            planId: priceId,
            status: "pending_pix",
            stripeCustomerId: customerId,
            pixPaymentIntentId: paymentIntent.id,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };
        if (!subscriptionsSnapshot.empty) {
            const existingDoc = subscriptionsSnapshot.docs[0];
            await existingDoc.ref.update(subData);
        }
        else {
            await admin.firestore().collection("subscriptions").add(Object.assign(Object.assign({}, subData), { startDate: new Date(), createdAt: admin.firestore.FieldValue.serverTimestamp() }));
        }
        // 6. Increment coupon usage if used
        if (couponId && stripeCouponId) {
            await admin.firestore()
                .collection("coupons")
                .doc(couponId)
                .update({
                usedCount: admin.firestore.FieldValue.increment(1),
            });
        }
        return {
            clientSecret: paymentIntent.client_secret,
            paymentIntentId: paymentIntent.id,
            publishableKey: exports.stripePublishableKey.value(),
            amount: amount,
            originalAmount: price.unit_amount,
            discountAmount: discountAmount,
        };
    }
    catch (error) {
        console.error("Error creating PIX subscription payment:", error);
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
exports.createPaymentSheet = (0, https_1.onCall)({ secrets: [exports.stripeSecret, exports.stripePublishableKey], cors: true }, async (request) => {
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
                        publishableKey: exports.stripePublishableKey.value(),
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
            publishableKey: exports.stripePublishableKey.value(),
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
    // ... (existing code)
    try {
        switch (event.type) {
            case "customer.subscription.created":
            case "customer.subscription.updated":
            case "customer.subscription.deleted":
                await handleSubscriptionUpdate(event.data.object);
                break;
            case "checkout.session.completed": {
                const session = event.data.object;
                // Check if it's a subscription or one-time payment
                if (session.mode === "subscription") {
                    if (session.subscription) {
                        const subscriptionId = typeof session.subscription === "string" ?
                            session.subscription :
                            session.subscription.id;
                        const stripe = (0, exports.getStripe)();
                        const sub = await stripe.subscriptions.retrieve(subscriptionId);
                        await handleSubscriptionUpdate(sub);
                    }
                }
                else if (session.mode === "payment") {
                    // Handle one-time payment fulfillment
                    await (0, orders_1.fulfillCheckout)(session);
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
        // Rule 1: Minimum period before downgrade (30 days after last upgrade)
        const MINIMUM_UPGRADE_PERIOD_DAYS = 30;
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
/**
 * Admin: Pause a subscription (stops billing but keeps subscription)
 */
exports.adminPauseSubscription = (0, https_1.onCall)({ secrets: [exports.stripeSecret], cors: true }, async (request) => {
    var _a, _b;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Must be authenticated.");
    }
    // Verify admin role
    const adminDoc = await admin.firestore()
        .collection("users")
        .doc(request.auth.uid)
        .get();
    if (((_a = adminDoc.data()) === null || _a === void 0 ? void 0 : _a.role) !== "admin") {
        throw new https_1.HttpsError("permission-denied", "Only admins can manage subscriptions.");
    }
    const { userId } = request.data;
    if (!userId) {
        throw new https_1.HttpsError("invalid-argument", "userId is required.");
    }
    try {
        const stripe = (0, exports.getStripe)();
        // Get subscription from Firestore
        const subDoc = await admin.firestore()
            .collection("subscriptions")
            .doc(userId)
            .get();
        if (!subDoc.exists) {
            throw new https_1.HttpsError("not-found", "Subscription not found.");
        }
        const stripeSubId = (_b = subDoc.data()) === null || _b === void 0 ? void 0 : _b.stripeSubscriptionId;
        if (!stripeSubId) {
            throw new https_1.HttpsError("failed-precondition", "No Stripe subscription ID found.");
        }
        // Pause subscription in Stripe
        await stripe.subscriptions.update(stripeSubId, {
            pause_collection: { behavior: "void" },
        });
        // Update Firestore
        await subDoc.ref.update({
            status: "paused",
            pausedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`Subscription paused for user ${userId}`);
        return { success: true, message: "Subscription paused successfully." };
    }
    catch (error) {
        console.error("Error pausing subscription:", error);
        const message = error.message || "Unknown error";
        throw new https_1.HttpsError("internal", message);
    }
});
/**
 * Admin: Cancel a subscription
 */
exports.adminCancelSubscription = (0, https_1.onCall)({ secrets: [exports.stripeSecret], cors: true }, async (request) => {
    var _a, _b;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Must be authenticated.");
    }
    // Verify admin role
    const adminDoc = await admin.firestore()
        .collection("users")
        .doc(request.auth.uid)
        .get();
    if (((_a = adminDoc.data()) === null || _a === void 0 ? void 0 : _a.role) !== "admin") {
        throw new https_1.HttpsError("permission-denied", "Only admins can manage subscriptions.");
    }
    const { userId, cancelAtPeriodEnd } = request.data;
    if (!userId) {
        throw new https_1.HttpsError("invalid-argument", "userId is required.");
    }
    try {
        const stripe = (0, exports.getStripe)();
        // Get subscription from Firestore
        const subDoc = await admin.firestore()
            .collection("subscriptions")
            .doc(userId)
            .get();
        if (!subDoc.exists) {
            throw new https_1.HttpsError("not-found", "Subscription not found.");
        }
        const stripeSubId = (_b = subDoc.data()) === null || _b === void 0 ? void 0 : _b.stripeSubscriptionId;
        if (!stripeSubId) {
            throw new https_1.HttpsError("failed-precondition", "No Stripe subscription ID found.");
        }
        if (cancelAtPeriodEnd) {
            // Cancel at end of billing period
            await stripe.subscriptions.update(stripeSubId, {
                cancel_at_period_end: true,
            });
        }
        else {
            // Cancel immediately
            await stripe.subscriptions.cancel(stripeSubId);
        }
        // Update Firestore
        await subDoc.ref.update({
            status: "canceled",
            canceledAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`Subscription canceled for user ${userId}`);
        return { success: true, message: "Subscription canceled successfully." };
    }
    catch (error) {
        console.error("Error canceling subscription:", error);
        const message = error.message || "Unknown error";
        throw new https_1.HttpsError("internal", message);
    }
});
/**
 * Admin: Resume a paused subscription
 */
exports.adminResumeSubscription = (0, https_1.onCall)({ secrets: [exports.stripeSecret], cors: true }, async (request) => {
    var _a, _b;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Must be authenticated.");
    }
    // Verify admin role
    const adminDoc = await admin.firestore()
        .collection("users")
        .doc(request.auth.uid)
        .get();
    if (((_a = adminDoc.data()) === null || _a === void 0 ? void 0 : _a.role) !== "admin") {
        throw new https_1.HttpsError("permission-denied", "Only admins can manage subscriptions.");
    }
    const { userId } = request.data;
    if (!userId) {
        throw new https_1.HttpsError("invalid-argument", "userId is required.");
    }
    try {
        const stripe = (0, exports.getStripe)();
        // Get subscription from Firestore
        const subDoc = await admin.firestore()
            .collection("subscriptions")
            .doc(userId)
            .get();
        if (!subDoc.exists) {
            throw new https_1.HttpsError("not-found", "Subscription not found.");
        }
        const stripeSubId = (_b = subDoc.data()) === null || _b === void 0 ? void 0 : _b.stripeSubscriptionId;
        if (!stripeSubId) {
            throw new https_1.HttpsError("failed-precondition", "No Stripe subscription ID found.");
        }
        // Resume subscription in Stripe (remove pause)
        await stripe.subscriptions.update(stripeSubId, {
            pause_collection: null,
        });
        // Update Firestore
        await subDoc.ref.update({
            status: "active",
            resumedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`Subscription resumed for user ${userId}`);
        return { success: true, message: "Subscription resumed successfully." };
    }
    catch (error) {
        console.error("Error resuming subscription:", error);
        const message = error.message || "Unknown error";
        throw new https_1.HttpsError("internal", message);
    }
});
/**
 * Gets list of Stripe subscriptions for admin financial reports.
 * Requires admin role.
 */
exports.getStripeSubscriptions = (0, https_1.onCall)({ secrets: [exports.stripeSecret], cors: true }, async (request) => {
    var _a;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    // Check admin role
    const userDoc = await admin.firestore()
        .collection("users")
        .doc(request.auth.uid)
        .get();
    if (!userDoc.exists || ((_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a.role) !== "admin") {
        throw new https_1.HttpsError("permission-denied", "Only admins can access this function.");
    }
    const { status, limit = 100, startingAfter } = request.data;
    try {
        const stripe = (0, exports.getStripe)();
        const params = {
            limit: Math.min(limit, 100),
            expand: ["data.customer"],
        };
        if (status) {
            params.status = status;
        }
        if (startingAfter) {
            params.starting_after = startingAfter;
        }
        const subscriptions = await stripe.subscriptions.list(params);
        const formattedSubs = subscriptions.data.map((sub) => {
            var _a;
            const customer = sub.customer;
            const priceItem = sub.items.data[0];
            const price = priceItem === null || priceItem === void 0 ? void 0 : priceItem.price;
            // Use type assertion for properties that exist at runtime
            const subAny = sub;
            return {
                id: sub.id,
                customerId: (customer === null || customer === void 0 ? void 0 : customer.id) || sub.customer,
                customerEmail: (customer === null || customer === void 0 ? void 0 : customer.email) || null,
                customerName: (customer === null || customer === void 0 ? void 0 : customer.name) || null,
                status: sub.status,
                amount: ((price === null || price === void 0 ? void 0 : price.unit_amount) || 0) / 100,
                currency: (price === null || price === void 0 ? void 0 : price.currency) || "brl",
                interval: ((_a = price === null || price === void 0 ? void 0 : price.recurring) === null || _a === void 0 ? void 0 : _a.interval) || "month",
                currentPeriodStart: subAny.current_period_start,
                currentPeriodEnd: subAny.current_period_end,
                canceledAt: sub.canceled_at,
                createdAt: sub.created,
            };
        });
        return {
            subscriptions: formattedSubs,
            hasMore: subscriptions.has_more,
            lastId: formattedSubs.length > 0
                ? formattedSubs[formattedSubs.length - 1].id
                : null,
        };
    }
    catch (error) {
        console.error("Error fetching subscriptions:", error);
        const message = error.message || "Unknown error";
        throw new https_1.HttpsError("internal", message);
    }
});
/**
 * Gets list of Stripe transactions (charges/invoices) for admin financial reports.
 * Requires admin role.
 */
exports.getStripeTransactions = (0, https_1.onCall)({ secrets: [exports.stripeSecret], cors: true }, async (request) => {
    var _a;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    // Check admin role
    const userDoc = await admin.firestore()
        .collection("users")
        .doc(request.auth.uid)
        .get();
    if (!userDoc.exists || ((_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a.role) !== "admin") {
        throw new https_1.HttpsError("permission-denied", "Only admins can access this function.");
    }
    const { startDate, endDate, limit = 100, startingAfter } = request.data;
    try {
        const stripe = (0, exports.getStripe)();
        const params = {
            limit: Math.min(limit, 100),
            expand: ["data.customer"],
        };
        if (startDate) {
            params.created = params.created || {};
            params.created.gte = Math.floor(new Date(startDate).getTime() / 1000);
        }
        if (endDate) {
            params.created = params.created || {};
            params.created.lte = Math.floor(new Date(endDate).getTime() / 1000);
        }
        if (startingAfter) {
            params.starting_after = startingAfter;
        }
        const charges = await stripe.charges.list(params);
        const formattedTransactions = charges.data.map((charge) => {
            var _a;
            const customer = charge.customer;
            return {
                id: charge.id,
                customerId: (customer === null || customer === void 0 ? void 0 : customer.id) || charge.customer || null,
                customerEmail: (customer === null || customer === void 0 ? void 0 : customer.email) || ((_a = charge.billing_details) === null || _a === void 0 ? void 0 : _a.email) || null,
                amount: charge.amount / 100,
                currency: charge.currency,
                status: charge.status,
                description: charge.description,
                createdAt: charge.created,
                paid: charge.paid,
                refunded: charge.refunded,
                receiptUrl: charge.receipt_url,
            };
        });
        return {
            transactions: formattedTransactions,
            hasMore: charges.has_more,
            lastId: formattedTransactions.length > 0
                ? formattedTransactions[formattedTransactions.length - 1].id
                : null,
        };
    }
    catch (error) {
        console.error("Error fetching transactions:", error);
        const message = error.message || "Unknown error";
        throw new https_1.HttpsError("internal", message);
    }
});
/**
 * Admin: Adjust bonus washes for a subscriber.
 * Bonus washes are added to the plan's washesPerMonth limit.
 * This allows admins to grant extra washes without changing the plan.
 */
exports.adminAdjustBonusWashes = (0, https_1.onCall)({ cors: true }, async (request) => {
    var _a;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Must be authenticated.");
    }
    // Verify admin role
    const adminDoc = await admin.firestore()
        .collection("users")
        .doc(request.auth.uid)
        .get();
    if (((_a = adminDoc.data()) === null || _a === void 0 ? void 0 : _a.role) !== "admin") {
        throw new https_1.HttpsError("permission-denied", "Only admins can adjust bonus washes.");
    }
    const { userId, bonusWashes } = request.data;
    if (!userId) {
        throw new https_1.HttpsError("invalid-argument", "userId is required.");
    }
    if (typeof bonusWashes !== "number" || bonusWashes < 0) {
        throw new https_1.HttpsError("invalid-argument", "bonusWashes must be a non-negative number.");
    }
    try {
        // Find subscription for this user
        const subsQuery = await admin.firestore()
            .collection("subscriptions")
            .where("userId", "==", userId)
            .limit(1)
            .get();
        if (subsQuery.empty) {
            throw new https_1.HttpsError("not-found", "No subscription found for this user.");
        }
        const subDoc = subsQuery.docs[0];
        const previousBonusWashes = subDoc.data().bonusWashes || 0;
        // Update bonus washes
        await subDoc.ref.update({
            bonusWashes: bonusWashes,
            bonusWashesUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
            bonusWashesUpdatedBy: request.auth.uid,
        });
        console.log(`Bonus washes adjusted for user ${userId}: ${previousBonusWashes} -> ${bonusWashes}`);
        return {
            success: true,
            message: `Lavagens bônus atualizadas de ${previousBonusWashes} para ${bonusWashes}.`,
            previousBonusWashes,
            newBonusWashes: bonusWashes,
        };
    }
    catch (error) {
        if (error instanceof https_1.HttpsError)
            throw error;
        console.error("Error adjusting bonus washes:", error);
        const message = error.message || "Unknown error";
        throw new https_1.HttpsError("internal", message);
    }
});
/**
 * Admin: Grant premium days to a non-subscriber
 * Creates a promotional subscription without Stripe billing
 */
exports.adminGrantPremiumDays = (0, https_1.onCall)({ cors: true }, async (request) => {
    var _a, _b, _c;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Must be authenticated.");
    }
    // Verify admin role
    const adminDoc = await admin.firestore()
        .collection("users")
        .doc(request.auth.uid)
        .get();
    if (((_a = adminDoc.data()) === null || _a === void 0 ? void 0 : _a.role) !== "admin") {
        throw new https_1.HttpsError("permission-denied", "Only admins can grant premium days.");
    }
    const { userId, days } = request.data;
    if (!userId) {
        throw new https_1.HttpsError("invalid-argument", "userId is required.");
    }
    if (typeof days !== "number" || days <= 0) {
        throw new https_1.HttpsError("invalid-argument", "days must be a positive number.");
    }
    try {
        // Check if user already has a subscription
        const subsQuery = await admin.firestore()
            .collection("subscriptions")
            .where("userId", "==", userId)
            .limit(1)
            .get();
        const now = new Date();
        const endDate = new Date(now.getTime() + days * 24 * 60 * 60 * 1000);
        if (!subsQuery.empty) {
            // User has existing subscription - extend it or update
            const subDoc = subsQuery.docs[0];
            const currentEndDate = ((_c = (_b = subDoc.data().endDate) === null || _b === void 0 ? void 0 : _b.toDate) === null || _c === void 0 ? void 0 : _c.call(_b)) || now;
            const newEndDate = currentEndDate > now
                ? new Date(currentEndDate.getTime() + days * 24 * 60 * 60 * 1000)
                : endDate;
            await subDoc.ref.update({
                status: "active",
                endDate: newEndDate,
                type: "promo",
                promoGrantedAt: admin.firestore.FieldValue.serverTimestamp(),
                promoGrantedBy: request.auth.uid,
                promoDaysGranted: admin.firestore.FieldValue.increment(days),
            });
            console.log(`Extended subscription for user ${userId}: +${days} days until ${newEndDate.toISOString()}`);
        }
        else {
            // Create new promotional subscription
            await admin.firestore().collection("subscriptions").add({
                userId: userId,
                planId: "promo-admin",
                status: "active",
                type: "promo",
                startDate: now,
                endDate: endDate,
                promoGrantedAt: admin.firestore.FieldValue.serverTimestamp(),
                promoGrantedBy: request.auth.uid,
                promoDaysGranted: days,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            console.log(`Created promo subscription for user ${userId}: ${days} days until ${endDate.toISOString()}`);
        }
        return {
            success: true,
            message: `Premium concedido por ${days} dias.`,
            endDate: endDate.toISOString(),
        };
    }
    catch (error) {
        if (error instanceof https_1.HttpsError)
            throw error;
        console.error("Error granting premium days:", error);
        const message = error.message || "Unknown error";
        throw new https_1.HttpsError("internal", message);
    }
});
/**
 * Creates a Payment Intent for independent service bookings.
 * Returns the client secret and publishable key for the Flutter app.
 */
exports.createServicePaymentIntent = (0, https_1.onCall)({ secrets: [exports.stripeSecret, exports.stripePublishableKey], cors: true }, async (request) => {
    var _a;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const userId = request.auth.uid;
    const { serviceId, amount, serviceName } = request.data;
    if (!serviceId || !amount) {
        throw new https_1.HttpsError("invalid-argument", "serviceId and amount are required.");
    }
    try {
        const stripe = (0, exports.getStripe)();
        // Get or create Stripe customer
        const userDoc = await admin.firestore()
            .collection("users")
            .doc(userId)
            .get();
        let customerId = (_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a.stripeCustomerId;
        if (!customerId) {
            const userEmail = request.auth.token.email;
            const customer = await stripe.customers.create({
                email: userEmail,
                metadata: { firebaseUID: userId },
            });
            customerId = customer.id;
            await admin.firestore()
                .collection("users")
                .doc(userId)
                .update({ stripeCustomerId: customerId });
        }
        // Create ephemeral key
        const ephemeralKey = await stripe.ephemeralKeys.create({ customer: customerId }, { apiVersion: "2024-06-20" });
        // Create payment intent
        const paymentIntent = await stripe.paymentIntents.create({
            amount: amount,
            currency: "brl",
            customer: customerId,
            payment_method_types: ["card"],
            metadata: {
                firebaseUID: userId,
                serviceId: serviceId,
                serviceName: serviceName || "Serviço de Estética",
                type: "independent_service",
            },
        });
        console.log(`Created PaymentIntent ${paymentIntent.id} for service ${serviceId}`);
        return {
            paymentIntent: paymentIntent.client_secret,
            ephemeralKey: ephemeralKey.secret,
            customer: customerId,
            publishableKey: exports.stripePublishableKey.value(),
        };
    }
    catch (error) {
        console.error("Error creating service payment intent:", error);
        const message = error.message || "Unknown error";
        throw new https_1.HttpsError("internal", message);
    }
});
/**
 * Admin: Create subscription for a user manually using a Payment Method ID.
 * This is used when admin enters card details in the admin panel.
 */
exports.adminCreateSubscription = (0, https_1.onCall)({ secrets: [exports.stripeSecret], cors: true }, async (request) => {
    var _a, _b, _c, _d;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Must be authenticated.");
    }
    // Verify admin role
    const adminDoc = await admin.firestore()
        .collection("users")
        .doc(request.auth.uid)
        .get();
    if (((_a = adminDoc.data()) === null || _a === void 0 ? void 0 : _a.role) !== "admin") {
        throw new https_1.HttpsError("permission-denied", "Only admins can perform this action.");
    }
    const { userId, priceId, paymentMethodId } = request.data;
    if (!userId || !priceId || !paymentMethodId) {
        throw new https_1.HttpsError("invalid-argument", "Missing required parameters.");
    }
    try {
        const stripe = (0, exports.getStripe)();
        // 1. Get or Create Stripe Customer
        const userDoc = await admin.firestore()
            .collection("users")
            .doc(userId)
            .get();
        let customerId = (_b = userDoc.data()) === null || _b === void 0 ? void 0 : _b.stripeCustomerId;
        // Use email if available, otherwise just metadata
        const userEmail = (_c = userDoc.data()) === null || _c === void 0 ? void 0 : _c.email;
        if (!customerId) {
            const customer = await stripe.customers.create({
                email: userEmail,
                metadata: { firebaseUID: userId },
            });
            customerId = customer.id;
            await admin.firestore()
                .collection("users")
                .doc(userId)
                .update({ stripeCustomerId: customerId });
        }
        // 2. Attach Payment Method to Customer
        await stripe.paymentMethods.attach(paymentMethodId, {
            customer: customerId,
        });
        // 3. Set as Default Payment Method
        await stripe.customers.update(customerId, {
            invoice_settings: {
                default_payment_method: paymentMethodId,
            },
        });
        // 4. Create Subscription
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const subscriptionParams = {
            customer: customerId,
            items: [{ price: priceId }],
            expand: ['latest_invoice.payment_intent'],
            metadata: {
                firebaseUID: userId,
                createdBy: request.auth.uid,
                isManualAdmin: 'true'
            }
        };
        // Apply coupon if provided
        if (request.data.couponId) {
            console.log(`[Admin] Attempting to apply coupon ${request.data.couponId}`);
            const couponDoc = await admin.firestore()
                .collection("coupons")
                .doc(request.data.couponId)
                .get();
            if (!couponDoc.exists) {
                throw new https_1.HttpsError("not-found", `Coupon ${request.data.couponId} not found.`);
            }
            const stripeCouponId = (_d = couponDoc.data()) === null || _d === void 0 ? void 0 : _d.stripeCouponId;
            if (!stripeCouponId) {
                console.error(`[Admin] Coupon ${request.data.couponId} missing stripeCouponId`);
                throw new https_1.HttpsError("failed-precondition", "Coupon is missing Stripe ID.");
            }
            subscriptionParams.discounts = [{ coupon: stripeCouponId }];
            console.log(`[Admin] Applied coupon ${stripeCouponId} to subscription`);
            // Increment coupon usage count
            await admin.firestore()
                .collection("coupons")
                .doc(request.data.couponId)
                .update({
                usedCount: admin.firestore.FieldValue.increment(1),
            });
        }
        const subscription = await stripe.subscriptions.create(subscriptionParams);
        // CRITICAL: Immediately create/update Firestore subscription document
        const subscriptionsSnapshot = await admin.firestore()
            .collection("subscriptions")
            .where("userId", "==", userId)
            .limit(1)
            .get();
        // Use the actual status from the created subscription
        const status = subscription.status;
        console.log(`[Admin] Stripe subscription created. Status: ${status}, ID: ${subscription.id}`);
        if (status !== 'active' && status !== 'trialing') {
            console.warn(`[Admin] Subscription created but not active/trialing. Status: ${status}`);
            // Consider aborting or flagging? For now just log.
        }
        const subData = {
            userId: userId,
            planId: priceId,
            status: status === 'active' || status === 'trialing' ? 'active' : status,
            stripeSubscriptionId: subscription.id,
            stripeCustomerId: customerId,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            // If active, set start date now (or use subscription.current_period_start)
            startDate: new Date(),
            endDate: new Date(subscription.current_period_end * 1000)
        };
        if (!subscriptionsSnapshot.empty) {
            const existingDoc = subscriptionsSnapshot.docs[0];
            await existingDoc.ref.update(subData);
            console.log(`[Admin] Updated existing subscription doc for user ${userId}`);
        }
        else {
            await admin.firestore().collection("subscriptions").add(Object.assign(Object.assign({}, subData), { createdAt: admin.firestore.FieldValue.serverTimestamp() }));
            console.log(`[Admin] Created new subscription doc for user ${userId}`);
        }
        return {
            success: true,
            subscriptionId: subscription.id,
            status: subscription.status,
        };
    }
    catch (error) {
        console.error("Error creating subscription:", error);
        const message = error.message || "Unknown error";
        const code = error.code || "unknown_code";
        const type = error.type || "unknown_type";
        // Return detailed error to client
        throw new https_1.HttpsError("aborted", `Stripe Error [${type}/${code}]: ${message}`);
    }
});
/**
 * Retrieves detailed subscription information, including payment method.
 */
exports.getSubscriptionDetails = (0, https_1.onCall)({ secrets: [exports.stripeSecret], cors: true }, async (request) => {
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
        // Get subscription from Firestore to verify ownership and get stripeSubscriptionId
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
 * Used to display payment history in the subscription management screen.
 */
exports.getSubscriptionInvoices = (0, https_1.onCall)({ secrets: [exports.stripeSecret], cors: true }, async (request) => {
    var _a;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const userId = request.auth.uid;
    try {
        const stripe = (0, exports.getStripe)();
        // 1. Get user's Stripe customer ID
        const userDoc = await admin.firestore()
            .collection("users")
            .doc(userId)
            .get();
        const customerId = (_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a.stripeCustomerId;
        if (!customerId) {
            // No customer ID means no invoices yet
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
        // 3. Fetch ALL invoices from Stripe (not filtered by status)
        // This ensures we get both the initial subscription invoice and renewals
        const invoices = await stripe.invoices.list({
            customer: customerId,
            limit: 24,
            expand: ['data.charge'],
        });
        // 4. Map to simplified format - include paid and open invoices
        const allInvoices = invoices.data.filter(inv => inv.status === 'paid' || inv.status === 'open');
        // Sort by created date descending
        allInvoices.sort((a, b) => b.created - a.created);
        const mappedInvoices = allInvoices.map((invoice) => {
            var _a;
            // Try to get payment method details from the charge
            let paymentMethodBrand = null;
            let paymentMethodLast4 = null;
            // invoice.charge is expanded, cast to any for access
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
//# sourceMappingURL=stripe.js.map