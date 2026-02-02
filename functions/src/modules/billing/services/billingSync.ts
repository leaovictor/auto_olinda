
import * as admin from 'firebase-admin';
import { db, FieldValue } from '../../../config/firebase';
import { SubscriptionData } from '../../../core/types';
import Stripe from 'stripe';

export const handleStripeEvent = async (event: Stripe.Event) => {
  const { id: eventId, type } = event;
  
  // 1. Identify Customer ID
  let stripeCustomerId: string | undefined;
  
  // Cast event.data.object to 'any' solely to access common fields safely without excessive type guards for this strategy
  const dataObject = event.data.object as any; 

  if (dataObject.customer) {
    if (typeof dataObject.customer === 'string') {
        stripeCustomerId = dataObject.customer;
    } else if (typeof dataObject.customer === 'object' && dataObject.customer.id) {
        stripeCustomerId = dataObject.customer.id;
    }
  }

  if (!stripeCustomerId) {
    console.error(`[BillingSync] Could not identify customer for event ${eventId} (${type})`);
    return;
  }

  // 2. Find Tenant
  const tenantsSnap = await db.collection('tenants').where('stripeCustomerId', '==', stripeCustomerId).limit(1).get();
  if (tenantsSnap.empty) {
    console.error(`[BillingSync] Tenant not found for customer: ${stripeCustomerId}`);
    return;
  }
  const tenantDoc = tenantsSnap.docs[0];
  const tenantRef = tenantDoc.ref;

  // 3. Idempotency Check & Transaction
  try {
    await db.runTransaction(async (transaction) => {
      const eventRef = tenantRef.collection('billing_events').doc(eventId);
      const eventDoc = await transaction.get(eventRef);

      if (eventDoc.exists) {
        console.log(`[BillingSync] Event ${eventId} already processed. Skipping.`);
        return;
      }

      // Process Logic based on Type
      // We strictly rely on 'customer.subscription.*' events to update the source of truth.
      if (type.startsWith('customer.subscription.')) {
         const subObject = event.data.object as Stripe.Subscription;
         
         const priceId = subObject.items.data[0]?.price.id;

         // Check if current_period_end is a number (unix) or date
         // properties in Stripe-node are usually numbers/timestamps
         
         const subData: SubscriptionData = {
            status: subObject.status as any,
            planId: priceId,
            currentPeriodEnd: admin.firestore.Timestamp.fromMillis((subObject as any).current_period_end * 1000),
            stripeSubscriptionId: subObject.id,
            stripePriceId: priceId,
         };
         transaction.set(tenantRef.collection('billing').doc('subscription'), subData, { merge: true });
         console.log(`[BillingSync] Queueing subscription update for ${eventId}`);
      }

      // Log the event for history
      transaction.set(eventRef, {
        type: type,
        created: admin.firestore.Timestamp.fromMillis(event.created * 1000),
        processedAt: FieldValue.serverTimestamp(),
        // Store only essential data or full ID reference to save space? Storing full object is safer for Audit.
        data: event.data.object 
      });
    });
    console.log(`[BillingSync] Successfully processed ${type} : ${eventId}`);
  } catch (error) {
    console.error(`[BillingSync] Transaction failed for ${eventId}`, error);
    throw error; 
  }
};

