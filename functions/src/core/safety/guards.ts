import { CallableRequest } from 'firebase-functions/v2/https';
import { HttpsError } from 'firebase-functions/v2/https';
import { db } from '../../config/firebase';
import { UserData } from '../types';

export const requireAuth = (req: CallableRequest) => {
  if (!req.auth) {
    throw new HttpsError('unauthenticated', 'User must be logged in');
  }
  return req.auth;
};

export const requireTenantAdmin = async (uid: string, tenantId?: string) => {
  if (!tenantId) {
    throw new HttpsError('failed-precondition', 'User has no tenant');
  }

  const userDoc = await db.collection('users').doc(uid).get();
  const userData = userDoc.data() as UserData | undefined;

  if (!userData || userData.tenantId !== tenantId) {
     throw new HttpsError('permission-denied', 'User does not belong to this tenant');
  }

  if (userData.role !== 'admin' && userData.role !== 'owner') {
    throw new HttpsError('permission-denied', 'User is not an admin');
  }

  return userData;
};
