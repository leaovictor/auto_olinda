"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.asaasWebhook = void 0;
const https_1 = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
/**
 * Webhook handler for Asaas events
 */
exports.asaasWebhook = (0, https_1.onRequest)(async (req, res) => {
    // Asaas sends the event in the body
    const event = req.body.event;
    const payment = req.body.payment;
    console.log(`Asaas Webhook Event: ${event}`, JSON.stringify(payment));
    try {
        const db = admin.firestore();
        // Handle Payment Confirmed or Received
        if (event === "PAYMENT_RECEIVED" || event === "PAYMENT_CONFIRMED") {
            const userId = payment.externalReference;
            const paymentId = payment.id;
            if (!userId) {
                console.warn("No externalReference (userId) found in Asaas payment.");
                res.status(200).send("OK");
                return;
            }
            // 1. Create or Update Order Record
            const orderSnapshot = await db.collection("orders")
                .where("asaasPaymentId", "==", paymentId)
                .limit(1)
                .get();
            if (orderSnapshot.empty) {
                await db.collection("orders").add({
                    userId,
                    amount: payment.value,
                    netValue: payment.netValue,
                    currency: "brl",
                    status: "paid",
                    asaasPaymentId: paymentId,
                    method: "asaas",
                    billingType: payment.billingType,
                    createdAt: admin.firestore.FieldValue.serverTimestamp(),
                    asaasEvent: event,
                });
            }
            // 2. Handle Subscription Activation
            if (payment.subscription) {
                const subSnapshot = await db.collection("subscriptions")
                    .where("userId", "==", userId)
                    .limit(1)
                    .get();
                if (!subSnapshot.empty) {
                    await subSnapshot.docs[0].ref.update({
                        status: "active",
                        asaasSubscriptionId: payment.subscription,
                        lastPaymentId: paymentId,
                        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                    });
                }
                else {
                    // Create new subscription if it doesn't exist
                    await db.collection("subscriptions").add({
                        userId,
                        status: "active",
                        asaasSubscriptionId: payment.subscription,
                        startDate: admin.firestore.FieldValue.serverTimestamp(),
                        createdAt: admin.firestore.FieldValue.serverTimestamp(),
                        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                    });
                }
            }
        }
        // Handle Subscription Cancellation
        if (event === "SUBSCRIPTION_DELETED") {
            const subscriptionId = req.body.subscription.id;
            const subSnapshot = await db.collection("subscriptions")
                .where("asaasSubscriptionId", "==", subscriptionId)
                .limit(1)
                .get();
            if (!subSnapshot.empty) {
                await subSnapshot.docs[0].ref.update({
                    status: "cancelled",
                    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                });
            }
        }
        res.status(200).send("OK");
    }
    catch (error) {
        console.error("Asaas Webhook Processing Error:", error);
        res.status(500).send("Internal Error");
    }
});
//# sourceMappingURL=asaas.js.map