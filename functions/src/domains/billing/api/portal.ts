import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { stripeSecret } from "../../../config/env";
import { getStripe } from "../helpers/stripe";

export const createPortalSession = onCall(
  { secrets: [stripeSecret], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
      );
    }

    const { returnUrl } = request.data;
    const userId = request.auth.uid;
    const tenantId = request.auth.token.tenantId; // Custom claim if verified

    // If no tenantId in token, maybe look up user profile?
    // for MVP assuming admin/owner context has tenantId
    if (!tenantId) {
       // Check if user is owner of a tenant
       const userDoc = await admin.firestore().collection('users').doc(userId).get();
       const userTenantId = userDoc.data()?.tenantId;
       
       if (!userTenantId) {
         throw new HttpsError("failed-precondition", "User is not linked to a tenant.");
       }
       // Verify role if needed
    }

    try {
      const stripe = await getStripe();
      
      // Get Tenant to find Customer ID
      // CAUTION: This assumes the USER is managing the TENANT'S subscription
      // Depending on architecture, might need to fetch the Tenant Doc
      const docId = tenantId || (await admin.firestore().collection('users').doc(userId).get()).data()?.tenantId;
      
      const tenantDoc = await admin.firestore().collection('tenants').doc(docId).get();
      if (!tenantDoc.exists) {
          throw new HttpsError("not-found", "Tenant not found.");
      }
      
      const stripeCustomerId = tenantDoc.data()?.stripeCustomerId;
      if (!stripeCustomerId) {
          throw new HttpsError("failed-precondition", "Tenant has no Stripe Customer ID.");
      }

      const session = await stripe.billingPortal.sessions.create({
        customer: stripeCustomerId,
        return_url: returnUrl || 'https://dashboard.lavaflow.app', 
      });

      return { url: session.url };
    } catch (error) {
      console.error("Error creating portal session:", error);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const message = (error as any).message || "Unknown error";
      throw new HttpsError("internal", message);
    }
  },
);
