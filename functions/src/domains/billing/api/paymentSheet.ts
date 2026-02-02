import * as admin from "firebase-admin";

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { stripeSecret, stripePublishableKey } from "../../../config/env";
import { getStripe, getStripePublishableKey } from "../helpers/stripe";

/**
 * Creates a Payment Sheet for a subscription.
 */
export const createPaymentSheet = onCall(
  { secrets: [stripeSecret, stripePublishableKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
      );
    }

    const { priceId, couponId, vehiclePlate, vehicleId } = request.data;
    const userId = request.auth.uid;
    const userEmail = request.auth.token.email;

    if (!priceId) {
      throw new HttpsError(
        "invalid-argument",
        "The function must be called with a priceId.",
      );
    }

    try {
      // NOTE: We allow missing env var if dynamic key is present
      // if (!stripeSecret || !stripeSecret.value()) { ... } 
      
      const stripe = await getStripe();

      // 1. Get or Create Stripe Customer
      const userDoc = await admin.firestore()
        .collection("users")
        .doc(userId)
        .get();
      let customerId = userDoc.data()?.stripeCustomerId;
      let shouldCreateCustomer = !customerId;

      if (customerId) {
        try {
          const customer = await stripe.customers.retrieve(customerId);
          if (customer.deleted) {
            console.log(`Customer ${customerId} is deleted in Stripe. Creating new one.`);
            shouldCreateCustomer = true;
          }
        } catch (error: any) {
          if (error.code === "resource_missing") {
            console.log(`Customer ${customerId} not found in Stripe. Creating new one.`);
            shouldCreateCustomer = true;
          } else {
            throw error;
          }
        }
      }

      if (shouldCreateCustomer) {
        const customer = await stripe.customers.create({
          email: userEmail,
          metadata: { firebaseUID: userId },
        });
        customerId = customer.id;
        await userDoc.ref.update({ stripeCustomerId: customerId });
      }

      // 2. Create Ephemeral Key
      const ephemeralKey = await stripe.ephemeralKeys.create(
        { customer: customerId },
        { apiVersion: "2023-10-16" }
      );

      // 3. Fetch Stripe Coupon if couponId provided
      let stripeCouponId = null;
      if (couponId) {
        const couponDoc = await admin.firestore()
          .collection("coupons")
          .doc(couponId)
          .get();

        if (couponDoc.exists) {
          stripeCouponId = couponDoc.data()?.stripeCouponId;
        }
      }

      // 4. Create Subscription with Payment Intent
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const subscriptionParams: any = {
        customer: customerId,
        items: [{ price: priceId }],
        payment_behavior: "default_incomplete",
        payment_settings: { save_default_payment_method: "on_subscription" },
        expand: ["latest_invoice.payment_intent", "pending_setup_intent"],
        metadata: { 
          firebaseUID: userId,
          vehiclePlate: vehiclePlate || '',
          vehicleId: vehicleId || '',
        },
      };

      // Apply coupon if available
      if (stripeCouponId) {
        subscriptionParams.discounts = [{ coupon: stripeCouponId }];

        // Increment coupon usage count
        if (couponId) {
          await admin.firestore()
            .collection("coupons")
            .doc(couponId)
            .update({
              usedCount: admin.firestore.FieldValue.increment(1),
            });
        }
      }

      const subscription = await stripe.subscriptions.create(
        subscriptionParams
      );

      console.log(
        "Stripe subscription created:",
        JSON.stringify(subscription, null, 2)
      );

      // CRITICAL: Immediately create/update Firestore subscription document
      // This ensures stripeSubscriptionId is available for sync polling
      // before the webhook fires (which can be delayed)
      const subscriptionsSnapshot = await admin.firestore()
        .collection("subscriptions")
        .where("userId", "==", userId)
        .limit(1)
        .get();

      const subData = {
        userId: userId,
        planId: priceId,
        status: "incomplete", // Will be updated by webhook or sync
        stripeSubscriptionId: subscription.id,
        stripeCustomerId: customerId,
        linkedPlate: vehiclePlate, // Save linked plate
        vehicleId: vehicleId,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      if (!subscriptionsSnapshot.empty) {
        const existingDoc = subscriptionsSnapshot.docs[0];
        await existingDoc.ref.update(subData);
        console.log(`Updated existing subscription doc for user ${userId}`);
      } else {
        await admin.firestore().collection("subscriptions").add({
          ...subData,
          startDate: new Date(),
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`Created new subscription doc for user ${userId}`);
      }

      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      let latestInvoice = subscription.latest_invoice as any;

      // If latest_invoice is a string (expansion failed), retrieve it
      if (typeof latestInvoice === "string") {
        console.log("latest_invoice is a string, retrieving...");
        latestInvoice = await stripe.invoices.retrieve(latestInvoice);
        console.log(
          "Retrieved invoice:",
          JSON.stringify(latestInvoice, null, 2)
        );
      }

      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const paymentIntent = latestInvoice?.payment_intent;
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const setupIntent = subscription.pending_setup_intent as any;

      if (!paymentIntent?.client_secret && !setupIntent?.client_secret) {
        // Try to retrieve payment intent if it's a string
        if (typeof paymentIntent === "string") {
          console.log("payment_intent is a string, retrieving...");
          const pi = await stripe.paymentIntents.retrieve(paymentIntent);
          if (pi.client_secret) {
            return {
              paymentIntent: pi.client_secret,
              setupIntent: setupIntent?.client_secret,
              ephemeralKey: ephemeralKey.secret,
              customer: customerId,
              publishableKey: await getStripePublishableKey(),
              subscriptionId: subscription.id,
            };
          }
        }

        throw new HttpsError(
          "internal",
          "Failed to get client_secret from subscription. " +
          "This can happen if the plan has a free trial and " +
          "requires no immediate payment.",
        );
      }

      return {
        paymentIntent: paymentIntent?.client_secret,
        setupIntent: setupIntent?.client_secret,
        ephemeralKey: ephemeralKey.secret,
        customer: customerId,
        // Key should be handled by client
        publishableKey: await getStripePublishableKey(),
        subscriptionId: subscription.id,
      };
    } catch (error) {
      console.error("Error creating payment sheet:", error);
      if (error instanceof Error) {
        console.error("Stack trace:", error.stack);
      }
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const message = (error as any).message || "Unknown error";
      throw new HttpsError(
        "internal",
        `Unable to create payment sheet: ${message}`,
        message
      );
    }
  },
);
