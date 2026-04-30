import * as admin from 'firebase-admin';

async function check() {
  if (!admin.apps.length) {
    admin.initializeApp();
  }
  const db = admin.firestore();
  const tenantId = 'auto-olinda';
  const tenantRef = db.collection('tenants').doc(tenantId);
  const snap = await tenantRef.get();
  
  if (snap.exists) {
    console.log(`Tenant ${tenantId} exists.`);
  } else {
    console.log(`Tenant ${tenantId} NOT found. Creating it...`);
    await tenantRef.set({
      id: tenantId,
      name: 'Auto Olinda',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      status: 'active',
      branding: {
        primaryColor: '#0F172A',
        logoUrl: '',
      }
    });
    console.log(`Tenant ${tenantId} created.`);
  }
}

check().catch(console.error);
