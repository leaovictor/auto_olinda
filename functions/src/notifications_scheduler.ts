
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";

/**
 * T-24h Confirmation Reminder
 * Runs every hour. Finds bookings scheduled for [now + 23.5h] to [now + 24.5h].
 * Sends push with "Confirmar" action.
 */
export const sendBookingConfirmationReminder = onSchedule(
  {
    schedule: "every 1 hours",
    timeZone: "America/Sao_Paulo",
    retryCount: 0,
  },
  async () => {
    const db = admin.firestore();
    const now = new Date();
    
    // Target window: 24 hours from now (+/- 30 mins to catch all in hourly run)
    const targetStart = new Date(now.getTime() + (23 * 60 + 30) * 60 * 1000); // +23.5h
    const targetEnd = new Date(now.getTime() + (24 * 60 + 30) * 60 * 1000);   // +24.5h
    
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
        const fcmToken = userDoc.data()?.fcmToken;

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

    } catch (error) {
      console.error("[ConfReminder] Error:", error);
    }
  }
);


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
export const sendBookingOneHourReminder = onSchedule(
  {
    schedule: "every 15 minutes",
    timeZone: "America/Sao_Paulo",
    retryCount: 0,
  },
  async () => {
    const db = admin.firestore();
    const now = new Date();
    
    // Target window: +1h (+/- 10 mins)
    const targetStart = new Date(now.getTime() + (50) * 60 * 1000); // +50m
    const targetEnd = new Date(now.getTime() + (70) * 60 * 1000);   // +70m
    
    console.log(`[1hReminder] Running. Looking for bookings between ${targetStart.toISOString()} and ${targetEnd.toISOString()}`);

    try {
      // Find ACTIVE bookings (scheduled OR confirmed)
      const snapshot = await db.collection("appointments")
        .where("scheduledTime", ">=", admin.firestore.Timestamp.fromDate(targetStart))
        .where("scheduledTime", "<=", admin.firestore.Timestamp.fromDate(targetEnd))
        .get();

      const validBookings = snapshot.docs.filter(d => 
          ['scheduled', 'confirmed'].includes(d.data().status)
      );

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
        const fcmToken = userDoc.data()?.fcmToken;

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

    } catch (error) {
      console.error("[1hReminder] Error:", error);
    }
  }
);


/**
 * Rating Reminder
 * Runs every 30 minutes.
 * Logic: Find bookings that Finished between [30m, 60m] ago AND isRated == false.
 * Send "Avalie sua experiência" push.
 */
export const sendRatingReminder = onSchedule(
  {
    schedule: "every 30 minutes",
    timeZone: "America/Sao_Paulo",
    retryCount: 0,
  },
  async () => {
    const db = admin.firestore();
    const now = new Date();
    
    // Target window: 30-60 mins ago
    // If finishedAt was 30 mins ago -> now - 30m
    const windowStart = new Date(now.getTime() - 60 * 60 * 1000); // 1h ago
    const windowEnd = new Date(now.getTime() - 30 * 60 * 1000);   // 30m ago
    
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
        const fcmToken = userDoc.data()?.fcmToken;

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

    } catch (error) {
      console.error("[RatingReminder] Error:", error);
    }
  }
);
