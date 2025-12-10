import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

/**
 * Creates a Booking Order internally (e.g. when using Plan Credits).
 * Bypasses Stripe if the service is fully covered by the plan.
 */
export const createBookingOrder = onCall(async (request) => {
    if (!request.auth) {
        throw new HttpsError(
            "unauthenticated",
            "The function must be called while authenticated."
        );
    }

    const { serviceId, vehicleId, date, time } = request.data;
    const userId = request.auth.uid;

    if (!serviceId || !vehicleId || !date || !time) {
        throw new HttpsError("invalid-argument", "Missing required fields.");
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
            throw new HttpsError('permission-denied', 'No active subscription found for free booking.');
        }

        // Check if plan actually covers this service
        // For MVP: We assume if they have an active subscription, they *might* have credits.
        // In a real implementation we would check 'remaining_credits' on the subscription doc.
        const hasCredits = true; // Placeholder logic

        if (!hasCredits) {
            throw new HttpsError('resource-exhausted', 'No credits remaining in plan.');
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

    } catch (error) {
        console.error("Error creating booking order:", error);
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const message = (error as any).message || "Unknown error";
        throw new HttpsError("internal", message);
    }
});

/**
 * Internal helper to fulfill a Stripe Checkout order.
 * Called by the Stripe Webhook.
 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export async function fulfillCheckout(session: any) {
    const db = admin.firestore();
    const userId = session.metadata.firebaseUID;
    const serviceId = session.metadata.serviceId;

    if (!userId) {
        console.error("No firebaseUID in session metadata");
        return;
    }

    // Assuming we passed booking details in metadata, current implementation of createCheckoutSession
    // only puts serviceId. We might need vehicle info to create a proper booking.
    // OPTION A: The user books -> We reserve "pending" booking -> Checkout -> Webhook confirms.
    // OPTION B: User pays -> Webhook creates "Paid Order" -> User selects time/vehicle later.
    // Given the requirement "User selects and finalizes purchase... then redirects to Stripe",
    // it implies immediate fulfillment. 
    // IF we don't have vehicle/time in metadata, we can create an "Open Voucher" order.

    // For this MVP, let's create an Order record. The actual Booking (slot) might be handled 
    // if we add vehicle/date/time to metadata in createCheckoutSession.

    await db.collection("orders").add({
        userId,
        serviceId: serviceId || 'unknown',
        amount: session.amount_total ? session.amount_total / 100 : 0,
        currency: session.currency,
        status: 'paid',
        stripeSessionId: session.id,
        method: 'stripe',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        metadata: session.metadata
        // If we had booking details, we would create the appointment here too.
    });

    console.log(`Order fulfilled for user ${userId}, session ${session.id}`);
}
