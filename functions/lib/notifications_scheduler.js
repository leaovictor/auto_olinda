"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.processNoShowAndStrikes = exports.sendRatingReminder = exports.sendBookingOneHourReminder = exports.sendBookingConfirmationReminder = void 0;
const scheduler_1 = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
/**
 * T-24h Confirmation Reminder
 * Runs every hour. Finds bookings scheduled for [now + 23.5h] to [now + 24.5h].
 * Sends push with "Confirmar" action.
 */
exports.sendBookingConfirmationReminder = (0, scheduler_1.onSchedule)({
    schedule: "every 1 hours",
    timeZone: "America/Sao_Paulo",
    retryCount: 0,
}, async () => {
    var _a;
    const db = admin.firestore();
    const now = new Date();
    // Target window: 24 hours from now (+/- 30 mins to catch all in hourly run)
    const targetStart = new Date(now.getTime() + (23 * 60 + 30) * 60 * 1000); // +23.5h
    const targetEnd = new Date(now.getTime() + (24 * 60 + 30) * 60 * 1000); // +24.5h
    console.log(`[ConfReminder] Running. Looking for bookings between ${targetStart.toISOString()} and ${targetEnd.toISOString()}`);
    try {
        // Find Unconfirmed bookings
        const snapshot = await db.collection("appointments")
            .where("status", "==", "scheduled")
            .where("scheduledTime", ">=", admin.firestore.Timestamp.fromDate(targetStart))
            .where("scheduledTime", "<=", admin.firestore.Timestamp.fromDate(targetEnd))
            .get();
        if (snapshot.empty) {
            console.log("[ConfReminder] No bookings found.");
            return;
        }
        console.log(`[ConfReminder] Found ${snapshot.size} bookings.`);
        const batch = db.batch(); // For notifications history
        for (const doc of snapshot.docs) {
            const booking = doc.data();
            const userId = booking.userId;
            const bookingId = doc.id;
            // Double check not already notified? (Optional, skipping for MVP complexity)
            // 1. Send Push
            const userDoc = await db.collection("users").doc(userId).get();
            const fcmToken = (_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a.fcmToken;
            if (fcmToken) {
                await admin.messaging().send({
                    token: fcmToken,
                    data: {
                        bookingId: bookingId,
                        type: "confirm_reminder",
                        click_action: "FLUTTER_NOTIFICATION_CLICK",
                        title: "Confirmação Necessária 📅",
                        body: "Seu agendamento é amanhã! Confirme agora para garantir seu horário.",
                    },
                    android: {
                        notification: {
                            title: "Confirmação Necessária 📅",
                            body: "Seu agendamento é amanhã! Confirme agora para garantir seu horário.",
                            channelId: "high_importance_channel",
                            // Actions would be handled by client receiving logic usually, or actionable notifications 
                            // Android actions support needs client side setup.
                        },
                    },
                });
            }
            // 2. Add to In-App Notifications
            const notifRef = db.collection("users").doc(userId).collection("notifications").doc();
            batch.set(notifRef, {
                title: "Confirme seu Agendamento",
                body: "Você tem um agendamento amanhã. Confirme para não perder a vaga.",
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                bookingId: bookingId,
                type: "confirm_reminder",
                isRead: false
            });
        }
        await batch.commit();
        console.log("[ConfReminder] Done.");
    }
    catch (error) {
        console.error("[ConfReminder] Error:", error);
    }
});
/**
 * T-1h Departure Reminder
 * Runs every 15 minutes. Finds finished/washing jobs ending soon? NO.
 * Request: "Seu box estará pronto em 1 hora. Evite atrasos..." - Wait.
 * "Seu box estará pronto em 1 hora" implies BEFORE start?
 * "Evite atrasos para não sofrer penalidades."
 * Usually this means "Your booking STARTS in 1 hour".
 * IF it meant "Your car is READY in 1h", it would be during service.
 * "Evite atrasos para não sofrer penalidades" -> Penalties are for NO-SHOW (arrival).
 * So this is T-1h BEFORE START.
 *
 * Logic: Find bookings starting in [now + 50min, now + 70min] (for 15 min run)
 */
exports.sendBookingOneHourReminder = (0, scheduler_1.onSchedule)({
    schedule: "every 15 minutes",
    timeZone: "America/Sao_Paulo",
    retryCount: 0,
}, async () => {
    var _a;
    const db = admin.firestore();
    const now = new Date();
    // Target window: +1h (+/- 10 mins)
    const targetStart = new Date(now.getTime() + (50) * 60 * 1000); // +50m
    const targetEnd = new Date(now.getTime() + (70) * 60 * 1000); // +70m
    console.log(`[1hReminder] Running. Looking for bookings between ${targetStart.toISOString()} and ${targetEnd.toISOString()}`);
    try {
        // Find ACTIVE bookings (scheduled OR confirmed)
        const snapshot = await db.collection("appointments")
            .where("scheduledTime", ">=", admin.firestore.Timestamp.fromDate(targetStart))
            .where("scheduledTime", "<=", admin.firestore.Timestamp.fromDate(targetEnd))
            .get();
        const validBookings = snapshot.docs.filter(d => ['scheduled', 'confirmed'].includes(d.data().status));
        if (validBookings.length === 0) {
            console.log("[1hReminder] No bookings found.");
            return;
        }
        console.log(`[1hReminder] Found ${validBookings.length} bookings.`);
        const batch = db.batch();
        for (const doc of validBookings) {
            const booking = doc.data();
            const userId = booking.userId;
            const bookingId = doc.id;
            // 1. Send Push
            const userDoc = await db.collection("users").doc(userId).get();
            const fcmToken = (_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a.fcmToken;
            if (fcmToken) {
                await admin.messaging().send({
                    token: fcmToken,
                    data: {
                        bookingId: bookingId,
                        type: "start_reminder",
                        title: "Falta 1 Hora! ⏰",
                        body: "Seu box estará pronto em 1 hora. Evite atrasos para não sofrer penalidades.",
                    },
                    android: {
                        notification: {
                            title: "Falta 1 Hora! ⏰",
                            body: "Seu box estará pronto em 1 hora. Evite atrasos para não sofrer penalidades.",
                            channelId: "high_importance_channel",
                        },
                    },
                });
            }
            // 2. Add to In-App Notifications
            const notifRef = db.collection("users").doc(userId).collection("notifications").doc();
            batch.set(notifRef, {
                title: "Falta 1 Hora",
                body: "Seu agendamento começa em 1h. Evite atrasos.",
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                bookingId: bookingId,
                type: "start_reminder",
                isRead: false
            });
        }
        await batch.commit();
        console.log("[1hReminder] Done.");
    }
    catch (error) {
        console.error("[1hReminder] Error:", error);
    }
});
/**
 * Rating Reminder
 * Runs every 30 minutes.
 * Logic: Find bookings that Finished between [30m, 60m] ago AND isRated == false.
 * Send "Avalie sua experiência" push.
 */
exports.sendRatingReminder = (0, scheduler_1.onSchedule)({
    schedule: "every 30 minutes",
    timeZone: "America/Sao_Paulo",
    retryCount: 0,
}, async () => {
    var _a;
    const db = admin.firestore();
    const now = new Date();
    // Target window: 30-60 mins ago
    // If finishedAt was 30 mins ago -> now - 30m
    const windowStart = new Date(now.getTime() - 60 * 60 * 1000); // 1h ago
    const windowEnd = new Date(now.getTime() - 30 * 60 * 1000); // 30m ago
    console.log(`[RatingReminder] Running. Looking for bookings finished between ${windowStart.toISOString()} and ${windowEnd.toISOString()}`);
    try {
        const snapshot = await db.collection("appointments")
            .where("status", "==", "finished")
            .where("finishedAt", ">=", admin.firestore.Timestamp.fromDate(windowStart))
            .where("finishedAt", "<=", admin.firestore.Timestamp.fromDate(windowEnd))
            .where("isRated", "==", false)
            .get();
        if (snapshot.empty) {
            console.log("[RatingReminder] No bookings found.");
            return;
        }
        console.log(`[RatingReminder] Found ${snapshot.size} bookings.`);
        const batch = db.batch();
        for (const doc of snapshot.docs) {
            const booking = doc.data();
            const userId = booking.userId;
            const bookingId = doc.id;
            // 1. Send Push
            const userDoc = await db.collection("users").doc(userId).get();
            const fcmToken = (_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a.fcmToken;
            if (fcmToken) {
                await admin.messaging().send({
                    token: fcmToken,
                    data: {
                        bookingId: bookingId,
                        type: "rate_experience",
                        click_action: "FLUTTER_NOTIFICATION_CLICK",
                        title: "Avalie sua Experiência ⭐",
                        body: "Sua opinião é muito importante. Avalie o serviço!",
                    },
                    android: {
                        notification: {
                            title: "Avalie sua Experiência ⭐",
                            body: "Sua opinião é muito importante. Avalie o serviço!",
                            channelId: "high_importance_channel",
                        },
                    },
                });
            }
            // 2. Add to In-App Notifications
            const notifRef = db.collection("users").doc(userId).collection("notifications").doc();
            batch.set(notifRef, {
                title: "Avalie nosso serviço",
                body: "Como foi sua experiência? Toque para avaliar.",
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                bookingId: bookingId,
                type: "rate_experience",
                isRead: false
            });
        }
        await batch.commit();
        console.log("[RatingReminder] Done.");
    }
    catch (error) {
        console.error("[RatingReminder] Error:", error);
    }
});
/**
 * Process No-Show and Apply Strikes
 * Runs every 10 minutes.
 * Logic:
 * 1. Find bookings with status 'confirmed'.
 * 2. Where scheduledTime < (now - 15 minutes).
 * 3. Update status to 'noShow' (nao_compareceu).
 * 4. Apply 24h Strike to user.
 * 5. Consumes credit (penaltyApplied = true).
 */
exports.processNoShowAndStrikes = (0, scheduler_1.onSchedule)({
    schedule: "every 1 minutes",
    timeZone: "America/Sao_Paulo",
    retryCount: 0,
}, async () => {
    var _a;
    const db = admin.firestore();
    const now = new Date();
    // Tolerance: 15 minutes after scheduled time
    // If scheduledTime was 08:00, and now is 08:16 -> No Show.
    // Threshold = Now - 15 minutes.
    // Find bookings where scheduledTime < Threshold.
    const threshold = new Date(now.getTime() - 15 * 60 * 1000);
    console.log(`[NoShowCheck] Running at ${now.toISOString()}`);
    console.log(`[NoShowCheck] Threshold: ${threshold.toISOString()}`);
    try {
        const snapshot = await db.collection("appointments")
            .where("status", "==", "confirmed")
            .where("scheduledTime", "<", admin.firestore.Timestamp.fromDate(threshold))
            .get();
        if (snapshot.empty) {
            console.log("[NoShowCheck] No confirmed no-shows found.");
            return;
        }
        console.log(`[NoShowCheck] Found ${snapshot.size} potential no-shows.`);
        const batch = db.batch();
        const usersToNotify = [];
        for (const doc of snapshot.docs) {
            const booking = doc.data();
            const userId = booking.userId;
            const bookingId = doc.id;
            console.log(`[NoShowCheck] Processing No-Show for Booking ${bookingId} (User ${userId})`);
            // 1. Update Booking
            batch.update(doc.ref, {
                status: "noShow", // internal status
                penaltyApplied: true, // Consumes credit
                strikeApplied: true,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                cancellationReason: "auto_no_show"
            });
            // 2. Update User (Apply Strike)
            // Strike duration: 24h from NOW
            const strikeUntil = new Date(now.getTime() + 24 * 60 * 60 * 1000);
            const userRef = db.collection("users").doc(userId);
            batch.update(userRef, {
                strikeUntil: admin.firestore.Timestamp.fromDate(strikeUntil),
                lastStrikeReason: "No-Show (Não comparecimento)",
                noShowCount: admin.firestore.FieldValue.increment(1) // Track total no-shows
            });
            usersToNotify.push({ userId, bookingId });
            // 3. Add Notification (In-App)
            const notifRef = db.collection("users").doc(userId).collection("notifications").doc();
            batch.set(notifRef, {
                title: "Conta em Strike (24h) 🚫",
                body: "Você não compareceu ao agendamento confirmado. Sua conta ficará suspensa por 24h.",
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                bookingId: bookingId,
                type: "strike_alert",
                isRead: false
            });
        }
        await batch.commit();
        console.log(`[NoShowCheck] Batch committed for ${snapshot.size} bookings.`);
        // 4. Send Push Notifications
        for (const { userId, bookingId } of usersToNotify) {
            try {
                const userDoc = await db.collection("users").doc(userId).get();
                const fcmToken = (_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a.fcmToken;
                if (fcmToken) {
                    await admin.messaging().send({
                        token: fcmToken,
                        data: {
                            bookingId: bookingId,
                            type: "strike_alert",
                            title: "Não comparecimento detectado 🚫",
                            body: "Sua conta foi colocada em Strike por 24h devido ao No-Show.",
                        },
                        android: {
                            notification: {
                                title: "Não comparecimento detectado 🚫",
                                body: "Sua conta foi colocada em Strike por 24h devido ao No-Show.",
                                channelId: "high_importance_channel"
                            }
                        }
                    });
                }
            }
            catch (err) {
                console.error(`[NoShowCheck] Failed to notify user ${userId}:`, err);
            }
        }
    }
    catch (error) {
        console.error("[NoShowCheck] Critical error:", error);
    }
});
//# sourceMappingURL=notifications_scheduler.js.map