"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkStripeConnectStatus = exports.createStripeConnectAccount = exports.setupTenant = exports.setUserRole = void 0;
const https_1 = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const params_1 = require("firebase-functions/params");
const stripe_1 = require("stripe");
const stripeSecret = (0, params_1.defineSecret)("STRIPE_SECRET");
// ─────────────────────────────────────────────────────────────
// Helper: get Stripe instance
// ─────────────────────────────────────────────────────────────
const getStripe = () => new stripe_1.default(stripeSecret.value(), { apiVersion: "2023-10-16" });
// ─────────────────────────────────────────────────────────────
// Helper: assert caller is superAdmin
// ─────────────────────────────────────────────────────────────
function assertSuperAdmin(request) {
    if (!request.auth)
        throw new https_1.HttpsError("unauthenticated", "Auth required.");
    if (request.auth.token.role !== "superAdmin") {
        throw new https_1.HttpsError("permission-denied", "SuperAdmin access required.");
    }
}
// ─────────────────────────────────────────────────────────────
// Helper: assert caller is tenantOwner of the given tenant
// ─────────────────────────────────────────────────────────────
function assertTenantOwner(request, tenantId) {
    if (!request.auth)
        throw new https_1.HttpsError("unauthenticated", "Auth required.");
    const role = request.auth.token.role;
    const callerTenantId = request.auth.token.tenantId;
    if (role !== "superAdmin" &&
        !((role === "tenantOwner" || role === "admin") &&
            callerTenantId === tenantId)) {
        throw new https_1.HttpsError("permission-denied", "Not authorized for this tenant.");
    }
}
// ─────────────────────────────────────────────────────────────
// setUserRole
// Called by superAdmin to assign role + tenantId Custom Claims.
// Also mirrors role/tenantId into the user's Firestore document.
// ─────────────────────────────────────────────────────────────
exports.setUserRole = (0, https_1.onCall)(async (request) => {
    assertSuperAdmin(request);
    const { uid, role, tenantId } = request.data;
    if (!uid || !role) {
        throw new https_1.HttpsError("invalid-argument", "uid and role are required.");
    }
    const validRoles = ["superAdmin", "tenantOwner", "staff", "customer"];
    if (!validRoles.includes(role)) {
        throw new https_1.HttpsError("invalid-argument", `Invalid role: ${role}`);
    }
    // Set Custom Claims on the Auth token
    await admin.auth().setCustomUserClaims(uid, {
        role,
        tenantId: tenantId !== null && tenantId !== void 0 ? tenantId : null,
    });
    // Mirror to Firestore
    await admin.firestore().collection("users").doc(uid).update({
        role,
        tenantId: tenantId !== null && tenantId !== void 0 ? tenantId : null,
        roleUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`setUserRole: uid=${uid} role=${role} tenantId=${tenantId}`);
    return { success: true };
});
// ─────────────────────────────────────────────────────────────
// setupTenant
// Called by superAdmin to provision a new tenant:
// - Creates the tenants/{tenantId} document
// - Seeds baseline subcollections (services, config)
// - Sets Custom Claims for the ownerUid
// ─────────────────────────────────────────────────────────────
exports.setupTenant = (0, https_1.onCall)(async (request) => {
    assertSuperAdmin(request);
    const { name, ownerUid, phone, city, state, primaryColor, logoUrl } = request.data;
    if (!name || !ownerUid) {
        throw new https_1.HttpsError("invalid-argument", "name and ownerUid are required.");
    }
    const db = admin.firestore();
    const tenantRef = db.collection("tenants").doc(); // auto-id
    const tenantId = tenantRef.id;
    const batch = db.batch();
    // 1. Create tenant document
    batch.set(tenantRef, {
        id: tenantId,
        name,
        ownerUid,
        status: "active",
        plan: "starter",
        logoUrl: logoUrl !== null && logoUrl !== void 0 ? logoUrl : null,
        primaryColor: primaryColor !== null && primaryColor !== void 0 ? primaryColor : "#1A73E8",
        stripeConnectOnboarded: false,
        platformFeePercent: 5,
        phone: phone !== null && phone !== void 0 ? phone : null,
        city: city !== null && city !== void 0 ? city : null,
        state: state !== null && state !== void 0 ? state : null,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        settings: {
            maxSlotsPerHour: 2,
            openingHours: {
                monday: { open: "08:00", close: "18:00" },
                tuesday: { open: "08:00", close: "18:00" },
                wednesday: { open: "08:00", close: "18:00" },
                thursday: { open: "08:00", close: "18:00" },
                friday: { open: "08:00", close: "18:00" },
                saturday: { open: "08:00", close: "13:00" },
                sunday: { open: null, close: null },
            },
        },
    });
    // 2. Seed default services subcollection
    const defaultServices = [
        { id: "lavagem-simples", name: "Lavagem Simples", price: 35.0, durationMinutes: 30, isActive: true, order: 1 },
        { id: "lavagem-completa", name: "Lavagem Completa", price: 55.0, durationMinutes: 45, isActive: true, order: 2 },
        { id: "lavagem-premium", name: "Lavagem Premium", price: 80.0, durationMinutes: 60, isActive: true, order: 3 },
    ];
    for (const svc of defaultServices) {
        const svcRef = tenantRef.collection("services").doc(svc.id);
        batch.set(svcRef, Object.assign(Object.assign({}, svc), { createdAt: admin.firestore.FieldValue.serverTimestamp() }));
    }
    await batch.commit();
    // 3. Set Custom Claims for the owner
    await admin.auth().setCustomUserClaims(ownerUid, {
        role: "tenantOwner",
        tenantId,
    });
    // 4. Update owner's Firestore user document
    await db.collection("users").doc(ownerUid).update({
        role: "tenantOwner",
        tenantId,
        roleUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`setupTenant: tenantId=${tenantId} name=${name} ownerUid=${ownerUid}`);
    return { success: true, tenantId, name };
});
// ─────────────────────────────────────────────────────────────
// createStripeConnectAccount
// Called by tenantOwner to initiate Stripe Express onboarding.
// ─────────────────────────────────────────────────────────────
exports.createStripeConnectAccount = (0, https_1.onCall)({ secrets: [stripeSecret] }, async (request) => {
    if (!request.auth)
        throw new https_1.HttpsError("unauthenticated", "Auth required.");
    const { tenantId, returnUrl, refreshUrl } = request.data;
    if (!tenantId)
        throw new https_1.HttpsError("invalid-argument", "tenantId required.");
    assertTenantOwner(request, tenantId);
    const db = admin.firestore();
    const tenantDoc = await db.collection("tenants").doc(tenantId).get();
    if (!tenantDoc.exists)
        throw new https_1.HttpsError("not-found", "Tenant not found.");
    const tenantData = tenantDoc.data();
    const stripe = getStripe();
    // Reuse existing account if already created
    let accountId = tenantData.stripeConnectAccountId;
    if (!accountId) {
        const account = await stripe.accounts.create({
            type: "express",
            country: "BR",
            capabilities: {
                card_payments: { requested: true },
                transfers: { requested: true },
            },
            metadata: { tenantId },
        });
        accountId = account.id;
        await db.collection("tenants").doc(tenantId).update({
            stripeConnectAccountId: accountId,
            stripeConnectOnboarded: false,
        });
    }
    const accountLink = await stripe.accountLinks.create({
        account: accountId,
        refresh_url: refreshUrl || "https://app.yourdomain.com/tenant/stripe/refresh",
        return_url: returnUrl || "https://app.yourdomain.com/tenant/stripe/complete",
        type: "account_onboarding",
    });
    return { url: accountLink.url, accountId };
});
// ─────────────────────────────────────────────────────────────
// checkStripeConnectStatus
// Called after onboarding redirect to confirm account is active.
// ─────────────────────────────────────────────────────────────
exports.checkStripeConnectStatus = (0, https_1.onCall)({ secrets: [stripeSecret] }, async (request) => {
    var _a;
    if (!request.auth)
        throw new https_1.HttpsError("unauthenticated", "Auth required.");
    const { tenantId } = request.data;
    if (!tenantId)
        throw new https_1.HttpsError("invalid-argument", "tenantId required.");
    assertTenantOwner(request, tenantId);
    const db = admin.firestore();
    const tenantDoc = await db.collection("tenants").doc(tenantId).get();
    if (!tenantDoc.exists)
        throw new https_1.HttpsError("not-found", "Tenant not found.");
    const { stripeConnectAccountId } = tenantDoc.data();
    if (!stripeConnectAccountId) {
        return { onboarded: false };
    }
    const stripe = getStripe();
    const account = await stripe.accounts.retrieve(stripeConnectAccountId);
    const onboarded = account.details_submitted &&
        ((_a = account.capabilities) === null || _a === void 0 ? void 0 : _a.card_payments) === "active";
    if (onboarded) {
        await db.collection("tenants").doc(tenantId).update({
            stripeConnectOnboarded: true,
        });
    }
    return { onboarded: onboarded !== null && onboarded !== void 0 ? onboarded : false, accountId: stripeConnectAccountId };
});
//# sourceMappingURL=tenant.js.map