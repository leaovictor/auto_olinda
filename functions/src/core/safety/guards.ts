
import * as functions from 'firebase-functions';
import { db } from '../../config/firebase';
import { UserData } from '../types';

export const requireAuth = (context: functions.https.CallableContext) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
  }
  return context.auth;
};

export const requireTenantAdmin = async (uid: string, tenantId?: string) => {
  if (!tenantId) {
    throw new functions.https.HttpsError('failed-precondition', 'User has no tenant');
  }

  const userDoc = await db.collection('users').doc(uid).get();
  const userData = userDoc.data() as UserData | undefined;

  if (!userData || userData.tenantId !== tenantId) {
     throw new functions.https.HttpsError('permission-denied', 'User does not belong to this tenant');
  }

  if (userData.role !== 'admin' && userData.role !== 'owner') {
    throw new functions.https.HttpsError('permission-denied', 'User is not an admin');
  }

  return userData;
};
