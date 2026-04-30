import { onCall, onRequest, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import * as admin from "firebase-admin";
import Stripe from "stripe";
// NOTE: ecommerce/orders module removed (not part of SaaS scope)


/**
 * Creates a Stripe Checkout Session for a subscription.
 */
// ... (existing imports)

export const stripeSecret = defineSecret("STRIPE_SECRET");
export const stripeWebhookSecret = defineSecret("STRIPE_WEBHOOK_SECRET");
export const stripePublishableKey = defineSecret("STRIPE_PUBLISHABLE_KEY");

const getPaymentSettings = async () => {
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
        throw new Error("Stripe Secret Key not configured (neither in Firestore nor Env)");
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
const validatePlanCategory = async (priceId: string, vehicleCategory: string) => {
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

      let sessionParams: Stripe.Checkout.SessionCreateParams = {
        payment_method_types: ["card", "pix"],
        customer: customerId,
        line_items: lineItems,
        success_url: successUrl || "https://aquaclean.app/success",
        cancel_url: cancelUrl || "https://aquaclean.app/cancel",
        metadata: {
          firebaseUID: userId,
          // Inject Vehicle Data into Metadata
          vehicleId: vehicleId || '',
          vehiclePlate: vehiclePlate || '',
          vehicleCategory: vehicleCategory || '',
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


/**
 * Creates a Payment Intent specifically for Pix payments.
 * Returns the client secret to be used in the frontend.
 */
export const createPixPaymentIntent = onCall(
  { secrets: [stripeSecret], cors: true },
  async (request) => {
    // 1. Authentication Check
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated."
      );
    }

    const { amount, description } = request.data;
    const userId = request.auth.uid;
    const userEmail = request.auth.token.email;

    // 2. Input Validation
    if (!amount || isNaN(amount) || amount <= 0) {
      throw new HttpsError(
        "invalid-argument",
        "The function must be called with a valid positive amount (in cents)."
      );
    }

    try {
      const stripe = await getStripe();

      // 3. Get or Create Stripe Customer
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
            shouldCreateCustomer = true;
          }
        } catch (error: any) {
          shouldCreateCustomer = true;
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

      // 4. Create Payment Intent for Pix
      const paymentIntent = await stripe.paymentIntents.create({
        amount: Math.round(amount), // Ensure integer
        currency: 'brl',
        payment_method_types: ['pix'],
        customer: customerId,
        description: description || `Pix Payment for user ${userId}`,
        metadata: {
          firebaseUID: userId,
          type: 'pix_payment'
        },
      });

      // 5. Return Client Secret
      return {
        clientSecret: paymentIntent.client_secret,
        id: paymentIntent.id,
      };

    } catch (error) {
      console.error("Error creating Pix payment intent:", error);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const message = (error as any).message || "Unknown error";
      throw new HttpsError("internal", message);
    }
  }
);


/**
 * Creates a PIX Payment Intent for subscription first payment.
 * This creates a PaymentIntent with PIX method and pre-registers the subscription.
 */
export const createSubscriptionPixPayment = onCall(
  { secrets: [stripeSecret, stripePublishableKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated."
      );
    }

    const { priceId, couponId, vehiclePlate, vehicleId } = request.data;
    const userId = request.auth.uid;
    const userEmail = request.auth.token.email;

    if (!priceId) {
      throw new HttpsError(
        "invalid-argument",
        "The function must be called with a priceId."
      );
    }

    // Check for vehicle plate requirement
    if (!vehiclePlate) {
       throw new HttpsError('invalid-argument', 'Placa do veículo é obrigatória.');
    }

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
            shouldCreateCustomer = true;
          }
        } catch (error: any) {
          shouldCreateCustomer = true;
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

      // 2. Get price details to determine amount
      const price = await stripe.prices.retrieve(priceId);
      let amount = price.unit_amount || 0;

      // 3. Apply coupon discount if provided
      let discountAmount = 0;
      let stripeCouponId = null;
      if (couponId) {
        const couponDoc = await admin.firestore()
          .collection("coupons")
          .doc(couponId)
          .get();

        if (couponDoc.exists) {
          const couponData = couponDoc.data();
          stripeCouponId = couponData?.stripeCouponId;
          
          // Calculate discount
          if (couponData?.type === 'percentage') {
            discountAmount = Math.round(amount * (couponData.value / 100));
          } else {
            discountAmount = Math.round((couponData?.value || 0) * 100); // Convert to cents
          }
          
          amount = Math.max(amount - discountAmount, 0);
        }
      }

      // 4. Create Payment Intent for PIX
      const paymentIntent = await stripe.paymentIntents.create({
        amount: amount,
        currency: 'brl',
        payment_method_types: ['pix'],
        customer: customerId,
        description: `Assinatura via PIX`,
        metadata: {
          firebaseUID: userId,
          type: 'pix_subscription',
          priceId: priceId,
          couponId: couponId || '',
          vehiclePlate: vehiclePlate || '',
          vehicleId: vehicleId || '',
        },
      });

      // 5. Pre-register subscription in Firestore as pending
      const subscriptionsSnapshot = await admin.firestore()
        .collection("subscriptions")
        .where("userId", "==", userId)
        .limit(1)
        .get();

      const subData = {
        userId: userId,
        planId: priceId,
        status: "pending_pix", // Will be updated when payment confirmed
        stripeCustomerId: customerId,
        pixPaymentIntentId: paymentIntent.id,
        linkedPlate: vehiclePlate, // Save linked plate
        vehicleId: vehicleId,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      if (!subscriptionsSnapshot.empty) {
        const existingDoc = subscriptionsSnapshot.docs[0];
        await existingDoc.ref.update(subData);
      } else {
        await admin.firestore().collection("subscriptions").add({
          ...subData,
          startDate: new Date(),
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      // 6. Increment coupon usage if used
      if (couponId && stripeCouponId) {
        await admin.firestore()
          .collection("coupons")
          .doc(couponId)
          .update({
            usedCount: admin.firestore.FieldValue.increment(1),
          });
      }

      return {
        clientSecret: paymentIntent.client_secret,
        paymentIntentId: paymentIntent.id,
        // publishableKey: stripePublishableKey.value(), // Client should fetch this dynamically now
        amount: amount,
        originalAmount: price.unit_amount,
        discountAmount: discountAmount,
      };
    } catch (error) {
      console.error("Error creating PIX subscription payment:", error);
      const message = (error as any).message || "Unknown error";
      throw new HttpsError("internal", message);
    }
  }
);


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

/**
 * Stripe Webhook to handle events like subscription updates.
 */
export const stripeWebhook = onRequest(
  { secrets: [stripeSecret, stripeWebhookSecret], maxInstances: 1, cpu: 1 },
  async (req, res) => {
    const sig = req.headers["stripe-signature"];

    // Debug logging for webhook (using error to ensure visibility)
    console.error("DEBUG: Webhook called");
    if (req.rawBody) {
      console.error("DEBUG: RawBody length:", req.rawBody.length);
    }

    try {
      const stripe = await getStripe();
      const event = stripe.webhooks.constructEvent(
        req.rawBody,
        sig as string,
        stripeWebhookSecret.value(),
      );

      switch (event.type) {
        case "customer.subscription.created":
        case "customer.subscription.updated":
          await handleSubscriptionUpdate(
            event.data.object as Stripe.Subscription
          );
          break;
          
        case "customer.subscription.deleted":
          await handleSubscriptionDeleted(
            event.data.object as Stripe.Subscription
          );
          break;

        case "checkout.session.completed": {
          const session = event.data.object as Stripe.Checkout.Session;
          if (session.mode === "subscription") {
            if (session.subscription) {
              const subscriptionId = typeof session.subscription === "string" ?
                session.subscription :
                session.subscription.id;

              const stripe = await getStripe();
              const sub = await stripe.subscriptions.retrieve(subscriptionId);
              await handleSubscriptionUpdate(sub);
            }
          } else if (session.mode === "payment") {
            // ecommerce one-time payments removed from SaaS scope.
            // Independent service payments are handled via payment_intent.succeeded.
            console.log(`checkout.session.completed (payment mode) — session ${session.id} skipped.`);
          }
          break;
        }

        case "payment_intent.succeeded": {
          const paymentIntent = event.data.object as Stripe.PaymentIntent;
          if (paymentIntent.metadata.type === "independent_service") {
            await handleServicePaymentSuccess(paymentIntent);
          }
          break;
        }

        case "invoice.payment_succeeded":
          await handleInvoicePaymentSucceeded(
            event.data.object as Stripe.Invoice
          );
          break;

        case "invoice.payment_failed":
          await handleInvoicePaymentFailed(
            event.data.object as Stripe.Invoice
          );
          break;

        default:
          console.log(`Unhandled event type ${event.type}`);
      }

      res.json({ received: true });
    } catch (error) {
      console.error("Error handling webhook event:", error);
      res.status(500).send("Internal Server Error");
    }
  },
);

/**
 * Handles successful invoice payment (renewals).
 */
async function handleInvoicePaymentSucceeded(invoice: Stripe.Invoice) {
  const subscriptionId = (invoice as any).subscription as string;
  const billingReason = invoice.billing_reason;

  if (!subscriptionId) return; 

  console.log(`Invoice paid for subscription: ${subscriptionId} (Reason: ${billingReason})`);

  // We only care about renewals here, initial sub is handled by checkout.session.completed
  // But redundant updates are fine for safety.
  
  const snapshot = await admin.firestore()
    .collection("subscriptions")
    .where("stripeSubscriptionId", "==", subscriptionId)
    .limit(1)
    .get();

  if (!snapshot.empty) {
    const subDoc = snapshot.docs[0];
    await subDoc.ref.update({
      status: "active",
      lastPaymentDate: admin.firestore.FieldValue.serverTimestamp(),
      paymentIssue: false,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Validar status do usuário também
    const userId = subDoc.data().userId;
    if (userId) {
       await admin.firestore().collection("users").doc(userId).update({
          subscriptionStatus: "active",
          subscriptionUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
       });
    }
    console.log(`✅ Subscription ${subscriptionId} renewed and user ${userId} activated.`);
  }
}

/**
 * Handles failed invoice payment.
 */
async function handleInvoicePaymentFailed(invoice: Stripe.Invoice) {
  const subscriptionId = (invoice as any).subscription as string;
  if (!subscriptionId) return;

  console.warn(`❌ Invoice payment failed for subscription: ${subscriptionId}`);

  const snapshot = await admin.firestore()
    .collection("subscriptions")
    .where("stripeSubscriptionId", "==", subscriptionId)
    .limit(1)
    .get();

  if (!snapshot.empty) {
    const subDoc = snapshot.docs[0];
    await subDoc.ref.update({
      status: "past_due",
      paymentIssue: true,
      lastPaymentFailure: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    const userId = subDoc.data().userId;
    if (userId) {
      await admin.firestore().collection("users").doc(userId).update({
          subscriptionStatus: "past_due",
          subscriptionUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      console.log(`⚠️ User ${userId} marked as past_due.`);
    }
  }
}

/**
 * Handles subscription cancellation/deletion.
 */
async function handleSubscriptionDeleted(subscription: Stripe.Subscription) {
  console.log(`🚫 Subscription deleted: ${subscription.id}`);
  
  const snapshot = await admin.firestore()
    .collection("subscriptions")
    .where("stripeSubscriptionId", "==", subscription.id)
    .limit(1)
    .get();

  if (!snapshot.empty) {
      const doc = snapshot.docs[0];
      await doc.ref.update({
          status: "canceled",
          canceledAt: admin.firestore.FieldValue.serverTimestamp(),
          endDate: admin.firestore.FieldValue.serverTimestamp(), // Enforce end now
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      const userId = doc.data().userId;
      if (userId) {
        await admin.firestore().collection("users").doc(userId).update({
            subscriptionStatus: "inactive",
            subscriptionUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`🚫 User ${userId} marked as inactive (subscription deleted).`);
      }
  }
}

/**
 * Handles successful payment for independent services.
 * Creates the booking automatically from PaymentIntent metadata.
 * @param {Stripe.PaymentIntent} paymentIntent - The PaymentIntent object from Stripe.
 */
async function handleServicePaymentSuccess(paymentIntent: Stripe.PaymentIntent) {
  const metadata = paymentIntent.metadata;
  const userId = metadata.firebaseUID;
  const serviceId = metadata.serviceId;
  const scheduledTimeStr = metadata.scheduledTime;

  console.log(`🔵 handleServicePaymentSuccess: Processing PaymentIntent ${paymentIntent.id}`);
  console.log(`   User: ${userId}, Service: ${serviceId}, ScheduledTime: ${scheduledTimeStr}`);

  if (!userId || !serviceId || !scheduledTimeStr) {
    console.error(`❌ Missing required metadata for PaymentIntent ${paymentIntent.id}`);
    console.error(`   userId: ${userId}, serviceId: ${serviceId}, scheduledTime: ${scheduledTimeStr}`);
    return;
  }

  const db = admin.firestore();

  try {
    // Parse scheduled time
    const scheduledTime = new Date(scheduledTimeStr);
    if (isNaN(scheduledTime.getTime())) {
      console.error(`❌ Invalid scheduledTime format: ${scheduledTimeStr}`);
      return;
    }

    // Check for existing booking to avoid duplicates
    const existingBookings = await db.collection("service_bookings")
      .where("userId", "==", userId)
      .where("serviceId", "==", serviceId)
      .where("scheduledTime", "==", admin.firestore.Timestamp.fromDate(scheduledTime))
      .limit(1)
      .get();

    if (!existingBookings.empty) {
      console.log(`⚠️ Booking already exists for PaymentIntent ${paymentIntent.id}, skipping creation`);
      // Update payment status if not already paid
      const existingDoc = existingBookings.docs[0];
      if (existingDoc.data().paymentStatus !== 'paid') {
        await existingDoc.ref.update({
          paymentStatus: 'paid',
          paidAmount: (paymentIntent.amount / 100),
          stripePaymentIntentId: paymentIntent.id,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`✅ Updated existing booking ${existingDoc.id} payment status to paid`);
      }
      return;
    }

    // Create the booking
    const bookingData = {
      userId: userId,
      serviceId: serviceId,
      scheduledTime: admin.firestore.Timestamp.fromDate(scheduledTime),
      totalPrice: Number(metadata.totalPrice) || (paymentIntent.amount / 100),
      status: 'scheduled',
      paymentStatus: 'paid',
      paidAmount: (paymentIntent.amount / 100),
      vehicleId: metadata.vehicleId || null,
      vehiclePlate: metadata.vehiclePlate || null,
      vehicleModel: metadata.vehicleModel || null,
      userName: metadata.userName || null,
      userPhone: metadata.userPhone || null,
      stripePaymentIntentId: paymentIntent.id,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      createdVia: 'stripe_webhook', // Track that this was created via webhook
    };

    const bookingRef = await db.collection("service_bookings").add(bookingData);
    console.log(`✅ Created booking ${bookingRef.id} for PaymentIntent ${paymentIntent.id}`);

  } catch (error) {
    console.error(`❌ Error creating booking for PaymentIntent ${paymentIntent.id}:`, error);
    throw error; // Re-throw to mark webhook as failed
  }
}

/**
 * Updates user subscription status in Firestore.
 * @param {Stripe.Subscription} subscription - The subscription object
 * from Stripe.
 */
/**
 * Updates user subscription status in Firestore.
 * @param {Stripe.Subscription} subscription - The subscription object
 * from Stripe.
 */
/**
 * Interface extending Stripe.Subscription to include missing properties.
 */


/**
 * Handles subscription updates from Stripe webhooks.
 * @param {Stripe.Subscription} subscription - The subscription object.
 */
async function handleSubscriptionUpdate(subscription: any) {
  // Adicionamos um log para ver o conteúdo que chega do Stripe
  console.log("--- Conteúdo do Webhook de Assinatura ---");
  console.log(JSON.stringify(subscription, null, 2));

  const customerId = subscription.customer;
  const status = subscription.status;
  const priceId = subscription.items.data[0].price.id;
  const userId = subscription.metadata.firebaseUID;
  const sub = subscription; // Apenas para manter a consistência do código original

  // Extract vehicle data from metadata (REFACTOR: Subscription-only model)
  const vehiclePlate = subscription.metadata.vehiclePlate || null;
  const vehicleCategory = subscription.metadata.vehicleCategory || null;
  const vehicleId = subscription.metadata.vehicleId || null;

  if (!userId) {
    console.error("No firebaseUID found in subscription metadata for subscription:", sub.id);
    return;
  }

  // --- INÍCIO DA CORREÇÃO ---
  // Verificação de segurança para garantir que as datas existem e são válidas
  let currentPeriodStart = sub.current_period_start;
  let currentPeriodEnd = sub.current_period_end;

  // Se as datas estiverem faltando ou inválidas, usamos fallback
  if (typeof currentPeriodStart !== 'number' || typeof currentPeriodEnd !== 'number') {
    console.log(`Datas faltando no objeto do webhook para a assinatura ${sub.id}. Usando fallbacks.`);

    // Fallback 1: Tentar buscar do Stripe
    try {
      const stripe = await getStripe();
      const freshSub = await stripe.subscriptions.retrieve(sub.id);
      currentPeriodStart = (freshSub as any).current_period_start;
      currentPeriodEnd = (freshSub as any).current_period_end;
    } catch (error) {
      console.error("Erro ao buscar assinatura atualizada:", error);
    }
  }

  // Fallback 2: Se ainda inválido, usar data atual e +30 dias
  if (typeof currentPeriodStart !== 'number' || isNaN(currentPeriodStart)) {
    console.warn("Usando data atual como fallback para start date");
    currentPeriodStart = Math.floor(Date.now() / 1000);
  }

  if (typeof currentPeriodEnd !== 'number' || isNaN(currentPeriodEnd)) {
    console.warn("Usando data +30 dias como fallback para end date");
    currentPeriodEnd = currentPeriodStart + (30 * 24 * 60 * 60);
  }

  const startDate = new Date(currentPeriodStart * 1000);
  const endDate = new Date(currentPeriodEnd * 1000);
  // --- FIM DA CORREÇÃO ---

  let appStatus = "inactive";
  if (status === "active" || status === "trialing") {
    appStatus = "active";
  } else if (status === "past_due") {
    appStatus = "past_due";
  } else if (status === "canceled" || status === "unpaid" || status === "incomplete_expired") {
    appStatus = "canceled";
  } else if (status === "incomplete") {
    appStatus = "incomplete";
  } else if (status === "paused") {
    appStatus = "paused";
  }

  const subscriptionsSnapshot = await admin.firestore()
    .collection("subscriptions")
    .where("userId", "==", userId)
    .limit(1)
    .get();

  if (!subscriptionsSnapshot.empty) {
    const subscriptionDoc = subscriptionsSnapshot.docs[0];
    const updateData: any = {
      status: appStatus,
      planId: priceId,
      stripeSubscriptionId: sub.id,
      stripeCustomerId: customerId,
      endDate: endDate,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    
    // Add vehicle data if provided (subscription-only refactor)
    if (vehiclePlate) updateData.linkedPlate = vehiclePlate;
    if (vehicleCategory) updateData.vehicleCategory = vehicleCategory;
    if (vehicleId) updateData.vehicleId = vehicleId;
    
    await subscriptionDoc.ref.update(updateData);
    console.log(`Assinatura ATUALIZADA para o usuário ${userId}`);
  } else {
    const newSubData: any = {
      userId: userId,
      planId: priceId,
      status: appStatus,
      startDate: startDate,
      endDate: endDate,
      stripeSubscriptionId: sub.id,
      stripeCustomerId: customerId,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    
    // Add vehicle data if provided (subscription-only refactor)
    if (vehiclePlate) newSubData.linkedPlate = vehiclePlate;
    if (vehicleCategory) newSubData.vehicleCategory = vehicleCategory;
    if (vehicleId) newSubData.vehicleId = vehicleId;
    
    await admin.firestore().collection("subscriptions").add(newSubData);
    console.log(`Nova assinatura CRIADA para o usuário ${userId}`);
  }
  
  // Update user's subscriptionStatus field (REFACTOR: Subscription-only model)
  const userSubscriptionStatus = (status === 'active' || status === 'trialing') ? 'active' : 
                                 (status === 'canceled' || status === 'unpaid' || status === 'incomplete_expired') ? 'cancelled' : 'inactive';
  
  try {
    await admin.firestore().collection('users').doc(userId).update({
      subscriptionStatus: userSubscriptionStatus,
      subscriptionUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`✅ Updated user ${userId} subscriptionStatus to: ${userSubscriptionStatus}`);
  } catch (error) {
    console.error(`❌ Failed to update user subscriptionStatus for ${userId}:`, error);
    // Don't fail the webhook, just log the error
  }
}


/**
 * Cancels a Stripe subscription at the end of the billing period.
 */
export const cancelSubscription = onCall(
  { secrets: [stripeSecret], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
      );
    }

    const { subscriptionId } = request.data;
    const userId = request.auth.uid;

    console.log("cancelSubscription called");
    console.log("subscriptionId:", subscriptionId);
    console.log("userId:", userId);

    if (!subscriptionId) {
      throw new HttpsError(
        "invalid-argument",
        "The function must be called with a subscriptionId.",
      );
    }

    try {
      const stripe = await getStripe();

      // Get subscription from Firestore
      const subDoc = await admin.firestore()
        .collection("subscriptions")
        .doc(subscriptionId)
        .get();

      if (!subDoc.exists) {
        console.error("Subscription not found:", subscriptionId);
        throw new HttpsError("not-found", "Subscription not found.");
      }

      const subData = subDoc.data();
      console.log("Subscription data:", JSON.stringify(subData));

      if (subData?.userId !== userId) {
        throw new HttpsError(
          "permission-denied",
          "Not authorized to cancel this subscription.",
        );
      }

      const stripeSubId = subData.stripeSubscriptionId;
      if (!stripeSubId) {
        throw new HttpsError(
          "failed-precondition",
          "No Stripe subscription ID found.",
        );
      }

      console.log("Canceling Stripe subscription:", stripeSubId);

      // Cancel at period end in Stripe
      await stripe.subscriptions.update(stripeSubId, {
        cancel_at_period_end: true,
      });

      console.log("Stripe subscription canceled successfully");

      // Update Firestore
      await subDoc.ref.update({
        cancelAtPeriodEnd: true,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log("Firestore updated successfully");

      return {
        success: true,
        message: "Subscription will cancel at period end",
      };
    } catch (error) {
      console.error("Error canceling subscription:", error);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const message = (error as any).message || "Unknown error";
      throw new HttpsError("internal", message);
    }
  },
);

/**
 * Reactivates a canceled Stripe subscription.
 */
export const reactivateSubscription = onCall(
  { secrets: [stripeSecret], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
      );
    }

    const { subscriptionId } = request.data;
    const userId = request.auth.uid;

    if (!subscriptionId) {
      throw new HttpsError(
        "invalid-argument",
        "The function must be called with a subscriptionId.",
      );
    }

    try {
      const stripe = await getStripe();

      // Get subscription from Firestore
      const subDoc = await admin.firestore()
        .collection("subscriptions")
        .doc(subscriptionId)
        .get();

      if (!subDoc.exists) {
        throw new HttpsError("not-found", "Subscription not found.");
      }

      const subData = subDoc.data();
      if (subData?.userId !== userId) {
        throw new HttpsError(
          "permission-denied",
          "Not authorized to reactivate this subscription.",
        );
      }

      const stripeSubId = subData.stripeSubscriptionId;
      if (!stripeSubId) {
        throw new HttpsError(
          "failed-precondition",
          "No Stripe subscription ID found.",
        );
      }

      // Resume in Stripe
      await stripe.subscriptions.update(stripeSubId, {
        cancel_at_period_end: false,
      });

      // Update Firestore
      await subDoc.ref.update({
        cancelAtPeriodEnd: false,
        status: "active",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        message: "Subscription reactivated successfully",
      };
    } catch (error) {
      console.error("Error reactivating subscription:", error);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const message = (error as any).message || "Unknown error";
      throw new HttpsError("internal", message);
    }
  },
);

/**
 * Forcefully syncs subscription status from Stripe to Firestore.
 * Useful when webhook events are delayed or fail.
 */
export const syncSubscriptionStatus = onCall(
  { secrets: [stripeSecret], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
      );
    }

    const { subscriptionId } = request.data;
    const userId = request.auth.uid;

    if (!subscriptionId) {
      throw new HttpsError(
        "invalid-argument",
        "The function must be called with a subscriptionId (Stripe sub ID).",
      );
    }

    console.log(`Syncing subscription ${subscriptionId} for user ${userId}`);

    try {
      const stripe = await getStripe();

      // Fetch fresh subscription from Stripe
      const subscription = await stripe.subscriptions.retrieve(subscriptionId);

      console.log(
        "Retrieved subscription from Stripe:",
        JSON.stringify(subscription, null, 2)
      );

      // Map Stripe status to app status
      const status = subscription.status;
      let appStatus = "inactive";
      if (status === "active" || status === "trialing") {
        appStatus = "active";
      } else if (status === "past_due") {
        appStatus = "past_due";
      } else if (
        status === "canceled" ||
        status === "unpaid" ||
        status === "incomplete_expired"
      ) {
        appStatus = "canceled";
      } else if (status === "incomplete") {
        appStatus = "incomplete";
      } else if (status === "paused") {
        appStatus = "paused";
      }

      // Get dates from subscription
      const sub = subscription as any;
      let currentPeriodStart = sub.current_period_start;
      let currentPeriodEnd = sub.current_period_end;

      // Fallback if dates are missing
      if (
        typeof currentPeriodStart !== "number" ||
        isNaN(currentPeriodStart)
      ) {
        currentPeriodStart = Math.floor(Date.now() / 1000);
      }
      if (typeof currentPeriodEnd !== "number" || isNaN(currentPeriodEnd)) {
        currentPeriodEnd = currentPeriodStart + 30 * 24 * 60 * 60;
      }

      const startDate = new Date(currentPeriodStart * 1000);
      const endDate = new Date(currentPeriodEnd * 1000);
      const priceId = subscription.items.data[0]?.price?.id;
      const customerId =
        typeof subscription.customer === "string"
          ? subscription.customer
          : subscription.customer?.id;

      // Find and update Firestore subscription for this user
      const subscriptionsSnapshot = await admin
        .firestore()
        .collection("subscriptions")
        .where("userId", "==", userId)
        .limit(1)
        .get();

      if (!subscriptionsSnapshot.empty) {
        const subscriptionDoc = subscriptionsSnapshot.docs[0];
        await subscriptionDoc.ref.update({
          status: appStatus,
          planId: priceId,
          stripeSubscriptionId: subscriptionId,
          stripeCustomerId: customerId,
          startDate: startDate,
          endDate: endDate,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(
          `Subscription SYNCED for user ${userId}: status=${appStatus}`
        );
      } else {
        // Create new subscription document if none exists
        await admin.firestore().collection("subscriptions").add({
          userId: userId,
          planId: priceId,
          status: appStatus,
          startDate: startDate,
          endDate: endDate,
          stripeSubscriptionId: subscriptionId,
          stripeCustomerId: customerId,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(
          `NEW subscription CREATED for user ${userId}: status=${appStatus}`
        );
      }

      // --- FIX: ALWAYS Update User Profile Status ---
      // This ensures the AppRouter (which listens to user profile) gets unblocked immediately
      // without waiting for the webhook.
      const userSubscriptionStatus = (status === 'active' || status === 'trialing') 
          ? 'active' 
          : (status === 'canceled' || status === 'unpaid' || status === 'incomplete_expired') 
              ? 'cancelled' 
              : 'inactive';

      await admin.firestore().collection('users').doc(userId).update({
        subscriptionStatus: userSubscriptionStatus,
        subscriptionUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      console.log(`✅ FORCE-SYNCED user ${userId} subscriptionStatus to: ${userSubscriptionStatus}`);

      return { success: true, status: appStatus };
    } catch (error) {
      console.error("Error syncing subscription:", error);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const message = (error as any).message || "Unknown error";
      throw new HttpsError("internal", message);
    }
  },
);

/**
 * Syncs all active subscriptions for a user from Stripe.
 * This ensures that even if a plan is deactivated in Firestore,
 * the user's active subscription in Stripe remains valid.
 */
export const syncUserSubscriptionsFromStripe = onCall(
  { secrets: [stripeSecret], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
      );
    }

    const userId = request.auth.uid;
    console.log(`Syncing all subscriptions for user ${userId} from Stripe`);

    try {
      const stripe = await getStripe();

      // Get user's Stripe customer ID
      const userDoc = await admin.firestore()
        .collection("users")
        .doc(userId)
        .get();
      
      const customerId = userDoc.data()?.stripeCustomerId;
      
      if (!customerId) {
        console.log(`No Stripe customer ID found for user ${userId}`);
        return { success: true, synced: 0, message: "No Stripe customer found" };
      }

      // Fetch all subscriptions from Stripe for this customer
      const subscriptions = await stripe.subscriptions.list({
        customer: customerId,
        status: 'all', // Get all subscriptions including canceled
      });

      console.log(`Found ${subscriptions.data.length} subscriptions in Stripe for customer ${customerId}`);

      let syncedCount = 0;
      
      // Process each subscription
      for (const subscription of subscriptions.data) {
        const status = subscription.status;
        const priceId = subscription.items.data[0]?.price?.id;
        
        if (!priceId) {
          console.warn(`Subscription ${subscription.id} has no price ID, skipping`);
          continue;
        }

        // Map Stripe status to app status
        let appStatus = "inactive";
        if (status === "active" || status === "trialing") {
          appStatus = "active";
        } else if (status === "past_due") {
          appStatus = "past_due";
        } else if (status === "canceled" || status === "unpaid" || status === "incomplete_expired") {
          appStatus = "canceled";
        }

        // Get period dates
        const currentPeriodStart = (subscription as any).current_period_start;
        const currentPeriodEnd = (subscription as any).current_period_end;
        const startDate = new Date(currentPeriodStart * 1000);
        const endDate = new Date(currentPeriodEnd * 1000);

        // Extract vehicle metadata if present
        const vehiclePlate = subscription.metadata?.vehiclePlate || null;
        const vehicleCategory = subscription.metadata?.vehicleCategory || null;
        const vehicleId = subscription.metadata?.vehicleId || null;

        // Find existing subscription in Firestore
        const existingSubQuery = await admin.firestore()
          .collection("subscriptions")
          .where("stripeSubscriptionId", "==", subscription.id)
          .limit(1)
          .get();

        const updateData: any = {
          userId: userId,
          planId: priceId,
          status: appStatus,
          stripeSubscriptionId: subscription.id,
          stripeCustomerId: customerId,
          endDate: endDate,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };

        if (vehiclePlate) updateData.linkedPlate = vehiclePlate;
        if (vehicleCategory) updateData.vehicleCategory = vehicleCategory;
        if (vehicleId) updateData.vehicleId = vehicleId;
        if (subscription.cancel_at_period_end) {
          updateData.cancelAtPeriodEnd = true;
        }

        if (!existingSubQuery.empty) {
          // Update existing subscription
          await existingSubQuery.docs[0].ref.update(updateData);
          console.log(`Updated subscription ${subscription.id} for user ${userId}`);
        } else {
          // Create new subscription record
          await admin.firestore().collection("subscriptions").add({
            ...updateData,
            startDate: startDate,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          console.log(`Created subscription record ${subscription.id} for user ${userId}`);
        }

        syncedCount++;
      }

      // Update user's subscription status based on active subscriptions
      const hasActiveSubscription = subscriptions.data.some(
        sub => sub.status === 'active' || sub.status === 'trialing'
      );
      
      const userSubscriptionStatus = hasActiveSubscription ? 'active' : 'inactive';
      
      await admin.firestore().collection('users').doc(userId).update({
        subscriptionStatus: userSubscriptionStatus,
        subscriptionUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`✅ Synced ${syncedCount} subscriptions for user ${userId}, status: ${userSubscriptionStatus}`);

      return { 
        success: true, 
        synced: syncedCount,
        status: userSubscriptionStatus,
        message: `Synced ${syncedCount} subscription(s)` 
      };
    } catch (error) {
      console.error("Error syncing user subscriptions:", error);
      const message = (error as any).message || "Unknown error";
      throw new HttpsError("internal", message);
    }
  },
);



/**
 * Changes the plan of an existing Stripe subscription.
 */
export const changeSubscriptionPlan = onCall(
  { secrets: [stripeSecret], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
      );
    }

    const { subscriptionId, newPriceId } = request.data;
    const userId = request.auth.uid;

    // Debug logging
    console.log("changeSubscriptionPlan called");
    console.log("request.data:", JSON.stringify(request.data));
    console.log("subscriptionId:", subscriptionId);
    console.log("newPriceId:", newPriceId);
    console.log("userId:", userId);

    if (!subscriptionId || !newPriceId) {
      console.error(
        "Missing parameters - subscriptionId:",
        subscriptionId,
        "newPriceId:",
        newPriceId,
      );
      throw new HttpsError(
        "invalid-argument",
        "subscriptionId and newPriceId are required.",
      );
    }

    try {
      const stripe = await getStripe();

      // Get subscription from Firestore
      const subDoc = await admin.firestore()
        .collection("subscriptions")
        .doc(subscriptionId)
        .get();

      if (!subDoc.exists) {
        throw new HttpsError("not-found", "Subscription not found.");
      }

      const subData = subDoc.data();
      if (subData?.userId !== userId) {
        throw new HttpsError(
          "permission-denied",
          "Not authorized to change this subscription.",
        );
      }

      const stripeSubId = subData.stripeSubscriptionId;
      if (!stripeSubId) {
        throw new HttpsError(
          "failed-precondition",
          "No Stripe subscription ID found.",
        );
      }

      // Get current subscription from Stripe
      const subscription = await stripe.subscriptions.retrieve(stripeSubId);
      const currentItemId = subscription.items.data[0].id;
      const currentPriceId = subscription.items.data[0].price.id;

      // Get price info to determine if it's an upgrade or downgrade
      const currentPrice = await stripe.prices.retrieve(currentPriceId);
      const newPrice = await stripe.prices.retrieve(newPriceId);

      const currentAmount = currentPrice.unit_amount || 0;
      const newAmount = newPrice.unit_amount || 0;

      const isDowngrade = newAmount < currentAmount;
      const isUpgrade = newAmount > currentAmount;

      console.log(`Plan change: current=${currentAmount}, new=${newAmount}, ` +
        `isUpgrade=${isUpgrade}, isDowngrade=${isDowngrade}`);

      // === ANTI-FRAUD RULES ===

      // Rule 1: Minimum period before downgrade (30 days after last upgrade)
      const MINIMUM_UPGRADE_PERIOD_DAYS = 30;

      if (isDowngrade) {
        const lastUpgradeDate = subData.lastUpgradeAt?.toDate();

        if (lastUpgradeDate) {
          const daysSinceUpgrade = Math.floor(
            (Date.now() - lastUpgradeDate.getTime()) / (1000 * 60 * 60 * 24)
          );

          console.log(`Days since last upgrade: ${daysSinceUpgrade}`);

          if (daysSinceUpgrade < MINIMUM_UPGRADE_PERIOD_DAYS) {
            const remainingDays = MINIMUM_UPGRADE_PERIOD_DAYS - daysSinceUpgrade;
            throw new HttpsError(
              "failed-precondition",
              `Você precisa aguardar mais ${remainingDays} dia(s) antes de ` +
              `fazer downgrade. Período mínimo: ${MINIMUM_UPGRADE_PERIOD_DAYS} dias.`,
            );
          }
        }

        // Rule 2: Downgrade only takes effect at the end of billing period
        // Update subscription with proration but apply at period end
        await stripe.subscriptions.update(stripeSubId, {
          items: [
            {
              id: currentItemId,
              price: newPriceId,
            },
          ],
          proration_behavior: "none", // No proration for downgrade
          billing_cycle_anchor: "unchanged",
        });

        // Record plan change history
        await admin.firestore().collection("plan_changes").add({
          userId,
          subscriptionId,
          fromPriceId: currentPriceId,
          toPriceId: newPriceId,
          changeType: "downgrade",
          effectiveAt: new Date((subscription as any).current_period_end * 1000),
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Update Firestore
        await subDoc.ref.update({
          planId: newPriceId,
          pendingDowngrade: true,
          pendingPlanId: newPriceId,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return {
          success: true,
          message: "Downgrade agendado para o próximo ciclo de cobrança.",
          effectiveDate: new Date((subscription as any).current_period_end * 1000)
            .toISOString(),
        };
      } else if (isUpgrade) {
        // Rule 3: Upgrade takes effect immediately with proration
        await stripe.subscriptions.update(stripeSubId, {
          items: [
            {
              id: currentItemId,
              price: newPriceId,
            },
          ],
          proration_behavior: "create_prorations", // Charge difference for upgrade
        });

        // Record plan change history
        await admin.firestore().collection("plan_changes").add({
          userId,
          subscriptionId,
          fromPriceId: currentPriceId,
          toPriceId: newPriceId,
          changeType: "upgrade",
          effectiveAt: new Date(),
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Update Firestore with lastUpgradeAt to track minimum period
        await subDoc.ref.update({
          planId: newPriceId,
          lastUpgradeAt: admin.firestore.FieldValue.serverTimestamp(),
          pendingDowngrade: false,
          pendingPlanId: null,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return {
          success: true,
          message: "Upgrade realizado com sucesso! Novos benefícios já ativos.",
        };
      } else {
        // Same price, just update
        await stripe.subscriptions.update(stripeSubId, {
          items: [
            {
              id: currentItemId,
              price: newPriceId,
            },
          ],
          proration_behavior: "none",
        });

        await subDoc.ref.update({
          planId: newPriceId,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return {
          success: true,
          message: "Plano alterado com sucesso.",
        };
      }
    } catch (error) {
      console.error("Error changing subscription plan:", error);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const message = (error as any).message || "Unknown error";
      throw new HttpsError("internal", message);
    }
  },
);

/**
 * Creates or updates a Stripe product and price for a subscription plan.
 * Called when admins create or update plans.
 */
export const syncPlanWithStripe = onCall(
  { secrets: [stripeSecret], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
      );
    }

    const { planId, name, price, features, category } = request.data;

    if (!planId || !name || price === undefined) {
      throw new HttpsError(
        "invalid-argument",
        "planId, name, and price are required.",
      );
    }

    try {
      const stripe = await getStripe();

      // Check if plan already has a Stripe product/price
      const planDoc = await admin.firestore()
        .collection("plans")
        .doc(planId)
        .get();

      let productId = planDoc.data()?.stripeProductId;
      let priceId = planDoc.data()?.stripePriceId;

      // Build description - Stripe doesn't accept empty strings
      const description = features?.length > 0
        ? features.join(", ")
        : `Plano ${name}`;

      // Create or update product
      if (productId) {
        try {
          // Attempt to update existing product
          await stripe.products.update(productId, {
            name: name,
            description: description,
            metadata: {
               firebasePlanId: planId,
               category: category || 'any', // Save category
            },
          });
          console.log(`Updated Stripe product: ${productId}`);
        } catch (error: any) {
          // If product not found (e.g. changed Stripe accounts), clear ID to create new
          if (error.code === 'resource_missing') {
             console.warn(`Product ${productId} not found in Stripe. Creating new one.`);
             productId = undefined;
          } else {
             throw error;
          }
        }
      }

      if (!productId) {
        // Create new product
        const product = await stripe.products.create({
          name: name,
          description: description,
          metadata: {
            firebasePlanId: planId,
            category: category || 'any',
          },
        });
        productId = product.id;
        console.log(`Created Stripe product: ${productId}`);
      }

      // Check if price has changed
      let priceChanged = true;
      if (priceId) {
        try {
          const currentPrice = await stripe.prices.retrieve(priceId);
          const currentAmount = currentPrice.unit_amount;
          const newAmount = Math.round(price * 100);

          if (currentAmount === newAmount && currentPrice.active) {
            priceChanged = false;
            console.log(
              `Price amount unchanged (${newAmount}), skipping price creation.`
            );
          }
        } catch (error) {
          console.warn(
            "Error retrieving current price, will create new one:",
            error
          );
        }
      }

      if (priceChanged) {
        // Create new price
        // (Stripe prices are immutable, so create new if price changed)
        const newPrice = await stripe.prices.create({
          product: productId,
          unit_amount: Math.round(price * 100), // Convert to cents
          currency: "brl",
          recurring: {
            interval: "month",
          },
          metadata: {
            firebasePlanId: planId,
          },
        });

        // Archive old price if it exists and is different
        if (priceId && priceId !== newPrice.id) {
          try {
            await stripe.prices.update(priceId, {
              active: false,
            });
            console.log(`Archived old price: ${priceId}`);
          } catch (error) {
            console.error("Error archiving old price:", error);
          }
        }

        priceId = newPrice.id;
        console.log(`Created new Stripe price: ${priceId}`);
      }

      // Update Firestore plan with Stripe IDs
      await planDoc.ref.update({
        stripeProductId: productId,
        stripePriceId: priceId,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        productId: productId,
        priceId: priceId,
        message: "Plan synced with Stripe successfully",
      };
    } catch (error) {
      console.error("Error syncing plan with Stripe:", error);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const message = (error as any).message || "Unknown error";
      throw new HttpsError("internal", message);
    }
  },
);

/**
 * Admin: Pause a subscription (stops billing but keeps subscription)
 */
export const adminPauseSubscription = onCall(
  { secrets: [stripeSecret], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be authenticated.");
    }

    // Verify admin role
    const adminDoc = await admin.firestore()
      .collection("users")
      .doc(request.auth.uid)
      .get();

    if (adminDoc.data()?.role !== "admin") {
      throw new HttpsError("permission-denied", "Only admins can manage subscriptions.");
    }

    const { userId } = request.data;
    if (!userId) {
      throw new HttpsError("invalid-argument", "userId is required.");
    }

    try {
      const stripe = await getStripe();

      // Log the incoming user ID for debugging
      console.log(`[adminPauseSubscription] Attempting to pause for userId: ${userId}`);

      // Get subscription from Firestore (Query by userId)
      let subQuery = await admin.firestore()
        .collection("subscriptions")
        .where("userId", "==", userId)
        .orderBy("createdAt", "desc")
        .limit(1)
        .get();

      // Fallback: If generic query fails
      if (subQuery.empty) {
         console.log(`[adminPauseSubscription] No subscription found via index query for ${userId}. Trying fallback.`);
         const simpleQuery = await admin.firestore()
            .collection("subscriptions")
            .where("userId", "==", userId)
            .limit(1)
            .get();
            
         if (!simpleQuery.empty) {
             subQuery = simpleQuery;
         } else {
             // FINAL FALLBACK: Check if user has 'premium' in metadata/claims and create a dummy doc/return error
             console.log(`[adminPauseSubscription] No subscription doc found. Checking user doc for legacy flags.`);
             const userTargetDoc = await admin.firestore().collection('users').doc(userId).get();
             if (userTargetDoc.exists && userTargetDoc.data()?.isPremium) {
                 // User is marked as premium but has no subscription doc.
                 // We can't "pause" a flag, but we can set isPremium = false?
                 // For now, let's return a specific error.
                 throw new HttpsError("failed-precondition", "Usuário é Premium (Legacy) mas não possui documento de assinatura. Contate o suporte técnico.");
             }
             
             throw new HttpsError("not-found", `Nenhuma assinatura encontrada para o usuário ${userId}.`);
         }
      }
      
      const subDoc = subQuery.docs[0];
      const subData = subDoc.data();
      
      // Check status manually
      if (!["active", "trialing", "past_due"].includes(subData.status)) {
           // Allow pausing if it is NOT already paused? 
           // If it is 'canceled', we can't pause.
           // If it is 'paused', we can't pause.
          if (subData.status === 'paused') {
              throw new HttpsError("failed-precondition", "Assinatura já está pausada.");
          }
          if (subData.status === 'canceled') {
              throw new HttpsError("failed-precondition", "Assinatura cancelada não pode ser pausada.");
          }
           // Just warn properly
           // throw new HttpsError("failed-precondition", `Status da assinatura inválido: ${subData.status}`);
      }
      // Re-use subData declared above
      const stripeSubId = subData?.stripeSubscriptionId;
      const isManual = subData?.isManual || subData?.type === 'promo';

      if (!stripeSubId) {
        if (isManual) {
           console.log(`Pausing MANUAL/PROMO subscription for user ${userId}`);
           // Just update Firestore for manual subs
           await subDoc.ref.update({
            status: "paused",
            pausedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          return { success: true, message: "Assinatura manual pausada com sucesso." };
        }
        
        throw new HttpsError("failed-precondition", "No Stripe subscription ID found.");
      }

      // Pause subscription in Stripe
      await stripe.subscriptions.update(stripeSubId, {
        pause_collection: { behavior: "void" },
      });

      // Update Firestore
      await subDoc.ref.update({
        status: "paused",
        pausedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`Subscription paused for user ${userId}`);
      return { success: true, message: "Subscription paused successfully." };
    } catch (error: any) {
      if (error instanceof HttpsError) throw error; // Don't wrap HttpsErrors
      console.error("Error pausing subscription:", error);
      
      // Explicitly handle Stripe errors
      if (error?.type?.startsWith('Stripe')) {
         const stripeMsg = error.message || "Stripe error";
         if (error.code === 'resource_missing') {
             throw new HttpsError("not-found", `Stripe: ${stripeMsg}`);
         }
         throw new HttpsError("failed-precondition", `Stripe: ${stripeMsg}`);
      }
      
      const message = error.message || "Unknown error";
      throw new HttpsError("internal", message);
    }
  },
);

/**
 * Admin: Cancel a subscription
 */
export const adminCancelSubscription = onCall(
  { secrets: [stripeSecret], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be authenticated.");
    }

    // Verify admin role
    const adminDoc = await admin.firestore()
      .collection("users")
      .doc(request.auth.uid)
      .get();

    if (adminDoc.data()?.role !== "admin") {
      throw new HttpsError("permission-denied", "Only admins can manage subscriptions.");
    }

    const { userId, cancelAtPeriodEnd } = request.data;
    if (!userId) {
      throw new HttpsError("invalid-argument", "userId is required.");
    }

    try {
      const stripe = await getStripe();

      // Get subscription from Firestore
      const subQuery = await admin.firestore()
        .collection("subscriptions")
        .where("userId", "==", userId)
        // We might want to cancel non-active ones too? Usually only active.
        // But if it is paused, we might want to cancel it.
        // Let's just find the most recent one regardless of status, or filter by relevance inside.
        // Actually, Stripe cancel only works on non-canceled.
        .where("status", "in", ["active", "trialing", "past_due", "paused"])
        .orderBy("createdAt", "desc")
        .limit(1)
        .get();

      if (subQuery.empty) {
        throw new HttpsError("not-found", "No active/paused subscription found.");
      }
      
      const subDoc = subQuery.docs[0];
      const subData = subDoc.data();
      const stripeSubId = subData?.stripeSubscriptionId;
      const isManual = subData?.isManual || subData?.type === 'promo';

      if (!stripeSubId) {
        if (isManual) {
           console.log(`Canceling MANUAL/PROMO subscription for user ${userId}`);
           await subDoc.ref.update({
            status: "canceled",
            canceledAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          return { success: true, message: "Assinatura manual cancelada com sucesso." };
        }
        throw new HttpsError("failed-precondition", "No Stripe subscription ID found.");
      }

      if (cancelAtPeriodEnd) {
        // Cancel at end of billing period
        await stripe.subscriptions.update(stripeSubId, {
          cancel_at_period_end: true,
        });
      } else {
        // Cancel immediately
        await stripe.subscriptions.cancel(stripeSubId);
      }

      // Update Firestore
      await subDoc.ref.update({
        status: "canceled",
        canceledAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`Subscription canceled for user ${userId}`);
      return { success: true, message: "Subscription canceled successfully." };
    } catch (error: any) {
      if (error instanceof HttpsError) throw error;
      console.error("Error canceling subscription:", error);
      
      // Explicitly handle Stripe errors
      if (error?.type?.startsWith('Stripe')) {
         const stripeMsg = error.message || "Stripe error";
         if (error.code === 'resource_missing') {
             throw new HttpsError("not-found", `Stripe: ${stripeMsg}`);
         }
         throw new HttpsError("failed-precondition", `Stripe: ${stripeMsg}`);
      }

      const message = error.message || "Unknown error";
      throw new HttpsError("internal", message);
    }
  },
);

/**
 * Admin: Resume a paused subscription
 */
export const adminResumeSubscription = onCall(
  { secrets: [stripeSecret], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be authenticated.");
    }

    // Verify admin role
    const adminDoc = await admin.firestore()
      .collection("users")
      .doc(request.auth.uid)
      .get();

    if (adminDoc.data()?.role !== "admin") {
      throw new HttpsError("permission-denied", "Only admins can manage subscriptions.");
    }

    const { userId } = request.data;
    if (!userId) {
      throw new HttpsError("invalid-argument", "userId is required.");
    }

    try {
      const stripe = await getStripe();

      // Get subscription from Firestore (Query by userId)
      const subQuery = await admin.firestore()
        .collection("subscriptions")
        .where("userId", "==", userId)
        .where("status", "in", ["active", "trialing", "past_due", "paused"])
        .orderBy("createdAt", "desc")
        .limit(1)
        .get();

      if (subQuery.empty) {
        throw new HttpsError("not-found", "Subscription not found.");
      }
      
      const subDoc = subQuery.docs[0];
      const subData = subDoc.data();
      const stripeSubId = subData?.stripeSubscriptionId;
      const isManual = subData?.isManual || subData?.type === 'promo';

      if (!stripeSubId) {
        if (isManual) {
           console.log(`Resuming MANUAL/PROMO subscription for user ${userId}`);
           await subDoc.ref.update({
            status: "active",
            resumedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          return { success: true, message: "Assinatura manual retomada com sucesso." };
        }
        throw new HttpsError("failed-precondition", "No Stripe subscription ID found.");
      }

      // Resume subscription in Stripe (remove pause)
      await stripe.subscriptions.update(stripeSubId, {
        pause_collection: null,
      });

      // Update Firestore
      await subDoc.ref.update({
        status: "active",
        resumedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`Subscription resumed for user ${userId}`);
      return { success: true, message: "Subscription resumed successfully." };
    } catch (error: any) {
      if (error instanceof HttpsError) throw error;
      console.error("Error resuming subscription:", error);
      
      // Explicitly handle Stripe errors
      if (error?.type?.startsWith('Stripe')) {
         const stripeMsg = error.message || "Stripe error";
         if (error.code === 'resource_missing') {
             throw new HttpsError("not-found", `Stripe: ${stripeMsg}`);
         }
         throw new HttpsError("failed-precondition", `Stripe: ${stripeMsg}`);
      }

      const message = error.message || "Unknown error";
      throw new HttpsError("internal", message);
    }
  },
);

/**
 * Gets list of Stripe subscriptions for admin financial reports.
 * Requires admin role.
 */
export const getStripeSubscriptions = onCall(
  { secrets: [stripeSecret], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
      );
    }

    // Check admin role
    const userDoc = await admin.firestore()
      .collection("users")
      .doc(request.auth.uid)
      .get();

    if (!userDoc.exists || userDoc.data()?.role !== "admin") {
      throw new HttpsError(
        "permission-denied",
        "Only admins can access this function.",
      );
    }

    const { status, limit = 100, startingAfter } = request.data;

    try {
      const stripe = await getStripe();

      const params: any = {
        limit: Math.min(limit, 100),
        expand: ["data.customer"],
      };

      if (status) {
        params.status = status;
      }

      if (startingAfter) {
        params.starting_after = startingAfter;
      }

      const subscriptions = await stripe.subscriptions.list(params);

      const formattedSubs = subscriptions.data.map((sub) => {
        const customer = sub.customer as Stripe.Customer;
        const priceItem = sub.items.data[0];
        const price = priceItem?.price;
        // Use type assertion for properties that exist at runtime
        const subAny = sub as any;

        return {
          id: sub.id,
          customerId: customer?.id || sub.customer,
          customerEmail: customer?.email || null,
          customerName: customer?.name || null,
          status: sub.status,
          amount: (price?.unit_amount || 0) / 100,
          currency: price?.currency || "brl",
          interval: price?.recurring?.interval || "month",
          currentPeriodStart: subAny.current_period_start,
          currentPeriodEnd: subAny.current_period_end,
          canceledAt: sub.canceled_at,
          createdAt: sub.created,
        };
      });

      return {
        subscriptions: formattedSubs,
        hasMore: subscriptions.has_more,
        lastId: formattedSubs.length > 0
          ? formattedSubs[formattedSubs.length - 1].id
          : null,
      };
    } catch (error) {
      console.error("Error fetching subscriptions:", error);
      const message = (error as any).message || "Unknown error";
      throw new HttpsError("internal", message);
    }
  },
);

/**
 * Gets list of Stripe transactions (charges/invoices) for admin financial reports.
 * Requires admin role.
 */
export const getStripeTransactions = onCall(
  { secrets: [stripeSecret], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
      );
    }

    // Check admin role
    const userDoc = await admin.firestore()
      .collection("users")
      .doc(request.auth.uid)
      .get();

    if (!userDoc.exists || userDoc.data()?.role !== "admin") {
      throw new HttpsError(
        "permission-denied",
        "Only admins can access this function.",
      );
    }

    const { startDate, endDate, limit = 100, startingAfter } = request.data;

    try {
      const stripe = await getStripe();

      const params: any = {
        limit: Math.min(limit, 100),
        expand: ["data.customer"],
      };

      if (startDate) {
        params.created = params.created || {};
        params.created.gte = Math.floor(new Date(startDate).getTime() / 1000);
      }

      if (endDate) {
        params.created = params.created || {};
        params.created.lte = Math.floor(new Date(endDate).getTime() / 1000);
      }

      if (startingAfter) {
        params.starting_after = startingAfter;
      }

      const charges = await stripe.charges.list(params);

      const formattedTransactions = charges.data.map((charge) => {
        const customer = charge.customer as Stripe.Customer;

        return {
          id: charge.id,
          customerId: customer?.id || charge.customer || null,
          customerEmail: customer?.email || charge.billing_details?.email || null,
          amount: charge.amount / 100,
          currency: charge.currency,
          status: charge.status,
          description: charge.description,
          createdAt: charge.created,
          paid: charge.paid,
          refunded: charge.refunded,
          receiptUrl: charge.receipt_url,
        };
      });

      return {
        transactions: formattedTransactions,
        hasMore: charges.has_more,
        lastId: formattedTransactions.length > 0
          ? formattedTransactions[formattedTransactions.length - 1].id
          : null,
      };
    } catch (error) {
      console.error("Error fetching transactions:", error);
      const message = (error as any).message || "Unknown error";
      throw new HttpsError("internal", message);
    }
  },
);

/**
 * Admin: Adjust bonus washes for a subscriber.
 * Bonus washes are added to the plan's washesPerMonth limit.
 * This allows admins to grant extra washes without changing the plan.
 */
export const adminAdjustBonusWashes = onCall(
  { cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be authenticated.");
    }

    // Verify admin role
    const adminDoc = await admin.firestore()
      .collection("users")
      .doc(request.auth.uid)
      .get();

    if (adminDoc.data()?.role !== "admin") {
      throw new HttpsError("permission-denied", "Only admins can adjust bonus washes.");
    }

    const { userId, bonusWashes } = request.data;
    
    if (!userId) {
      throw new HttpsError("invalid-argument", "userId is required.");
    }
    
    if (typeof bonusWashes !== "number" || bonusWashes < 0) {
      throw new HttpsError("invalid-argument", "bonusWashes must be a non-negative number.");
    }

    try {
      // Find subscription for this user
      const subsQuery = await admin.firestore()
        .collection("subscriptions")
        .where("userId", "==", userId)
        .limit(1)
        .get();

      if (subsQuery.empty) {
        throw new HttpsError("not-found", "No subscription found for this user.");
      }

      const subDoc = subsQuery.docs[0];
      const previousBonusWashes = subDoc.data().bonusWashes || 0;

      // Update bonus washes
      await subDoc.ref.update({
        bonusWashes: bonusWashes,
        bonusWashesUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
        bonusWashesUpdatedBy: request.auth.uid,
      });

      console.log(`Bonus washes adjusted for user ${userId}: ${previousBonusWashes} -> ${bonusWashes}`);
      
      return { 
        success: true, 
        message: `Lavagens bônus atualizadas de ${previousBonusWashes} para ${bonusWashes}.`,
        previousBonusWashes,
        newBonusWashes: bonusWashes,
      };
    } catch (error) {
      if (error instanceof HttpsError) throw error;
      console.error("Error adjusting bonus washes:", error);
      const message = (error as any).message || "Unknown error";
      throw new HttpsError("internal", message);
    }
  },
);

/**
 * Admin: Grant premium days to a non-subscriber
 * Creates a promotional subscription without Stripe billing
 */
export const adminGrantPremiumDays = onCall(
  { cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be authenticated.");
    }

    // Verify admin role
    const adminDoc = await admin.firestore()
      .collection("users")
      .doc(request.auth.uid)
      .get();

    if (adminDoc.data()?.role !== "admin") {
      throw new HttpsError("permission-denied", "Only admins can grant premium days.");
    }

    const { userId, days } = request.data;
    
    if (!userId) {
      throw new HttpsError("invalid-argument", "userId is required.");
    }
    
    if (typeof days !== "number" || days <= 0) {
      throw new HttpsError("invalid-argument", "days must be a positive number.");
    }

    try {
      // Check if user already has a subscription
      const subsQuery = await admin.firestore()
        .collection("subscriptions")
        .where("userId", "==", userId)
        .limit(1)
        .get();

      const now = new Date();
      const endDate = new Date(now.getTime() + days * 24 * 60 * 60 * 1000);

      if (!subsQuery.empty) {
        // User has existing subscription - extend it or update
        const subDoc = subsQuery.docs[0];
        const currentEndDate = subDoc.data().endDate?.toDate?.() || now;
        const newEndDate = currentEndDate > now 
          ? new Date(currentEndDate.getTime() + days * 24 * 60 * 60 * 1000)
          : endDate;

        await subDoc.ref.update({
          status: "active",
          endDate: newEndDate,
          type: "promo",
          promoGrantedAt: admin.firestore.FieldValue.serverTimestamp(),
          promoGrantedBy: request.auth.uid,
          promoDaysGranted: admin.firestore.FieldValue.increment(days),
        });

        console.log(`Extended subscription for user ${userId}: +${days} days until ${newEndDate.toISOString()}`);
      } else {
        // Create new promotional subscription
        await admin.firestore().collection("subscriptions").add({
          userId: userId,
          planId: "promo-admin",
          status: "active",
          type: "promo",
          startDate: now,
          endDate: endDate,
          promoGrantedAt: admin.firestore.FieldValue.serverTimestamp(),
          promoGrantedBy: request.auth.uid,
          promoDaysGranted: days,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log(`Created promo subscription for user ${userId}: ${days} days until ${endDate.toISOString()}`);
      }

      return { 
        success: true, 
        message: `Premium concedido por ${days} dias.`,
        endDate: endDate.toISOString(),
      };
    } catch (error) {
      if (error instanceof HttpsError) throw error;
      console.error("Error granting premium days:", error);
      const message = (error as any).message || "Unknown error";
      throw new HttpsError("internal", message);
    }
  },
);

/**
 * Creates a Payment Intent for independent service bookings.
 * Returns the client secret and publishable key for the Flutter app.
 */
export const createServicePaymentIntent = onCall(
  { secrets: [stripeSecret, stripePublishableKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
      );
    }

    const userId = request.auth.uid;
    const { 
      serviceId, 
      amount, 
      serviceName,
      // Booking metadata for webhook to create booking automatically
      scheduledTime,
      vehicleId,
      vehiclePlate,
      vehicleModel,
      userName,
      userPhone,
      totalPrice,
    } = request.data;

    if (!serviceId || !amount) {
      throw new HttpsError(
        "invalid-argument",
        "serviceId and amount are required.",
      );
    }

    try {
      const stripe = await getStripe();

      // Get or create Stripe customer
      const userDoc = await admin.firestore()
        .collection("users")
        .doc(userId)
        .get();

      let customerId = userDoc.data()?.stripeCustomerId;

      if (!customerId) {
        const userEmail = request.auth.token.email;
        const customer = await stripe.customers.create({
          email: userEmail,
          metadata: { firebaseUID: userId },
        });
        customerId = customer.id;

        await admin.firestore()
          .collection("users")
          .doc(userId)
          .update({ stripeCustomerId: customerId });
      }

      // Create ephemeral key
      const ephemeralKey = await stripe.ephemeralKeys.create(
        { customer: customerId },
        { apiVersion: "2024-06-20" },
      );

      // Create payment intent with booking metadata
      const paymentIntent = await stripe.paymentIntents.create({
        amount: Math.round(Number(amount)), // Ensure integer cents
        currency: "brl",
        customer: customerId,
        payment_method_types: ["card"],
        metadata: {
          firebaseUID: userId,
          serviceId: serviceId,
          serviceName: serviceName || "Serviço de Estética",
          type: "independent_service",
          // Booking data for webhook to create booking
          scheduledTime: scheduledTime || "",
          vehicleId: vehicleId || "",
          vehiclePlate: vehiclePlate || "",
          vehicleModel: vehicleModel || "",
          userName: userName || "",
          userPhone: userPhone || "",
          totalPrice: String(totalPrice || 0),
        },
      });

      console.log(`Created PaymentIntent ${paymentIntent.id} for service ${serviceId} scheduled at ${scheduledTime}`);

      const publishableKey = await getStripePublishableKey();

      return {
        paymentIntent: paymentIntent.client_secret,
        ephemeralKey: ephemeralKey.secret,
        customer: customerId,
        publishableKey: publishableKey,
      };
    } catch (error) {
      console.error("Error creating service payment intent:", error);
      const message = (error as any).message || "Unknown error";
      throw new HttpsError("internal", message);
    }
  },
);

/**
 * Admin: Create subscription for a user manually using a Payment Method ID.
 * This is used when admin enters card details in the admin panel.
 */
export const adminCreateSubscription = onCall(
  { secrets: [stripeSecret], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be authenticated.");
    }

    // Verify admin role
    const adminDoc = await admin.firestore()
      .collection("users")
      .doc(request.auth.uid)
      .get();

    if (adminDoc.data()?.role !== "admin") {
      throw new HttpsError("permission-denied", "Only admins can perform this action.");
    }

    const { userId, priceId, paymentMethodId } = request.data;
    
    if (!userId || !priceId || !paymentMethodId) {
      throw new HttpsError("invalid-argument", "Missing required parameters.");
    }

    try {
      const stripe = await getStripe();

      // 1. Get or Create Stripe Customer
      const userDoc = await admin.firestore()
        .collection("users")
        .doc(userId)
        .get();
      
      let customerId = userDoc.data()?.stripeCustomerId;
      // Use email if available, otherwise just metadata
      const userEmail = userDoc.data()?.email; 

      if (!customerId) {
        const customer = await stripe.customers.create({
          email: userEmail,
          metadata: { firebaseUID: userId },
        });
        customerId = customer.id;

        await admin.firestore()
          .collection("users")
          .doc(userId)
          .update({ stripeCustomerId: customerId });
      }

      // 2. Attach Payment Method to Customer
      await stripe.paymentMethods.attach(paymentMethodId, {
        customer: customerId,
      });

      // 3. Set as Default Payment Method
      await stripe.customers.update(customerId, {
        invoice_settings: {
          default_payment_method: paymentMethodId,
        },
      });

      // 4. Create Subscription
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const subscriptionParams: any = {
        customer: customerId,
        items: [{ price: priceId }],
        expand: ['latest_invoice.payment_intent'],
        metadata: {
           firebaseUID: userId,
           createdBy: request.auth.uid, // Admin ID
           isManualAdmin: 'true'
        }
      };

      // Apply coupon if provided
      if (request.data.couponId) {
        console.log(`[Admin] Attempting to apply coupon ${request.data.couponId}`);
        const couponDoc = await admin.firestore()
          .collection("coupons")
          .doc(request.data.couponId)
          .get();
        
        if (!couponDoc.exists) {
            throw new HttpsError("not-found", `Coupon ${request.data.couponId} not found.`);
        }
        
        const stripeCouponId = couponDoc.data()?.stripeCouponId;
        if (!stripeCouponId) {
            console.error(`[Admin] Coupon ${request.data.couponId} missing stripeCouponId`);
            throw new HttpsError("failed-precondition", "Coupon is missing Stripe ID.");
        }

        subscriptionParams.discounts = [{ coupon: stripeCouponId }];
        console.log(`[Admin] Applied coupon ${stripeCouponId} to subscription`);

        // Increment coupon usage count
        await admin.firestore()
        .collection("coupons")
        .doc(request.data.couponId)
        .update({
             usedCount: admin.firestore.FieldValue.increment(1),
        });
      }

      const subscription = await stripe.subscriptions.create(subscriptionParams);

      // CRITICAL: Immediately create/update Firestore subscription document
      const subscriptionsSnapshot = await admin.firestore()
        .collection("subscriptions")
        .where("userId", "==", userId)
        .limit(1)
        .get();

      // Use the actual status from the created subscription
      const status = subscription.status;
      console.log(`[Admin] Stripe subscription created. Status: ${status}, ID: ${subscription.id}`);
      
      if (status !== 'active' && status !== 'trialing') {
        console.warn(`[Admin] Subscription created but not active/trialing. Status: ${status}`);
        // Consider aborting or flagging? For now just log.
      }
      
      const subData = {
        userId: userId,
        planId: priceId,
        status: status === 'active' || status === 'trialing' ? 'active' : status,
        stripeSubscriptionId: subscription.id,
        stripeCustomerId: customerId,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        // If active, set start date now (or use subscription.current_period_start)
        startDate: new Date(),
        endDate: new Date((subscription as any).current_period_end * 1000)
      };

      if (!subscriptionsSnapshot.empty) {
        const existingDoc = subscriptionsSnapshot.docs[0];
        await existingDoc.ref.update(subData);
        console.log(`[Admin] Updated existing subscription doc for user ${userId}`);
      } else {
        await admin.firestore().collection("subscriptions").add({
          ...subData,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`[Admin] Created new subscription doc for user ${userId}`);
      }

      return {
        success: true,
        subscriptionId: subscription.id,
        status: subscription.status,
      };

    } catch (error: any) {
      console.error("Error creating subscription:", error);
      
      const message = error.message || "Unknown error";
      const code = error.code || "unknown_code";
      const type = error.type || "unknown_type";
      
      // Return detailed error to client
      throw new HttpsError("aborted", `Stripe Error [${type}/${code}]: ${message}`);
    }
  },
);

/**
 * Retrieves detailed subscription information, including payment method.
 */
export const getSubscriptionDetails = onCall(
  { secrets: [stripeSecret], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
      );
    }

    const { subscriptionId } = request.data;
    const userId = request.auth.uid;

    if (!subscriptionId) {
      throw new HttpsError(
        "invalid-argument",
        "The function must be called with a subscriptionId.",
      );
    }

    try {
      const stripe = await getStripe();

      // Get subscription from Firestore to verify ownership and get stripeSubscriptionId
      const subDoc = await admin.firestore()
        .collection("subscriptions")
        .doc(subscriptionId)
        .get();

      if (!subDoc.exists) {
        throw new HttpsError("not-found", "Subscription not found.");
      }

      const subData = subDoc.data();
      if (subData?.userId !== userId) {
        throw new HttpsError(
          "permission-denied",
          "Not authorized to view this subscription.",
        );
      }

      const stripeSubId = subData.stripeSubscriptionId;
      if (!stripeSubId) {
        throw new HttpsError(
          "failed-precondition",
          "No Stripe subscription ID found.",
        );
      }

      // Retrieve from Stripe expanding the payment method
      const subscription = await stripe.subscriptions.retrieve(stripeSubId, {
        expand: ['default_payment_method'],
      });

      let paymentMethodDetails = null;
      if (typeof subscription.default_payment_method === 'object' && subscription.default_payment_method !== null) {
          const pm = subscription.default_payment_method as Stripe.PaymentMethod;
          if (pm.card) {
              paymentMethodDetails = {
                  brand: pm.card.brand,
                  last4: pm.card.last4,
                  expMonth: pm.card.exp_month,
                  expYear: pm.card.exp_year,
              };
          }
      }

      return {
        status: subscription.status,
        cancelAtPeriodEnd: subscription.cancel_at_period_end,
        currentPeriodEnd: (subscription as any).current_period_end,
        paymentMethod: paymentMethodDetails,
      };

    } catch (error) {
       console.error("Error getting subscription details:", error);
       // eslint-disable-next-line @typescript-eslint/no-explicit-any
       const message = (error as any).message || "Unknown error";
       throw new HttpsError("internal", message);
    }
  }
);

/**
 * Fetches subscription invoices for the authenticated user.
 * Used to display payment history in the subscription management screen.
 */
export const getSubscriptionInvoices = onCall(
  { secrets: [stripeSecret], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
      );
    }

    const userId = request.auth.uid;

    try {
      const stripe = await getStripe();

      // 1. Get user's Stripe customer ID
      const userDoc = await admin.firestore()
        .collection("users")
        .doc(userId)
        .get();
      
      const customerId = userDoc.data()?.stripeCustomerId;
      
      if (!customerId) {
        // No customer ID means no invoices yet
        return { invoices: [] };
      }

      // 2. Verify customer exists in Stripe
      try {
        const customer = await stripe.customers.retrieve(customerId);
        if (customer.deleted) {
          return { invoices: [] };
        }
      } catch (error: any) {
        if (error.code === "resource_missing") {
          return { invoices: [] };
        }
        throw error;
      }

      // 3. Fetch ALL invoices from Stripe (not filtered by status)
      // This ensures we get both the initial subscription invoice and renewals
      const invoices = await stripe.invoices.list({
        customer: customerId,
        limit: 24, // Last 24 invoices (2 years of monthly)
        expand: ['data.charge'],
      });

      // 4. Map to simplified format - include paid and open invoices
      const allInvoices = invoices.data.filter(inv => 
        inv.status === 'paid' || inv.status === 'open'
      );
      
      // Sort by created date descending
      allInvoices.sort((a, b) => b.created - a.created);

      const mappedInvoices = allInvoices.map((invoice) => {
        // Try to get payment method details from the charge
        let paymentMethodBrand = null;
        let paymentMethodLast4 = null;
        
        // invoice.charge is expanded, cast to any for access
        const charge = (invoice as any).charge as Stripe.Charge | null;
        if (charge && charge.payment_method_details?.card) {
          paymentMethodBrand = charge.payment_method_details.card.brand;
          paymentMethodLast4 = charge.payment_method_details.card.last4;
        }

        return {
          id: invoice.id,
          amountPaid: invoice.amount_paid,
          created: invoice.created,
          status: invoice.status,
          invoicePdf: invoice.invoice_pdf,
          paymentMethodBrand,
          paymentMethodLast4,
        };
      });

      return { invoices: mappedInvoices };

    } catch (error) {
      console.error("Error fetching subscription invoices:", error);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const message = (error as any).message || "Unknown error";
      throw new HttpsError("internal", message);
    }
  }
);

/**
 * Returns the Stripe Publishable Key to authenticated users.
 * This allows the frontend to initialize Stripe without direct access
 * to the secure admin settings document.
 */
export const getPublicStripeConfig = onCall(
  { secrets: [stripePublishableKey], cors: true },
  async (request) => {
    // Check if user is authenticated
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be authenticated.");
    }

    try {
      const settings = await getPaymentSettings();
      
      // Prefer dynamic key, fallback to env var
      const publishableKey = settings?.stripe_publishable_key || stripePublishableKey.value();

      if (!publishableKey) {
        console.warn("No Stripe Publishable Key found.");
        return { publishableKey: null };
      }

      return { publishableKey };
    } catch (error) {
      console.error("Error fetching public Stripe config:", error);
      throw new HttpsError("internal", "Failed to fetch configuration.");
    }
  }
);



