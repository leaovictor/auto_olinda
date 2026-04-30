const admin = require('firebase-admin');

async function run() {
  try {
    admin.initializeApp({
      projectId: 'autoolinda-5199e'
    });
    console.log('Admin SDK initialized for project autoolinda-5199e');
    
    const db = admin.firestore();
    const tenantId = 'auto-olinda';
    const tenantRef = db.collection('tenants').doc(tenantId);
    
    const snap = await tenantRef.get();
    if (snap.exists) {
      console.log(`Tenant ${tenantId} already exists.`);
    } else {
      console.log(`Creating tenant ${tenantId}...`);
      await tenantRef.set({
        id: tenantId,
        name: 'Auto Olinda',
        status: 'active',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      console.log(`Tenant ${tenantId} created successfully.`);
    }
    
    process.exit(0);
  } catch (err) {
    console.error('Failed to initialize or create tenant:', err);
    process.exit(1);
  }
}

run();
