import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { getStripe, stripeSecret } from "./stripe";

/**
 * Creates a Payment Intent for a booking.
 * Used for non-premium users or paid services.
 */
export const createBookingPaymentIntent = onCall(
    { secrets: [stripeSecret], cors: true },
    async (request) => {
        console.log("createBookingPaymentIntent called");
        if (!request.auth) {
            throw new HttpsError(
                "unauthenticated",
                "The function must be called while authenticated.",
            );
        }

        const { amount, currency = "brl" } = request.data;
        const userId = request.auth.uid;
        const userEmail = request.auth.token.email;

        if (!amount) {
            throw new HttpsError(
                "invalid-argument",
                "The function must be called with an amount.",
            );
        }

        try {
            const stripe = getStripe();

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

            // 3. Create Payment Intent
            // Amount is expected in cents (e.g., 1000 for R$ 10.00)
            // If the frontend sends float (e.g., 10.00), multiply by 100.
            // Assuming frontend sends the float value, we convert here to be safe.
            const amountInCents = Math.round(amount * 100);

            const paymentIntent = await stripe.paymentIntents.create({
                amount: amountInCents,
                currency: currency,
                customer: customerId,
                automatic_payment_methods: {
                    enabled: true,
                },
                metadata: {
                    firebaseUID: userId,
                    type: "booking_payment",
                },
            });

            return {
                paymentIntent: paymentIntent.client_secret,
                ephemeralKey: ephemeralKey.secret,
                customer: customerId,
                publishableKey: "pk_test_51SYcoM5uVLC6EX3m78P74UhblBFyRfK4kilvUS8rO94CbvXrQYmsg1ApO9r3Sf0YuCELV3TcKE06b3HOfvCJkN7I00reQwOwau", // TODO: Use env var
            };
        } catch (error) {
            console.error("Error creating booking payment intent:", error);
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
            const message = (error as any).message || "Unknown error";
            throw new HttpsError("internal", message);
        }
    },
);

/**
 * Creates a Checkout Session for a booking (for mobile web).
 * Redirects users to Stripe's hosted payment page which works
 * reliably on mobile browsers.
 */
export const createBookingCheckoutSession = onCall(
    { secrets: [stripeSecret], cors: true },
    async (request) => {
        console.log("createBookingCheckoutSession called");
        if (!request.auth) {
            throw new HttpsError(
                "unauthenticated",
                "The function must be called while authenticated.",
            );
        }

        const { amount, currency = "brl", successUrl, cancelUrl, vehicleId, serviceIds, scheduledTime } = request.data;
        const userId = request.auth.uid;
        const userEmail = request.auth.token.email;

        // ...

        // Convert serviceIds array to comma-separated string for metadata
        const serviceIdsStr = Array.isArray(serviceIds) ? serviceIds.join(',') : (serviceIds || "");

        if (!amount) {
            throw new HttpsError(
                "invalid-argument",
                "The function must be called with an amount.",
            );
        }

        try {
            const stripe = getStripe();

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
                        console.log(`Customer ${customerId} deleted. Creating new one.`);
                        shouldCreateCustomer = true;
                    }
                } catch (error: any) {
                    if (error.code === "resource_missing") {
                        console.log(`Customer ${customerId} not found. Creating new one.`);
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

            // 2. Convert amount to cents
            const amountInCents = Math.round(amount * 100);

            // 3. Create Checkout Session
            const session = await stripe.checkout.sessions.create({
                mode: "payment",
                payment_method_types: ["card", "pix"],
                customer: customerId,
                line_items: [
                    {
                        price_data: {
                            currency: currency,
                            product_data: {
                                name: "Lavagem Auto Olinda",
                                description: "Pagamento de serviço de lavagem",
                            },
                            unit_amount: amountInCents,
                        },
                        quantity: 1,
                    },
                ],
                success_url: successUrl || "https://autoolinda.app/payment-success",
                cancel_url: cancelUrl || "https://autoolinda.app/payment-cancel",
                metadata: {
                    firebaseUID: userId,
                    type: "one_time_service", // Matches orders.ts fulfillment logic
                    vehicleId: vehicleId || "",
                    serviceIds: serviceIdsStr,
                    scheduledTime: scheduledTime || "",
                },
            });

            return {
                url: session.url,
                sessionId: session.id,
            };
        } catch (error) {
            console.error("Error creating booking checkout session:", error);
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
            const message = (error as any).message || "Unknown error";
            throw new HttpsError("internal", message);
        }
    },
);
