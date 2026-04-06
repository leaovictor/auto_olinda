/**
 * @file types/index.ts
 * Central TypeScript type definitions for the multi-tenant SaaS platform.
 *
 * Hardening changes (v2):
 *  - REMOVED asaasApiKey from TenantDoc (security: moved to Secret Manager pool)
 *  - ADDED TenantStatus: "active" | "suspended" | "trial"
 *  - ADDED TenantFeatures: per-tenant feature flags
 *  - ADDED AsaasExternalRef: structured JSON type for webhook attribution
 *  - ADDED TenantLog: per-tenant audit log document
 *  - ADDED PaymentProviderType to TenantDoc
 *  - Eliminated remaining `any` usages in shared types
 *  - CreateSubscriptionInput.externalReference is now typed as string (JSON-serialized)
 */

import * as admin from "firebase-admin";

// ─────────────────────────────────────────────────────────────────────────────
// Primitive enums
// ─────────────────────────────────────────────────────────────────────────────

export type UserRole = "admin" | "staff" | "customer";

export type TenantStatus = "active" | "suspended" | "trial";

export type TenantPlan = "starter" | "professional" | "enterprise";

export type SubscriptionStatus =
  | "active"
  | "inactive"
  | "pending"
  | "pending_pix"
  | "delinquent"
  | "cancelled"
  | "trialing"
  | "incomplete";

export type BookingStatus =
  | "scheduled"
  | "confirmed"
  | "checkIn"
  | "washing"
  | "vacuuming"
  | "drying"
  | "polishing"
  | "finished"
  | "cancelled"
  | "noShow";

export type AsaasBillingType = "BOLETO" | "CREDIT_CARD" | "PIX" | "UNDEFINED";

export type AsaasWebhookEventType =
  | "PAYMENT_RECEIVED"
  | "PAYMENT_CONFIRMED"
  | "PAYMENT_OVERDUE"
  | "PAYMENT_REFUNDED"
  | "PAYMENT_DELETED"
  | "SUBSCRIPTION_CREATED"
  | "SUBSCRIPTION_UPDATED"
  | "SUBSCRIPTION_DELETED"
  | "SUBSCRIPTION_EXPIRED";

/** Keys for the per-tenant feature flag map. */
export type FeatureKey = "subscriptions" | "pix" | "coupons" | "multiVehicle";

/** Payment provider discriminator stored in tenant config. */
export type PaymentProviderType = "asaas" | "stripe";

// ─────────────────────────────────────────────────────────────────────────────
// Feature flags
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Per-tenant feature flags.
 * Controls which capabilities are available to this tenant's users.
 * Defaults are all true for backward compatibility — restrict via Firestore.
 */
export interface TenantFeatures {
  subscriptions: boolean;
  pix: boolean;
  coupons: boolean;
  multiVehicle: boolean;
}

// ─────────────────────────────────────────────────────────────────────────────
// Firestore Documents
// ─────────────────────────────────────────────────────────────────────────────

/**
 * /tenants/{tenantId}
 *
 * SECURITY NOTE:
 *   asaasApiKey is NOT stored here.
 *   API keys live in Firebase Secret Manager under ASAAS_API_KEY_POOL
 *   (a JSON map of tenantId → apiKey).
 *   Only asaasAccountId (non-secret identifier) is stored in Firestore.
 */
export interface TenantDoc {
  name: string;
  plan: TenantPlan;
  /** Non-secret identifier used to look up the API key in Secret Manager */
  asaasAccountId?: string;
  /** Whether to use the Asaas sandbox environment */
  asaasSandbox: boolean;
  /** Default billing type for new subscriptions */
  defaultBillingType: AsaasBillingType;
  /** Which payment provider this tenant uses */
  paymentProvider: PaymentProviderType;
  /** Firebase UID of the first admin user */
  ownerUid: string;
  /** Contact email for the tenant */
  email?: string;
  /** Contact phone */
  phone?: string;
  /** Tenant lifecycle status — suspended tenants are fully blocked */
  status: TenantStatus;
  /** Per-tenant feature flags */
  features: TenantFeatures;
  createdAt: admin.firestore.Timestamp | admin.firestore.FieldValue;
  updatedAt: admin.firestore.Timestamp | admin.firestore.FieldValue;
}

/**
 * /tenants/{tenantId}/users/{userId}
 */
export interface UserDoc {
  tenantId: string;
  displayName: string;
  email: string;
  phone?: string;
  role: UserRole;
  fcmToken?: string;
  asaasCustomerId?: string;
  stripeCustomerId?: string;
  noShowCount?: number;
  strikeUntil?: admin.firestore.Timestamp;
  lastStrikeReason?: string;
  status?: "active" | "suspended";
  createdAt: admin.firestore.Timestamp | admin.firestore.FieldValue;
  updatedAt?: admin.firestore.Timestamp | admin.firestore.FieldValue;
}

/**
 * /tenants/{tenantId}/customers/{customerId}
 */
export interface CustomerDoc {
  tenantId: string;
  name: string;
  email?: string;
  phone?: string;
  cpf?: string;
  asaasCustomerId?: string;
  userId?: string;
  createdAt: admin.firestore.Timestamp | admin.firestore.FieldValue;
  updatedAt?: admin.firestore.Timestamp | admin.firestore.FieldValue;
}

/**
 * /tenants/{tenantId}/subscriptions/{subscriptionId}
 *
 * Index signature allows direct use as Record<string, unknown> in
 * webhook event handler signatures without casting.
 */
