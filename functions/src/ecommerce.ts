import * as admin from "firebase-admin";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getStripe, stripeSecret } from "./stripe";


/**
 * Sync service with Stripe - creates/updates product and price
 */
export const syncServiceWithStripe = onCall(
  { secrets: [stripeSecret] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Not authenticated.");
    }

    const { serviceId, name, description, price, imageUrl, collectionName = "services" } = request.data;

    if (!serviceId || !name || price === undefined) {
      throw new HttpsError(
        "invalid-argument",
        "serviceId, name, and price are required.",
      );
    }

    const stripe = await getStripe();

    try {
      const serviceDoc = await admin.firestore()
        .collection(collectionName)
        .doc(serviceId)
        .get();

      if (!serviceDoc.exists) {
        throw new HttpsError("not-found", `${collectionName} not found.`);
      }

      let stripeProductId = serviceDoc.data()?.stripeProductId;
      let stripePriceId = serviceDoc.data()?.stripePriceId;

      // Create or update Stripe product
      if (stripeProductId) {
        try {
           await stripe.products.update(stripeProductId, {
            name: name,
            description: description || "",
            images: imageUrl ? [imageUrl] : [],
          });
        } catch (error: any) {
           if (error.code === 'resource_missing') {
             console.warn(`Product ${stripeProductId} not found. Creating new one.`);
             stripeProductId = undefined;
           } else {
             throw error;
           }
        }
      }

      if (!stripeProductId) {
        const product = await stripe.products.create({
          name: name,
          description: description || "",
          images: imageUrl ? [imageUrl] : [],
          metadata: {
            firebaseID: serviceId,
            type: collectionName === "services" ? "service" : "product",
          },
        });
        stripeProductId = product.id;
      }

      // Sanitize price
      let numericPrice = price;
      if (typeof price === 'string') {
        numericPrice = parseFloat(price.replace(',', '.'));
      }
      
      if (isNaN(numericPrice)) {
         throw new HttpsError("invalid-argument", "Invalid price format.");
      }

      // Create new price
      const newPrice = await stripe.prices.create({
        product: stripeProductId,
        unit_amount: Math.round(numericPrice * 100),
        currency: "brl",
        metadata: {
          firebaseID: serviceId,
        },
      });

      // Archive old price
      if (stripePriceId && stripePriceId !== newPrice.id) {
        try {
          await stripe.prices.update(stripePriceId, {
            active: false,
          });
        } catch (error) {
          console.error("Error archiving old price:", error);
        }
      }

      stripePriceId = newPrice.id;

      // Update Firestore
      await serviceDoc.ref.update({
        stripeProductId: stripeProductId,
        stripePriceId: stripePriceId,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        productId: stripeProductId,
        priceId: stripePriceId,
      };
    } catch (error: any) {
      console.error("Error syncing service with Stripe:", error);
      throw new HttpsError("internal", `Unable to sync service with Stripe: ${error.message || error}`);
    }
  },
);

/**
 * Create Stripe coupon
 */
