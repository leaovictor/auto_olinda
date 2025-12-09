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
 * If changed, sends an FCM notification to the user.
 */
export const onBookingStatusChange = onDocumentUpdated(
  "appointments/{bookingId}",
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

    console.log(
      `Booking ${bookingId} status changed from ${oldData.status} ` +
      `to ${newStatus} for user ${userId}`,
    );

    try {
      // 1. Get User's FCM Token
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

      if (!fcmToken) {
        console.log(`No FCM token for user ${userId}`);
        return;
      }

      // 2. Prepare Notification Content
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
        case "polishing":
          title = "Polimento em Andamento ✨";
          body = "Estamos dando brilho especial ao seu carro.";
          break;
        case "drying":
          title = "Secagem em Andamento 💨";
          body = "Quase lá! Estamos dando o toque final.";
          break;
        case "finished":
          title = "Seu carro brilha! ✨";
          body = "Tudo pronto. Pode vir retirar seu veículo. Avalie sua experiência!";
          break;
        case "cancelled":
          title = "Agendamento Cancelado";
          body = "Seu agendamento foi cancelado.";
          break;
      }

      // 3. Send FCM Message
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
      };

      await admin.messaging().send(message);
      console.log(`Notification sent to user ${userId}`);

      // 4. Save to Firestore Notification History
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
        });
    } catch (error) {
      console.error("Error sending notification:", error);
    }
  },
);
export * from "./stripe";
export * from "./booking";
// export * from "./seed";  // Removed - function deleted
// export * from "./migrate_plans";  // Removed - function deleted
export * from "./ecommerce";
export * from "./notifications";

export {
  createBookingPaymentIntent,
  createBookingCheckoutSession,
} from "./payment";

