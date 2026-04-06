"use strict";
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
exports.migrateToMultiTenant = void 0;
const https_1 = require("firebase-functions/v2/https");
const params_1 = require("firebase-functions/params");
const admin = __importStar(require("firebase-admin"));
const tenantRepository_1 = require("../repositories/tenantRepository");
const secrets_1 = require("../config/secrets");
const SUPER_ADMIN_UID = (0, params_1.defineSecret)("SUPER_ADMIN_UID");
// Collections to migrate and their target names in the tenant subcollection
const MIGRATION_MAP = {
    users: "users",
    appointments: "bookings", // Renamed for clarity
    subscriptions: "subscriptions",
    vehicles: "vehicles",
    services: "services",
    plans: "plans",
};
exports.migrateToMultiTenant = (0, https_1.onCall)({ secrets: [SUPER_ADMIN_UID], timeoutSeconds: 540 }, async (request) => {
    // ── Super-admin gate ─────────────────────────────────────────────────
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Authentication required.");
    }
    const superAdminUid = (0, secrets_1.getSecret)(SUPER_ADMIN_UID, "SUPER_ADMIN_UID");
    if (superAdminUid && request.auth.uid !== superAdminUid) {
        throw new https_1.HttpsError("permission-denied", "Only the platform super-admin can run migrations.");
    }
    const { tenantId, dryRun = true, collections } = request.data;
    if (!tenantId) {
        throw new https_1.HttpsError("invalid-argument", "tenantId is required.");
    }
    // Verify tenant exists
    const tenantDoc = await admin.firestore().collection("tenants").doc(tenantId).get();
    if (!tenantDoc.exists) {
        throw new https_1.HttpsError("not-found", `Tenant "${tenantId}" not found. Run createTenant first.`);
    }
    const db = admin.firestore();
    const targetCollections = collections
        ? Object.fromEntries(Object.entries(MIGRATION_MAP).filter(([k]) => collections.includes(k)))
        : MIGRATION_MAP;
    const result = {
        tenantId,
        dryRun,
        collections: {},
        errors: [],
    };
    console.log(`[Migration] Starting migration to tenant "${tenantId}" (dryRun=${dryRun})`);
    // ── Migrate each collection ──────────────────────────────────────────
    for (const [sourceCollection, targetCollection] of Object.entries(targetCollections)) {
        const stats = { read: 0, written: 0, skipped: 0 };
        try {
            console.log(`[Migration] Reading /${sourceCollection} → /tenants/${tenantId}/${targetCollection}`);
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
                const targetRef = tenantRepository_1.Paths.tenantCollection(tenantId, targetCollection).doc(doc.id);
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
                }
                else {
                    stats.written++; // Count as "would write" in dry run
                }
            }
            // Commit remaining docs
            if (!dryRun && batchCount > 0) {
                await batch.commit();
                console.log(`[Migration] Committed final batch of ${batchCount} docs for ${sourceCollection}`);
            }
            console.log(`[Migration] /${sourceCollection}: read=${stats.read}, ` +
                `written=${stats.written}, skipped=${stats.skipped}`);
        }
        catch (err) {
            const errMsg = `Error migrating ${sourceCollection}: ${err.message}`;
            console.error(`[Migration] ${errMsg}`);
            result.errors.push(errMsg);
        }
        result.collections[sourceCollection] = stats;
    }
    console.log(`[Migration] ✅ Done. dryRun=${dryRun}`, result);
    return result;
});
//# sourceMappingURL=migrateToMultiTenant.js.map