export interface SubscriptionDoc {
  [key: string]: unknown;
  tenantId: string;
  userId: string;
  planId: string;
  status: SubscriptionStatus;
  asaasSubscriptionId?: string;
  asaasCustomerId?: string;
  linkedPlate?: string;
  vehicleId?: string;
  billingType?: AsaasBillingType;
  value?: number;
  nextDueDate?: admin.firestore.Timestamp;
  startDate?: admin.firestore.Timestamp | Date;
  endDate?: admin.firestore.Timestamp | Date;
  activatedAt?: admin.firestore.Timestamp | admin.firestore.FieldValue;
  cancelledAt?: admin.firestore.Timestamp | admin.firestore.FieldValue;
  isManual?: boolean;
  paymentMethod?: string;
  createdBy?: string;
  createdAt: admin.firestore.Timestamp | admin.firestore.FieldValue;
  updatedAt: admin.firestore.Timestamp | admin.firestore.FieldValue;
}

/**
 * /tenants/{tenantId}/bookings/{bookingId}
 */
export interface BookingDoc {
  tenantId: string;
  userId: string;
  vehicleId: string;
  serviceIds: string[];
  scheduledTime: admin.firestore.Timestamp;
  status: BookingStatus;
  totalPrice: number;
  paymentStatus: "subscription" | "pending" | "paid" | "free";
  staffNotes?: string;
  beforePhotos?: string[];
  afterPhotos?: string[];
  isRated?: boolean;
  penaltyApplied?: boolean;
  strikeApplied?: boolean;
  cancellationWarning?: string;
  cancelledAt?: admin.firestore.Timestamp | admin.firestore.FieldValue;
  cancelledBy?: string;
  finishedAt?: admin.firestore.Timestamp | admin.firestore.FieldValue;
  createdAt: admin.firestore.Timestamp | admin.firestore.FieldValue;
}

/**
 * /tenants/{tenantId}/services/{serviceId}
 */
export interface ServiceDoc {
  tenantId: string;
  name: string;
  description?: string;
  price: number;
  duration: number;
  isActive: boolean;
  order?: number;
  category?: string;
  createdAt: admin.firestore.Timestamp | admin.firestore.FieldValue;
}

/**
 * /tenants/{tenantId}/plans/{planId}
 */
export interface PlanDoc {
  tenantId: string;
  name: string;
  description?: string;
  price: number;
  washesPerMonth: number;
  serviceType?: string;
  isActive: boolean;
  order?: number;
  category?: string;
  defaultBillingType?: AsaasBillingType;
  createdAt: admin.firestore.Timestamp | admin.firestore.FieldValue;
}

/**
 * /tenants/{tenantId}/logs/{logId}
 * Per-tenant audit/event log document.
 */
export interface TenantLog {
  tenantId: string;
  level: "info" | "warn" | "error";
  fn: string;
  message: string;
  data?: Record<string, unknown>;
  userId?: string;
  timestamp: admin.firestore.FieldValue;
}

// ─────────────────────────────────────────────────────────────────────────────
// Structured externalReference
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Structured payload embedded in Asaas externalReference field.
 * Serialized as JSON string: JSON.stringify(AsaasExternalRef)
 *
 * Version field allows future schema migrations without breaking webhook parsing.
 */
export interface AsaasExternalRef {
  /** The tenant who owns this subscription */
  tenantId: string;
  /** The Firebase Auth UID of the subscribing user */
  userId: string;
  /** Type discriminator for future extensibility */
  type: "subscription" | "charge";
  /** Schema version — bump when structure changes */
  v: 1;
}

// ─────────────────────────────────────────────────────────────────────────────
// Middleware contexts
// ─────────────────────────────────────────────────────────────────────────────

export interface TenantContext {
  tenantId: string;
  userId: string;
  role: UserRole;
  email: string | undefined;
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment provider I/O
// ─────────────────────────────────────────────────────────────────────────────

export interface CreateCustomerInput {
  name: string;
  email?: string;
  phone?: string;
  cpf?: string;
  tenantId: string;
  userId: string;
}

export interface ProviderCustomer {
  id: string;
  name: string;
  email?: string;
}

export interface CreateSubscriptionInput {
  customerId: string;
  /**
   * JSON-serialized AsaasExternalRef.
   * Always build via: JSON.stringify({ tenantId, userId, type: "subscription", v: 1 })
   */
  externalReference: string;
  billingType: AsaasBillingType;
  value: number;
  nextDueDate: string;
  description?: string;
  cycle?: "MONTHLY" | "WEEKLY" | "YEARLY";
}

export interface ProviderSubscription {
  id: string;
  status: string;
  nextDueDate?: string;
  value: number;
}

export interface WebhookEvent {
  type: AsaasWebhookEventType;
  /**
   * Parsed externalReference — always an AsaasExternalRef object,
   * never the raw string, after webhook validation.
   */
  externalRef: AsaasExternalRef;
  subscriptionId?: string;
  paymentId?: string;
  value?: number;
  rawPayload: Record<string, unknown>;
}

// ─────────────────────────────────────────────────────────────────────────────
// Controller I/O
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Input to createTenant callable.
 * NOTE: asaasApiKey is accepted here but NEVER written to Firestore —
 *       it is stored in Secret Manager via the ASAAS_API_KEY_POOL pattern.
 *       The super-admin is responsible for updating the secret pool separately.
 */
export interface CreateTenantInput {
  name: string;
  ownerEmail: string;
  ownerDisplayName: string;
  ownerUid: string;
  /** Non-secret Asaas account identifier */
  asaasAccountId?: string;
  asaasSandbox?: boolean;
  plan?: TenantPlan;
  features?: Partial<TenantFeatures>;
}

export interface CreateBookingInput {
  vehicleId: string;
  serviceIds: string[];
  scheduledTime: string;
  staffNotes?: string;
}

export interface CreateSubscriptionCallableInput {
  planId: string;
  vehiclePlate?: string;
  vehicleId?: string;
  billingType?: AsaasBillingType;
}
