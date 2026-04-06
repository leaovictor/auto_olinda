"use strict";
/**
 * @file services/payments/paymentProvider.ts
 * Abstract interface for payment providers.
 * This allows swapping Asaas ↔ Stripe without changing controller logic.
 *
 * Architecture Decision:
 * - Controllers depend only on IPaymentProvider
 * - Concrete implementations (AsaasService, StripeService) are injected
 * - Tenant-level configuration determines which provider is used
 */
Object.defineProperty(exports, "__esModule", { value: true });
//# sourceMappingURL=paymentProvider.js.map