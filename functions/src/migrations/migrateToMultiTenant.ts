/**
 * @file migrations/migrateToMultiTenant.ts
 *
 * One-time migration script to copy existing flat-collection data into the
 * multi-tenant Firestore structure under tenants/{tenantId}/...
 *
 * SAFETY:
 *  - Only callable by the platform super-admin (SUPER_ADMIN_UID secret)
 *  - Defaults to dryRun: true — set dryRun: false to actually write data
 *  - Original data is NEVER deleted by this script (read-only source)
 *  - Each copied document gets tenantId field added
 *
 * Usage (from Firebase Functions shell or admin panel):
 *   migrateToMultiTenant({ tenantId: "abc123", dryRun: false })
 *
 * Collections migrated:
 *   /users                → /tenants/{tenantId}/users
 *   /appointments         → /tenants/{tenantId}/bookings
 *   /subscriptions        → /tenants/{tenantId}/subscriptions
 *   /vehicles             → /tenants/{tenantId}/vehicles
 *   /services             → /tenants/{tenantId}/services
 *   /plans                → /tenants/{tenantId}/plans
 */

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import * as admin from "firebase-admin";
import { Paths } from "../repositories/tenantRepository";
import { getSecret } from "../config/secrets";

const SUPER_ADMIN_UID = defineSecret("SUPER_ADMIN_UID");

// Collections to migrate and their target names in the tenant subcollection
const MIGRATION_MAP: Record<string, string> = {
  users: "users",
  appointments: "bookings",   // Renamed for clarity
  subscriptions: "subscriptions",
  vehicles: "vehicles",
  services: "services",
  plans: "plans",
};

interface MigrateInput {
  tenantId: string;
  dryRun?: boolean;
  collections?: string[]; // If provided, only migrate these. Else migrate all.
}

interface MigrateResult {
  tenantId: string;
  dryRun: boolean;
  collections: Record<string, { read: number; written: number; skipped: number }>;
  errors: string[];
}

export const migrateToMultiTenant = onCall(
  { secrets: [SUPER_ADMIN_UID], timeoutSeconds: 540 },
  async (request): Promise<MigrateResult> => {
    // ── Super-admin gate ─────────────────────────────────────────────────
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication required.");
    }

    const superAdminUid = getSecret(SUPER_ADMIN_UID, "SUPER_ADMIN_UID");
    if (superAdminUid && request.auth.uid !== superAdminUid) {
      throw new HttpsError(
        "permission-denied",
        "Only the platform super-admin can run migrations."
      );
    }

    const { tenantId, dryRun = true, collections } =
      request.data as MigrateInput;

    if (!tenantId) {
      throw new HttpsError("invalid-argument", "tenantId is required.");
    }

    // Verify tenant exists
    const tenantDoc = await admin.firestore().collection("tenants").doc(tenantId).get();
    if (!tenantDoc.exists) {
      throw new HttpsError(
        "not-found",
        `Tenant "${tenantId}" not found. Run createTenant first.`
      );
    }

    const db = admin.firestore();
    const targetCollections = collections
      ? Object.fromEntries(
          Object.entries(MIGRATION_MAP).filter(([k]) => collections.includes(k))
        )
      : MIGRATION_MAP;

    const result: MigrateResult = {
      tenantId,
      dryRun,
      collections: {},
      errors: [],
    };

    console.log(
      `[Migration] Starting migration to tenant "${tenantId}" (dryRun=${dryRun})`
    );

    // ── Migrate each collection ──────────────────────────────────────────
    for (const [sourceCollection, targetCollection] of Object.entries(
      targetCollections
    )) {
      const stats = { read: 0, written: 0, skipped: 0 };

      try {
        console.log(
          `[Migration] Reading /${sourceCollection} → /tenants/${tenantId}/${targetCollection}`
        );

        const snap = await db.collection(sourceCollection).get();
        stats.read = snap.size;

        if (snap.empty) {
          console.log(`[Migration] /${sourceCollection} is empty. Skipping.`);
          result.collections[sourceCollection] = stats;
          continue;
        }

        // Write in batches of 400 (Firestore limit is 500 per batch)
        const BATCH_SIZE = 400;
        let batch = db.batch();
        let batchCount = 0;

        for (const doc of snap.docs) {
          const sourceData = doc.data();

          // Check if already migrated (prevent duplicates on re-run)
          const targetRef = Paths.tenantCollection(
            tenantId,
            targetCollection
          ).doc(doc.id);

          const exists = await targetRef.get();
          if (exists.exists) {
            stats.skipped++;
            continue;
          }

          // Enrich document with tenantId
          const targetData = {
            ...sourceData,
            tenantId,
            migratedAt: admin.firestore.FieldValue.serverTimestamp(),
            migratedFrom: `/${sourceCollection}/${doc.id}`,
          };

          if (!dryRun) {
            batch.set(targetRef, targetData);
            batchCount++;
            stats.written++;

            // Commit batch when full
            if (batchCount >= BATCH_SIZE) {
              await batch.commit();
              console.log(`[Migration] Committed batch of ${batchCount} docs for ${sourceCollection}`);
              batch = db.batch();
              batchCount = 0;
            }
          } else {
            stats.written++; // Count as "would write" in dry run
          }
        }

        // Commit remaining docs
        if (!dryRun && batchCount > 0) {
          await batch.commit();
          console.log(`[Migration] Committed final batch of ${batchCount} docs for ${sourceCollection}`);
        }

        console.log(
          `[Migration] /${sourceCollection}: read=${stats.read}, ` +
            `written=${stats.written}, skipped=${stats.skipped}`
        );
      } catch (err) {
        const errMsg = `Error migrating ${sourceCollection}: ${(err as Error).message}`;
        console.error(`[Migration] ${errMsg}`);
        result.errors.push(errMsg);
      }

      result.collections[sourceCollection] = stats;
    }

    console.log(`[Migration] ✅ Done. dryRun=${dryRun}`, result);

    return result;
  }
);
