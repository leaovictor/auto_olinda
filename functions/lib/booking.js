"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.autoExpireUnconfirmedBookings = exports.cancelBooking = exports.createBooking = void 0;
const https_1 = require("firebase-functions/v2/https");
const scheduler_1 = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
/**
 * Creates a new booking with security checks.
 * Enforces:
 * 1. Schema Validation
 * 2. Lead Time (min 2 hours)
 * 3. Subscription Limits (Excessive Wash)
 * 4. Concurrency Anti-spam
 */
exports.createBooking = (0, https_1.onCall)(async (request) => {
    console.log("==== createBooking function started ====");
    if (!request.auth) {
        console.log("ERROR: No authentication!");
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    console.log("Authenticated user:", request.auth.uid);
    console.log("Request data:", JSON.stringify(request.data));
    const { vehicleId, serviceIds, scheduledTime, staffNotes } = request.data;
    const userId = request.auth.uid;
    console.log("vehicleId:", vehicleId);
    console.log("serviceIds:", serviceIds);
    console.log("scheduledTime:", scheduledTime);
    // 1. Validation
    if (!vehicleId || !serviceIds || !Array.isArray(serviceIds) || serviceIds.length === 0 || !scheduledTime) {
        console.log("ERROR: Missing required fields!");
        throw new https_1.HttpsError("invalid-argument", "Missing required fields (vehicleId, serviceIds, scheduledTime).");
    }
    console.log("✓ Validation passed");
    const db = admin.firestore();
    // Parse Scheduled Time
    const bookingDate = new Date(scheduledTime);
    const now = new Date();
    console.log("Parsed bookingDate:", bookingDate.toISOString());
    console.log("Current time:", now.toISOString());
    if (isNaN(bookingDate.getTime())) {
        console.log("ERROR: Invalid date format!");
        throw new https_1.HttpsError("invalid-argument", "Invalid date format.");
    }
    // 2. Lead Time Rule: 2 Hours minimum
    // TODO: Make this configurable via Firestore 'config'
    const MIN_LEAD_HOURS = 2;
    const diffHours = (bookingDate.getTime() - now.getTime()) / (1000 * 60 * 60);
    console.log("Lead time check - diffHours:", diffHours, "MIN_LEAD_HOURS:", MIN_LEAD_HOURS);
    if (diffHours < MIN_LEAD_HOURS) {
        console.log("ERROR: Lead time too short!");
        throw new https_1.HttpsError("failed-precondition", `Agendamentos devem ser feitos com no mínimo ${MIN_LEAD_HOURS} horas de antecedência.`);
    }
    console.log("✓ Lead time check passed");
    try {
        // 3. User & Subscription Check
        // Check if user is blocked or suspended (optional)
        console.log("Fetching user document...");
        const userDoc = await db.collection("users").doc(userId).get();
        const userData = userDoc.data();
        console.log("User exists:", userDoc.exists, "userData:", userData ? "found" : "null");
        if ((userData === null || userData === void 0 ? void 0 : userData.status) === 'suspended') {
            console.log("ERROR: User is suspended!");
            throw new https_1.HttpsError("permission-denied", "Sua conta está suspensa. Entre em contato com o suporte.");
        }
        console.log("✓ User check passed");
        // Check Subscription Limit
        console.log("Checking subscription...");
        const subsQuery = await db.collection("subscriptions")
            .where("userId", "==", userId)
            .where("status", "==", "active")
            .limit(1)
            .get();
        console.log("Subscription query returned:", subsQuery.size, "documents");
        if (!subsQuery.empty) {
            const sub = subsQuery.docs[0].data();
            const planId = sub.planId; // This is actually a Stripe price ID like "price_xxx"
            console.log("User has subscription with planId (Stripe Price ID):", planId);
            if (planId) {
                // planId is a Stripe price ID, so we need to query plans by stripePriceId field
                // First, try to find by stripePriceId field
                let planData = null;
                const planQuery = await db.collection("plans")
                    .where("stripePriceId", "==", planId)
                    .limit(1)
                    .get();
                if (!planQuery.empty) {
                    planData = planQuery.docs[0].data();
                    console.log("Found plan by stripePriceId:", planQuery.docs[0].id);
                }
                else {
                    // Fallback: try by document ID (for backwards compatibility)
                    const planDoc = await db.collection("plans").doc(planId).get();
                    if (planDoc.exists) {
                        planData = planDoc.data();
                        console.log("Found plan by document ID:", planId);
                    }
                }
                if (!planData) {
                    console.log("WARNING: No plan found for planId:", planId, "- Allowing booking (no limit check)");
                }
                else {
                    const limit = planData.washesPerMonth || 0;
                    const bonusWashes = sub.bonusWashes || 0;
                    const effectiveLimit = limit === -1 ? -1 : limit + bonusWashes;
                    console.log("Plan limit:", limit, "washesPerMonth (-1 = unlimited)");
                    console.log("Bonus washes:", bonusWashes, "Effective limit:", effectiveLimit);
                    if (effectiveLimit !== -1) { // -1 means unlimited
                        // Count bookings for this month
                        const startOfMonth = new Date(bookingDate.getFullYear(), bookingDate.getMonth(), 1);
                        const endOfMonth = new Date(bookingDate.getFullYear(), bookingDate.getMonth() + 1, 0, 23, 59, 59);
                        console.log("Checking bookings between:", startOfMonth.toISOString(), "and", endOfMonth.toISOString());
                        const countQuery = await db.collection("appointments")
                            .where("userId", "==", userId)
                            .where("scheduledTime", ">=", admin.firestore.Timestamp.fromDate(startOfMonth))
                            .where("scheduledTime", "<=", admin.firestore.Timestamp.fromDate(endOfMonth))
                            .get();
                        console.log("Found", countQuery.size, "bookings in date range");
                        // Filter out cancelled bookings (client-side filtering because of compound query limitations usually)
                        // Or we can rely on index if we add 'status' to the query, but let's filter here for simplicity and robustness
                        const validBookings = countQuery.docs.filter(d => d.data().status !== 'cancelled');
                        console.log("Valid (non-cancelled) bookings:", validBookings.length);
                        if (validBookings.length >= effectiveLimit) {
                            console.log("ERROR: Monthly booking limit reached!");
                            throw new https_1.HttpsError("resource-exhausted", `Você atingiu o limite de ${effectiveLimit} lavagens do seu plano para este mês.`);
                        }
                    }
                }
            }
        }
        else {
            console.log("User has no active subscription (non-premium)");
        }
        console.log("✓ Subscription check passed");
        // 4. Calculate Total Price
        // Fetch services to validate IDs and sum price
        console.log("Fetching services with IDs:", serviceIds);
        let totalPrice = 0;
        const servicesSnap = await db.collection("services").where(admin.firestore.FieldPath.documentId(), "in", serviceIds).get();
        console.log("Services found:", servicesSnap.size, "of", serviceIds.length, "requested");
        if (servicesSnap.empty || servicesSnap.size !== serviceIds.length) {
            // Some services might be invalid, but we'll proceed with found ones or throw
            // Let's just sum found ones
            console.log("WARNING: Some services not found, but continuing...");
        }
        servicesSnap.docs.forEach(doc => {
            const price = doc.data().price || 0;
            console.log(`Service ${doc.id}: price = ${price}`);
            totalPrice += price;
        });
        console.log("Total price calculated:", totalPrice);
        // 4. Concurrency & Capacity Checks
        // A. Check if THIS vehicle is already booked at this time (Prevent double booking same car)
        console.log("Checking vehicle conflict for vehicleId:", vehicleId, "at time:", bookingDate.toISOString());
        const vehicleConflictQuery = await db.collection("appointments")
            .where("vehicleId", "==", vehicleId)
            .where("scheduledTime", "==", admin.firestore.Timestamp.fromDate(bookingDate)) // Exact match probably enough for slots
            .get();
        console.log("Vehicle conflict query returned:", vehicleConflictQuery.size, "documents");
        const activeVehicleConflict = vehicleConflictQuery.docs.find(d => d.data().status !== 'cancelled');
        if (activeVehicleConflict) {
            console.log("ERROR: Vehicle already booked at this time!");
            throw new https_1.HttpsError("already-exists", "Este veículo já possui um agendamento neste horário.");
        }
        console.log("✓ Vehicle conflict check passed");
        // B. Check Global Shop Capacity (Anti-spam / Race condition)
        // We assume a standard capacity if not in config. 
        // Ideally fetch from /config/calendar or similar.
        const MAX_CONCURRENT_JOBS = 4; // Hardcoded safety limit
        console.log("Checking time slot capacity...");
        const timeSlotQuery = await db.collection("appointments")
            .where("scheduledTime", "==", admin.firestore.Timestamp.fromDate(bookingDate))
            .get();
        const activeJobsInSlot = timeSlotQuery.docs.filter(d => d.data().status !== 'cancelled').length;
        console.log("Active jobs in slot:", activeJobsInSlot, "of", MAX_CONCURRENT_JOBS, "max");
        if (activeJobsInSlot >= MAX_CONCURRENT_JOBS) {
            console.log("ERROR: Time slot capacity reached!");
            throw new https_1.HttpsError("resource-exhausted", "Horário esgotado! Por favor selecione outro horário (Capacidade máxima atingida).");
        }
        console.log("✓ Capacity check passed");
        // 5. Create Booking
        console.log("Creating booking...");
        const bookingData = {
            userId,
            vehicleId,
            serviceIds,
            scheduledTime: admin.firestore.Timestamp.fromDate(bookingDate),
            status: "scheduled",
            totalPrice,
            staffNotes: staffNotes || "",
            beforePhotos: [],
            afterPhotos: [],
            isRated: false,
            logs: [],
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        };
        console.log("Booking data:", JSON.stringify(Object.assign(Object.assign({}, bookingData), { scheduledTime: bookingDate.toISOString() })));
        const bookingRef = await db.collection("appointments").add(bookingData);
        console.log("✓ Booking created successfully! ID:", bookingRef.id);
        return { bookingId: bookingRef.id, status: "success", totalPrice };
    }
    catch (error) {
        if (error instanceof https_1.HttpsError)
            throw error;
        console.error("ERROR creating booking:", error);
        console.error("Error stack:", error.stack);
        throw new https_1.HttpsError("internal", "Não foi possível criar o agendamento.", error);
    }
});
/**
 * Cancels a booking with window validation.
 */
exports.cancelBooking = (0, https_1.onCall)(async (request) => {
    var _a, _b, _c;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Auth required.");
    }
    const { bookingId } = request.data;
    const userId = request.auth.uid;
    if (!bookingId) {
        throw new https_1.HttpsError("invalid-argument", "Missing bookingId.");
    }
    const db = admin.firestore();
    const bookingRef = db.collection("appointments").doc(bookingId);
    const bookingDoc = await bookingRef.get();
    if (!bookingDoc.exists) {
        throw new https_1.HttpsError("not-found", "Agendamento não encontrado.");
    }
    const booking = bookingDoc.data();
    // Security: Only owner or admin can cancel
    // We assume admin check is done via role but simple check here:
    if ((booking === null || booking === void 0 ? void 0 : booking.userId) !== userId) {
        // Check if user is admin? For now, strict owner check or error.
        // If needed, check user role.
        const userRoleDoc = await db.collection("users").doc(userId).get();
        if (((_a = userRoleDoc.data()) === null || _a === void 0 ? void 0 : _a.role) !== 'admin' && ((_b = userRoleDoc.data()) === null || _b === void 0 ? void 0 : _b.role) !== 'staff') {
            throw new https_1.HttpsError("permission-denied", "Não autorizado.");
        }
    }
    if ((booking === null || booking === void 0 ? void 0 : booking.status) === 'cancelled') {
        throw new https_1.HttpsError("failed-precondition", "Agendamento já cancelado.");
    }
    if ((booking === null || booking === void 0 ? void 0 : booking.status) === 'finished') {
        throw new https_1.HttpsError("failed-precondition", "Não é possível cancelar um agendamento finalizado.");
    }
    // Validation: Cancellation Window (e.g., 4 hours)
    const MIN_CANCEL_HOURS = 4;
    const scheduledTime = (booking === null || booking === void 0 ? void 0 : booking.scheduledTime) instanceof admin.firestore.Timestamp
        ? booking.scheduledTime.toDate()
        : new Date(booking === null || booking === void 0 ? void 0 : booking.scheduledTime); // Fallback if regular string
    const now = new Date();
    const diffHours = (scheduledTime.getTime() - now.getTime()) / (1000 * 60 * 60);
    // If cancelling close to time (less than 4 hours remaining)
    if (diffHours < MIN_CANCEL_HOURS && diffHours > 0) { // diffHours > 0 means still in future
        // Apply Policy: Prevent or Warning?
        // For now, PREVENT as per strict brainstorm rule, unless admin
        const userRoleDoc = await db.collection("users").doc(userId).get();
        const isStaffOrAdmin = ['admin', 'staff'].includes((_c = userRoleDoc.data()) === null || _c === void 0 ? void 0 : _c.role);
        if (!isStaffOrAdmin) {
            throw new https_1.HttpsError("failed-precondition", `Cancelamento permitido apenas com ${MIN_CANCEL_HOURS} horas de antecedência.`);
        }
    }
    await bookingRef.update({
        status: "cancelled",
        cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
        cancelledBy: userId
    });
    return { success: true };
});
/**
 * Scheduled function that runs every 5 minutes.
 * Automatically cancels bookings that:
 * 1. Have status 'scheduled' (not confirmed)
 * 2. Are past their deadline (scheduledTime - 15 minutes < now)
 */
