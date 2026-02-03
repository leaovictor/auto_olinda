
import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';
import { db, FieldValue } from '../../config/firebase';
import { UserData, UserRole } from '../../core/types';

export const onCreateUser = functions.auth.user().onCreate(async (user) => {
  const { uid, email, displayName } = user;
  
  // 0. Check if user already has a document (created by frontend)
  const existingUserDoc = await db.collection('users').doc(uid).get();
  const existingUserData = existingUserDoc.data();

  if (existingUserData?.tenantId) {
    console.log(`[Auth] User ${uid} already has tenant ${existingUserData.tenantId}. Skipping automatic creation.`);
    // Still set custom claims to be safe
    await admin.auth().setCustomUserClaims(uid, {
        tenantId: existingUserData.tenantId,
        role: existingUserData.role || 'client'
    });
    return;
  }

  // 1. Check if user has a pending invite (Staff/Admin flow)
  let tenantId: string | null = null;
  let role: UserRole = 'client';
  let inviteId: string | null = null;
  
  const inviteQuery = await db.collection('invites')
      .where('email', '==', email)
      .limit(1)
      .get();

  if (!inviteQuery.empty) {
    // JOINING EXISTING TENANT VIA INVITE
    const inviteDoc = inviteQuery.docs[0];
    const inviteData = inviteDoc.data();
    tenantId = inviteData.tenantId;
    role = (inviteData.role as UserRole) || 'staff';
    inviteId = inviteDoc.id;

    console.log(`[Auth] User ${uid} joining tenant ${tenantId} as ${role} via invite`);
  } 

  // 2. Set Custom Claims (if tenant resolved)
  if (tenantId) {
    try {
      await admin.auth().setCustomUserClaims(uid, {
          tenantId,
          role
      });
    } catch (error) {
      console.error(`[Auth] Failed to set claims for ${uid}`, error);
    }
  }

  // 3. Create/Update User Profile
  const newUser: Partial<UserData> = {
    uid,
    email: email || '',
    displayName: displayName || existingUserData?.displayName || '',
    createdAt: existingUserData?.createdAt || FieldValue.serverTimestamp() as FirebaseFirestore.Timestamp,
    tenantId: tenantId || existingUserData?.tenantId,
    role: role || existingUserData?.role || 'client',
  };

  await db.collection('users').doc(uid).set(newUser, { merge: true });
  
  // 4. Cleanup Invite if used
  if (inviteId) {
    await db.collection('invites').doc(inviteId).delete();
  }
});
