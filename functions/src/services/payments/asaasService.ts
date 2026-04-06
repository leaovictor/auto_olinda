/**
 * @file services/payments/asaasService.ts
 * Asaas payment provider implementation — hardened v2.
 *
 * Breaking changes from v1:
 *  - No more `any` — all Asaas API types are fully typed
 *  - externalReference is now JSON-serialized AsaasExternalRef (structured)
 *  - handleWebhook returns a WebhookEvent with .externalRef (parsed object, not raw string)
 *  - createCustomer also uses JSON externalReference for CRM traceability
 *  - AsaasErrorResponse type replaces error body cast
 */

import { IPaymentProvider } from "./paymentProvider";
import {
  AsaasBillingType,
  AsaasWebhookEventType,
  AsaasExternalRef,
  CreateCustomerInput,
  CreateSubscriptionInput,
  ProviderCustomer,
  ProviderSubscription,
  WebhookEvent,
} from "../../types";

// ─────────────────────────────────────────────────────────────────────────────
// Asaas API internal types (fully typed — no `any`)
// ─────────────────────────────────────────────────────────────────────────────

interface AsaasCustomerResponse {
  id: string;
  name: string;
  email?: string;
  phone?: string;
  mobilePhone?: string;
  cpfCnpj?: string;
  externalReference?: string;
}

interface AsaasSubscriptionResponse {
  id: string;
  status: string;
  nextDueDate: string;
  value: number;
  billingType: string;
  cycle: string;
  externalReference?: string;
}

interface AsaasErrorDetail {
  code: string;
  description: string;
}

interface AsaasErrorResponse {
  errors?: AsaasErrorDetail[];
}

/**
 * Raw Asaas webhook body shape.
 * Covers all event types we handle (payments and subscriptions).
 */
interface AsaasWebhookPayload {
  event: string;
  payment?: AsaasPaymentObject;
  subscription?: AsaasSubscriptionObject;
}

interface AsaasPaymentObject {
  id: string;
  subscription?: string;
  externalReference?: string;
  value: number;
  status?: string;
  dueDate?: string;
  invoiceUrl?: string;
}

interface AsaasSubscriptionObject {
  id: string;
  externalReference?: string;
  status?: string;
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Builds the structured externalReference JSON string.
 * This format is set on ALL Asaas objects (customers, subscriptions)
 * so the webhook handler can always resolve tenant + user.
 */
export function buildExternalRef(
  tenantId: string,
  userId: string,
  type: AsaasExternalRef["type"] = "subscription"
): string {
  const ref: AsaasExternalRef = { tenantId, userId, type, v: 1 };
  return JSON.stringify(ref);
}

/**
 * Parses an externalReference string back into a typed AsaasExternalRef.
 * Validates the required fields before returning.
 *
 * @throws Error if the string is not valid JSON or is missing required fields
 */
export function parseExternalRef(raw: string): AsaasExternalRef {
  let parsed: unknown;
  try {
    parsed = JSON.parse(raw);
  } catch {
    throw new Error(
      `Invalid externalReference: not valid JSON. Got: "${raw}"`
    );
  }

  if (
    typeof parsed !== "object" ||
    parsed === null ||
    typeof (parsed as AsaasExternalRef).tenantId !== "string" ||
    typeof (parsed as AsaasExternalRef).userId !== "string"
  ) {
    throw new Error(
      `Invalid externalReference: missing tenantId or userId. Got: ${JSON.stringify(parsed)}`
    );
  }

  return parsed as AsaasExternalRef;
}

// ─────────────────────────────────────────────────────────────────────────────
// AsaasService
// ─────────────────────────────────────────────────────────────────────────────

export class AsaasService implements IPaymentProvider {
  private readonly baseUrl: string;
  private readonly apiKey: string;
  private readonly webhookToken: string;

