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
exports.updateSubscriptionVehicle = void 0;
const https_1 = require("firebase-functions/v2/https");
const admin = __importStar(require("firebase-admin"));
/**
 * Updates the vehicle linked to a subscription, enforcing the 30-day rule.
 */
exports.updateSubscriptionVehicle = (0, https_1.onCall)(async (request) => {
    // 1. Authentication Check
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const { subscriptionId, newVehicleId } = request.data;
    const userId = request.auth.uid;
    // 2. Input Validation
    if (!subscriptionId || !newVehicleId) {
        throw new https_1.HttpsError("invalid-argument", "subscriptionId and newVehicleId are required.");
    }
    try {
        const db = admin.firestore();
        const subRef = db.collection("subscriptions").doc(subscriptionId);
        const subDoc = await subRef.get();
        if (!subDoc.exists) {
            throw new https_1.HttpsError("not-found", "Subscription not found.");
        }
        const subData = subDoc.data();
        // 3. Authorization Check
        if (subData?.userId !== userId) {
            throw new https_1.HttpsError("permission-denied", "You do not have permission to modify this subscription.");
        }
        // 4. Validate 30-day rule
        const now = admin.firestore.Timestamp.now();
        const lastChange = subData?.lastPlateChange;
        const currentVehicleId = subData?.vehicleId;
        // If there is a vehicle linked AND a last change date, check the diff
        if (currentVehicleId && lastChange) {
            const lastChangeDate = lastChange.toDate();
            const diffTime = Math.abs(now.toDate().getTime() - lastChangeDate.getTime());
            // Use 30 days as the threshold.
            // Note: diffDays is rounded up, so if it's exactly 30 days ago, it should be allowed.
            // Actually strictly: if (now - lastChange < 30 days) -> Error
            const thirtyDaysInMs = 30 * 24 * 60 * 60 * 1000;
            if (diffTime < thirtyDaysInMs) {
                const daysRemaining = Math.ceil((thirtyDaysInMs - diffTime) / (1000 * 60 * 60 * 24));
                throw new https_1.HttpsError("failed-precondition", `Você só pode trocar de veículo a cada 30 dias. Faltam ${daysRemaining} dias.`);
            }
        }
        // 5. Update Subscription
        await subRef.update({
            vehicleId: newVehicleId,
            lastPlateChange: now,
            updatedAt: now,
        });
        return { success: true, message: "Vehicle updated successfully." };
    }
    catch (error) {
        console.error("Error updating subscription vehicle:", error);
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        throw new https_1.HttpsError("internal", "An internal error occurred.");
    }
});
//# sourceMappingURL=subscription_vehicle.js.map