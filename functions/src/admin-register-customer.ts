import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { getStripe } from "./stripe";

/**
 * Admin function to register a new customer, create their account,
 * register their vehicle, and create a Stripe subscription.
 */
export const registerCustomerByAdmin = onCall(async (request) => {
    // 1. Verify Admin Role
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "User must be authenticated.");
    }

    const callerUid = request.auth.uid;
    const callerDoc = await admin.firestore().collection("users").doc(callerUid).get();
    
    if (!callerDoc.exists || callerDoc.data()?.role !== "admin") {
        throw new HttpsError("permission-denied", "Only admins can register customers.");
    }

    const {
        email,
        phone,
        name,
        plate,
        model,
        planId,
        paymentMethodId,
        vehicleCategory
    } = request.data;

    if (!email || !phone || !plate || !planId) {
        throw new HttpsError("invalid-argument", "Missing required fields (email, phone, plate, planId).");
    }

    try {
        const db = admin.firestore();
        const stripe = await getStripe();

        // 2. Check if user exists in Auth
        let userRecord;
        try {
            userRecord = await admin.auth().getUserByEmail(email);
            console.log(`User already exists in Auth: ${userRecord.uid}`);
        } catch (e: any) {
            if (e.code === 'auth/user-not-found') {
                // Create user
                console.log(`Creating new user in Auth for email: ${email}`);
                userRecord = await admin.auth().createUser({
                    email,
                    phoneNumber: phone,
                    displayName: name,
                    password: Math.random().toString(36).slice(-10), // Random temp password
                });
            } else {
                throw e;
            }
        }

        const userId = userRecord.uid;

        // 3. Ensure user doc exists in Firestore
        const userRef = db.collection("users").doc(userId);
        let userDoc = await userRef.get();

        if (!userDoc.exists) {
            console.log(`Creating user document in Firestore: ${userId}`);
            await userRef.set({
                uid: userId,
                email,
                displayName: name,
                phoneNumber: phone,
                role: "client",
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                subscriptionStatus: "inactive",
                ndaAcceptedVersion: 0,
            });
            userDoc = await userRef.get();
        }

        // 4. Create/Get Stripe Customer
        let stripeCustomerId = userDoc.data()?.stripeCustomerId;
        if (!stripeCustomerId) {
            console.log(`Creating Stripe customer for user: ${userId}`);
            const customer = await stripe.customers.create({
                email,
                name,
                phone,
                metadata: { firebaseUID: userId },
            });
            stripeCustomerId = customer.id;
            await userRef.update({ stripeCustomerId });
        }

        // 5. Attach Payment Method if provided
        if (paymentMethodId) {
            console.log(`Attaching payment method ${paymentMethodId} to customer ${stripeCustomerId}`);
            await stripe.paymentMethods.attach(paymentMethodId, {
                customer: stripeCustomerId,
            });
            await stripe.customers.update(stripeCustomerId, {
                invoice_settings: { default_payment_method: paymentMethodId },
            });
        }

        // 6. Get Plan Details
        const planDoc = await db.collection("plans").doc(planId).get();
        if (!planDoc.exists) {
            throw new HttpsError("not-found", "Plan not found.");
        }
        const planData = planDoc.data();
        const stripePriceId = planData?.stripePriceId;
        if (!stripePriceId) {
            throw new HttpsError("failed-precondition", "Plan is not synced with Stripe.");
        }

        // 7. Create Stripe Subscription
        console.log(`Creating Stripe subscription for price: ${stripePriceId}`);
        const subscription = await stripe.subscriptions.create({
            customer: stripeCustomerId,
            items: [{ price: stripePriceId }],
            payment_behavior: 'default_incomplete',
            payment_settings: { save_default_payment_method: 'on_subscription' },
            expand: ['latest_invoice.payment_intent'],
            metadata: {
                firebaseUID: userId,
                vehiclePlate: plate,
            }
        });

        // 8. Create/Link Vehicle
        const vehicleSnapshot = await db.collection("vehicles")
            .where("plate", "==", plate)
            .limit(1)
            .get();

        let vehicleId;
        if (vehicleSnapshot.empty) {
            console.log(`Creating new vehicle for plate: ${plate}`);
            const newVehicleRef = await db.collection("vehicles").add({
                userId,
                plate,
                model,
                category: vehicleCategory || planData?.category || "hatchback",
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            vehicleId = newVehicleRef.id;
        } else {
            vehicleId = vehicleSnapshot.docs[0].id;
            console.log(`Updating existing vehicle: ${vehicleId}`);
            await db.collection("vehicles").doc(vehicleId).update({
                userId,
                model,
                category: vehicleCategory || planData?.category || "hatchback",
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        }

        // 9. Save Subscription to Firestore
        const appStatus = (subscription.status === 'active' || subscription.status === 'trialing') ? 'active' : 'incomplete';
        
        console.log(`Saving subscription to Firestore. Status: ${appStatus}`);
        await db.collection('subscriptions').add({
            userId,
            planId: stripePriceId, // App convention: planId stores stripePriceId
            vehicleId: vehicleId,
            status: appStatus,
            stripeSubscriptionId: subscription.id,
            stripeCustomerId: stripeCustomerId,
            linkedPlate: plate,
            startDate: admin.firestore.FieldValue.serverTimestamp(),
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Update user status
        await userRef.update({
            subscriptionStatus: appStatus,
            subscriptionUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return {
            success: true,
            userId,
            subscriptionId: subscription.id,
            status: subscription.status
        };

    } catch (error: any) {
        console.error("Error in registerCustomerByAdmin:", error);
        throw new HttpsError("internal", error.message || "Failed to register customer.");
    }
});
