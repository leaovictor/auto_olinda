"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validatePlanCategory = exports.getStripePublishableKey = exports.getStripe = exports.getPaymentSettings = void 0;
const admin = require("firebase-admin");
const stripe_1 = require("stripe");
const https_1 = require("firebase-functions/v2/https");
const env_1 = require("../../../config/env");
const getPaymentSettings = async () => {
    const doc = await admin.firestore().collection('admin_settings').doc('payments').get();
    if (doc.exists) {
        return doc.data();
    }
    return null;
};
exports.getPaymentSettings = getPaymentSettings;
const getStripe = async () => {
    let secretKey = env_1.stripeSecret.value();
    // Try to get dynamic key
    try {
        const settings = await (0, exports.getPaymentSettings)();
        if (settings === null || settings === void 0 ? void 0 : settings.stripe_secret_key) {
            secretKey = settings.stripe_secret_key;
        }
    }
    catch (e) {
        console.warn("Failed to fetch dynamic Stripe keys, falling back to env vars", e);
    }
    if (!secretKey) {
        throw new Error("Stripe Secret Key not configured (neither in Firestore nor Env)");
    }
    return new stripe_1.default(secretKey, {
        apiVersion: "2023-10-16",
    });
};
exports.getStripe = getStripe;
const getStripePublishableKey = async () => {
    let publishableKey = env_1.stripePublishableKey.value();
    // Try to get dynamic key
    try {
        const settings = await (0, exports.getPaymentSettings)();
        if (settings === null || settings === void 0 ? void 0 : settings.stripe_publishable_key) {
            publishableKey = settings.stripe_publishable_key;
        }
    }
    catch (e) {
        console.warn("Failed to fetch dynamic Stripe keys, falling back to env vars", e);
    }
    return publishableKey;
};
exports.getStripePublishableKey = getStripePublishableKey;
/**
 * Validates if the selected plan is compatible with the vehicle category.
 * SUV cannot use Hatch plans.
 */
const validatePlanCategory = async (priceId, vehicleCategory) => {
    var _a;
    if (!vehicleCategory)
        return; // Skip if no category provided (legacy)
    // Normalize category
    const category = vehicleCategory.toLowerCase();
    // Fetch plan details from Firestore to get its allowed category
    // We assume plans have a 'category' or 'allowedCategories' field
    // or we infer from the name/metadata.
    // For this refactor, let's look up the plan document.
    const plansSnapshot = await admin.firestore()
        .collection('plans')
        .where('stripePriceId', '==', priceId)
        .limit(1)
        .get();
    if (plansSnapshot.empty) {
        console.warn(`Plan not found for priceId ${priceId}, skipping category validation.`);
        return;
    }
    const planData = plansSnapshot.docs[0].data();
    const planCategory = ((_a = planData.category) === null || _a === void 0 ? void 0 : _a.toLowerCase()) || 'any'; // hatchback, suv, motorcycle, any
    console.log(`Validating Plan: ${planCategory} vs Vehicle: ${category}`);
    if (category === 'suv' || category === 'pickup' || category === 'crossover') {
        // SUVs cannot use Hatch plans
        if (planCategory === 'hatch' || planCategory === 'hatchback' || planCategory === 'moto') {
            throw new https_1.HttpsError('invalid-argument', 'Veículos da categoria SUV/Pick-up não podem aderir a planos Hatch/Moto.');
        }
    }
};
exports.validatePlanCategory = validatePlanCategory;
//# sourceMappingURL=stripe.js.map