"use strict";
/**
 * @file repositories/tenantRepository.ts
 * Low-level Firestore helpers for tenant-scoped data access.
 *
 * Hardening changes (v2):
 *  - REMOVED getTenantAsaasKey (API keys no longer in Firestore)
 *  - ADDED getTenantConfig — returns lightweight config (no secrets)
 *  - ADDED assertTenantActive — throws if tenant is suspended
 *  - ADDED checkFeature — throws if a feature flag is disabled
 *  - Updated createTenantDoc to include status, features, paymentProvider
 *  - Updated seedTenantDefaults to be fully compatible with new TenantDoc
 */
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.Paths = exports.DEFAULT_FEATURES = void 0;
exports.getTenantConfig = getTenantConfig;
exports.getTenant = getTenant;
exports.assertTenantActive = assertTenantActive;
exports.checkFeature = checkFeature;
exports.createTenantDoc = createTenantDoc;
exports.updateTenantStatus = updateTenantStatus;
exports.seedTenantDefaults = seedTenantDefaults;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const db = () => admin.firestore();
// ─────────────────────────────────────────────────────────────────────────────
// Default feature flags
// ─────────────────────────────────────────────────────────────────────────────
exports.DEFAULT_FEATURES = {
    subscriptions: true,
    pix: true,
    coupons: true,
    multiVehicle: false,
};
// ─────────────────────────────────────────────────────────────────────────────
// Path helpers (single source of truth)
// ─────────────────────────────────────────────────────────────────────────────
exports.Paths = {
    tenant: (tenantId) => db().collection("tenants").doc(tenantId),
    tenantCollection: (tenantId, collection) => db().collection("tenants").doc(tenantId).collection(collection),
    user: (tenantId, userId) => db().collection("tenants").doc(tenantId).collection("users").doc(userId),
    booking: (tenantId, bookingId) => db().collection("tenants").doc(tenantId).collection("bookings").doc(bookingId),
    subscription: (tenantId, subId) => db().collection("tenants").doc(tenantId).collection("subscriptions").doc(subId),
    service: (tenantId, serviceId) => db().collection("tenants").doc(tenantId).collection("services").doc(serviceId),
    plan: (tenantId, planId) => db().collection("tenants").doc(tenantId).collection("plans").doc(planId),
    config: (tenantId, configId) => db().collection("tenants").doc(tenantId).collection("config").doc(configId),
    vehicle: (tenantId, vehicleId) => db().collection("tenants").doc(tenantId).collection("vehicles").doc(vehicleId),
    notification: (tenantId, userId) => db()
        .collection("tenants")
        .doc(tenantId)
        .collection("users")
        .doc(userId)
        .collection("notifications"),
    log: (tenantId) => db().collection("tenants").doc(tenantId).collection("logs"),
};
/**
 * Fetches a tenant document and returns the lightweight TenantConfig.
 * Use this in controllers — getTenant() is for admin ops only.
 *
 * @throws HttpsError("not-found") if tenant doesn't exist
 */
async function getTenantConfig(tenantId) {
    const doc = await exports.Paths.tenant(tenantId).get();
    if (!doc.exists) {
        throw new https_1.HttpsError("not-found", `Tenant "${tenantId}" not found.`);
    }
    const data = doc.data();
    return {
        name: data.name,
        status: data.status ?? "active",
        asaasAccountId: data.asaasAccountId,
        asaasSandbox: data.asaasSandbox ?? false,
        defaultBillingType: data.defaultBillingType ?? "PIX",
        paymentProvider: data.paymentProvider ?? "asaas",
        features: data.features ?? exports.DEFAULT_FEATURES,
    };
}
/**
 * Full tenant document fetch (for admin operations, migrations, etc.)
 * @throws plain Error if tenant doesn't exist
 */
async function getTenant(tenantId) {
    const doc = await exports.Paths.tenant(tenantId).get();
    if (!doc.exists) {
        throw new Error(`Tenant "${tenantId}" not found.`);
    }
    return doc.data();
}
// ─────────────────────────────────────────────────────────────────────────────
// Tenant status enforcement
// ─────────────────────────────────────────────────────────────────────────────
/**
 * Asserts that a tenant is in "active" or "trial" status.
 * Throws HttpsError("permission-denied") if suspended.
 *
 * Call this at the START of every tenant-scoped callable function,
 * AFTER extractTenantContext() and BEFORE any business logic.
 *
 * @param config - Must be the result of getTenantConfig()
 * @param tenantId - Used in the error message
 */
