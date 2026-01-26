
import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

/**
 * Updates the vehicle linked to a subscription, enforcing the 30-day rule.
 */
export const updateSubscriptionVehicle = onCall(async (request) => {
  // 1. Authentication Check
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "The function must be called while authenticated."
    );
  }

  const { subscriptionId, newVehicleId } = request.data;
  const userId = request.auth.uid;

  // 2. Input Validation
  if (!subscriptionId || !newVehicleId) {
    throw new HttpsError(
      "invalid-argument",
      "subscriptionId and newVehicleId are required."
    );
  }

  try {
    const db = admin.firestore();
    const subRef = db.collection("subscriptions").doc(subscriptionId);
    const subDoc = await subRef.get();

    if (!subDoc.exists) {
      throw new HttpsError("not-found", "Subscription not found.");
    }

    const subData = subDoc.data();

    // 3. Authorization Check
    if (subData?.userId !== userId) {
      throw new HttpsError(
        "permission-denied",
        "You do not have permission to modify this subscription."
      );
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
         throw new HttpsError(
          "failed-precondition",
          `Você só pode trocar de veículo a cada 30 dias. Faltam ${daysRemaining} dias.`
        );
      }
    }

    // 5. Update Subscription
    await subRef.update({
      vehicleId: newVehicleId,
      lastPlateChange: now,
      updatedAt: now,
    });

    return { success: true, message: "Vehicle updated successfully." };

  } catch (error) {
    console.error("Error updating subscription vehicle:", error);
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", "An internal error occurred.");
  }
});
