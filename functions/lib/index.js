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
exports.createPixPaymentIntent = exports.createBookingCheckoutSession = exports.createBookingPaymentIntent = exports.seedDatabase = exports.onBookingStatusChange = exports.onNewBookingCreated = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const v2_1 = require("firebase-functions/v2");
const admin = require("firebase-admin");
admin.initializeApp();
// Set resource limits to control costs and stay within quota
// Using São Paulo region for better latency in Brazil
// CPU set to gcf_gen1 for automatic allocation (avoids quota exceeded errors)
// Note: gcf_gen1 doesn't support concurrency > 1
(0, v2_1.setGlobalOptions)({
    region: "southamerica-east1",
    maxInstances: 1,
    minInstances: 0,
    memory: "256MiB",
    cpu: "gcf_gen1", // Use automatic CPU allocation based on memory
});
/**
 * Triggers when a NEW booking document is created.
 * Sends notification to all admins about the new booking.
 */
exports.onNewBookingCreated = (0, firestore_1.onDocumentCreated)({
    document: "appointments/{bookingId}",
    // Uses southamerica-east1 from setGlobalOptions (Firestore database must be in same region)
}, async (event) => {
    var _a;
    if (!event.data)
        return;
    const bookingData = event.data.data();
    const bookingId = event.params.bookingId;
    const userId = bookingData === null || bookingData === void 0 ? void 0 : bookingData.userId;
    const vehicleId = bookingData === null || bookingData === void 0 ? void 0 : bookingData.vehicleId;
    const scheduledTime = bookingData === null || bookingData === void 0 ? void 0 : bookingData.scheduledTime;
    console.log(`New booking ${bookingId} created by user ${userId}`);
    try {
        // 1. Get user info
        let userName = "Cliente";
        if (userId) {
            console.log(`Fetching user info for userId: ${userId}`);
            const userDoc = await admin.firestore()
                .collection("users")
                .doc(userId)
                .get();
            if (userDoc.exists) {
                userName = ((_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a.displayName) || "Cliente";
            }
            console.log(`User name: ${userName}`);
        }
        // 2. Get vehicle info (from main vehicles collection)
        let vehicleInfo = "";
        let vehiclePlate = "";
        if (vehicleId) {
            try {
                console.log(`Fetching vehicle info for vehicleId: ${vehicleId}`);
                const vehicleDoc = await admin.firestore()
                    .collection("vehicles")
                    .doc(vehicleId)
                    .get();
                if (vehicleDoc.exists) {
                    const vehicleData = vehicleDoc.data();
                    vehiclePlate = (vehicleData === null || vehicleData === void 0 ? void 0 : vehicleData.plate) || "";
                    vehicleInfo = `${(vehicleData === null || vehicleData === void 0 ? void 0 : vehicleData.brand) || ""} ${(vehicleData === null || vehicleData === void 0 ? void 0 : vehicleData.model) || ""} (${vehiclePlate})`.trim();
                }
                console.log(`Vehicle info: ${vehicleInfo}`);
            }
            catch (vehicleError) {
                console.log("Could not fetch vehicle info:", vehicleError);
            }
        }
        // 3. Format scheduled time
        let timeInfo = "";
        if (scheduledTime) {
            try {
                const date = scheduledTime.toDate ? scheduledTime.toDate() : new Date(scheduledTime);
                timeInfo = date.toLocaleDateString("pt-BR", {
                    day: "2-digit",
                    month: "2-digit",
                    hour: "2-digit",
                    minute: "2-digit",
                });
            }
            catch (_b) {
                timeInfo = "";
            }
        }
        // 4. Prepare notification content
        const title = vehiclePlate ? `Novo: ${vehiclePlate} 📅` : "Novo Agendamento 📅";
        const body = vehicleInfo
            ? `${userName} agendou ${vehicleInfo}${timeInfo ? ` para ${timeInfo}` : ""}`
            : `${userName} fez um novo agendamento${timeInfo ? ` para ${timeInfo}` : ""}`;
        // 5. Get all admin users and notify them
        console.log("Fetching admin users...");
        const adminUsersSnapshot = await admin.firestore()
            .collection("users")
            .where("role", "==", "admin")
            .get();
        console.log(`Found ${adminUsersSnapshot.size} admin users`);
        const adminTokens = [];
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
                title: title,
                body: body,
                timestamp: timestamp,
                bookingId: bookingId,
                isRead: false,
                type: "booking_new",
            });
            // Collect FCM tokens for push notifications
            if (adminData.fcmToken) {
                adminTokens.push(adminData.fcmToken);
            }
        }
        // Commit admin notifications batch
        await notificationBatch.commit();
        console.log(`In-app notifications saved for ${adminUsersSnapshot.size} admins`);
        // 6. Send FCM to admins
        if (adminTokens.length > 0) {
            try {
                const adminMessage = {
                    data: {
                        bookingId: bookingId,
                        type: "booking_new",
                        // Add title/body to data so Web SW can use it manually
                        title: title,
                        body: body,
                    },
                    tokens: adminTokens,
                    android: {
                        notification: {
                            title: title,
                            body: body,
                            channelId: "high_importance_channel",
                            priority: "high",
                        },
                    },
                    apns: {
                        headers: {
                            "apns-priority": "10",
                            "apns-push-type": "alert",
                        },
                        payload: {
                            aps: {
                                alert: {
                                    title: title,
                                    body: body,
                                },
                                badge: 1,
                                sound: "default",
                                "content-available": 1,
                            },
                        },
                    },
                    webpush: {
                        headers: {
                            Urgency: "high",
                            TTL: "86400",
                        },
                        // No notification key here prevents auto-display by browser
                        fcmOptions: {
                            link: "/dashboard",
                        },
                    },
                };
                const adminResponse = await admin.messaging().sendEachForMulticast(adminMessage);
                console.log(`Push sent to ${adminResponse.successCount} admins for new booking`);
            }
            catch (fcmError) {
                console.error("Error sending FCM to admins:", fcmError);
            }
        }
    }
    catch (error) {
        console.error("Critical error in onNewBookingCreated:", error);
    }
});
/**
 * Triggers when a booking document is updated.
 * Checks if the 'status' field has changed.
 * If changed, sends an FCM notification to the user AND all admins.
 */
