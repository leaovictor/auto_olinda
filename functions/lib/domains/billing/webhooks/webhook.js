"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.stripeWebhook = void 0;
const admin = require("firebase-admin");
const https_1 = require("firebase-functions/v2/https");
const env_1 = require("../../../config/env");
const stripe_1 = require("../helpers/stripe");
const orders_1 = require("../../../orders");
/**
 * Stripe Webhook to handle events like subscription updates.
 */
exports.stripeWebhook = (0, https_1.onRequest)({ secrets: [env_1.stripeSecret, env_1.stripeWebhookSecret], maxInstances: 1, cpu: 1 }, async (req, res) => {
    const sig = req.headers["stripe-signature"];
    console.error("DEBUG: Webhook called");
    if (req.rawBody) {
        console.error("DEBUG: RawBody length:", req.rawBody.length);
    }
    try {
        const stripe = await (0, stripe_1.getStripe)();
        const event = stripe.webhooks.constructEvent(req.rawBody, sig, env_1.stripeWebhookSecret.value());
        switch (event.type) {
            case "customer.subscription.created":
            case "customer.subscription.updated":
                await handleSubscriptionUpdate(event.data.object);
                break;
            case "customer.subscription.deleted":
                await handleSubscriptionDeleted(event.data.object);
                break;
            case "checkout.session.completed": {
                const session = event.data.object;
                if (session.mode === "subscription") {
                    if (session.subscription) {
                        const subscriptionId = typeof session.subscription === "string" ?
                            session.subscription :
                            session.subscription.id;
                        const sub = await stripe.subscriptions.retrieve(subscriptionId);
                        await handleSubscriptionUpdate(sub);
                    }
                }
                else if (session.mode === "payment") {
                    await (0, orders_1.fulfillCheckout)(session);
                }
                break;
            }
            case "payment_intent.succeeded": {
                const paymentIntent = event.data.object;
                if (paymentIntent.metadata.type === "independent_service") {
                    await handleServicePaymentSuccess(paymentIntent);
                }
                break;
            }
            case "invoice.payment_succeeded":
                await handleInvoicePaymentSucceeded(event.data.object);
                break;
            case "invoice.payment_failed":
                await handleInvoicePaymentFailed(event.data.object);
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
 * Handles successful invoice payment (renewals).
 */
async function handleInvoicePaymentSucceeded(invoice) {
    const subscriptionId = invoice.subscription;
    const billingReason = invoice.billing_reason;
    if (!subscriptionId)
        return;
    console.log(`Invoice paid for subscription: ${subscriptionId} (Reason: ${billingReason})`);
    const snapshot = await admin.firestore()
        .collection("subscriptions")
        .where("stripeSubscriptionId", "==", subscriptionId)
        .limit(1)
        .get();
    if (!snapshot.empty) {
        const subDoc = snapshot.docs[0];
        await subDoc.ref.update({
            status: "active",
            lastPaymentDate: admin.firestore.FieldValue.serverTimestamp(),
            paymentIssue: false,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        const userId = subDoc.data().userId;
        if (userId) {
            await admin.firestore().collection("users").doc(userId).update({
                subscriptionStatus: "active",
                subscriptionUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
        console.log(`✅ Subscription ${subscriptionId} renewed and user ${userId} activated.`);
    }
}
/**
 * Handles failed invoice payment.
 */
async function handleInvoicePaymentFailed(invoice) {
    const subscriptionId = invoice.subscription;
    if (!subscriptionId)
        return;
    console.warn(`❌ Invoice payment failed for subscription: ${subscriptionId}`);
    const snapshot = await admin.firestore()
        .collection("subscriptions")
        .where("stripeSubscriptionId", "==", subscriptionId)
        .limit(1)
        .get();
    if (!snapshot.empty) {
        const subDoc = snapshot.docs[0];
        await subDoc.ref.update({
            status: "past_due",
            paymentIssue: true,
            lastPaymentFailure: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        const userId = subDoc.data().userId;
        if (userId) {
            await admin.firestore().collection("users").doc(userId).update({
                subscriptionStatus: "past_due",
                subscriptionUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            console.log(`⚠️ User ${userId} marked as past_due.`);
        }
    }
}
/**
 * Handles subscription cancellation/deletion.
 */
async function handleSubscriptionDeleted(subscription) {
    console.log(`🚫 Subscription deleted: ${subscription.id}`);
    const snapshot = await admin.firestore()
        .collection("subscriptions")
        .where("stripeSubscriptionId", "==", subscription.id)
        .limit(1)
        .get();
    if (!snapshot.empty) {
        const doc = snapshot.docs[0];
        await doc.ref.update({
            status: "canceled",
            canceledAt: admin.firestore.FieldValue.serverTimestamp(),
            endDate: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        const userId = doc.data().userId;
        if (userId) {
            await admin.firestore().collection("users").doc(userId).update({
                subscriptionStatus: "inactive",
                subscriptionUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            console.log(`🚫 User ${userId} marked as inactive (subscription deleted).`);
        }
    }
}
/**
 * Handles successful payment for independent services.
 */
async function handleServicePaymentSuccess(paymentIntent) {
    const metadata = paymentIntent.metadata;
    const userId = metadata.firebaseUID;
    const serviceId = metadata.serviceId;
    const scheduledTimeStr = metadata.scheduledTime;
    console.log(`🔵 handleServicePaymentSuccess: Processing PaymentIntent ${paymentIntent.id}`);
    if (!userId || !serviceId || !scheduledTimeStr) {
        console.error(`❌ Missing required metadata for PaymentIntent ${paymentIntent.id}`);
        return;
    }
    const db = admin.firestore();
    try {
        const scheduledTime = new Date(scheduledTimeStr);
        if (isNaN(scheduledTime.getTime())) {
            console.error(`❌ Invalid scheduledTime format: ${scheduledTimeStr}`);
            return;
        }
        const existingBookings = await db.collection("service_bookings")
            .where("userId", "==", userId)
            .where("serviceId", "==", serviceId)
            .where("scheduledTime", "==", admin.firestore.Timestamp.fromDate(scheduledTime))
            .limit(1)
            .get();
        if (!existingBookings.empty) {
            console.log(`⚠️ Booking already exists for PaymentIntent ${paymentIntent.id}, skipping creation`);
            const existingDoc = existingBookings.docs[0];
            if (existingDoc.data().paymentStatus !== 'paid') {
                await existingDoc.ref.update({
                    paymentStatus: 'paid',
                    paidAmount: (paymentIntent.amount / 100),
                    stripePaymentIntentId: paymentIntent.id,
                    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                });
                console.log(`✅ Updated existing booking ${existingDoc.id} payment status to paid`);
            }
            return;
        }
        const bookingData = {
            userId: userId,
            serviceId: serviceId,
            scheduledTime: admin.firestore.Timestamp.fromDate(scheduledTime),
            totalPrice: Number(metadata.totalPrice) || (paymentIntent.amount / 100),
            status: 'scheduled',
            paymentStatus: 'paid',
            paidAmount: (paymentIntent.amount / 100),
            vehicleId: metadata.vehicleId || null,
            vehiclePlate: metadata.vehiclePlate || null,
            vehicleModel: metadata.vehicleModel || null,
            userName: metadata.userName || null,
            userPhone: metadata.userPhone || null,
            stripePaymentIntentId: paymentIntent.id,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            createdVia: 'stripe_webhook',
        };
        const bookingRef = await db.collection("service_bookings").add(bookingData);
        console.log(`✅ Created booking ${bookingRef.id} for PaymentIntent ${paymentIntent.id}`);
    }
    catch (error) {
        console.error(`❌ Error creating booking for PaymentIntent ${paymentIntent.id}:`, error);
        throw error;
    }
}
/**
 * Handles subscription updates from Stripe webhooks.
 */
async function handleSubscriptionUpdate(subscription) {
    var _a;
    console.log("--- Conteúdo do Webhook de Assinatura ---");
    console.log(JSON.stringify(subscription, null, 2));
    const customerId = subscription.customer;
    const status = subscription.status;
    const priceId = subscription.items.data[0].price.id;
    const userId = subscription.metadata.firebaseUID;
    const sub = subscription;
    const vehiclePlate = subscription.metadata.vehiclePlate || null;
    const vehicleCategory = subscription.metadata.vehicleCategory || null;
    const vehicleId = subscription.metadata.vehicleId || null;
    if (!userId) {
        console.error("No firebaseUID found in subscription metadata for subscription:", sub.id);
        return;
    }
    // Fallback checks for missing dates
    let currentPeriodStart = sub.current_period_start;
    let currentPeriodEnd = sub.current_period_end;
    if (typeof currentPeriodStart !== 'number' || typeof currentPeriodEnd !== 'number') {
        console.log(`Datas faltando no objeto do webhook para a assinatura ${sub.id}. Usando fallbacks.`);
        try {
            const stripe = await (0, stripe_1.getStripe)();
            const freshSub = await stripe.subscriptions.retrieve(sub.id);
            currentPeriodStart = freshSub.current_period_start;
            currentPeriodEnd = freshSub.current_period_end;
        }
        catch (error) {
            console.error("Erro ao buscar assinatura atualizada:", error);
        }
    }
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
        const updateData = {
            status: appStatus,
            planId: priceId,
            stripeSubscriptionId: sub.id,
            stripeCustomerId: customerId,
            cancelAtPeriodEnd: sub.cancel_at_period_end || false,
            endDate: endDate,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };
        if (vehiclePlate)
            updateData.linkedPlate = vehiclePlate;
        if (vehicleCategory)
            updateData.vehicleCategory = vehicleCategory;
        if (vehicleId)
            updateData.vehicleId = vehicleId;
        // Fallback: if planId is in metadata, use it (though priceId from items is safer)
        if ((_a = sub.metadata) === null || _a === void 0 ? void 0 : _a.planId)
            updateData.planId = sub.metadata.planId;
        await subscriptionDoc.ref.update(updateData);
        console.log(`Assinatura ATUALIZADA para o usuário ${userId}`);
    }
    else {
        const newSubData = {
            userId: userId,
            planId: priceId,
            status: appStatus,
            startDate: startDate,
            endDate: endDate,
            stripeSubscriptionId: sub.id,
            stripeCustomerId: customerId,
            cancelAtPeriodEnd: sub.cancel_at_period_end || false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        };
        if (vehiclePlate)
            newSubData.linkedPlate = vehiclePlate;
        if (vehicleCategory)
            newSubData.vehicleCategory = vehicleCategory;
        if (vehicleId)
            newSubData.vehicleId = vehicleId;
        await admin.firestore().collection("subscriptions").add(newSubData);
        console.log(`Nova assinatura CRIADA para o usuário ${userId}`);
    }
    const userSubscriptionStatus = (status === 'active' || status === 'trialing') ? 'active' :
        (status === 'canceled' || status === 'unpaid' || status === 'incomplete_expired') ? 'cancelled' : 'inactive';
    try {
        await admin.firestore().collection('users').doc(userId).update({
            subscriptionStatus: userSubscriptionStatus,
            subscriptionUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`✅ Updated user ${userId} subscriptionStatus to: ${userSubscriptionStatus}`);
    }
    catch (error) {
        console.error(`❌ Failed to update user subscriptionStatus for ${userId}:`, error);
    }
}
//# sourceMappingURL=webhook.js.map