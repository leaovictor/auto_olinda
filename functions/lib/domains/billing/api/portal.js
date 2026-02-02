"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createPortalSession = void 0;
const https_1 = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const env_1 = require("../../../config/env");
const stripe_1 = require("../helpers/stripe");
exports.createPortalSession = (0, https_1.onCall)({ secrets: [env_1.stripeSecret], cors: true }, async (request) => {
    var _a, _b, _c;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const { returnUrl } = request.data;
    const userId = request.auth.uid;
    const tenantId = request.auth.token.tenantId; // Custom claim if verified
    // If no tenantId in token, maybe look up user profile?
    // for MVP assuming admin/owner context has tenantId
    if (!tenantId) {
        // Check if user is owner of a tenant
        const userDoc = await admin.firestore().collection('users').doc(userId).get();
        const userTenantId = (_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a.tenantId;
        if (!userTenantId) {
            throw new https_1.HttpsError("failed-precondition", "User is not linked to a tenant.");
        }
        // Verify role if needed
    }
    try {
        const stripe = await (0, stripe_1.getStripe)();
        // Get Tenant to find Customer ID
        // CAUTION: This assumes the USER is managing the TENANT'S subscription
        // Depending on architecture, might need to fetch the Tenant Doc
        const docId = tenantId || ((_b = (await admin.firestore().collection('users').doc(userId).get()).data()) === null || _b === void 0 ? void 0 : _b.tenantId);
        const tenantDoc = await admin.firestore().collection('tenants').doc(docId).get();
        if (!tenantDoc.exists) {
            throw new https_1.HttpsError("not-found", "Tenant not found.");
        }
        const stripeCustomerId = (_c = tenantDoc.data()) === null || _c === void 0 ? void 0 : _c.stripeCustomerId;
        if (!stripeCustomerId) {
            throw new https_1.HttpsError("failed-precondition", "Tenant has no Stripe Customer ID.");
        }
        const session = await stripe.billingPortal.sessions.create({
            customer: stripeCustomerId,
            return_url: returnUrl || 'https://dashboard.lavaflow.app',
        });
        return { url: session.url };
    }
    catch (error) {
        console.error("Error creating portal session:", error);
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const message = error.message || "Unknown error";
        throw new https_1.HttpsError("internal", message);
    }
});
//# sourceMappingURL=portal.js.map