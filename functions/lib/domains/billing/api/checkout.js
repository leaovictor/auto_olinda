"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createCheckoutSession = void 0;
const admin = require("firebase-admin");
const https_1 = require("firebase-functions/v2/https");
const env_1 = require("../../../config/env");
const stripe_1 = require("../helpers/stripe");
/**
 * Creates a Stripe Checkout Session for a subscription or one-time payment.
 * Supports dynamic pricing for services based on active subscription logic.
 */
exports.createCheckoutSession = (0, https_1.onCall)({ secrets: [env_1.stripeSecret], cors: true }, async (request) => {
    var _a, _b;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const { priceId, mode = 'subscription', successUrl, cancelUrl, couponId, serviceId, items, vehicleId, vehiclePlate, // injected from frontend
    vehicleCategory, // injected from frontend
    scheduledTime } = request.data;
    const userId = request.auth.uid;
    const userEmail = request.auth.token.email;
    if (!priceId && (!items || items.length === 0)) {
        throw new https_1.HttpsError("invalid-argument", "The function must be called with a priceId or a list of items.");
    }
    // --- REFACTOR START: Category Validation & Anti-Fraud ---
    if (mode === 'subscription') {
        if (!vehiclePlate) {
            throw new https_1.HttpsError('invalid-argument', 'A placa do veículo é obrigatória para assinar.');
        }
        // 1. Validate Category
        await (0, stripe_1.validatePlanCategory)(priceId, vehicleCategory);
        // 2. Check if plate is already linked to an active subscription
        // Use a transaction or simpler query for now (Firebase Transactions for strictness)
        const existingSub = await admin.firestore()
            .collection('subscriptions')
            .where('linkedPlate', '==', vehiclePlate)
            .where('status', 'in', ['active', 'trialing'])
            .limit(1)
            .get();
        if (!existingSub.empty) {
            // Check if it's the same user (maybe upgrading?)
            const sub = existingSub.docs[0].data();
            if (sub.userId !== userId) {
                throw new https_1.HttpsError('already-exists', `O veículo de placa ${vehiclePlate} já possui uma assinatura ativa em outra conta.`);
            }
        }
    }
    // --- REFACTOR END ---
    try {
        const stripe = await (0, stripe_1.getStripe)();
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
                // Inject Vehicle Data into Metadata
                vehicleId: vehicleId || '',
                vehiclePlate: vehiclePlate || '',
                vehicleCategory: vehicleCategory || '',
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
            if (scheduledTime)
                sessionParams.metadata.scheduledTime = scheduledTime;
        }
        else {
            sessionParams.mode = 'subscription';
            // Ensure plate is in subscription metadata as well (for webhook)
            sessionParams.subscription_data = {
                metadata: {
                    firebaseUID: userId,
                    vehiclePlate: vehiclePlate || '',
                    vehicleId: vehicleId || '',
                    vehicleCategory: vehicleCategory || '',
                }
            };
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
//# sourceMappingURL=checkout.js.map