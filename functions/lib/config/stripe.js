"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.stripe = void 0;
const stripe_1 = require("stripe");
const env_1 = require("./env");
exports.stripe = new stripe_1.default(env_1.env.STRIPE_SECRET_KEY, {
    apiVersion: '2025-01-27.acacia', // Use latest or pinned version
    typescript: true,
});
//# sourceMappingURL=stripe.js.map