"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onCreateUser = void 0;
const functions = require("firebase-functions/v1");
const firebase_1 = require("../../config/firebase");
exports.onCreateUser = functions.auth.user().onCreate(async (user) => {
    const newUser = {
        uid: user.uid,
        email: user.email || '',
        displayName: user.displayName || '',
        createdAt: firebase_1.FieldValue.serverTimestamp(),
        // tenantId remains undefined until they create or join a tenant
    };
    await firebase_1.db.collection('users').doc(user.uid).set(newUser);
    console.log(`[Auth] User created: ${user.uid}`);
});
//# sourceMappingURL=onCreateUser.js.map