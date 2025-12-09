import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

interface SendNotificationRequest {
    targetType: "all" | "plan" | "user";
    targetId?: string; // planId for 'plan', userId for 'user'
    title: string;
    body: string;
}

/**
 * Cloud Function to send push notifications from admin panel
 * Supports: all users, users by subscription plan, individual user
 */
export const sendAdminNotification = onCall(
    { maxInstances: 2 },
    async (request) => {
        // Verify admin role
        if (!request.auth) {
            throw new HttpsError("unauthenticated", "Usuário não autenticado");
        }

        // Get user role from Firestore
        const adminDoc = await admin.firestore()
            .collection("users")
            .doc(request.auth.uid)
            .get();

        if (!adminDoc.exists || adminDoc.data()?.role !== "admin") {
            throw new HttpsError(
                "permission-denied",
                "Apenas administradores podem enviar notificações"
            );
        }

        const data = request.data as SendNotificationRequest;

        // Validate input
        if (!data.title || data.title.length > 65) {
            throw new HttpsError(
                "invalid-argument",
                "Título é obrigatório e deve ter no máximo 65 caracteres"
            );
        }

        if (!data.body || data.body.length > 240) {
            throw new HttpsError(
                "invalid-argument",
                "Mensagem é obrigatória e deve ter no máximo 240 caracteres"
            );
        }

        if (!["all", "plan", "user"].includes(data.targetType)) {
            throw new HttpsError("invalid-argument", "Tipo de destino inválido");
        }

        if ((data.targetType === "plan" || data.targetType === "user") &&
            !data.targetId) {
            throw new HttpsError(
                "invalid-argument",
                "ID do destino é obrigatório para este tipo"
            );
        }

        try {
            let userIds: string[] = [];
            const db = admin.firestore();

            // Get target user IDs based on type
            switch (data.targetType) {
                case "all": {
                    // Get all users with FCM tokens
                    const allUsers = await db.collection("users")
                        .where("fcmToken", "!=", null)
                        .get();
                    userIds = allUsers.docs.map((doc) => doc.id);
                    break;
                }
                case "plan": {
                    // Get users subscribed to specific plan
                    const subscribers = await db.collection("subscriptions")
                        .where("planId", "==", data.targetId)
                        .where("status", "==", "active")
                        .get();

                    for (const sub of subscribers.docs) {
                        const subData = sub.data();
                        if (subData.userId) {
                            userIds.push(subData.userId);
                        }
                    }
                    break;
                }
                case "user": {
                    userIds = [data.targetId!];
                    break;
                }
            }

            if (userIds.length === 0) {
                return { success: false, message: "Nenhum destinatário encontrado" };
            }

            // Get FCM tokens for users
            const tokens: string[] = [];
            const batch = db.batch();
            const timestamp = admin.firestore.FieldValue.serverTimestamp();

            for (const userId of userIds) {
                const userDoc = await db.collection("users").doc(userId).get();
                const userData = userDoc.data();

                if (userData?.fcmToken) {
                    tokens.push(userData.fcmToken);
                }

                // Save notification to user's history
                const notificationRef = db.collection("users")
                    .doc(userId)
                    .collection("notifications")
                    .doc();

                batch.set(notificationRef, {
                    title: data.title,
                    body: data.body,
                    timestamp: timestamp,
                    isRead: false,
                    type: "admin_message",
                });
            }

            // Commit notification history batch
            await batch.commit();

            // Send FCM messages
            if (tokens.length > 0) {
                const message = {
                    notification: {
                        title: data.title,
                        body: data.body,
                    },
                    data: {
                        type: "admin_message",
                    },
                    tokens: tokens,
                };

                const response = await admin.messaging().sendEachForMulticast(message);

                console.log(
                    `Notifications sent: ${response.successCount} success, ` +
                    `${response.failureCount} failures`
                );

                return {
                    success: true,
                    sent: response.successCount,
                    failed: response.failureCount,
                    totalUsers: userIds.length,
                };
            }

            return {
                success: true,
                sent: 0,
                failed: 0,
                totalUsers: userIds.length,
                message: "Notificações salvas, mas nenhum token FCM encontrado",
            };
        } catch (error) {
            console.error("Error sending admin notification:", error);
            throw new HttpsError("internal", "Erro ao enviar notificações");
        }
    }
);
