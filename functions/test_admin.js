const admin = require("firebase-admin");
console.log("admin.firestore type:", typeof admin.firestore);
console.log("admin.firestore.FieldValue:", admin.firestore.FieldValue);
try {
  const { FieldValue } = require("firebase-admin/firestore");
  console.log("FieldValue from firestore:", FieldValue);
} catch (e) {
  console.log("Error loading from firestore:", e.message);
}
