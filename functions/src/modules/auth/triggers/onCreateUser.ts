
import * as functions from 'firebase-functions';
import { db, FieldValue } from '../../../config/firebase';
import { UserData } from '../../../core/types';

export const onCreateUser = functions.auth.user().onCreate(async (user) => {
  const newUser: UserData = {
    uid: user.uid,
    email: user.email || '',
    displayName: user.displayName || '',
    createdAt: FieldValue.serverTimestamp() as FirebaseFirestore.Timestamp,
    // tenantId remains undefined until they create or join a tenant
  };

  await db.collection('users').doc(user.uid).set(newUser);
  console.log(`[Auth] User created: ${user.uid}`);
});
