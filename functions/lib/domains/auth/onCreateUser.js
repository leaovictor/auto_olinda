"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onCreateUser = void 0;
const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
const firebase_1 = require("../../config/firebase");
exports.onCreateUser = functions.auth.user().onCreate(async (user) => {
    const { uid, email, displayName } = user;
    // 0. Check if user already has a document (created by frontend)
    const existingUserDoc = await firebase_1.db.collection('users').doc(uid).get();
    const existingUserData = existingUserDoc.data();
    if (existingUserData === null || existingUserData === void 0 ? void 0 : existingUserData.tenantId) {
        console.log(`[Auth] User ${uid} already has tenant ${existingUserData.tenantId}. Skipping automatic creation.`);
        // Still set custom claims to be safe
        await admin.auth().setCustomUserClaims(uid, {
            tenantId: existingUserData.tenantId,
            role: existingUserData.role || 'client'
        });
        return;
    }
    // 1. Check if user has a pending invite (Staff/Admin flow)
    let tenantId = null;
    let role = 'client';
    let inviteId = null;
    const inviteQuery = await firebase_1.db.collection('invites')
        .where('email', '==', email)
        .limit(1)
        .get();
    if (!inviteQuery.empty) {
        // JOINING EXISTING TENANT VIA INVITE
        const inviteDoc = inviteQuery.docs[0];
        const inviteData = inviteDoc.data();
        tenantId = inviteData.tenantId;
        role = inviteData.role || 'staff';
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
        }
        catch (error) {
            console.error(`[Auth] Failed to set claims for ${uid}`, error);
        }
    }
    // 3. Create/Update User Profile
    const newUser = {
        uid,
        email: email || '',
        displayName: displayName || (existingUserData === null || existingUserData === void 0 ? void 0 : existingUserData.displayName) || '',
        createdAt: (existingUserData === null || existingUserData === void 0 ? void 0 : existingUserData.createdAt) || firebase_1.FieldValue.serverTimestamp(),
        tenantId: tenantId || (existingUserData === null || existingUserData === void 0 ? void 0 : existingUserData.tenantId),
        role: role || (existingUserData === null || existingUserData === void 0 ? void 0 : existingUserData.role) || 'client',
    };
    await firebase_1.db.collection('users').doc(uid).set(newUser, { merge: true });
    // 4. Cleanup Invite if used
    if (inviteId) {
        await firebase_1.db.collection('invites').doc(inviteId).delete();
    }
});
//# sourceMappingURL=onCreateUser.js.map