"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createTenant = void 0;
const https_1 = require("firebase-functions/v2/https");
const guards_1 = require("../../core/safety/guards");
const validators_1 = require("../../core/safety/validators");
const tenantService_1 = require("./services/tenantService");
const response_1 = require("../../core/utils/response");
const firebase_1 = require("../../config/firebase");
exports.createTenant = (0, https_1.onCall)(async (request) => {
    const auth = (0, guards_1.requireAuth)(request);
    // Validation
    const validation = validators_1.createTenantSchema.safeParse(request.data);
    if (!validation.success) {
        return (0, response_1.errorResponse)('invalid-argument', 'Invalid data', validation.error.format());
    }
    // Check if user already has a tenant (Optional restriction)
    const userSnap = await firebase_1.db.collection('users').doc(auth.uid).get();
    const userData = userSnap.data();
    if (userData === null || userData === void 0 ? void 0 : userData.tenantId) {
        return (0, response_1.errorResponse)('already-exists', 'User already belongs to a tenant');
    }
    try {
        const result = await (0, tenantService_1.createTenantService)(auth.uid, validation.data.name);
        return (0, response_1.successResponse)(result);
    }
    catch (error) {
        console.error(error);
        return (0, response_1.errorResponse)('internal', 'Failed to create tenant', error.message);
    }
});
//# sourceMappingURL=createTenant.js.map