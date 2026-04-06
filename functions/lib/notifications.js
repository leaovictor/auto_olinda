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
exports.sendAdminNotification = void 0;
const https_1 = require("firebase-functions/v2/https");
const admin = __importStar(require("firebase-admin"));
/**
 * Cloud Function to send push notifications from admin panel
 * Supports: all users, users by subscription plan, individual user
 */
exports.sendAdminNotification = (0, https_1.onCall)({ maxInstances: 2 }, async (request) => {
    // Verify admin role
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Usuário não autenticado");
    }
    // Get user role from Firestore
    const adminDoc = await admin.firestore()
        .collection("users")
        .doc(request.auth.uid)
        .get();
    if (!adminDoc.exists || adminDoc.data()?.role !== "admin") {
        throw new https_1.HttpsError("permission-denied", "Apenas administradores podem enviar notificações");
    }
    const data = request.data;
    // Validate input
    if (!data.title || data.title.length > 65) {
        throw new https_1.HttpsError("invalid-argument", "Título é obrigatório e deve ter no máximo 65 caracteres");
    }
    if (!data.body || data.body.length > 240) {
        throw new https_1.HttpsError("invalid-argument", "Mensagem é obrigatória e deve ter no máximo 240 caracteres");
    }
    if (!["all", "plan", "user"].includes(data.targetType)) {
        throw new https_1.HttpsError("invalid-argument", "Tipo de destino inválido");
    }
    if ((data.targetType === "plan" || data.targetType === "user") &&
        !data.targetId) {
        throw new https_1.HttpsError("invalid-argument", "ID do destino é obrigatório para este tipo");
    }
    try {
        let userIds = [];
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
                userIds = [data.targetId];
                break;
            }
        }
        if (userIds.length === 0) {
            return { success: false, message: "Nenhum destinatário encontrado" };
        }
        // Get FCM tokens for users
        const tokenSet = new Set();
        const batch = db.batch();
        const timestamp = admin.firestore.FieldValue.serverTimestamp();
        for (const userId of userIds) {
            const userDoc = await db.collection("users").doc(userId).get();
            const userData = userDoc.data();
            if (userData?.fcmToken) {
                // Use Set to avoid duplicate tokens (same device, different users)
                tokenSet.add(userData.fcmToken);
                console.log(`Token found for user ${userId}: ${userData.fcmToken.substring(0, 20)}...`);
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
        // Convert Set to Array for FCM multicast
        const tokens = Array.from(tokenSet);
        // Send FCM messages
        if (tokens.length > 0) {
            console.log(`Sending push to ${tokens.length} unique tokens for ${userIds.length} users`);
            const message = {
                notification: {
                    title: data.title,
                    body: data.body,
                },
                data: {
                    type: "admin_message",
                },
                tokens: tokens,
                android: {
                    notification: {
                        channelId: "high_importance_channel",
                        priority: "high",
                    },
                },
            };
            const response = await admin.messaging().sendEachForMulticast(message);
            console.log(`Notifications sent: ${response.successCount} success, ` +
                `${response.failureCount} failures`);
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
    }
    catch (error) {
        console.error("Error sending admin notification:", error);
        throw new https_1.HttpsError("internal", "Erro ao enviar notificações");
    }
});
//# sourceMappingURL=notifications.js.map