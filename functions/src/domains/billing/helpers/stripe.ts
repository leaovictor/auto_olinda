import * as admin from "firebase-admin";
import Stripe from "stripe";
import { HttpsError } from "firebase-functions/v2/https";
import { stripeSecret, stripePublishableKey } from "../../../config/env";

export const getPaymentSettings = async () => {
  const doc = await admin.firestore().collection('admin_settings').doc('payments').get();
  if (doc.exists) {
    return doc.data();
  }
  return null;
};

export const getStripe = async () => {
    let secretKey = stripeSecret.value();
    
    // Try to get dynamic key
    try {
        const settings = await getPaymentSettings();
        if (settings?.stripe_secret_key) {
            secretKey = settings.stripe_secret_key;
        }
    } catch (e) {
        console.warn("Failed to fetch dynamic Stripe keys, falling back to env vars", e);
    }
    
    if (!secretKey) {
        throw new Error("Stripe Secret Key not configured. Please set 'stripe_secret_key' in Firestore (admin_settings/payments) or via CLI (firebase functions:secrets:set STRIPE_SECRET).");
    }

  return new Stripe(secretKey, {
    apiVersion: "2023-10-16" as any,
  });
};

export const getStripePublishableKey = async () => {
  let publishableKey = stripePublishableKey.value();

  // Try to get dynamic key
  try {
      const settings = await getPaymentSettings();
      if (settings?.stripe_publishable_key) {
          publishableKey = settings.stripe_publishable_key;
      }
  } catch (e) {
      console.warn("Failed to fetch dynamic Stripe keys, falling back to env vars", e);
  }

  return publishableKey;
};

/**
 * Validates if the selected plan is compatible with the vehicle category.
 * SUV cannot use Hatch plans.
 */
export const validatePlanCategory = async (priceId: string, vehicleCategory: string) => {
  if (!vehicleCategory) return; // Skip if no category provided (legacy)

  // Normalize category
  const category = vehicleCategory.toLowerCase();

  // Fetch plan details from Firestore to get its allowed category
  // We assume plans have a 'category' or 'allowedCategories' field
  // or we infer from the name/metadata.
  // For this refactor, let's look up the plan document.
  const plansSnapshot = await admin.firestore()
    .collection('plans')
    .where('stripePriceId', '==', priceId)
    .limit(1)
    .get();

  if (plansSnapshot.empty) {
    console.warn(`Plan not found for priceId ${priceId}, skipping category validation.`);
    return;
  }

  const planData = plansSnapshot.docs[0].data();
  const planCategory = planData.category?.toLowerCase() || 'any'; // hatchback, suv, motorcycle, any

  console.log(`Validating Plan: ${planCategory} vs Vehicle: ${category}`);

  if (category === 'suv' || category === 'pickup' || category === 'crossover') {
    // SUVs cannot use Hatch plans
    if (planCategory === 'hatch' || planCategory === 'hatchback' || planCategory === 'moto') {
      throw new HttpsError(
        'invalid-argument',
        'Veículos da categoria SUV/Pick-up não podem aderir a planos Hatch/Moto.',
      );
    }
  }
};
