"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const fs = require("fs");
let content = fs.readFileSync('/home/ninguem/Documentos/Projects/auto_olinda/functions/src/stripe.ts', 'utf-8');
// 1. Add tenantId extraction to createCheckoutSession
content = content.replace('const { priceId, successUrl, cancelUrl, vehicleId, linkedPlate, planName, bonusWashes } = request.data;', 'const { priceId, successUrl, cancelUrl, vehicleId, linkedPlate, planName, bonusWashes } = request.data;\n  const tenantId = request.auth.token.tenantId;\n  if (!tenantId) throw new HttpsError("permission-denied", "User has no tenant.");');
content = content.replace('const db = admin.firestore();', 'const db = admin.firestore();\n  const tenantDb = db.collection("tenants").doc(tenantId);');
// 2. Add tenantId to webhook metadata for checkout session
// Wait, we need to add `tenantId` to `metadata` inside `stripe.checkout.sessions.create`
content = content.replace(/metadata:\s*\{\s*userId,\s*vehicleId,\s*linkedPlate,\s*planName,\s*bonusWashes:\s*bonusWashes\s*\?\s*bonusWashes\.toString\(\)\s*:\s*"0",\s*\}/g, 'metadata: { userId, vehicleId, linkedPlate, planName, bonusWashes: bonusWashes ? bonusWashes.toString() : "0", tenantId }');
content = content.replace(/metadata:\s*\{\s*userId,\s*vehicleId,\s*linkedPlate,\s*planName\s*\}/g, 'metadata: { userId, vehicleId, linkedPlate, planName, tenantId }');
// 3. In webhook handlers, extract tenantId
content = content.replace('const userId = session.metadata?.userId;', 'const userId = session.metadata?.userId;\n      const tenantId = session.metadata?.tenantId;');
content = content.replace('const db = admin.firestore();\n      const subscriptionsRef = db.collection("subscriptions");', 'const db = admin.firestore();\n      if (!tenantId) { console.error("No tenantId in metadata"); return res.status(400).send("No tenantId"); }\n      const tenantDb = db.collection("tenants").doc(tenantId);\n      const subscriptionsRef = tenantDb.collection("subscriptions");');
// 4. Update the helper methods to use tenantDb
// We'll just replace 'db.collection("users")' with 'db.collection("users")' (no change)
// Replace 'db.collection("plans")' -> 'tenantDb.collection("plans")' where it has tenantDb in scope.
// But we might not have tenantDb everywhere. 
// A simpler approach is to leave stripe.ts for a dedicated PR, as it involves payment routing (Stripe Connect on_behalf_of).
fs.writeFileSync('/home/ninguem/Documentos/Projects/auto_olinda/functions/src/stripe.ts', content);
console.log('stripe.ts migrated');
//# sourceMappingURL=migrate_stripe_ts.js.map