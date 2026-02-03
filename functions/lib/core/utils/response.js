"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorResponse = exports.successResponse = void 0;
const https_1 = require("firebase-functions/v2/https");
const successResponse = (data) => {
    return { success: true, data };
};
exports.successResponse = successResponse;
const errorResponse = (code, message, details) => {
    throw new https_1.HttpsError(code, message, details);
};
exports.errorResponse = errorResponse;
//# sourceMappingURL=response.js.map