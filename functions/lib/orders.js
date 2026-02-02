"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createBookingOrder = void 0;
exports.fulfillCheckout = fulfillCheckout;
const https_1 = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
/**
 * Creates a Booking Order internally (e.g. when using Plan Credits).
 * Bypasses Stripe if the service is fully covered by the plan.
 */
exports.createBookingOrder = (0, https_1.onCall)(async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const { serviceId, vehicleId, date, time } = request.data;
    const userId = request.auth.uid;
    if (!serviceId || !vehicleId || !date || !time) {
        throw new https_1.HttpsError("invalid-argument", "Missing required fields.");
    }
    const db = admin.firestore();
    try {
        // 1. Verify availability (simplified)
        // TODO: Add real availability check
        // 2. Verify Plan Eligibility for "Free" Booking
        const subSnapshot = await db.collection('subscriptions')
            .where('userId', '==', userId)
            .where('status', 'in', ['active', 'trialing'])
            .get();
        if (subSnapshot.empty) {
            throw new https_1.HttpsError('permission-denied', 'No active subscription found for free booking.');
        }
        // Check if plan actually covers this service
        // For MVP: We assume if they have an active subscription, they *might* have credits.
        // In a real implementation we would check 'remaining_credits' on the subscription doc.
        const hasCredits = true; // Placeholder logic
        if (!hasCredits) {
            throw new https_1.HttpsError('resource-exhausted', 'No credits remaining in plan.');
        }
        // 3. Create Appointment
        const bookingRef = await db.collection("appointments").add({
            userId,
            vehicleId,
            serviceId,
            date,
            time,
            status: "scheduled", // Ready to go
            paymentStatus: "plan_credit",
            totalPrice: 0,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        // 4. Record "Order" for admin/staff view
        await db.collection("orders").add({
            userId,
            bookingId: bookingRef.id,
            serviceId,
            amount: 0,
            currency: 'brl',
            status: 'paid',
            method: 'subscription_credit',
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return { success: true, bookingId: bookingRef.id };
    }
    catch (error) {
        console.error("Error creating booking order:", error);
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const message = error.message || "Unknown error";
        throw new https_1.HttpsError("internal", message);
    }
});
/**
 * Internal helper to fulfill a Stripe Checkout order.
 * Called by the Stripe Webhook.
 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
async function fulfillCheckout(session) {
    const db = admin.firestore();
    const userId = session.metadata.firebaseUID;
    const serviceId = session.metadata.serviceId;
    const vehicleId = session.metadata.vehicleId;
    const scheduledTime = session.metadata.scheduledTime;
    const type = session.metadata.type;
    if (!userId) {
        console.error("No firebaseUID in session metadata");
        return;
    }
    // 1. Create Order Record (Financial Record)
    const orderRef = await db.collection("orders").add({
        userId,
        serviceId: serviceId || 'unknown',
        amount: session.amount_total ? session.amount_total / 100 : 0,
        currency: session.currency,
        status: 'paid',
        stripeSessionId: session.id,
        method: 'stripe',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        metadata: session.metadata
    });
    console.log(`Order fulfilled for user ${userId}, session ${session.id}, Order ID: ${orderRef.id}`);
    // 2. Create Appointment (Service Record) - If metadata exists
    if (type === 'one_time_service' && vehicleId && scheduledTime) {
        try {
            // Handle multiple services from metadata (comma-separated or single)
            let serviceIds = [];
            if (session.metadata.serviceIds) {
                serviceIds = session.metadata.serviceIds.split(',');
            }
            else if (serviceId) {
                serviceIds = serviceId.split(',');
            }
            // Ideally we need to parse scheduledTime back to a Date or Timestamp if it's string
            // Stripe metadata is string.
            // Assuming scheduledTime is ISO string.
            // Check for existing booking to avoid duplicates from client-side creation
            const existing = await db.collection("appointments")
                .where("userId", "==", userId)
                .where("vehicleId", "==", vehicleId)
                .where("scheduledTime", "==", scheduledTime)
                .limit(1)
                .get();
            if (!existing.empty) {
                console.log("Booking already exists, skipping webhook creation.");
                return;
            }
            await db.collection("appointments").add({
                userId,
                vehicleId,
                serviceIds: serviceIds, // Note: Booking model uses serviceIds (plural)
                scheduledTime: scheduledTime, // ISO String
                status: "scheduled",
                paymentStatus: "paid",
                totalPrice: session.amount_total ? session.amount_total / 100 : 0,
                orderId: orderRef.id, // Link to order
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            console.log(`✅ Appointment created automatically for Order ${orderRef.id}`);
        }
        catch (error) {
            console.error(`❌ Failed to create auto-appointment for Order ${orderRef.id}:`, error);
        }
    }
}
//# sourceMappingURL=orders.js.map