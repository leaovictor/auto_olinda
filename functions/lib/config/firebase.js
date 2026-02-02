"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.FieldValue = exports.auth = exports.db = void 0;
const admin = require("firebase-admin");
if (!admin.apps.length) {
    admin.initializeApp();
}
exports.db = admin.firestore();
exports.auth = admin.auth();
exports.FieldValue = admin.firestore.FieldValue;
//# sourceMappingURL=firebase.js.map