"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.stripePublishableKey = exports.stripeWebhookSecret = exports.stripeSecret = void 0;
const params_1 = require("firebase-functions/params");
exports.stripeSecret = (0, params_1.defineSecret)("STRIPE_SECRET");
exports.stripeWebhookSecret = (0, params_1.defineSecret)("STRIPE_WEBHOOK_SECRET");
exports.stripePublishableKey = (0, params_1.defineSecret)("STRIPE_PUBLISHABLE_KEY");
//# sourceMappingURL=env.js.map