exports.onBookingStatusChange = (0, firestore_1.onDocumentUpdated)({
    document: "appointments/{bookingId}",
    // Uses southamerica-east1 from setGlobalOptions (Firestore database must be in same region)
}, async (event) => {
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
    const vehicleId = newData.vehicleId;
    console.log(`Booking ${bookingId} status changed from ${oldData.status} ` +
        `to ${newStatus} for user ${userId}`);
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
        const fcmToken = userData === null || userData === void 0 ? void 0 : userData.fcmToken;
        // 2. Get vehicle info for admin notification (from main vehicles collection)
        let vehiclePlate = "S/ Placa";
        let vehicleModel = "Veículo";
        if (vehicleId) {
            try {
                const vehicleDoc = await admin.firestore()
                    .collection("vehicles")
                    .doc(vehicleId)
                    .get();
                if (vehicleDoc.exists) {
                    const vehicleData = vehicleDoc.data();
                    vehiclePlate = (vehicleData === null || vehicleData === void 0 ? void 0 : vehicleData.plate) || "S/ Placa";
                    vehicleModel = `${(vehicleData === null || vehicleData === void 0 ? void 0 : vehicleData.brand) || ""} ${(vehicleData === null || vehicleData === void 0 ? void 0 : vehicleData.model) || ""}`.trim();
                }
            }
            catch (vehicleError) {
                console.log("Could not fetch vehicle info:", vehicleError);
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
        const statusTranslations = {
            pending: "Pendente",
            confirmed: "Confirmado",
            checkIn: "Check-in",
            washing: "Lavando",
            vacuuming: "Aspirando",
            drying: "Secando",
            polishing: "Polindo",
            finished: "Finalizado",
            cancelled: "Cancelado",
        };
        const statusText = statusTranslations[newStatus] || newStatus;
        const adminTitle = `${vehiclePlate} - ${statusText}`;
        const adminBody = `${vehicleModel} - Cliente: ${(userData === null || userData === void 0 ? void 0 : userData.displayName) || "Cliente"}`;
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
        // --- NO-SHOW LOGIC ---
        if (newStatus === 'noShow') {
            await admin.firestore().collection('users').doc(userId).update({
                noShowCount: admin.firestore.FieldValue.increment(1)
            });
            console.log(`User ${userId} noShowCount incremented.`);
        }
        // Optional: Decrement if status changes FROM noShow to something else (correction)
        if (oldData.status === 'noShow' && newStatus !== 'noShow') {
            await admin.firestore().collection('users').doc(userId).update({
                noShowCount: admin.firestore.FieldValue.increment(-1)
            });
        }
        // ---------------------
        console.log(`In-app notification saved for user ${userId}`);
        // 6. Get all admin users and notify them
        const adminUsersSnapshot = await admin.firestore()
            .collection("users")
            .where("role", "==", "admin")
            .get();
        const adminTokens = [];
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
                    data: {
                        bookingId: bookingId,
                        status: newStatus,
                        type: "booking_update",
                        // Add title/body to data so Web SW can use it manually
                        title: adminTitle,
                        body: adminBody,
                    },
                    tokens: adminTokens,
                    android: {
                        notification: {
                            title: adminTitle,
                            body: adminBody,
                            channelId: "high_importance_channel",
                            priority: "high",
                        },
                    },
                    apns: {
                        headers: {
                            "apns-priority": "10",
                            "apns-push-type": "alert",
                        },
                        payload: {
                            aps: {
                                alert: {
                                    title: adminTitle,
                                    body: adminBody,
                                },
                                badge: 1,
                                sound: "default",
                                "content-available": 1,
                            },
                        },
                    },
                    webpush: {
                        headers: {
                            Urgency: "high",
                            TTL: "86400",
                        },
                        // No notification key here prevents auto-display by browser
                        fcmOptions: {
                            link: `/booking/${bookingId}`,
                        },
                    },
                };
                const adminResponse = await admin.messaging().sendEachForMulticast(adminMessage);
                console.log(`Push sent to ${adminResponse.successCount} admins`);
            }
            catch (adminFcmError) {
                console.error("Error sending FCM to admins:", adminFcmError);
            }
        }
        // 8. Send FCM Message to CLIENT (IF TOKEN EXISTS)
        if (!fcmToken) {
            console.log(`No FCM token for user ${userId} - skipping push notification`);
            return;
        }
        const message = {
            data: {
                bookingId: bookingId,
                status: newStatus,
                click_action: "FLUTTER_NOTIFICATION_CLICK",
                // Add title/body to data so Web SW can use it manually
                title: title,
                body: body,
            },
            token: fcmToken,
            android: {
                notification: {
                    title: title,
                    body: body,
                    channelId: "high_importance_channel",
                    priority: "high",
                },
            },
            apns: {
                headers: {
                    "apns-priority": "10",
                    "apns-push-type": "alert",
                },
                payload: {
                    aps: {
                        alert: {
                            title: title,
                            body: body,
                        },
                        badge: 1,
                        sound: "default",
                        "content-available": 1,
                    },
                },
            },
            webpush: {
                headers: {
                    Urgency: "high",
                    TTL: "86400",
                },
                // No notification key here prevents auto-display by browser
                fcmOptions: {
                    link: `/booking/${bookingId}`,
                },
            },
        };
        try {
            await admin.messaging().send(message);
            console.log(`Push notification sent to user ${userId}`);
        }
        catch (fcmError) {
            console.error(`Error sending FCM to user ${userId}:`, fcmError);
            // Continue execution - do not rethrow, as in-app notification is already saved
        }
    }
    catch (error) {
        console.error("Critical error in onBookingStatusChange:", error);
    }
});
// Import callable functions
const https_1 = require("firebase-functions/v2/https");
/**
 * Seed the database with initial data (services, plans, config)
 * Run this once after creating a new database
 */
