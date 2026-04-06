"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.migrateBookingPaymentStatus = void 0;
const admin = __importStar(require("firebase-admin"));
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
            const scheduledTime = booking.scheduledTime?.toDate() || new Date();
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
                    const startDate = sub.startDate?.toDate();
                    const endDate = sub.endDate?.toDate();
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