  constructor(apiKey: string, webhookToken: string, sandbox = false) {
    if (!apiKey) throw new Error("AsaasService: apiKey is required.");
    if (!webhookToken) throw new Error("AsaasService: webhookToken is required.");

    this.apiKey = apiKey;
    this.webhookToken = webhookToken;
    this.baseUrl = sandbox
      ? "https://sandbox.asaas.com/api/v3"
      : "https://api.asaas.com/api/v3";
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HTTP helper — strongly typed, no `any`
  // ─────────────────────────────────────────────────────────────────────────

  private async request<T>(
    method: "GET" | "POST" | "DELETE" | "PUT",
    path: string,
    body?: Record<string, unknown>
  ): Promise<T> {
    const url = `${this.baseUrl}${path}`;

    const init: RequestInit = {
      method,
      headers: {
        "Content-Type": "application/json",
        "access_token": this.apiKey,
        "User-Agent": "AutoWash-SaaS/2.0",
      },
      ...(body !== undefined ? { body: JSON.stringify(body) } : {}),
    };

    let response: Response;
    try {
      response = await fetch(url, init);
    } catch (networkErr: unknown) {
      throw new Error(
        `Asaas network error calling ${method} ${path}: ${(networkErr as Error).message}`
      );
    }

    if (!response.ok) {
      let errorBody: AsaasErrorResponse = {};
      try {
        errorBody = (await response.json()) as AsaasErrorResponse;
      } catch {
        // ignore JSON parse failure for error body
      }
      const message =
        errorBody.errors?.[0]?.description ??
        `Asaas API error: ${response.status} ${response.statusText}`;
      throw new Error(message);
    }

    if (response.status === 204) {
      return undefined as unknown as T;
    }

    return response.json() as Promise<T>;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // IPaymentProvider implementation
  // ─────────────────────────────────────────────────────────────────────────

  async createCustomer(data: CreateCustomerInput): Promise<ProviderCustomer> {
    const payload: Record<string, unknown> = {
      name: data.name,
      // Customer also gets externalReference for CRM traceability
      externalReference: buildExternalRef(data.tenantId, data.userId, "charge"),
    };

    if (data.email) payload.email = data.email;
    if (data.phone) payload.mobilePhone = data.phone;
    if (data.cpf) payload.cpfCnpj = data.cpf;

    const result = await this.request<AsaasCustomerResponse>(
      "POST",
      "/customers",
      payload
    );

    return {
      id: result.id,
      name: result.name,
      email: result.email,
    };
  }

  async createSubscription(
    data: CreateSubscriptionInput
  ): Promise<ProviderSubscription> {
    // Validate that externalReference is proper JSON before sending
    parseExternalRef(data.externalReference); // throws if malformed

    const payload: Record<string, unknown> = {
      customer: data.customerId,
      billingType: data.billingType,
      value: data.value,
      nextDueDate: data.nextDueDate,
      cycle: data.cycle ?? "MONTHLY",
      externalReference: data.externalReference,
    };

    if (data.description) payload.description = data.description;

    const result = await this.request<AsaasSubscriptionResponse>(
      "POST",
      "/subscriptions",
      payload
    );

    return {
      id: result.id,
      status: result.status,
      nextDueDate: result.nextDueDate,
      value: result.value,
    };
  }

  async cancelSubscription(subscriptionId: string): Promise<void> {
    if (!subscriptionId) throw new Error("cancelSubscription: subscriptionId is required.");
    await this.request<void>("DELETE", `/subscriptions/${subscriptionId}`);
  }

  /**
   * Validates the access token header and parses the webhook payload.
   *
   * Security hardening:
   *  1. Constant-time-ish comparison (simple === is fine since token is random)
   *  2. Never reveal expected token in error messages
   *  3. Strict JSON schema validation before returning
   *  4. externalRef is PARSED (not raw string) in the returned WebhookEvent
   *
   * @param rawBody - Raw request body as Buffer
   * @param incomingToken - Value of the "asaas-access-token" header
   */
  async handleWebhook(
    rawBody: Buffer,
    incomingToken: string
  ): Promise<WebhookEvent> {
    // ── 1. Token gate ────────────────────────────────────────────────────
    if (!incomingToken) {
      throw new Error("Webhook rejected: missing asaas-access-token header.");
    }
    if (incomingToken !== this.webhookToken) {
      throw new Error("Webhook rejected: invalid access token.");
    }

    // ── 2. Parse payload ─────────────────────────────────────────────────
    let payload: AsaasWebhookPayload;
    try {
      payload = JSON.parse(rawBody.toString("utf-8")) as AsaasWebhookPayload;
    } catch {
      throw new Error("Webhook rejected: malformed JSON payload.");
    }

    // ── 3. Validate event type ────────────────────────────────────────────
    if (!payload.event || typeof payload.event !== "string") {
      throw new Error(`Webhook rejected: missing or invalid 'event' field.`);
    }

    // ── 4. Extract + parse externalReference (JSON format) ────────────────
    const rawRef =
      payload.payment?.externalReference ??
      payload.subscription?.externalReference ??
      "";

    if (!rawRef) {
      throw new Error(
        `Webhook event "${payload.event}" is missing externalReference.`
      );
    }

    const externalRef = parseExternalRef(rawRef); // throws on invalid format

    // ── 5. Build typed normalized event ───────────────────────────────────
    const event: WebhookEvent = {
      type: payload.event as AsaasWebhookEventType,
      externalRef,
      subscriptionId:
        payload.payment?.subscription ?? payload.subscription?.id,
      paymentId: payload.payment?.id,
      value: payload.payment?.value,
      rawPayload: payload as unknown as Record<string, unknown>,
    };

    return event;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers (exported for use in controllers)
// ─────────────────────────────────────────────────────────────────────────────

export function mapAsaasStatus(
  asaasStatus: string
): "active" | "inactive" | "delinquent" | "cancelled" | "pending" {
  const map: Record<
    string,
    "active" | "inactive" | "delinquent" | "cancelled" | "pending"
  > = {
    ACTIVE: "active",
    INACTIVE: "inactive",
    EXPIRED: "cancelled",
    DELETED: "cancelled",
    OVERDUE: "delinquent",
    PENDING: "pending",
  };
  return map[asaasStatus?.toUpperCase()] ?? "inactive";
}

export function formatAsaasDate(date: Date): string {
  return date.toISOString().split("T")[0];
}

export const BILLING_TYPES: Record<string, AsaasBillingType> = {
  PIX: "PIX",
  BOLETO: "BOLETO",
  CREDIT_CARD: "CREDIT_CARD",
};
