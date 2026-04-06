"use strict";
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
exports.tenantLogger = tenantLogger;
const admin = __importStar(require("firebase-admin"));
// ─────────────────────────────────────────────────────────────────────────────
// Core write (internal)
// ─────────────────────────────────────────────────────────────────────────────
function writeLog(entry) {
    // Always write to Cloud Logging first (synchronous)
    const prefix = `[${entry.fn}][${entry.tenantId}]`;
    const logLine = `${prefix} ${entry.message}${entry.data ? " " + JSON.stringify(entry.data) : ""}`;
    if (entry.level === "error") {
        console.error(logLine);
    }
    else if (entry.level === "warn") {
        console.warn(logLine);
    }
    else {
        console.log(logLine);
    }
    // Fire-and-forget Firestore write — failure is non-critical
    admin
        .firestore()
        .collection("tenants")
        .doc(entry.tenantId)
        .collection("logs")
        .add(entry)
        .catch((err) => {
        // Only console — never throw from logger
        console.error(`[Logger] Failed to write log to Firestore:`, err);
    });
}
/**
 * Creates a scoped logger for a tenant + function context.
 * Bind it once at the top of a function, then use throughout.
 *
 * @param tenantId - Tenant being operated on
 * @param fn - Name of the calling function (for attribution in logs)
 */
function tenantLogger(tenantId, fn) {
    const ts = () => admin.firestore.FieldValue.serverTimestamp();
    return {
        info(message, data, userId) {
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
        warn(message, data, userId) {
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
        error(message, data, userId) {
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
//# sourceMappingURL=logger.js.map