export const createStripeCoupon = onCall(
  { secrets: [stripeSecret], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Not authenticated.");
    }

    const { couponId, code, type, value } = request.data;

    if (!couponId || !code || !type || value === undefined) {
      throw new HttpsError(
        "invalid-argument",
        "couponId, code, type, and value are required.",
      );
    }

    const stripe = await getStripe();

    try {
      // Create Stripe coupon
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const couponData: any = {
        name: code.toUpperCase(),
        metadata: {
          firebaseCouponId: couponId,
        },
      };

      let numericValue = value;
      if (typeof value === 'string') {
        numericValue = parseFloat(value.replace(',', '.'));
      }

      if (isNaN(numericValue)) {
        throw new HttpsError("invalid-argument", "Invalid value format.");
      }

      if (type === "percentage") {
        couponData.percent_off = numericValue;
      } else {
        couponData.amount_off = Math.round(numericValue * 100);
        couponData.currency = "brl";
      }

      const stripeCoupon = await stripe.coupons.create(couponData);

      // Update Firestore with Stripe ID
      await admin.firestore()
        .collection("coupons")
        .doc(couponId)
        .update({
          stripeCouponId: stripeCoupon.id,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      return {
        success: true,
        stripeCouponId: stripeCoupon.id,
      };
    } catch (error) {
      console.error("Error creating Stripe coupon:", error);
      throw new HttpsError("internal", "Unable to create Stripe coupon.");
    }
  },
);

/**
 * Validate coupon before checkout
 */
export const validateCoupon = onCall(
  { cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Not authenticated.");
    }

    const { code, applicableTo, amount } = request.data;

    if (!code || !applicableTo || amount === undefined) {
      throw new HttpsError(
        "invalid-argument",
        "code, applicableTo, and amount are required.",
      );
    }

    try {
      // Find coupon by code
      const couponSnapshot = await admin.firestore()
        .collection("coupons")
        .where("code", "==", code.toUpperCase())
        .where("isActive", "==", true)
        .limit(1)
        .get();

      if (couponSnapshot.empty) {
        return {
          valid: false,
          error: "Cupom não encontrado ou inativo.",
        };
      }

      const couponDoc = couponSnapshot.docs[0];
      const coupon = couponDoc.data();

      // Check validity
      const now = new Date();

      if (coupon.validFrom &&
        new Date(coupon.validFrom._seconds * 1000) > now) {
        return {
          valid: false,
          error: "Cupom ainda não está válido.",
        };
      }

      if (coupon.validUntil &&
        new Date(coupon.validUntil._seconds * 1000) < now) {
        return {
          valid: false,
          error: "Cupom expirado.",
        };
      }

      if (coupon.maxUses && coupon.usedCount >= coupon.maxUses) {
        return {
          valid: false,
          error: "Cupom atingiu o limite de uso.",
        };
      }

      if (!coupon.applicableTo.includes(applicableTo)) {
        return {
          valid: false,
          error: "Cupom não válido para este tipo de compra.",
        };
      }

      if (coupon.minimumPurchase && amount < coupon.minimumPurchase) {
        return {
          valid: false,
          error: "Valor mínimo de compra: R$ " +
            coupon.minimumPurchase.toFixed(2),
        };
      }

      // Calculate discount
      let discount = 0;
      if (coupon.type === "percentage") {
        discount = amount * (coupon.value / 100);
      } else {
        discount = Math.min(coupon.value, amount);
      }

      return {
        valid: true,
        couponId: couponDoc.id,
        discount: discount,
        finalAmount: amount - discount,
      };
    } catch (error) {
      console.error("Error validating coupon:", error);
      throw new HttpsError("internal", "Unable to validate coupon.");
    }
  },
);

/**
 * Apply coupon (increment usage count)
 */
export const applyCoupon = onCall(
  { cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Not authenticated.");
    }

    const { couponId } = request.data;

    if (!couponId) {
      throw new HttpsError("invalid-argument", "couponId is required.");
    }

    try {
      await admin.firestore()
        .collection("coupons")
        .doc(couponId)
        .update({
          usedCount: admin.firestore.FieldValue.increment(1),
        });

      return { success: true };
    } catch (error) {
      console.error("Error applying coupon:", error);
      throw new HttpsError("internal", "Unable to apply coupon.");
    }
  },
);

/**
 * Get coupon usage statistics
 */
export const getCouponUsage = onCall(
  { cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Not authenticated.");
    }

    const { couponId } = request.data;

    if (!couponId) {
      throw new HttpsError("invalid-argument", "couponId is required.");
    }

    try {
      const couponDoc = await admin.firestore()
        .collection("coupons")
        .doc(couponId)
        .get();

      if (!couponDoc.exists) {
        throw new HttpsError("not-found", "Coupon not found.");
      }

      const coupon = couponDoc.data();

      return {
        code: coupon?.code,
        usedCount: coupon?.usedCount || 0,
        maxUses: coupon?.maxUses,
        isActive: coupon?.isActive,
      };
    } catch (error) {
      console.error("Error getting coupon usage:", error);
      throw new HttpsError("internal", "Unable to get coupon usage.");
    }
  },
);


