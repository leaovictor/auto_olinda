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
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !Object.prototype.hasOwnProperty.call(exports, p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.createBookingCheckoutSession = exports.createBookingPaymentIntent = exports.onBookingStatusChange = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const v2_1 = require("firebase-functions/v2");
const admin = require("firebase-admin");
admin.initializeApp();
// Set max instances to control costs
(0, v2_1.setGlobalOptions)({ maxInstances: 2 });
/**
 * Triggers when a booking document is updated.
 * Checks if the 'status' field has changed.
 * If changed, sends an FCM notification to the user.
 */
exports.onBookingStatusChange = (0, firestore_1.onDocumentUpdated)("appointments/{bookingId}", async (event) => {
    if (!event.data)
        return;
    const oldData = event.data.before.data();
    const newData = event.data.after.data();
    // If data is missing or status hasn't changed, do nothing
    if (!oldData || !newData || oldData.status === newData.status) {
        return;
    }
    const userId = newData.userId;
    const newStatus = newData.status;
    const bookingId = event.params.bookingId;
    console.log(`Booking ${bookingId} status changed from ${oldData.status} ` +
        `to ${newStatus} for user ${userId}`);
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
        const fcmToken = userData === null || userData === void 0 ? void 0 : userData.fcmToken;
        if (!fcmToken) {
            console.log(`No FCM token for user ${userId}`);
            return;
        }
        // 2. Prepare Notification Content
        let title = "Atualização de Agendamento";
        let body = `O status do seu agendamento mudou para ${newStatus}.`;
        switch (newStatus) {
            case "confirmed":
                title = "Agendamento Confirmado!";
                body = "Seu agendamento foi confirmado. Te esperamos lá!";
                break;
            case "washing":
                title = "Lavagem Iniciada 🚿";
                body = "Seu carro está tomando um banho agora.";
                break;
            case "drying":
                title = "Secagem em Andamento 💨";
                body = "Quase lá! Estamos dando o brilho final.";
                break;
            case "finished":
                title = "Seu carro brilha! ✨";
                body = "Tudo pronto. Pode vir retirar seu veículo.";
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
    }
    catch (error) {
        console.error("Error sending notification:", error);
    }
});
__exportStar(require("./stripe"), exports);
__exportStar(require("./booking"), exports);
__exportStar(require("./seed"), exports);
__exportStar(require("./migrate_plans"), exports);
__exportStar(require("./ecommerce"), exports);
var payment_1 = require("./payment");
Object.defineProperty(exports, "createBookingPaymentIntent", { enumerable: true, get: function () { return payment_1.createBookingPaymentIntent; } });
Object.defineProperty(exports, "createBookingCheckoutSession", { enumerable: true, get: function () { return payment_1.createBookingCheckoutSession; } });
//# sourceMappingURL=index.js.map