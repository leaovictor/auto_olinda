/**
 * @file config/secrets.ts
 * Unified secret resolution for both production (Secret Manager) and
 * local emulator (process.env via .secret.local).
 *
 * Problem:
 *   `defineSecret("FOO").value()` throws `ReferenceError: Couldn't find secret FOO`
 *   when running inside the Firebase Emulator, because Secret Manager is not
 *   accessible locally.
 *
 * Solution:
 *   Firebase Emulators (CLI ≥ 12.0) read `functions/.secret.local` and inject
 *   each KEY=value as a process.env variable at emulator startup.
 *
 *   This module provides `getSecret(name)` which:
 *     1. In emulator → reads process.env[name] (populated from .secret.local)
 *     2. In production → calls secret.value() (Secret Manager)
 *
 * Usage:
 *   // In your function (after declaring with defineSecret):
 *   const ASAAS_API_KEY_POOL = defineSecret("ASAAS_API_KEY_POOL");
 *   ...
 *   const pool = getSecret(ASAAS_API_KEY_POOL, "ASAAS_API_KEY_POOL");
 *
 * NOTE:
 *   All secrets must still be declared with defineSecret() in every function
 *   that uses them — this is required for firebase deploy to bind the secret.
 *   getSecret() only changes HOW the value is read at runtime.
 */

// ─────────────────────────────────────────────────────────────────────────────
// Environment detection
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Returns true when the code is running inside the Firebase Emulator.
 *
 * Firebase sets FUNCTIONS_EMULATOR=true in the emulator environment.
 * We also check FIREBASE_EMULATOR_HUB as a fallback.
 */
export function isEmulator(): boolean {
  return (
    process.env.FUNCTIONS_EMULATOR === "true" ||
    !!process.env.FIREBASE_EMULATOR_HUB
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Secret accessor interface (minimal — avoids importing firebase-functions/params)
// ─────────────────────────────────────────────────────────────────────────────

interface SecretParam {
  value(): string;
}

// ─────────────────────────────────────────────────────────────────────────────
// Core resolver
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Resolves a secret value safely in both emulator and production.
 *
 * @param secret - The result of defineSecret("NAME") from firebase-functions/params
 * @param envKey - The process.env key name (same as the secret name, e.g. "ASAAS_WEBHOOK_TOKEN")
 * @returns The secret value string
 * @throws Error if neither the secret nor process.env provides a value
 */
export function getSecret(secret: SecretParam, envKey: string): string {
  if (isEmulator()) {
    const value = process.env[envKey];
    if (!value) {
      throw new Error(
        `[Emulator] Secret "${envKey}" is not set. ` +
          `Add it to functions/.secret.local:\n  ${envKey}=your_value_here`
      );
    }
    return value;
  }

  // Production: use Secret Manager via defineSecret
  try {
    return secret.value();
  } catch (err: unknown) {
    throw new Error(
      `[Production] Failed to resolve secret "${envKey}": ${(err as Error).message}`
    );
  }
}

/**
 * Tries to read a secret but returns a fallback if not found.
 * Useful for optional secrets (e.g., STRIPE_SECRET for Asaas-only tenants).
 */
export function getSecretOrDefault(
  secret: SecretParam,
  envKey: string,
  defaultValue: string
): string {
  try {
    return getSecret(secret, envKey);
  } catch {
    return defaultValue;
  }
}
