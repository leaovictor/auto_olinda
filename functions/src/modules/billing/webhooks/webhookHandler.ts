
import * as functions from 'firebase-functions';
import { stripe } from '../../../config/stripe';
import { env } from '../../../config/env';
import { handleStripeEvent } from '../services/billingSync';

export const stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'];

  if (!sig) {
    res.status(400).send('Webhook Error: Missing stripe-signature');
    return;
  }

  let event;

  try {
    // rawBody is available in Firebase Functions (needs to be enabled in some setups, but standard in others)
    event = stripe.webhooks.constructEvent((req as any).rawBody, sig, env.STRIPE_WEBHOOK_SECRET);
  } catch (err: any) {
    console.error(`⚠️  Webhook signature verification failed.`, err.message);
    res.status(400).send(`Webhook Error: ${err.message}`);
    return;
  }

  try {
    // Whitelist events we care about to reduce noise / cost
    const allowedEvents = [
      'checkout.session.completed',
      'invoice.payment_succeeded', 
      'invoice.payment_failed',
      'customer.subscription.created',
      'customer.subscription.updated',
      'customer.subscription.deleted'
    ];

    if (allowedEvents.includes(event.type)) {
      await handleStripeEvent(event);
    } else {
      console.log(`Ignoring event type ${event.type}`);
    }

    res.json({ received: true });
  } catch (error) {
    console.error(`Error processing webhook:`, error);
    res.status(500).send('Internal Server Error');
  }
});