function assertTenantActive(config, tenantId) {
    if (config.status === "suspended") {
        throw new https_1.HttpsError("permission-denied", `Tenant "${tenantId}" está suspenso. Entre em contato com o suporte da plataforma.`);
    }
}
/**
 * Checks that a specific feature is enabled for a tenant.
 * Throws HttpsError("failed-precondition") if disabled.
 *
 * @example
 *   checkFeature(config, "subscriptions", tenantId);
 */
function checkFeature(config, feature, tenantId) {
    const enabled = config.features?.[feature] ?? true; // default: enabled
    if (!enabled) {
        throw new https_1.HttpsError("failed-precondition", `Feature "${feature}" is not enabled for this tenant (${tenantId}).`);
    }
}
// ─────────────────────────────────────────────────────────────────────────────
// Tenant write operations
// ─────────────────────────────────────────────────────────────────────────────
/**
 * Creates the root tenant document.
 * NOTE: asaasApiKey is NOT written here — it lives in Secret Manager.
 */
async function createTenantDoc(tenantId, data) {
    await exports.Paths.tenant(tenantId).set({
        ...data,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}
/**
 * Updates the tenant status (active / suspended / trial).
 * Only callable by platform super-admin via Admin SDK.
 */
async function updateTenantStatus(tenantId, status) {
    await exports.Paths.tenant(tenantId).update({
        status,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}
// ─────────────────────────────────────────────────────────────────────────────
// Seeding
// ─────────────────────────────────────────────────────────────────────────────
async function seedTenantDefaults(tenantId) {
    const batch = db().batch();
    const ts = admin.firestore.FieldValue.serverTimestamp();
    const defaultServices = [
        { id: "lavagem-simples", name: "Lavagem Simples", description: "Lavagem externa completa", price: 35.0, duration: 30, isActive: true, order: 1 },
        { id: "lavagem-completa", name: "Lavagem Completa", description: "Lavagem externa + aspiração interna", price: 55.0, duration: 45, isActive: true, order: 2 },
        { id: "lavagem-premium", name: "Lavagem Premium", description: "Lavagem completa + cera + hidratação", price: 80.0, duration: 60, isActive: true, order: 3 },
    ];
    for (const svc of defaultServices) {
        batch.set(exports.Paths.service(tenantId, svc.id), { ...svc, tenantId, createdAt: ts });
    }
    const defaultPlans = [
        { id: "plano-basico", name: "Plano Básico", description: "4 lavagens simples por mês", price: 99.9, washesPerMonth: 4, serviceType: "lavagem-simples", isActive: true, order: 1 },
        { id: "plano-premium", name: "Plano Premium", description: "4 lavagens completas por mês", price: 179.9, washesPerMonth: 4, serviceType: "lavagem-completa", isActive: true, order: 2 },
        { id: "plano-vip", name: "Plano VIP", description: "Lavagens ilimitadas", price: 299.9, washesPerMonth: -1, serviceType: "lavagem-premium", isActive: true, order: 3 },
    ];
    for (const plan of defaultPlans) {
        batch.set(exports.Paths.plan(tenantId, plan.id), { ...plan, tenantId, createdAt: ts });
    }
    batch.set(exports.Paths.config(tenantId, "calendar"), {
        tenantId,
        weeklySchedule: [
            { dayOfWeek: 1, isOpen: true, startHour: 8, endHour: 17 },
            { dayOfWeek: 2, isOpen: true, startHour: 8, endHour: 17 },
            { dayOfWeek: 3, isOpen: true, startHour: 8, endHour: 17 },
            { dayOfWeek: 4, isOpen: true, startHour: 8, endHour: 17 },
            { dayOfWeek: 5, isOpen: true, startHour: 8, endHour: 17 },
            { dayOfWeek: 6, isOpen: true, startHour: 8, endHour: 13 },
            { dayOfWeek: 7, isOpen: false, startHour: 0, endHour: 0 },
        ],
        defaultSlotCapacity: 2,
        updatedAt: ts,
    });
    batch.set(exports.Paths.config(tenantId, "app_version"), {
        tenantId, web_version: "1.0.0", force_update: false, updatedAt: ts,
    });
    await batch.commit();
    console.log(`[TenantRepo] Seeded defaults for tenant ${tenantId}`);
}
//# sourceMappingURL=tenantRepository.js.map