exports.seedDatabase = (0, https_1.onCall)(async () => {
    const db = admin.firestore();
    const batch = db.batch();
    // 1. Seed Services
    const services = [
        {
            id: "lavagem-simples",
            name: "Lavagem Simples",
            description: "Lavagem externa completa do veículo",
            price: 35.00,
            duration: 30,
            isActive: true,
            order: 1,
        },
        {
            id: "lavagem-completa",
            name: "Lavagem Completa",
            description: "Lavagem externa + aspiração interna",
            price: 55.00,
            duration: 45,
            isActive: true,
            order: 2,
        },
        {
            id: "lavagem-premium",
            name: "Lavagem Premium",
            description: "Lavagem completa + cera + hidratação de pneus",
            price: 80.00,
            duration: 60,
            isActive: true,
            order: 3,
        },
        {
            id: "polimento",
            name: "Polimento",
            description: "Polimento técnico para remoção de arranhões",
            price: 150.00,
            duration: 120,
            isActive: true,
            order: 4,
        },
    ];
    for (const service of services) {
        const ref = db.collection("services").doc(service.id);
        batch.set(ref, Object.assign(Object.assign({}, service), { createdAt: admin.firestore.FieldValue.serverTimestamp() }));
    }
    // 2. Seed Subscription Plans
    const plans = [
        {
            id: "plano-basico",
            name: "Plano Básico",
            description: "4 lavagens simples por mês",
            price: 99.90,
            washesPerMonth: 4,
            serviceType: "lavagem-simples",
            isActive: true,
            order: 1,
        },
        {
            id: "plano-premium",
            name: "Plano Premium",
            description: "4 lavagens completas por mês",
            price: 179.90,
            washesPerMonth: 4,
            serviceType: "lavagem-completa",
            isActive: true,
            order: 2,
        },
        {
            id: "plano-vip",
            name: "Plano VIP",
            description: "Lavagens ilimitadas (premium)",
            price: 299.90,
            washesPerMonth: -1,
            serviceType: "lavagem-premium",
            isActive: true,
            order: 3,
        },
    ];
    for (const plan of plans) {
        const ref = db.collection("plans").doc(plan.id);
        batch.set(ref, Object.assign(Object.assign({}, plan), { createdAt: admin.firestore.FieldValue.serverTimestamp() }));
    }
    // 3. Seed Config
    const configRef = db.collection("config").doc("app_version");
    batch.set(configRef, {
        web_version: "1.0.2",
        force_update: false,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    const businessConfig = db.collection("config").doc("business");
    batch.set(businessConfig, {
        name: "Auto Olinda",
        address: "Olinda, PE",
        phone: "(81) 99999-9999",
        openingHours: {
            monday: { open: "08:00", close: "18:00" },
            tuesday: { open: "08:00", close: "18:00" },
            wednesday: { open: "08:00", close: "18:00" },
            thursday: { open: "08:00", close: "18:00" },
            friday: { open: "08:00", close: "18:00" },
            saturday: { open: "08:00", close: "13:00" },
            sunday: { open: null, close: null },
        },
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await batch.commit();
    console.log("Database seeded successfully!");
    return { success: true, message: "Database seeded successfully!" };
});
__exportStar(require("./stripe"), exports);
__exportStar(require("./booking"), exports);
__exportStar(require("./ecommerce"), exports);
__exportStar(require("./notifications"), exports);
__exportStar(require("./orders"), exports);
var payment_1 = require("./payment");
Object.defineProperty(exports, "createBookingPaymentIntent", { enumerable: true, get: function () { return payment_1.createBookingPaymentIntent; } });
Object.defineProperty(exports, "createBookingCheckoutSession", { enumerable: true, get: function () { return payment_1.createBookingCheckoutSession; } });
var stripe_1 = require("./stripe");
Object.defineProperty(exports, "createPixPaymentIntent", { enumerable: true, get: function () { return stripe_1.createPixPaymentIntent; } });
//# sourceMappingURL=index.js.map