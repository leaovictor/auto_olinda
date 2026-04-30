"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const fs = require("fs");
let content = fs.readFileSync('/home/ninguem/Documentos/Projects/auto_olinda/functions/src/booking.ts', 'utf-8');
// 1. Add tenantId extraction to createBooking
content = content.replace('const { vehicleId, serviceIds, scheduledTime, staffNotes } = request.data;', 'const { vehicleId, serviceIds, scheduledTime, staffNotes } = request.data;\n  const tenantId = request.auth.token.tenantId;\n  if (!tenantId) throw new HttpsError("permission-denied", "User has no tenant.");');
content = content.replace('const db = admin.firestore();', 'const db = admin.firestore();\n  const tenantDb = db.collection("tenants").doc(tenantId);');
// 2. Add tenantId extraction to cancelBooking
content = content.replace('const { bookingId } = request.data;\n  const userId = request.auth.uid;', 'const { bookingId } = request.data;\n  const userId = request.auth.uid;\n  const tenantId = request.auth.token.tenantId;\n  if (!tenantId) throw new HttpsError("permission-denied", "User has no tenant.");');
content = content.replace('const db = admin.firestore();\n  const bookingRef = db.collection("appointments").doc(bookingId);', 'const db = admin.firestore();\n  const tenantDb = db.collection("tenants").doc(tenantId);\n  const bookingRef = tenantDb.collection("appointments").doc(bookingId);');
// 3. Update collectionGroup in autoExpireUnconfirmedBookings
content = content.replace('const scheduledQuery = await db.collection("appointments")', 'const scheduledQuery = await db.collectionGroup("appointments")');
content = content.replace('const confirmedQuery = await db.collection("appointments")', 'const confirmedQuery = await db.collectionGroup("appointments")');
// 4. Replace remaining specific root collections to tenantDb (in createBooking)
content = content.replace(/db\.collection\("appointments"\)/g, 'tenantDb.collection("appointments")');
content = content.replace(/db\.collection\("subscriptions"\)/g, 'tenantDb.collection("subscriptions")');
content = content.replace(/db\.collection\("plans"\)/g, 'tenantDb.collection("plans")');
content = content.replace(/db\.collection\("services"\)/g, 'tenantDb.collection("services")');
content = content.replace(/db\.collection\("vehicles"\)/g, 'tenantDb.collection("vehicles")');
content = content.replace(/db\.collection\("prices"\)/g, 'tenantDb.collection("prices")');
content = content.replace(/db\.collection\("config"\)/g, 'tenantDb.collection("config")');
// Note: db.collectionGroup("appointments") might have been reverted back if the order is wrong.
// But we did the collectionGroup replacements FIRST? No, the global replacement comes AFTER collectionGroup replacements.
// Ah! tenantDb.collection("appointments") will NOT match db.collectionGroup("appointments").
// Let's fix that order. Wait, the global replaces /db\.collection\(/ which won't match db.collectionGroup\(. So it's safe.
fs.writeFileSync('/home/ninguem/Documentos/Projects/auto_olinda/functions/src/booking.ts', content);
console.log('booking.ts migrated successfully');
//# sourceMappingURL=migrate_booking_ts.js.map