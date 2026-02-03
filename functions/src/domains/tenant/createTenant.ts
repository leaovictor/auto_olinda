
import { onCall, CallableRequest, HttpsError } from 'firebase-functions/v2/https';
import { requireAuth } from '../../core/safety/guards';
import { createTenantSchema } from '../../core/safety/validators';
import { createTenantService } from './services/tenantService';
import { successResponse } from '../../core/utils/response';
import { db } from '../../config/firebase';

export const createTenant = onCall(async (request: CallableRequest<any>) => {
  const auth = requireAuth(request);
  
  // Validation
  const validation = createTenantSchema.safeParse(request.data);
  if (!validation.success) {
    throw new HttpsError('invalid-argument', 'Invalid data', validation.error.format());
  }

  // Check if user already has a tenant (Optional restriction)
  const userSnap = await db.collection('users').doc(auth.uid).get();
  const userData = userSnap.data();

  try {
    if (userData?.tenantId) {
      console.log(`[Tenant] Adopting existing tenant ${userData.tenantId} for user ${auth.uid}`);
      const result = await createTenantService(auth.uid, validation.data.name, userData.tenantId);
      return successResponse(result);
    }

    const result = await createTenantService(auth.uid, validation.data.name);
    return successResponse(result);
  } catch (error: any) {
    console.error(error);
    if (error instanceof HttpsError) throw error;
    throw new HttpsError('internal', `Falha ao criar estética: ${error.message}`, error);
  }
});
