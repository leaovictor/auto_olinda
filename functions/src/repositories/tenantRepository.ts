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

import * as admin from "firebase-admin";
import {
  TenantDoc,
  TenantFeatures,
  TenantStatus,
  AsaasBillingType,
  PaymentProviderType,
  FeatureKey,
} from "../types";
import { HttpsError } from "firebase-functions/v2/https";

const db = () => admin.firestore();

// ─────────────────────────────────────────────────────────────────────────────
// Default feature flags
// ─────────────────────────────────────────────────────────────────────────────

export const DEFAULT_FEATURES: TenantFeatures = {
  subscriptions: true,
  pix: true,
  coupons: true,
  multiVehicle: false,
};

// ─────────────────────────────────────────────────────────────────────────────
// Path helpers (single source of truth)
// ─────────────────────────────────────────────────────────────────────────────

export const Paths = {
  tenant: (tenantId: string) =>
    db().collection("tenants").doc(tenantId),

  tenantCollection: (tenantId: string, collection: string) =>
    db().collection("tenants").doc(tenantId).collection(collection),

  user: (tenantId: string, userId: string) =>
    db().collection("tenants").doc(tenantId).collection("users").doc(userId),

  booking: (tenantId: string, bookingId: string) =>
    db().collection("tenants").doc(tenantId).collection("bookings").doc(bookingId),

  subscription: (tenantId: string, subId: string) =>
    db().collection("tenants").doc(tenantId).collection("subscriptions").doc(subId),

  service: (tenantId: string, serviceId: string) =>
    db().collection("tenants").doc(tenantId).collection("services").doc(serviceId),

  plan: (tenantId: string, planId: string) =>
    db().collection("tenants").doc(tenantId).collection("plans").doc(planId),

  config: (tenantId: string, configId: string) =>
    db().collection("tenants").doc(tenantId).collection("config").doc(configId),

  vehicle: (tenantId: string, vehicleId: string) =>
    db().collection("tenants").doc(tenantId).collection("vehicles").doc(vehicleId),

  notification: (tenantId: string, userId: string) =>
    db()
      .collection("tenants")
      .doc(tenantId)
      .collection("users")
      .doc(userId)
      .collection("notifications"),

  log: (tenantId: string) =>
    db().collection("tenants").doc(tenantId).collection("logs"),
} as const;

// ─────────────────────────────────────────────────────────────────────────────
// Lightweight tenant config (no secrets)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Minimal tenant config shape returned by getTenantConfig.
 * Does NOT include asaasApiKey (which is in Secret Manager).
 */
export interface TenantConfig {
  name: string;
  status: TenantStatus;
  asaasAccountId?: string;
  asaasSandbox: boolean;
  defaultBillingType: AsaasBillingType;
  paymentProvider: PaymentProviderType;
  features: TenantFeatures;
}

/**
 * Fetches a tenant document and returns the lightweight TenantConfig.
 * Use this in controllers — getTenant() is for admin ops only.
 *
 * @throws HttpsError("not-found") if tenant doesn't exist
 */
export async function getTenantConfig(tenantId: string): Promise<TenantConfig> {
  const doc = await Paths.tenant(tenantId).get();
  if (!doc.exists) {
    throw new HttpsError("not-found", `Tenant "${tenantId}" not found.`);
  }
  const data = doc.data() as TenantDoc;
  return {
    name: data.name,
    status: data.status ?? "active",
    asaasAccountId: data.asaasAccountId,
    asaasSandbox: data.asaasSandbox ?? false,
    defaultBillingType: data.defaultBillingType ?? "PIX",
    paymentProvider: data.paymentProvider ?? "asaas",
    features: data.features ?? DEFAULT_FEATURES,
  };
}

/**
 * Full tenant document fetch (for admin operations, migrations, etc.)
 * @throws plain Error if tenant doesn't exist
 */
export async function getTenant(tenantId: string): Promise<TenantDoc> {
  const doc = await Paths.tenant(tenantId).get();
  if (!doc.exists) {
    throw new Error(`Tenant "${tenantId}" not found.`);
  }
  return doc.data() as TenantDoc;
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
export function assertTenantActive(
  config: TenantConfig,
  tenantId: string
): void {
  if (config.status === "suspended") {
    throw new HttpsError(
      "permission-denied",
      `Tenant "${tenantId}" está suspenso. Entre em contato com o suporte da plataforma.`
    );
  }
}

/**
 * Checks that a specific feature is enabled for a tenant.
 * Throws HttpsError("failed-precondition") if disabled.
 *
 * @example
 *   checkFeature(config, "subscriptions", tenantId);
 */
export function checkFeature(
  config: TenantConfig,
  feature: FeatureKey,
  tenantId: string
): void {
  const enabled = config.features?.[feature] ?? true; // default: enabled
  if (!enabled) {
    throw new HttpsError(
      "failed-precondition",
      `Feature "${feature}" is not enabled for this tenant (${tenantId}).`
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tenant write operations
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Creates the root tenant document.
 * NOTE: asaasApiKey is NOT written here — it lives in Secret Manager.
 */
export async function createTenantDoc(
  tenantId: string,
  data: Omit<TenantDoc, "createdAt" | "updatedAt">
): Promise<void> {
  await Paths.tenant(tenantId).set({
    ...data,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Updates the tenant status (active / suspended / trial).
 * Only callable by platform super-admin via Admin SDK.
 */
export async function updateTenantStatus(
  tenantId: string,
  status: TenantStatus
): Promise<void> {
  await Paths.tenant(tenantId).update({
    status,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Seeding
// ─────────────────────────────────────────────────────────────────────────────

export async function seedTenantDefaults(tenantId: string): Promise<void> {
  const batch = db().batch();
  const ts = admin.firestore.FieldValue.serverTimestamp();

  const defaultServices = [
    { id: "lavagem-simples", name: "Lavagem Simples", description: "Lavagem externa completa", price: 35.0, duration: 30, isActive: true, order: 1 },
    { id: "lavagem-completa", name: "Lavagem Completa", description: "Lavagem externa + aspiração interna", price: 55.0, duration: 45, isActive: true, order: 2 },
    { id: "lavagem-premium", name: "Lavagem Premium", description: "Lavagem completa + cera + hidratação", price: 80.0, duration: 60, isActive: true, order: 3 },
  ];

  for (const svc of defaultServices) {
    batch.set(Paths.service(tenantId, svc.id), { ...svc, tenantId, createdAt: ts });
  }

  const defaultPlans = [
    { id: "plano-basico", name: "Plano Básico", description: "4 lavagens simples por mês", price: 99.9, washesPerMonth: 4, serviceType: "lavagem-simples", isActive: true, order: 1 },
    { id: "plano-premium", name: "Plano Premium", description: "4 lavagens completas por mês", price: 179.9, washesPerMonth: 4, serviceType: "lavagem-completa", isActive: true, order: 2 },
    { id: "plano-vip", name: "Plano VIP", description: "Lavagens ilimitadas", price: 299.9, washesPerMonth: -1, serviceType: "lavagem-premium", isActive: true, order: 3 },
  ];

  for (const plan of defaultPlans) {
    batch.set(Paths.plan(tenantId, plan.id), { ...plan, tenantId, createdAt: ts });
  }

  batch.set(Paths.config(tenantId, "calendar"), {
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

  batch.set(Paths.config(tenantId, "app_version"), {
    tenantId, web_version: "1.0.0", force_update: false, updatedAt: ts,
  });

  await batch.commit();
  console.log(`[TenantRepo] Seeded defaults for tenant ${tenantId}`);
}
