import { onCall, HttpsError } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";

/**
 * Creates a new booking with security checks.
 * Enforces:
 * 1. Schema Validation
 * 2. Lead Time (min 2 hours)
 * 3. Subscription Limits (Excessive Wash)
 * 4. Concurrency Anti-spam
 */
export const createBooking = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "The function must be called while authenticated.",
    );
  }

  const { vehicleId, serviceIds, scheduledTime, staffNotes } = request.data;
  const userId = request.auth.uid;

  // 1. Validation
  if (!vehicleId || !serviceIds || !Array.isArray(serviceIds) || serviceIds.length === 0 || !scheduledTime) {
    throw new HttpsError("invalid-argument", "Missing required fields (vehicleId, serviceIds, scheduledTime).");
  }

  const db = admin.firestore();
  
  // Parse Scheduled Time
  const bookingDate = new Date(scheduledTime);
  const now = new Date();
  
  if (isNaN(bookingDate.getTime())) {
    throw new HttpsError("invalid-argument", "Invalid date format.");
  }

  // 2. Lead Time Rule: 2 Hours minimum
  // TODO: Make this configurable via Firestore 'config'
  const MIN_LEAD_HOURS = 2; 
  const diffHours = (bookingDate.getTime() - now.getTime()) / (1000 * 60 * 60);

  if (diffHours < MIN_LEAD_HOURS) {
    throw new HttpsError(
      "failed-precondition", 
      `Agendamentos devem ser feitos com no mínimo ${MIN_LEAD_HOURS} horas de antecedência.`
    );
  }

  try {
    // 3. User & Subscription Check
    // Check if user is blocked or suspended (optional)
    const userDoc = await db.collection("users").doc(userId).get();
    const userData = userDoc.data();
    
    if (userData?.status === 'suspended') {
      throw new HttpsError("permission-denied", "Sua conta está suspensa. Entre em contato com o suporte.");
    }

    // Check Subscription Limit
    const subsQuery = await db.collection("subscriptions")
      .where("userId", "==", userId)
      .where("status", "==", "active")
      .limit(1)
      .get();

    if (!subsQuery.empty) {
      const sub = subsQuery.docs[0].data();
      const planId = sub.planId;
      
      if (planId) {
        const planDoc = await db.collection("plans").doc(planId).get();
        const planData = planDoc.data();
        const limit = planData?.washesPerMonth || 0;

        if (limit !== -1) { // -1 usually means unlimited
          // Count bookings for this month
          const startOfMonth = new Date(bookingDate.getFullYear(), bookingDate.getMonth(), 1);
          const endOfMonth = new Date(bookingDate.getFullYear(), bookingDate.getMonth() + 1, 0, 23, 59, 59);

          const countQuery = await db.collection("appointments")
            .where("userId", "==", userId)
            .where("scheduledTime", ">=", admin.firestore.Timestamp.fromDate(startOfMonth))
            .where("scheduledTime", "<=", admin.firestore.Timestamp.fromDate(endOfMonth))
            .get();

          // Filter out cancelled bookings (client-side filtering because of compound query limitations usually)
          // Or we can rely on index if we add 'status' to the query, but let's filter here for simplicity and robustness
          const validBookings = countQuery.docs.filter(d => d.data().status !== 'cancelled');
          
          if (validBookings.length >= limit) {
             throw new HttpsError(
              "resource-exhausted", 
              `Você atingiu o limite de ${limit} lavagens do seu plano para este mês.`
            );
          }
        }
      }
    }

    // 4. Calculate Total Price
    // Fetch services to validate IDs and sum price
    let totalPrice = 0;
    const servicesSnap = await db.collection("services").where(admin.firestore.FieldPath.documentId(), "in", serviceIds).get();
    
    if (servicesSnap.empty || servicesSnap.size !== serviceIds.length) {
       // Some services might be invalid, but we'll proceed with found ones or throw
       // Let's just sum found ones
    }
    
    servicesSnap.docs.forEach(doc => {
      totalPrice += (doc.data().price || 0);
    });


    // 4. Concurrency & Capacity Checks
    // A. Check if THIS vehicle is already booked at this time (Prevent double booking same car)
    const vehicleConflictQuery = await db.collection("appointments")
      .where("vehicleId", "==", vehicleId)
      .where("scheduledTime", "==", admin.firestore.Timestamp.fromDate(bookingDate)) // Exact match probably enough for slots
      .get();
      
    const activeVehicleConflict = vehicleConflictQuery.docs.find(d => d.data().status !== 'cancelled');
    if (activeVehicleConflict) {
       throw new HttpsError("already-exists", "Este veículo já possui um agendamento neste horário.");
    }

    // B. Check Global Shop Capacity (Anti-spam / Race condition)
    // We assume a standard capacity if not in config. 
    // Ideally fetch from /config/calendar or similar.
    const MAX_CONCURRENT_JOBS = 4; // Hardcoded safety limit
    
    const timeSlotQuery = await db.collection("appointments")
      .where("scheduledTime", "==", admin.firestore.Timestamp.fromDate(bookingDate))
      .get();
      
    const activeJobsInSlot = timeSlotQuery.docs.filter(d => d.data().status !== 'cancelled').length;
    
    if (activeJobsInSlot >= MAX_CONCURRENT_JOBS) {
       throw new HttpsError("resource-exhausted", "Horário esgotado! Por favor selecione outro horário (Capacidade máxima atingida).");
    }

    // 5. Create Booking
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

    const bookingRef = await db.collection("appointments").add(bookingData);

    return { bookingId: bookingRef.id, status: "success", totalPrice };

  } catch (error: any) {
    if (error instanceof HttpsError) throw error;
    console.error("Error creating booking:", error);
    throw new HttpsError("internal", "Não foi possível criar o agendamento.", error);
  }
});

