import * as admin from "firebase-admin";
import Stripe from "stripe";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { stripeSecret } from "../../../config/env";
import { getStripe, validatePlanCategory } from "../helpers/stripe";

/**
 * Creates a Stripe Checkout Session for a subscription or one-time payment.
 * Supports dynamic pricing for services based on active subscription logic.
 */
export const createCheckoutSession = onCall(
  { secrets: [stripeSecret], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
      );
    }

    const { 
      priceId, 
      mode = 'subscription', 
      successUrl, 
      cancelUrl, 
      couponId, 
      serviceId, 
      items, 
      vehicleId, 
      vehiclePlate, // injected from frontend
      vehicleCategory, // injected from frontend
      scheduledTime 
    } = request.data;
    
    const userId = request.auth.uid;
    const userEmail = request.auth.token.email;

    if (!priceId && (!items || items.length === 0)) {
      throw new HttpsError(
        "invalid-argument",
        "The function must be called with a priceId or a list of items.",
      );
    }

    // --- REFACTOR START: Category Validation & Anti-Fraud ---
    if (mode === 'subscription') {
      if (!vehiclePlate) {
        throw new HttpsError(
          'invalid-argument',
          'A placa do veículo é obrigatória para assinar.',
        );
      }

      // 1. Validate Category
      await validatePlanCategory(priceId, vehicleCategory);

      // 2. Check if plate is already linked to an active subscription
      // Use a transaction or simpler query for now (Firebase Transactions for strictness)
      const existingSub = await admin.firestore()
        .collection('subscriptions')
        .where('linkedPlate', '==', vehiclePlate)
        .where('status', 'in', ['active', 'trialing'])
        .limit(1)
        .get();

      if (!existingSub.empty) {
        // Check if it's the same user (maybe upgrading?)
        const sub = existingSub.docs[0].data();
        if (sub.userId !== userId) {
           throw new HttpsError(
            'already-exists',
            `O veículo de placa ${vehiclePlate} já possui uma assinatura ativa em outra conta.`,
          );
        }
      }
    }
    // --- REFACTOR END ---

    try {
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

      // 2. Prepare Checkout Logic
      let lineItems: Stripe.Checkout.SessionCreateParams.LineItem[] = [];

      if (items && items.length > 0) {
        // Handle multiple items
        lineItems = items.map((item: any) => ({
          price: item.priceId,
          quantity: item.quantity || 1,
        }));
      } else {
        // Handle single priceId legacy/simple mode
        lineItems = [
          {
            price: priceId,
            quantity: 1,
          },
        ];
      }

      if (mode === 'subscription' && items && items.length > 1) {
          throw new HttpsError(
            "invalid-argument",
            "Apenas um plano de assinatura pode ser adquirido por vez.",
          );
      }

      let sessionParams: Stripe.Checkout.SessionCreateParams = {
        payment_method_types: ["card", "pix"],
        customer: customerId,
        line_items: lineItems,
        success_url: successUrl || "https://auto-olinda.web.app/success",
        cancel_url: cancelUrl || "https://auto-olinda.web.app/cancel",
        metadata: {
          firebaseUID: userId,
          // Inject Vehicle Data into Metadata
          vehicleId: vehicleId || '',
          vehiclePlate: vehiclePlate || '',
          vehicleCategory: vehicleCategory || '',
          planId: priceId || (items && items[0]?.priceId) || '',
        },
      };

      // Apply dynamic discounts based on Coupon ID
      if (couponId) {
        // Verify coupon validity internally or assume ID is sufficient?
        // Safer to look up the Stripe Coupon ID from our internal DB
        const couponDoc = await admin.firestore().collection('coupons').doc(couponId).get();
        if (couponDoc.exists) {
          const stripeCouponId = couponDoc.data()?.stripeCouponId;
          if (stripeCouponId) {
            sessionParams.discounts = [{ coupon: stripeCouponId }];
          }
        }
      }

      if (mode === 'payment') {
        sessionParams.mode = 'payment';
        sessionParams.metadata = {
          ...sessionParams.metadata,
          type: 'one_time_service'
        };

        if (serviceId) sessionParams.metadata.serviceId = serviceId;
        if (scheduledTime) sessionParams.metadata.scheduledTime = scheduledTime;
      } else {
        sessionParams.mode = 'subscription';
        // Ensure plate is in subscription metadata as well (for webhook)
        sessionParams.subscription_data = {
          metadata: {
             firebaseUID: userId,
             vehiclePlate: vehiclePlate || '',
             vehicleId: vehicleId || '',
             vehicleCategory: vehicleCategory || '',
             planId: priceId || (items && items[0]?.priceId) || '',
          }
        };
      }

      const session = await stripe.checkout.sessions.create(sessionParams);

      return { url: session.url, sessionId: session.id };
    } catch (error) {
      console.error("Error creating checkout session:", error);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const message = (error as any).message || "Unknown error";
      throw new HttpsError("internal", message);
    }
  },
);
