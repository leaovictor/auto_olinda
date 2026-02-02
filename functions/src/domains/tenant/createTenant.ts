
import { onCall, CallableRequest } from 'firebase-functions/v2/https';
import { requireAuth } from '../../core/safety/guards';
import { createTenantSchema } from '../../core/safety/validators';
import { createTenantService } from './services/tenantService';
import { successResponse, errorResponse } from '../../core/utils/response';
import { db } from '../../config/firebase';

export const createTenant = onCall(async (request: CallableRequest<any>) => {
  const auth = requireAuth(request);
  
  // Validation
  const validation = createTenantSchema.safeParse(request.data);
  if (!validation.success) {
    return errorResponse('invalid-argument', 'Invalid data', validation.error.format());
  }

  // Check if user already has a tenant (Optional restriction)
  const userSnap = await db.collection('users').doc(auth.uid).get();
  const userData = userSnap.data();
  if (userData?.tenantId) {
    return errorResponse('already-exists', 'User already belongs to a tenant');
  }

  try {
    const result = await createTenantService(auth.uid, validation.data.name);
    return successResponse(result);
  } catch (error: any) {
    console.error(error);
    return errorResponse('internal', 'Failed to create tenant', error.message);
  }
});
