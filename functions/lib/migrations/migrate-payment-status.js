"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.migrateBookingPaymentStatus = void 0;
const admin = require("firebase-admin");
const https_1 = require("firebase-functions/v2/https");
/**
 * ONE-TIME MIGRATION FUNCTION
 * Migrates all bookings without paymentStatus field.
 * Sets paymentStatus based on whether user had active subscription at booking time.
 *
 * Usage: Call this HTTPS endpoint once, then delete/comment out.
 * Example: https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/migrateBookingPaymentStatus
 */
exports.migrateBookingPaymentStatus = (0, https_1.onRequest)({
    region: "southamerica-east1",
    timeoutSeconds: 540, // 9 minutes max
    memory: "512MiB",
}, async (req, res) => {
    var _a, _b, _c;
    const db = admin.firestore();
    console.log("🔄 Starting paymentStatus migration...");
    try {
        // Fetch ALL bookings
        const bookingsSnapshot = await db.collection("appointments").get();
        console.log(`📊 Found ${bookingsSnapshot.size} total bookings`);
        // Filter bookings WITHOUT paymentStatus
        const bookingsToMigrate = bookingsSnapshot.docs.filter(doc => {
            const data = doc.data();
            return !data.paymentStatus;
        });
        console.log(`🎯 Found ${bookingsToMigrate.length} bookings to migrate`);
        if (bookingsToMigrate.length === 0) {
            res.status(200).json({
                success: true,
                message: "No bookings to migrate",
                migrated: 0,
            });
            return;
        }
        const batch = db.batch();
        let migratedCount = 0;
        let subscriptionCount = 0;
        let pendingCount = 0;
        for (const bookingDoc of bookingsToMigrate) {
            const booking = bookingDoc.data();
            const userId = booking.userId;
            const scheduledTime = ((_a = booking.scheduledTime) === null || _a === void 0 ? void 0 : _a.toDate()) || new Date();
            // Check if user had active subscription at booking time
            const subsQuery = await db.collection("subscriptions")
                .where("userId", "==", userId)
                .where("status", "==", "active")
                .get();
            let paymentStatus = "pending";
            if (!subsQuery.empty) {
                // User has/had subscription - verify it was active at booking time
                for (const subDoc of subsQuery.docs) {
                    const sub = subDoc.data();
                    const startDate = (_b = sub.startDate) === null || _b === void 0 ? void 0 : _b.toDate();
                    const endDate = (_c = sub.endDate) === null || _c === void 0 ? void 0 : _c.toDate();
                    // Check if subscription was active at booking time
                    if (startDate && scheduledTime >= startDate) {
                        if (!endDate || scheduledTime <= endDate) {
                            paymentStatus = "subscription";
                            break;
                        }
                    }
                }
            }
            // Update booking
            batch.update(bookingDoc.ref, {
                paymentStatus: paymentStatus,
            });
            migratedCount++;
            if (paymentStatus === "subscription") {
                subscriptionCount++;
            }
            else {
                pendingCount++;
            }
            console.log(`✅ Booking ${bookingDoc.id}: ${paymentStatus}`);
        }
        // Commit batch
        await batch.commit();
        const result = {
            success: true,
            message: "Migration completed successfully",
            total: migratedCount,
            subscription: subscriptionCount,
            pending: pendingCount,
        };
        console.log("🎉 Migration complete:", result);
        res.status(200).json(result);
    }
    catch (error) {
        console.error("❌ Migration failed:", error);
        res.status(500).json({
            success: false,
            error: String(error),
        });
    }
});
//# sourceMappingURL=migrate-payment-status.js.map