
import * as functions from 'firebase-functions';
import { requireAuth, requireTenantAdmin } from '../../../core/safety/guards';
import { createPortalSessionSchema } from '../../../core/safety/validators';
import { stripe } from '../../../config/stripe';
import { successResponse, errorResponse } from '../../../core/utils/response';
import { db } from '../../../config/firebase';

export const createPortalSession = functions.https.onCall(async (data, context) => {
  const auth = requireAuth(context);
  const user = await requireTenantAdmin(auth.uid, auth.token.tenantId);

  const validation = createPortalSessionSchema.safeParse(data);
  if (!validation.success) {
    return errorResponse('invalid-argument', 'Invalid data', validation.error.format());
  }

  const tenantSnap = await db.collection('tenants').doc(user.tenantId!).get();
  const tenantData = tenantSnap.data();

  if (!tenantData || !tenantData.stripeCustomerId) {
    return errorResponse('failed-precondition', 'Tenant has no Stripe Customer ID');
  }

  try {
    const session = await stripe.billingPortal.sessions.create({
      customer: tenantData.stripeCustomerId,
      return_url: validation.data.returnUrl,
    });

    return successResponse({ url: session.url });
  } catch (error: any) {
    console.error(error);
    return errorResponse('internal', 'Stripe Portal Failed', error.message);
  }
});
