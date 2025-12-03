"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createUnifiedCheckoutSession = exports.getCouponUsage = exports.applyCoupon = exports.validateCoupon = exports.createStripeCoupon = exports.syncServiceWithStripe = exports.syncProductWithStripe = void 0;
const admin = require("firebase-admin");
const https_1 = require("firebase-functions/v2/https");
const stripe_1 = require("./stripe");
/**
 * Sync product with Stripe - creates/updates product and price
 */
exports.syncProductWithStripe = (0, https_1.onCall)({ secrets: [stripe_1.stripeSecret] }, async (request) => {
    var _a, _b;
    // Admin only
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Not authenticated.");
    }
    const { productId, name, description, price, imageUrl } = request.data;
    if (!productId || !name || price === undefined) {
        throw new https_1.HttpsError("invalid-argument", "productId, name, and price are required.");
    }
    const stripe = (0, stripe_1.getStripe)();
    try {
        const productDoc = await admin.firestore()
            .collection("products")
            .doc(productId)
            .get();
        if (!productDoc.exists) {
            throw new https_1.HttpsError("not-found", "Product not found.");
        }
        let stripeProductId = (_a = productDoc.data()) === null || _a === void 0 ? void 0 : _a.stripeProductId;
        let stripePriceId = (_b = productDoc.data()) === null || _b === void 0 ? void 0 : _b.stripePriceId;
        // Create or update Stripe product
        if (!stripeProductId) {
            const product = await stripe.products.create({
                name: name,
                description: description || "",
                images: imageUrl ? [imageUrl] : [],
                metadata: {
                    firebaseProductId: productId,
                },
            });
            stripeProductId = product.id;
        }
        else {
            await stripe.products.update(stripeProductId, {
                name: name,
                description: description || "",
                images: imageUrl ? [imageUrl] : [],
            });
        }
        // Create new price (prices are immutable in Stripe)
        const newPrice = await stripe.prices.create({
            product: stripeProductId,
            unit_amount: Math.round(price * 100),
            currency: "brl",
            metadata: {
                firebaseProductId: productId,
            },
        });
        // Archive old price if exists
        if (stripePriceId && stripePriceId !== newPrice.id) {
            try {
                await stripe.prices.update(stripePriceId, {
                    active: false,
                });
            }
            catch (error) {
                console.error("Error archiving old price:", error);
            }
        }
        stripePriceId = newPrice.id;
        // Update Firestore
        await productDoc.ref.update({
            stripeProductId: stripeProductId,
            stripePriceId: stripePriceId,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return {
            success: true,
            productId: stripeProductId,
            priceId: stripePriceId,
        };
    }
    catch (error) {
        console.error("Error syncing product with Stripe:", error);
        throw new https_1.HttpsError("internal", "Unable to sync product with Stripe.");
    }
});
/**
 * Sync service with Stripe - creates/updates product and price
 */
exports.syncServiceWithStripe = (0, https_1.onCall)({ secrets: [stripe_1.stripeSecret] }, async (request) => {
    var _a, _b;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Not authenticated.");
    }
    const { serviceId, name, description, price, imageUrl } = request.data;
    if (!serviceId || !name || price === undefined) {
        throw new https_1.HttpsError("invalid-argument", "serviceId, name, and price are required.");
    }
    const stripe = (0, stripe_1.getStripe)();
    try {
        const serviceDoc = await admin.firestore()
            .collection("services")
            .doc(serviceId)
            .get();
        if (!serviceDoc.exists) {
            throw new https_1.HttpsError("not-found", "Service not found.");
        }
        let stripeProductId = (_a = serviceDoc.data()) === null || _a === void 0 ? void 0 : _a.stripeProductId;
        let stripePriceId = (_b = serviceDoc.data()) === null || _b === void 0 ? void 0 : _b.stripePriceId;
        // Create or update Stripe product
        if (!stripeProductId) {
            const product = await stripe.products.create({
                name: name,
                description: description || "",
                images: imageUrl ? [imageUrl] : [],
                metadata: {
                    firebaseServiceId: serviceId,
                    type: "service",
                },
            });
            stripeProductId = product.id;
        }
        else {
            await stripe.products.update(stripeProductId, {
                name: name,
                description: description || "",
                images: imageUrl ? [imageUrl] : [],
            });
        }
        // Create new price
        const newPrice = await stripe.prices.create({
            product: stripeProductId,
            unit_amount: Math.round(price * 100),
            currency: "brl",
            metadata: {
                firebaseServiceId: serviceId,
            },
        });
        // Archive old price
        if (stripePriceId && stripePriceId !== newPrice.id) {
            try {
                await stripe.prices.update(stripePriceId, {
                    active: false,
                });
            }
            catch (error) {
                console.error("Error archiving old price:", error);
            }
        }
        stripePriceId = newPrice.id;
        // Update Firestore
        await serviceDoc.ref.update({
            stripeProductId: stripeProductId,
            stripePriceId: stripePriceId,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return {
            success: true,
            productId: stripeProductId,
            priceId: stripePriceId,
        };
    }
    catch (error) {
        console.error("Error syncing service with Stripe:", error);
        throw new https_1.HttpsError("internal", "Unable to sync service with Stripe.");
    }
});
/**
 * Create Stripe coupon
 */
exports.createStripeCoupon = (0, https_1.onCall)({ secrets: [stripe_1.stripeSecret] }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Not authenticated.");
    }
    const { couponId, code, type, value } = request.data;
    if (!couponId || !code || !type || value === undefined) {
        throw new https_1.HttpsError("invalid-argument", "couponId, code, type, and value are required.");
    }
    const stripe = (0, stripe_1.getStripe)();
    try {
        // Create Stripe coupon
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const couponData = {
            name: code.toUpperCase(),
            metadata: {
                firebaseCouponId: couponId,
            },
        };
        if (type === "percentage") {
            couponData.percent_off = value;
        }
        else {
            couponData.amount_off = Math.round(value * 100);
            couponData.currency = "brl";
        }
        const stripeCoupon = await stripe.coupons.create(couponData);
        // Update Firestore with Stripe ID
        await admin.firestore()
            .collection("coupons")
            .doc(couponId)
            .update({
            stripeCouponId: stripeCoupon.id,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return {
            success: true,
            stripeCouponId: stripeCoupon.id,
        };
    }
    catch (error) {
        console.error("Error creating Stripe coupon:", error);
        throw new https_1.HttpsError("internal", "Unable to create Stripe coupon.");
    }
});
/**
 * Validate coupon before checkout
 */
exports.validateCoupon = (0, https_1.onCall)(async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Not authenticated.");
    }
    const { code, applicableTo, amount } = request.data;
    if (!code || !applicableTo || amount === undefined) {
        throw new https_1.HttpsError("invalid-argument", "code, applicableTo, and amount are required.");
    }
    try {
        // Find coupon by code
        const couponSnapshot = await admin.firestore()
            .collection("coupons")
            .where("code", "==", code.toUpperCase())
            .where("isActive", "==", true)
            .limit(1)
            .get();
        if (couponSnapshot.empty) {
            return {
                valid: false,
                error: "Cupom não encontrado ou inativo.",
            };
        }
        const couponDoc = couponSnapshot.docs[0];
        const coupon = couponDoc.data();
        // Check validity
        const now = new Date();
        if (coupon.validFrom &&
            new Date(coupon.validFrom._seconds * 1000) > now) {
            return {
                valid: false,
                error: "Cupom ainda não está válido.",
            };
        }
        if (coupon.validUntil &&
            new Date(coupon.validUntil._seconds * 1000) < now) {
            return {
                valid: false,
                error: "Cupom expirado.",
            };
        }
        if (coupon.maxUses && coupon.usedCount >= coupon.maxUses) {
            return {
                valid: false,
                error: "Cupom atingiu o limite de uso.",
            };
        }
        if (!coupon.applicableTo.includes(applicableTo)) {
            return {
                valid: false,
                error: "Cupom não válido para este tipo de compra.",
            };
        }
        if (coupon.minimumPurchase && amount < coupon.minimumPurchase) {
            return {
                valid: false,
                error: "Valor mínimo de compra: R$ " +
                    coupon.minimumPurchase.toFixed(2),
            };
        }
        // Calculate discount
        let discount = 0;
        if (coupon.type === "percentage") {
            discount = amount * (coupon.value / 100);
        }
        else {
            discount = Math.min(coupon.value, amount);
        }
        return {
            valid: true,
            couponId: couponDoc.id,
            discount: discount,
            finalAmount: amount - discount,
        };
    }
    catch (error) {
        console.error("Error validating coupon:", error);
        throw new https_1.HttpsError("internal", "Unable to validate coupon.");
    }
});
/**
 * Apply coupon (increment usage count)
 */
