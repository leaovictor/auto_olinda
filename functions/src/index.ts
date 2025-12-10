import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { setGlobalOptions } from "firebase-functions/v2";
import * as admin from "firebase-admin";

admin.initializeApp();

// Set resource limits to control costs and stay within quota
// Using São Paulo region for better latency in Brazil
setGlobalOptions({
  region: "southamerica-east1",
  maxInstances: 1,
  minInstances: 0,
  memory: "256MiB",
  cpu: 1,
  concurrency: 80,
});

/**
 * Triggers when a booking document is updated.
 * Checks if the 'status' field has changed.
 * If changed, sends an FCM notification to the user AND all admins.
 * 
 * NOTE: We override the region here because Firestore database is in nam5 (US)
 * and Firestore triggers require the function to be in a compatible region.
 */
export const onBookingStatusChange = onDocumentUpdated(
  {
    document: "appointments/{bookingId}",
    region: "us-central1", // Must be in US region for Firestore triggers with nam5 database
  },
  async (event) => {
    if (!event.data) return;

    const oldData = event.data.before.data();
    const newData = event.data.after.data();

    // If data is missing or status hasn't changed, do nothing
    if (!oldData || !newData || oldData.status === newData.status) {
      return;
    }

    const userId = newData.userId;
    const newStatus = newData.status;
    const bookingId = event.params.bookingId;
    const vehicleId = newData.vehicleId;

    console.log(
      `Booking ${bookingId} status changed from ${oldData.status} ` +
      `to ${newStatus} for user ${userId}`,
    );

    try {
      // 1. Get User's FCM Token and Data
      const userDoc = await admin.firestore()
        .collection("users")
        .doc(userId)
        .get();

      if (!userDoc.exists) {
        console.log(`User ${userId} not found`);
        return;
      }

      const userData = userDoc.data();
      const fcmToken = userData?.fcmToken;

      // 2. Get vehicle info for admin notification
      let vehicleInfo = "";
      if (vehicleId) {
        // Try to get vehicle from user's vehicles subcollection
        const vehicleQuery = await admin.firestore()
          .collectionGroup("vehicles")
          .where("id", "==", vehicleId)
          .limit(1)
          .get();

        if (!vehicleQuery.empty) {
          const vehicleData = vehicleQuery.docs[0].data();
          vehicleInfo = `${vehicleData.brand || ""} ${vehicleData.model || ""} (${vehicleData.plate || ""})`.trim();
        }
      }

      // 3. Prepare Notification Content for CLIENT
      let title = "Atualização de Agendamento";
      let body = `O status do seu agendamento mudou para ${newStatus}.`;

      switch (newStatus) {
        case "checkIn":
          title = "Check-in Realizado ✅";
          body = "Seu veículo está em nossas mãos. Aguarde!";
          break;
        case "confirmed":
          title = "Agendamento Confirmado!";
          body = "Seu agendamento foi confirmado. Te esperamos lá!";
          break;
        case "washing":
          title = "Lavagem Iniciada 🚿";
          body = "Seu carro está tomando um banho agora.";
          break;
        case "vacuuming":
          title = "Aspiração em Andamento 🧹";
          body = "Estamos limpando o interior do seu veículo.";
          break;
        case "drying":
          title = "Secagem em Andamento 💨";
          body = "Estamos secando seu veículo com cuidado.";
          break;
        case "polishing":
          title = "Polimento em Andamento ✨";
          body = "Quase lá! Estamos dando o toque final de brilho.";
          break;
        case "finished":
          title = "Seu carro brilha! ✨";
          body = "Tudo pronto. Pode vir retirar seu veículo. Avalie sua experiência!";
          break;
        case "cancelled":
          title = "Agendamento Cancelado";
          body = "Seu agendamento foi cancelado.";
          break;
        default:
          // Keep generic title/body
          break;
      }

      // 4. Prepare Admin Notification Content
      const adminTitle = `Atualização: ${newStatus}`;
      const adminBody = vehicleInfo
        ? `Veículo ${vehicleInfo} mudou para ${newStatus}`
        : `Agendamento #${bookingId.substring(0, 6)} mudou para ${newStatus}`;

      // 5. Save to Firestore Notification History for CLIENT
      await admin.firestore()
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .add({
          title: title,
          body: body,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          bookingId: bookingId,
          isRead: false,
          type: "status_update",
          status: newStatus,
        });

      console.log(`In-app notification saved for user ${userId}`);

      // 6. Get all admin users and notify them
      const adminUsersSnapshot = await admin.firestore()
        .collection("users")
        .where("role", "==", "admin")
        .get();

      const adminTokens: string[] = [];
      const notificationBatch = admin.firestore().batch();
      const timestamp = admin.firestore.FieldValue.serverTimestamp();

      for (const adminDoc of adminUsersSnapshot.docs) {
        const adminData = adminDoc.data();

        // Create in-app notification for admin
        const notificationRef = admin.firestore()
          .collection("users")
          .doc(adminDoc.id)
          .collection("notifications")
          .doc();

        notificationBatch.set(notificationRef, {
          title: adminTitle,
          body: adminBody,
          timestamp: timestamp,
          bookingId: bookingId,
          isRead: false,
          type: "booking_update",
          status: newStatus,
        });

        // Collect FCM tokens for push notifications
        if (adminData.fcmToken && adminData.fcmToken !== fcmToken) {
          adminTokens.push(adminData.fcmToken);
        }
      }

      // Commit admin notifications batch
      await notificationBatch.commit();
      console.log(`In-app notifications saved for ${adminUsersSnapshot.size} admins`);

      // 7. Send FCM to admins
      if (adminTokens.length > 0) {
        try {
          const adminMessage = {
            notification: {
              title: adminTitle,
              body: adminBody,
            },
            data: {
              bookingId: bookingId,
              status: newStatus,
              type: "booking_update",
            },
            tokens: adminTokens,
            android: {
              notification: {
                channelId: "high_importance_channel",
                priority: "high" as const,
              },
            },
          };

          const adminResponse = await admin.messaging().sendEachForMulticast(adminMessage);
          console.log(`Push sent to ${adminResponse.successCount} admins`);
        } catch (adminFcmError) {
          console.error("Error sending FCM to admins:", adminFcmError);
        }
      }

      // 8. Send FCM Message to CLIENT (IF TOKEN EXISTS)
      if (!fcmToken) {
        console.log(`No FCM token for user ${userId} - skipping push notification`);
        return;
      }

      const message = {
        notification: {
          title: title,
          body: body,
        },
        data: {
          bookingId: bookingId,
          status: newStatus,
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        token: fcmToken,
        android: {
          notification: {
            channelId: "high_importance_channel",
            priority: "high" as const,
          },
        },
      };

      try {
        await admin.messaging().send(message);
        console.log(`Push notification sent to user ${userId}`);
      } catch (fcmError) {
        console.error(`Error sending FCM to user ${userId}:`, fcmError);
        // Continue execution - do not rethrow, as in-app notification is already saved
      }

    } catch (error) {
      console.error("Critical error in onBookingStatusChange:", error);
    }
  },
);

export * from "./stripe";
export * from "./booking";

export * from "./ecommerce";
export * from "./notifications";

export {
  createBookingPaymentIntent,
  createBookingCheckoutSession,
} from "./payment";

