"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createTenantService = void 0;
const firebase_1 = require("../../../config/firebase");
const stripe_1 = require("../../billing/helpers/stripe");
const generateSlug = (name) => {
    return name
        .toLowerCase()
        .normalize('NFD') // Remove accents
        .replace(/[\u0300-\u036f]/g, '')
        .trim()
        .replace(/[^\w\s-]/g, '')
        .replace(/[\s_-]+/g, '-')
        .replace(/^-+|-+$/g, '');
};
const createTenantService = async (ownerUid, name, preferredTenantId) => {
    // 1. Create Tenant Reference
    const tenantId = preferredTenantId || firebase_1.db.collection('tenants').doc().id;
    const tenantRef = firebase_1.db.collection('tenants').doc(tenantId);
    const slug = `${generateSlug(name)}-${tenantId.substring(0, 4)}`; // Ensure uniqueness with prefix
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
        slug: slug,
        ownerId: ownerUid,
        stripeCustomerId: customer.id,
        branding: {
            primaryColor: '#2196F3', // Default Material Blue
        },
        domains: {
            subdomain: slug,
            domainVerified: false,
        },
        createdAt: firebase_1.FieldValue.serverTimestamp(),
    };
    await tenantRef.set(newTenant);
    // 4. Update User with TenantId and Role
    await firebase_1.db.collection('users').doc(ownerUid).set({
        tenantId: tenantRef.id,
        role: 'owner'
    }, { merge: true });
    return { tenantId: tenantRef.id, slug: slug };
};
exports.createTenantService = createTenantService;
//# sourceMappingURL=tenantService.js.map