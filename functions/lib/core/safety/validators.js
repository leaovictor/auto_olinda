"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createPortalSessionSchema = exports.createCheckoutSessionSchema = exports.createTenantSchema = void 0;
const zod_1 = require("zod");
exports.createTenantSchema = zod_1.z.object({
    name: zod_1.z.string().min(3).max(100),
});
exports.createCheckoutSessionSchema = zod_1.z.object({
    priceId: zod_1.z.string().startsWith('price_'),
    successUrl: zod_1.z.string().url(),
    cancelUrl: zod_1.z.string().url(),
});
exports.createPortalSessionSchema = zod_1.z.object({
    returnUrl: zod_1.z.string().url(),
});
//# sourceMappingURL=validators.js.map