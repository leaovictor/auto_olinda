import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

/**
 * Updates existing plans with stripePriceId field.
 * This is a one-time migration function.
 */
export const migratePlansWithStripePriceId = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Authentication required.",
    );
  }

  const db = admin.firestore();

  try {
    // Mapping of plan IDs to their Stripe Price IDs
    const planStripePriceIds: Record<string, string> = {
      "toFdk1FwCk4UPRz9Z6nY": "price_1SaMyf5uVLC6EX3md2QVCnjU",
      // Add other plans here if needed
    };

    const plansSnapshot = await db.collection("plans").get();
    const batch = db.batch();
    let updatedCount = 0;

    for (const doc of plansSnapshot.docs) {
      const planData = doc.data();
      const planId = doc.id;

      // Check if stripePriceId is missing or empty
      if (!planData.stripePriceId || planData.stripePriceId === "") {
        const stripePriceId = planStripePriceIds[planId];

        if (stripePriceId) {
          batch.update(doc.ref, {
            stripePriceId: stripePriceId,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          updatedCount++;
          console.log(
            `Updating plan ${planId} with stripePriceId: ${stripePriceId}`,
          );
        } else {
          console.warn(`No stripePriceId mapping found for plan: ${planId}`);
        }
      }
    }

    if (updatedCount > 0) {
      await batch.commit();
      console.log(`Successfully updated ${updatedCount} plans`);
    }

    return {
      success: true,
      message: `Updated ${updatedCount} plans with stripePriceId`,
      updatedCount,
    };
  } catch (error) {
    console.error("Error migrating plans:", error);
    throw new HttpsError("internal", "Failed to migrate plans.");
  }
});