exports.applyCoupon = (0, https_1.onCall)(async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Not authenticated.");
    }
    const { couponId } = request.data;
    if (!couponId) {
        throw new https_1.HttpsError("invalid-argument", "couponId is required.");
    }
    try {
        await admin.firestore()
            .collection("coupons")
            .doc(couponId)
            .update({
            usedCount: admin.firestore.FieldValue.increment(1),
        });
        return { success: true };
    }
    catch (error) {
        console.error("Error applying coupon:", error);
        throw new https_1.HttpsError("internal", "Unable to apply coupon.");
    }
});
/**
 * Get coupon usage statistics
 */
exports.getCouponUsage = (0, https_1.onCall)(async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Not authenticated.");
    }
    const { couponId } = request.data;
    if (!couponId) {
        throw new https_1.HttpsError("invalid-argument", "couponId is required.");
    }
    try {
        const couponDoc = await admin.firestore()
            .collection("coupons")
            .doc(couponId)
            .get();
        if (!couponDoc.exists) {
            throw new https_1.HttpsError("not-found", "Coupon not found.");
        }
        const coupon = couponDoc.data();
        return {
            code: coupon === null || coupon === void 0 ? void 0 : coupon.code,
            usedCount: (coupon === null || coupon === void 0 ? void 0 : coupon.usedCount) || 0,
            maxUses: coupon === null || coupon === void 0 ? void 0 : coupon.maxUses,
            isActive: coupon === null || coupon === void 0 ? void 0 : coupon.isActive,
        };
    }
    catch (error) {
        console.error("Error getting coupon usage:", error);
        throw new https_1.HttpsError("internal", "Unable to get coupon usage.");
    }
});
/**
 * Create Unified Checkout Session
 * Handles products, services, and subscriptions in a single cart.
 */