exports.autoExpireUnconfirmedBookings = (0, scheduler_1.onSchedule)({
    schedule: "every 5 minutes",
    timeZone: "America/Sao_Paulo",
    retryCount: 0,
}, async () => {
    var _a;
    const db = admin.firestore();
    const now = new Date();
    // Deadline: 15 minutes before scheduled time
    // So we look for bookings where scheduledTime - 15min < now
    // Which means: scheduledTime < now + 15min
    const deadlineThreshold = new Date(now.getTime() + 15 * 60 * 1000);
    console.log(`[AutoExpire] Running at ${now.toISOString()}`);
    console.log(`[AutoExpire] Looking for unconfirmed bookings with scheduledTime < ${deadlineThreshold.toISOString()}`);
    try {
        // Query bookings with status 'scheduled' and scheduledTime before threshold
        const expiredQuery = await db.collection("appointments")
            .where("status", "==", "scheduled")
            .where("scheduledTime", "<", admin.firestore.Timestamp.fromDate(deadlineThreshold))
            .get();
        if (expiredQuery.empty) {
            console.log("[AutoExpire] No expired bookings found.");
            return;
        }
        console.log(`[AutoExpire] Found ${expiredQuery.size} booking(s) to cancel.`);
        const batch = db.batch();
        const usersToNotify = [];
        for (const doc of expiredQuery.docs) {
            const booking = doc.data();
            const bookingId = doc.id;
            const userId = booking.userId;
            const scheduledTime = booking.scheduledTime instanceof admin.firestore.Timestamp
                ? booking.scheduledTime.toDate()
                : new Date(booking.scheduledTime);
            console.log(`[AutoExpire] Cancelling booking ${bookingId} (scheduled for ${scheduledTime.toISOString()})`);
            // Update booking status
            batch.update(doc.ref, {
                status: "cancelled",
                cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
                cancelledBy: "system",
                cancellationReason: "auto_expired_unconfirmed",
            });
            usersToNotify.push({ userId, bookingId, scheduledTime });
        }
        await batch.commit();
        console.log(`[AutoExpire] Successfully cancelled ${expiredQuery.size} booking(s).`);
        // Send notifications to affected users
        for (const { userId, bookingId, scheduledTime: _scheduledTime } of usersToNotify) {
            try {
                // Create in-app notification
                await db.collection("users").doc(userId).collection("notifications").add({
                    title: "Agendamento Cancelado",
                    body: "Seu agendamento foi cancelado automaticamente pois não foi confirmado a tempo.",
                    timestamp: admin.firestore.FieldValue.serverTimestamp(),
                    bookingId: bookingId,
                    isRead: false,
                    type: "auto_cancelled",
                });
                // Get user's FCM token for push notification
                const userDoc = await db.collection("users").doc(userId).get();
                const fcmToken = (_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a.fcmToken;
                if (fcmToken) {
                    await admin.messaging().send({
                        token: fcmToken,
                        data: {
                            bookingId: bookingId,
                            type: "auto_cancelled",
                            title: "Agendamento Cancelado",
                            body: "Seu agendamento foi cancelado automaticamente pois não foi confirmado a tempo.",
                        },
                        android: {
                            notification: {
                                title: "Agendamento Cancelado ❌",
                                body: "Seu agendamento foi cancelado automaticamente.",
                                channelId: "high_importance_channel",
                            },
                        },
                        apns: {
                            payload: {
                                aps: {
                                    alert: {
                                        title: "Agendamento Cancelado",
                                        body: "Seu agendamento foi cancelado automaticamente.",
                                    },
                                    sound: "default",
                                },
                            },
                        },
                        webpush: {
                            headers: { Urgency: "high", TTL: "86400" },
                        },
                    });
                    console.log(`[AutoExpire] Push notification sent to user ${userId}`);
                }
            }
            catch (notifError) {
                console.error(`[AutoExpire] Failed to notify user ${userId}:`, notifError);
            }
        }
    }
    catch (error) {
        console.error("[AutoExpire] Critical error:", error);
    }
});
//# sourceMappingURL=booking.js.map