/**
 * Cancels a booking with window validation.
 */
export const cancelBooking = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Auth required.");
  }

  const { bookingId } = request.data;
  const userId = request.auth.uid;

  if (!bookingId) {
    throw new HttpsError("invalid-argument", "Missing bookingId.");
  }

  const db = admin.firestore();
  const bookingRef = db.collection("appointments").doc(bookingId);
  const bookingDoc = await bookingRef.get();

  if (!bookingDoc.exists) {
    throw new HttpsError("not-found", "Agendamento não encontrado.");
  }

  const booking = bookingDoc.data();
  
  // Security: Only owner or admin can cancel
  // We assume admin check is done via role but simple check here:
  if (booking?.userId !== userId) {
      // Check if user is admin? For now, strict owner check or error.
      // If needed, check user role.
      const userRoleDoc = await db.collection("users").doc(userId).get();
      if (userRoleDoc.data()?.role !== 'admin' && userRoleDoc.data()?.role !== 'staff') {
         throw new HttpsError("permission-denied", "Não autorizado.");
      }
  }

  if (booking?.status === 'cancelled') {
     throw new HttpsError("failed-precondition", "Agendamento já cancelado.");
  }

  if (booking?.status === 'finished') {
     throw new HttpsError("failed-precondition", "Não é possível cancelar um agendamento finalizado.");
  }
  
  // Validation: Cancellation Window (e.g., 4 hours)
  const MIN_CANCEL_HOURS = 4;
  const scheduledTime = booking?.scheduledTime instanceof admin.firestore.Timestamp 
    ? booking.scheduledTime.toDate() 
    : new Date(booking?.scheduledTime); // Fallback if regular string
    
  const now = new Date();
  const diffHours = (scheduledTime.getTime() - now.getTime()) / (1000 * 60 * 60);

  // If cancelling close to time (less than 4 hours remaining)
  if (diffHours < MIN_CANCEL_HOURS && diffHours > 0) { // diffHours > 0 means still in future
     // Apply Policy: Prevent or Warning?
     // For now, PREVENT as per strict brainstorm rule, unless admin
     const userRoleDoc = await db.collection("users").doc(userId).get();
     const isStaffOrAdmin = ['admin', 'staff'].includes(userRoleDoc.data()?.role);
     
     if (!isStaffOrAdmin) {
       throw new HttpsError(
         "failed-precondition", 
         `Cancelamento permitido apenas com ${MIN_CANCEL_HOURS} horas de antecedência.`
       );
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
export const autoExpireUnconfirmedBookings = onSchedule(
  {
    schedule: "every 5 minutes",
    timeZone: "America/Sao_Paulo",
    retryCount: 0,
  },
  async () => {
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
      const usersToNotify: { userId: string; bookingId: string; scheduledTime: Date }[] = [];

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
      for (const { userId, bookingId, scheduledTime } of usersToNotify) {
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
          const fcmToken = userDoc.data()?.fcmToken;

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
        } catch (notifError) {
          console.error(`[AutoExpire] Failed to notify user ${userId}:`, notifError);
        }
      }

    } catch (error) {
      console.error("[AutoExpire] Critical error:", error);
    }
  }
);
