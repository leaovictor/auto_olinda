"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.stripeWebhook = exports.createCheckoutSession = void 0;
const https_1 = require("firebase-functions/v2/https");
const https_2 = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const stripe_1 = require("stripe");
const params_1 = require("firebase-functions/params");
const stripeSecret = (0, params_1.defineSecret)("STRIPE_SECRET");
const getStripe = () => {
    return new stripe_1.default(stripeSecret.value(), {
    // apiVersion: "2023-10-16", // Let SDK choose default or configured version
    });
};
/**
 * Creates a Stripe Checkout Session for a subscription.
 */
exports.createCheckoutSession = (0, https_1.onCall)({ secrets: [stripeSecret] }, async (request) => {
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
    const stripe = getStripe();
    try {
        // 1. Get or Create Stripe Customer
        const userDoc = await admin.firestore().collection("users").doc(userId).get();
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
        throw new https_1.HttpsError("internal", "Unable to create checkout session.");
    }
});
/**
 * Stripe Webhook to handle events like subscription updates.
 */
exports.stripeWebhook = (0, https_2.onRequest)({ secrets: [stripeSecret] }, async (req, res) => {
    const sig = req.headers["stripe-signature"];
    const stripe = getStripe();
    let event;
    try {
        event = stripe.webhooks.constructEvent(req.rawBody, sig, stripeSecret.value());
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
async function handleSubscriptionUpdate(subscription) {
    const customerId = subscription.customer;
    const status = subscription.status;
    const priceId = subscription.items.data[0].price.id;
    // Find user by stripeCustomerId
    const usersSnapshot = await admin.firestore()
        .collection("users")
        .where("stripeCustomerId", "==", customerId)
        .limit(1)
        .get();
    if (usersSnapshot.empty) {
        console.error(`User with Stripe Customer ID ${customerId} not found.`);
        return;
    }
    const userDoc = usersSnapshot.docs[0];
    await userDoc.ref.update({
        subscriptionStatus: status,
        subscriptionPriceId: priceId,
        subscriptionId: subscription.id,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}
//# sourceMappingURL=stripe.js.map