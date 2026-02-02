"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createServicePaymentIntent = exports.createSubscriptionPixPayment = exports.createPixPaymentIntent = void 0;
const admin = require("firebase-admin");
const https_1 = require("firebase-functions/v2/https");
const env_1 = require("../../../config/env");
const stripe_1 = require("../helpers/stripe");
/**
 * Creates a Payment Intent specifically for Pix payments.
 * Returns the client secret to be used in the frontend.
 */
exports.createPixPaymentIntent = (0, https_1.onCall)({ secrets: [env_1.stripeSecret], cors: true }, async (request) => {
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
        const stripe = await (0, stripe_1.getStripe)();
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
            amount: Math.round(amount), // Ensure integer
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
exports.createSubscriptionPixPayment = (0, https_1.onCall)({ secrets: [env_1.stripeSecret, env_1.stripePublishableKey], cors: true }, async (request) => {
    var _a;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const { priceId, couponId, vehiclePlate, vehicleId } = request.data;
    const userId = request.auth.uid;
    const userEmail = request.auth.token.email;
    if (!priceId) {
        throw new https_1.HttpsError("invalid-argument", "The function must be called with a priceId.");
    }
    // Check for vehicle plate requirement
    if (!vehiclePlate) {
        throw new https_1.HttpsError('invalid-argument', 'Placa do veículo é obrigatória.');
    }
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
                vehiclePlate: vehiclePlate || '',
                vehicleId: vehicleId || '',
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
            status: "pending_pix", // Will be updated when payment confirmed
            stripeCustomerId: customerId,
            pixPaymentIntentId: paymentIntent.id,
            linkedPlate: vehiclePlate, // Save linked plate
            vehicleId: vehicleId,
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
            // publishableKey: stripePublishableKey.value(), // Client should fetch this dynamically now
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
 * Creates a Payment Intent for independent service bookings.
 * Returns the client secret and publishable key for the Flutter app.
 */
exports.createServicePaymentIntent = (0, https_1.onCall)({ secrets: [env_1.stripeSecret, env_1.stripePublishableKey], cors: true }, async (request) => {
    var _a;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const userId = request.auth.uid;
    const { serviceId, amount, serviceName, 
    // Booking metadata for webhook to create booking automatically
    scheduledTime, vehicleId, vehiclePlate, vehicleModel, userName, userPhone, totalPrice, } = request.data;
    if (!serviceId || !amount) {
        throw new https_1.HttpsError("invalid-argument", "serviceId and amount are required.");
    }
    try {
        const stripe = await (0, stripe_1.getStripe)();
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
        const ephemeralKey = await stripe.ephemeralKeys.create({ customer: customerId }, { apiVersion: "2023-10-16" });
        // Create payment intent with booking metadata
        const paymentIntent = await stripe.paymentIntents.create({
            amount: Math.round(Number(amount)), // Ensure integer cents
            currency: "brl",
            customer: customerId,
            payment_method_types: ["card"],
            metadata: {
                firebaseUID: userId,
                serviceId: serviceId,
                serviceName: serviceName || "Serviço de Estética",
                type: "independent_service",
                // Booking data for webhook to create booking
                scheduledTime: scheduledTime || "",
                vehicleId: vehicleId || "",
                vehiclePlate: vehiclePlate || "",
                vehicleModel: vehicleModel || "",
                userName: userName || "",
                userPhone: userPhone || "",
                totalPrice: String(totalPrice || 0),
            },
        });
        console.log(`Created PaymentIntent ${paymentIntent.id} for service ${serviceId} scheduled at ${scheduledTime}`);
        const publishableKey = await (0, stripe_1.getStripePublishableKey)();
        return {
            paymentIntent: paymentIntent.client_secret,
            ephemeralKey: ephemeralKey.secret,
            customer: customerId,
            publishableKey: publishableKey,
        };
    }
    catch (error) {
        console.error("Error creating service payment intent:", error);
        const message = error.message || "Unknown error";
        throw new https_1.HttpsError("internal", message);
    }
});
//# sourceMappingURL=pix.js.map