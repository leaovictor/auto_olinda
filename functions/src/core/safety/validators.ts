
import { z } from 'zod';

export const createTenantSchema = z.object({
  name: z.string().min(3).max(100),
});

export const createCheckoutSessionSchema = z.object({
  priceId: z.string().startsWith('price_'),
  successUrl: z.string().url(),
  cancelUrl: z.string().url(),
});

export const createPortalSessionSchema = z.object({
  returnUrl: z.string().url(),
});
