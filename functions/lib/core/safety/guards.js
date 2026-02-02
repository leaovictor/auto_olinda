"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireTenantAdmin = exports.requireAuth = void 0;
const https_1 = require("firebase-functions/v2/https");
const firebase_1 = require("../../config/firebase");
const requireAuth = (req) => {
    if (!req.auth) {
        throw new https_1.HttpsError('unauthenticated', 'User must be logged in');
    }
    return req.auth;
};
exports.requireAuth = requireAuth;
const requireTenantAdmin = async (uid, tenantId) => {
    if (!tenantId) {
        throw new https_1.HttpsError('failed-precondition', 'User has no tenant');
    }
    const userDoc = await firebase_1.db.collection('users').doc(uid).get();
    const userData = userDoc.data();
    if (!userData || userData.tenantId !== tenantId) {
        throw new https_1.HttpsError('permission-denied', 'User does not belong to this tenant');
    }
    if (userData.role !== 'admin' && userData.role !== 'owner') {
        throw new https_1.HttpsError('permission-denied', 'User is not an admin');
    }
    return userData;
};
exports.requireTenantAdmin = requireTenantAdmin;
//# sourceMappingURL=guards.js.map