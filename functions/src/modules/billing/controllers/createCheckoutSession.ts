
import * as functions from 'firebase-functions';
import { requireAuth, requireTenantAdmin } from '../../../core/safety/guards';
import { createCheckoutSessionSchema } from '../../../core/safety/validators';
import { stripe } from '../../../config/stripe';
import { successResponse, errorResponse } from '../../../core/utils/response';

export const createCheckoutSession = functions.https.onCall(async (data, context) => {
  const auth = requireAuth(context);
  // Get userData inside guard
  const user = await requireTenantAdmin(auth.uid, auth.token.tenantId);
  // user.tenantId is guaranteed to be present by requireTenantAdmin
  
  const validation = createCheckoutSessionSchema.safeParse(data);
  if (!validation.success) {
    return errorResponse('invalid-argument', 'Invalid data', validation.error.format());
  }

  // Fetch Tenant to get Stripe Customer ID
  // Optimisation: Could pass this in auth token custom claims, but for safety, fetch.
  // Actually requireTenantAdmin fetches user. Now fetch Tenant.
  const tenantRef = await import('../../../config/firebase').then(m => m.db.collection('tenants').doc(user.tenantId!));
  const tenantSnap = await tenantRef.get();
  const tenantData = tenantSnap.data();

  if (!tenantData || !tenantData.stripeCustomerId) {
    return errorResponse('failed-precondition', 'Tenant has no Stripe Customer ID');
  }

  try {
    const session = await stripe.checkout.sessions.create({
      customer: tenantData.stripeCustomerId,
      mode: 'subscription',
      payment_method_types: ['card'],
      line_items: [{ price: validation.data.priceId, quantity: 1 }],
      success_url: validation.data.successUrl,
      cancel_url: validation.data.cancelUrl,
      allow_promotion_codes: true,
      billing_address_collection: 'required',
      metadata: {
        firebaseTenantId: user.tenantId!,
        initiatedBy: auth.uid
      }
    });

    return successResponse({ url: session.url });
  } catch (error: any) {
    console.error(error);
    return errorResponse('internal', 'Stripe Checkout Failed', error.message);
  }
});
