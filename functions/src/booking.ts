import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

/**
 * Creates a new booking.
 * Validates availability and user credits.
 */
export const createBooking = onCall(async (request) => {
    if (!request.auth) {
        throw new HttpsError(
            "unauthenticated",
            "The function must be called while authenticated.",
        );
    }

    const { serviceId, date, time, vehicleId } = request.data;
    const userId = request.auth.uid;

    if (!serviceId || !date || !time || !vehicleId) {
        throw new HttpsError("invalid-argument", "Missing required fields.");
    }

    const db = admin.firestore();

    try {
        // 1. Check Availability (Simplified for now)
        // In a real app, you'd check if the slot is already taken in 'availability' collection
        // or count existing bookings for that slot.

        // 2. Check User Subscription/Credits
        const userDoc = await db.collection("users").doc(userId).get();
        const userData = userDoc.data();

        if (!userData) {
            throw new HttpsError("not-found", "User not found.");
        }

        // Example check: ensure user has active subscription
        if (userData.subscriptionStatus !== "active") {
            throw new HttpsError(
                "permission-denied",
                "You need an active subscription to book.",
            );
        }

        // 3. Create Booking
        const bookingRef = await db.collection("appointments").add({
            userId,
            vehicleId,
            serviceId,
            date,
            time,
            status: "pending",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return { bookingId: bookingRef.id, status: "success" };
    } catch (error) {
        console.error("Error creating booking:", error);
        throw new HttpsError("internal", "Unable to create booking.");
    }
});

/**
 * Completes a booking (Staff only).
 */
export const completeBooking = onCall(async (request) => {
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Authentication required.");
    }

    // Check if user is staff or admin
    const userDoc = await admin.firestore().collection("users").doc(request.auth.uid).get();
    const role = userDoc.data()?.role;

    if (role !== "staff" && role !== "admin") {
        throw new HttpsError("permission-denied", "Only staff can complete bookings.");
    }

    const { bookingId } = request.data;

    if (!bookingId) {
        throw new HttpsError("invalid-argument", "Booking ID is required.");
    }

    try {
        await admin.firestore().collection("appointments").doc(bookingId).update({
            status: "finished",
            completedAt: admin.firestore.FieldValue.serverTimestamp(),
            completedBy: request.auth.uid,
        });

        return { status: "success" };
    } catch (error) {
        console.error("Error completing booking:", error);
        throw new HttpsError("internal", "Unable to complete booking.");
    }
});
