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
                payment_method_types: ["card"], // Add 'pix' if enabled in Stripe Dashboard
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
