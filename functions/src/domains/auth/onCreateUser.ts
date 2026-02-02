
import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';
import { db, FieldValue } from '../../config/firebase';
import { UserData, UserRole } from '../../core/types';

export const onCreateUser = functions.auth.user().onCreate(async (user) => {
  const { uid, email, displayName } = user;
  
  // 1. Check if user has a pending invite (Staff/Admin flow)
  let tenantId: string;
  let role: UserRole;
  let inviteId: string | null = null;
  
  // NOTE: Assuming there's an 'invites' collection where document ID is email or queryable by email
  // specific implementation depends on Invite system, assuming query for now.
  const inviteQuery = await db.collection('invites')
      .where('email', '==', email)
      .limit(1)
      .get();

  if (!inviteQuery.empty) {
    // JOINING EXISTING TENANT
    const inviteDoc = inviteQuery.docs[0];
    const inviteData = inviteDoc.data();
    tenantId = inviteData.tenantId;
    role = (inviteData.role as UserRole) || 'staff';
    inviteId = inviteDoc.id;

    console.log(`[Auth] User ${uid} joining tenant ${tenantId} as ${role} via invite`);
  } else {
    // NEW TENANT (OWNER)
    // Create a new Tenant document
    const newTenantRef = db.collection('tenants').doc();
    tenantId = newTenantRef.id;
    role = 'owner';

    await newTenantRef.set({
      name: `${displayName || 'New'}'s Tenant`,
      createdAt: FieldValue.serverTimestamp(),
      ownerId: uid,
      status: 'active', // Important for security rules
      subscriptionStatus: 'trial',
    });
    
    console.log(`[Auth] User ${uid} created new tenant ${tenantId}`);
  }

  // 2. Set Custom Claims (CRITICAL for Security Rules)
  try {
    await admin.auth().setCustomUserClaims(uid, {
        tenantId,
        role
    });
    console.log(`[Auth] Claims set for ${uid}: tenantId=${tenantId}, role=${role}`);
  } catch (error) {
    console.error(`[Auth] Failed to set claims for ${uid}`, error);
    // Might want to delete the user or retry here to ensure consistency
  }

  // 3. Create User Profile
  const newUser: UserData = {
    uid,
    email: email || '',
    displayName: displayName || '',
    createdAt: FieldValue.serverTimestamp() as FirebaseFirestore.Timestamp,
    tenantId, // Redundant with claim but useful for frontend queries
    role,
  };

  await db.collection('users').doc(uid).set(newUser);
  
  // 4. Cleanup Invite if used
  if (inviteId) {
    await db.collection('invites').doc(inviteId).delete();
  }
});