exports.createUnifiedCheckoutSession = (0, https_1.onCall)({ secrets: [stripe_1.stripeSecret] }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Not authenticated.");
    }
    const { items, couponCode, successUrl, cancelUrl } = request.data;
    // items: [{
    //   type: 'product'|'service'|'subscription',
    //   id: string,
    //   quantity: number
    // }]
    if (!items || !Array.isArray(items) || items.length === 0) {
        throw new https_1.HttpsError("invalid-argument", "Items array is required and cannot be empty.");
    }
    const stripe = (0, stripe_1.getStripe)();
    const lineItems = [];
    let hasSubscription = false;
    try {
        // 1. Build Line Items
        for (const item of items) {
            let collectionName = "";
            if (item.type === "product")
                collectionName = "products";
            else if (item.type === "service")
                collectionName = "services";
            else if (item.type === "subscription") {
                collectionName = "plans";
                hasSubscription = true;
            }
            else {
                throw new https_1.HttpsError("invalid-argument", `Invalid item type: ${item.type}`);
            }
            const doc = await admin.firestore()
                .collection(collectionName)
                .doc(item.id)
                .get();
            if (!doc.exists) {
                throw new https_1.HttpsError("not-found", `Item not found: ${item.id} (${item.type})`);
            }
            const data = doc.data();
            if (!(data === null || data === void 0 ? void 0 : data.stripePriceId)) {
                throw new https_1.HttpsError("failed-precondition", `Item ${data === null || data === void 0 ? void 0 : data.name} is not linked to Stripe.`);
            }
            lineItems.push({
                price: data.stripePriceId,
                quantity: item.quantity || 1,
            });
        }
        // 2. Prepare Session Params
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const sessionParams = {
            payment_method_types: ["card"],
            line_items: lineItems,
            mode: hasSubscription ? "subscription" : "payment",
            success_url: successUrl || "https://aquaclean.app/success",
            cancel_url: cancelUrl || "https://aquaclean.app/cancel",
            customer_email: request.auth.token.email,
            metadata: {
                userId: request.auth.uid,
                // eslint-disable-next-line @typescript-eslint/no-explicit-any
                items: JSON.stringify(items.map((i) => `${i.type}:${i.id}:${i.quantity}`)),
            },
        };
        // 3. Handle Coupon
        if (couponCode) {
            // Find coupon in Firestore to get Stripe Coupon ID
            const couponSnapshot = await admin.firestore()
                .collection("coupons")
                .where("code", "==", couponCode.toUpperCase())
                .limit(1)
                .get();
            if (!couponSnapshot.empty) {
                const couponData = couponSnapshot.docs[0].data();
                if (couponData.stripeCouponId) {
                    sessionParams.discounts = [{ coupon: couponData.stripeCouponId }];
                }
            }
        }
        // Allow promotion codes input in Checkout if no coupon applied
        // programmatically
        if (!sessionParams.discounts) {
            sessionParams.allow_promotion_codes = true;
        }
        // 4. Create Session
        const session = await stripe.checkout.sessions.create(sessionParams);
        return {
            sessionId: session.id,
            url: session.url,
        };
    }
    catch (error) {
        console.error("Error creating checkout session:", error);
        throw new https_1.HttpsError("internal", "Unable to create checkout session.");
    }
});
//# sourceMappingURL=ecommerce.js.map