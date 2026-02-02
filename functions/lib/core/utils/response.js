"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorResponse = exports.successResponse = void 0;
const functions = require("firebase-functions");
const successResponse = (data) => {
    return { success: true, data };
};
exports.successResponse = successResponse;
const errorResponse = (code, message, details) => {
    throw new functions.https.HttpsError(code, message, details);
};
exports.errorResponse = errorResponse;
//# sourceMappingURL=response.js.map