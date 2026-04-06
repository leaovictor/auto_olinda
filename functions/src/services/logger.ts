/**
 * @file services/logger.ts
 * Per-tenant structured logging helper.
 *
 * Writes lightweight audit/event records to:
 *   tenants/{tenantId}/logs/{autoId}
 *
 * Design:
 *  - Fire-and-forget — NEVER throws or awaits in hot paths
 *  - Always console.* as backup so Cloud Logging captures everything
 *  - Accepts optional userId for user-attributed events
 *  - Level: "info" | "warn" | "error"
 *
 * Usage:
 *   const log = tenantLogger("abc123", "createBookingV2");
 *   log.info("Booking created", { bookingId, userId });
 *   log.error("Payment failed", { error: err.message });
 */

import * as admin from "firebase-admin";
import { TenantLog } from "../types";

// ─────────────────────────────────────────────────────────────────────────────
// Core write (internal)
// ─────────────────────────────────────────────────────────────────────────────

function writeLog(entry: TenantLog): void {
  // Always write to Cloud Logging first (synchronous)
  const prefix = `[${entry.fn}][${entry.tenantId}]`;
  const logLine = `${prefix} ${entry.message}${entry.data ? " " + JSON.stringify(entry.data) : ""}`;

  if (entry.level === "error") {
    console.error(logLine);
  } else if (entry.level === "warn") {
    console.warn(logLine);
  } else {
    console.log(logLine);
  }

  // Fire-and-forget Firestore write — failure is non-critical
  admin
    .firestore()
    .collection("tenants")
    .doc(entry.tenantId)
    .collection("logs")
    .add(entry)
    .catch((err: unknown) => {
      // Only console — never throw from logger
      console.error(`[Logger] Failed to write log to Firestore:`, err);
    });
}

// ─────────────────────────────────────────────────────────────────────────────
// Public API
// ─────────────────────────────────────────────────────────────────────────────

export interface TenantLoggerInstance {
  info(message: string, data?: Record<string, unknown>, userId?: string): void;
  warn(message: string, data?: Record<string, unknown>, userId?: string): void;
  error(message: string, data?: Record<string, unknown>, userId?: string): void;
}

/**
 * Creates a scoped logger for a tenant + function context.
 * Bind it once at the top of a function, then use throughout.
 *
 * @param tenantId - Tenant being operated on
 * @param fn - Name of the calling function (for attribution in logs)
 */
export function tenantLogger(
  tenantId: string,
  fn: string
): TenantLoggerInstance {
  const ts = () => admin.firestore.FieldValue.serverTimestamp();

  return {
    info(
      message: string,
      data?: Record<string, unknown>,
      userId?: string
    ): void {
      writeLog({
        tenantId,
        fn,
        level: "info",
        message,
        data,
        userId,
        timestamp: ts(),
      });
    },

    warn(
      message: string,
      data?: Record<string, unknown>,
      userId?: string
    ): void {
      writeLog({
        tenantId,
        fn,
        level: "warn",
        message,
        data,
        userId,
        timestamp: ts(),
      });
    },

    error(
      message: string,
      data?: Record<string, unknown>,
      userId?: string
    ): void {
      writeLog({
        tenantId,
        fn,
        level: "error",
        message,
        data,
        userId,
        timestamp: ts(),
      });
    },
  };
}
