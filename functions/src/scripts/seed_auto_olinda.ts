/**
 * seed_auto_olinda.ts
 *
 * One-time migration script: backfills tenantId = 'auto-olinda' onto all
 * existing Firestore documents and moves them into the
 * /tenants/auto-olinda/{collection} subcollection structure.
 *
 * Run ONCE from the functions directory with:
 *   npx ts-node --project tsconfig.json src/scripts/seed_auto_olinda.ts
 *
 * Prerequisites:
 *   - GOOGLE_APPLICATION_CREDENTIALS env var pointing to a service-account key
 *     with Firestore read/write and Auth admin permissions.
 *   - The tenant doc must already exist in /tenants/auto-olinda (created by
 *     setupTenant Cloud Function or manually in the console).
 *
 * The script is idempotent: it skips documents that already have tenantId set.
 */

import * as admin from 'firebase-admin';

const TENANT_ID = 'auto-olinda';

// Root collections that need to be migrated into /tenants/{TENANT_ID}/*
const COLLECTIONS_TO_MIGRATE = [
  'appointments',
  'services',
  'plans',
  'subscriptions',
  'vehicles',
  'availability',
  'wash_logs',
  'subscription_status_logs',
  'aggregated_metrics',
  'fcm_notification_logs',
  'admin_events',
  'leads_clients',
  'servicos_ativos',
  'settings',
  'admin_settings',
  'config',
  'independent_services',
  'service_availability',
  'service_bookings',
];

async function main() {
  if (!admin.apps.length) {
    admin.initializeApp();
  }
  const db = admin.firestore();
  const auth = admin.auth();

  // ── 1. Ensure tenant doc exists ─────────────────────────────────────────────
  const tenantRef = db.collection('tenants').doc(TENANT_ID);
  const tenantSnap = await tenantRef.get();
  if (!tenantSnap.exists) {
    console.error(
      `❌  Tenant document /tenants/${TENANT_ID} does not exist.\n` +
      `   Create it via the setupTenant Cloud Function first:\n` +
      `   firebase functions:shell → setupTenant({id:'${TENANT_ID}', ...})`
    );
    process.exit(1);
  }
  console.log(`✅  Tenant doc found: ${TENANT_ID}`);

  // ── 2. Backfill tenantId on all users ──────────────────────────────────────
  console.log('\n📋  Backfilling users...');
  let userCount = 0;
  let nextPageToken: string | undefined;

  do {
    const listResult = await auth.listUsers(1000, nextPageToken);
    nextPageToken = listResult.pageToken;

    const batch: Promise<void>[] = [];

    for (const user of listResult.users) {
      const claims = user.customClaims as Record<string, string> | undefined;
      const alreadyHasTenant = claims?.tenantId;

      if (!alreadyHasTenant) {
        // Set claims — preserve existing role if any
        const existingRole = claims?.role ?? 'customer';
        batch.push(
          auth.setCustomUserClaims(user.uid, {
            ...claims,
            tenantId: TENANT_ID,
            role: existingRole,
          })
        );
      }

      // Backfill Firestore user doc
      const userDocRef = db.collection('users').doc(user.uid);
      const userSnap = await userDocRef.get();
      if (userSnap.exists) {
        const data = userSnap.data()!;
        if (!data.tenantId) {
          await userDocRef.update({ tenantId: TENANT_ID });
          userCount++;
        }
      }
    }

    await Promise.all(batch);
  } while (nextPageToken);

  console.log(`   ✅  ${userCount} user docs backfilled with tenantId`);

  // ── 3. Migrate root collections → tenant subcollections ────────────────────
  for (const colName of COLLECTIONS_TO_MIGRATE) {
    console.log(`\n📦  Migrating /${colName}...`);
    const srcCol = db.collection(colName);
    const destCol = tenantRef.collection(colName);

    const snap = await srcCol.get();
    if (snap.empty) {
      console.log(`   (empty, skipping)`);
      continue;
    }

    let migrated = 0;
    let skipped = 0;

    // Process in batches of 400 (Firestore limit is 500 ops/batch)
    const chunks = chunkArray(snap.docs, 400);
    for (const chunk of chunks) {
      const writeBatch = db.batch();

      for (const doc of chunk) {
        const destRef = destCol.doc(doc.id);
        const destSnap = await destRef.get();

        if (destSnap.exists) {
          skipped++;
          continue; // idempotent — already migrated
        }

        writeBatch.set(destRef, {
          ...doc.data(),
          tenantId: TENANT_ID,
          _migratedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        migrated++;
      }

      await writeBatch.commit();
    }

    console.log(`   ✅  ${migrated} migrated, ${skipped} already present`);
  }

  // ── 4. Summary ──────────────────────────────────────────────────────────────
  console.log('\n' + '='.repeat(60));
  console.log('🎉  Seed complete!');
  console.log('');
  console.log('Next steps:');
  console.log('  1. Verify data in Firebase Console under /tenants/auto-olinda/');
  console.log('  2. Deploy the new firestore.rules (firebase deploy --only firestore:rules)');
  console.log('  3. Test the app — all queries should now hit the subcollection');
  console.log('  4. Once verified, delete the root collections (optional)');
  console.log('='.repeat(60));
}

function chunkArray<T>(arr: T[], size: number): T[][] {
  const result: T[][] = [];
  for (let i = 0; i < arr.length; i += size) {
    result.push(arr.slice(i, i + size));
  }
  return result;
}

main().catch((err) => {
  console.error('❌  Seed failed:', err);
  process.exit(1);
});
