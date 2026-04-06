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
exports.onNegativeReviewCreated = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const admin = __importStar(require("firebase-admin"));
/**
 * Cloud Function to send push notification when a negative review is created
 * Triggered when an appointment document is updated with a rating <= 2
 */
exports.onNegativeReviewCreated = (0, firestore_1.onDocumentUpdated)({
    document: "appointments/{bookingId}",
}, async (event) => {
    if (!event.data)
        return;
    const before = event.data.before.data();
    const after = event.data.after.data();
    const bookingId = event.params.bookingId;
    // Check if review was just added (isRated changed from false to true)
    if (!before.isRated && after.isRated && after.rating <= 2) {
        // eslint-disable-next-line max-len
        console.log(`Negative review detected: ${bookingId} with rating ${after.rating}`);
        try {
            // Get all admin users
            const adminsSnapshot = await admin
                .firestore()
                .collection("users")
                .where("role", "==", "admin")
                .get();
            // Extract FCM tokens
            const tokens = [];
            adminsSnapshot.docs.forEach((doc) => {
                const fcmToken = doc.data().fcmToken;
                if (fcmToken) {
                    tokens.push(fcmToken);
                }
            });
            if (tokens.length === 0) {
                console.log("No admin tokens found");
                return null;
            }
            // Get customer name for better notification
            let customerName = "Cliente";
            if (after.userId) {
                const userDoc = await admin
                    .firestore()
                    .collection("users")
                    .doc(after.userId)
                    .get();
                if (userDoc.exists) {
                    customerName = userDoc.data()?.displayName || "Cliente";
                }
            }
            // Generate notification body
            const ratingStars = "⭐".repeat(after.rating);
            const comment = after.ratingComment ?
                after.ratingComment.substring(0, 80) :
                "Sem comentário";
            const notification = {
                tokens,
                notification: {
                    title: "⚠️ Avaliação Negativa Recebida",
                    body: `${customerName} - ${ratingStars}\n${comment}`,
                },
                data: {
                    type: "negative_review",
                    bookingId: bookingId,
                    rating: after.rating.toString(),
                    route: "/admin/reviews",
                    click_action: "FLUTTER_NOTIFICATION_CLICK",
                },
                android: {
                    priority: "high",
                    notification: {
                        priority: "high",
                        defaultSound: true,
                        defaultVibrateTimings: true,
                    },
                },
                apns: {
                    payload: {
                        aps: {
                            sound: "default",
                            badge: 1,
                        },
                    },
                },
            };
            const response = await admin.messaging().sendEachForMulticast(notification);
            console.log(`Notification sent to ${response.successCount} admins`);
            if (response.failureCount > 0) {
                console.error("Some notifications failed:", response.responses);
            }
            return { success: response.successCount, failed: response.failureCount };
        }
        catch (error) {
            console.error("Error sending notification:", error);
            return null;
        }
    }
    return null;
});
//# sourceMappingURL=reviews.js.map