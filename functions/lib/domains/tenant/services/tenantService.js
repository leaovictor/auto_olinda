"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createTenantService = void 0;
const firebase_1 = require("../../../config/firebase");
const stripe_1 = require("../../billing/helpers/stripe");
const createTenantService = async (ownerUid, name) => {
    // 1. Create Tenant Reference
    const tenantRef = firebase_1.db.collection('tenants').doc();
    // 2. Create Stripe Customer with Metadata
    const stripe = await (0, stripe_1.getStripe)();
    const customer = await stripe.customers.create({
        name: name,
        metadata: {
            firebaseTenantId: tenantRef.id,
            ownerUid: ownerUid
        }
    });
    // 3. Create Tenant Doc
    const newTenant = {
        id: tenantRef.id,
        name: name,
        ownerId: ownerUid,
        stripeCustomerId: customer.id,
        createdAt: firebase_1.FieldValue.serverTimestamp(),
    };
    await tenantRef.set(newTenant);
    // 4. Update User with TenantId and Role
    await firebase_1.db.collection('users').doc(ownerUid).update({
        tenantId: tenantRef.id,
        role: 'owner'
    });
    return { tenantId: tenantRef.id };
};
exports.createTenantService = createTenantService;
//# sourceMappingURL=tenantService.js.map