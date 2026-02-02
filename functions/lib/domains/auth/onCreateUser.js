"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onCreateUser = void 0;
const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
const firebase_1 = require("../../config/firebase");
exports.onCreateUser = functions.auth.user().onCreate(async (user) => {
    const { uid, email, displayName } = user;
    // 1. Check if user has a pending invite (Staff/Admin flow)
    let tenantId;
    let role;
    let inviteId = null;
    // NOTE: Assuming there's an 'invites' collection where document ID is email or queryable by email
    // specific implementation depends on Invite system, assuming query for now.
    const inviteQuery = await firebase_1.db.collection('invites')
        .where('email', '==', email)
        .limit(1)
        .get();
    if (!inviteQuery.empty) {
        // JOINING EXISTING TENANT
        const inviteDoc = inviteQuery.docs[0];
        const inviteData = inviteDoc.data();
        tenantId = inviteData.tenantId;
        role = inviteData.role || 'staff';
        inviteId = inviteDoc.id;
        console.log(`[Auth] User ${uid} joining tenant ${tenantId} as ${role} via invite`);
    }
    else {
        // NEW TENANT (OWNER)
        // Create a new Tenant document
        const newTenantRef = firebase_1.db.collection('tenants').doc();
        tenantId = newTenantRef.id;
        role = 'owner';
        await newTenantRef.set({
            name: `${displayName || 'New'}'s Tenant`,
            createdAt: firebase_1.FieldValue.serverTimestamp(),
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
    }
    catch (error) {
        console.error(`[Auth] Failed to set claims for ${uid}`, error);
        // Might want to delete the user or retry here to ensure consistency
    }
    // 3. Create User Profile
    const newUser = {
        uid,
        email: email || '',
        displayName: displayName || '',
        createdAt: firebase_1.FieldValue.serverTimestamp(),
        tenantId, // Redundant with claim but useful for frontend queries
        role,
    };
    await firebase_1.db.collection('users').doc(uid).set(newUser);
    // 4. Cleanup Invite if used
    if (inviteId) {
        await firebase_1.db.collection('invites').doc(inviteId).delete();
    }
});
//# sourceMappingURL=onCreateUser.js.map