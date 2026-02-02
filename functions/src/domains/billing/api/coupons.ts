import * as admin from "firebase-admin";
import { onCall, HttpsError } from "firebase-functions/v2/https";

/**
 * Validate coupon before checkout.
 * Returns discount details if valid.
 */
export const validateCoupon = onCall(
  { cors: true },
  async (request) => {
    // Note: Can be called publicly (e.g. before login) or requires auth?
    // User usually initiates checkout logged in.
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

      // Check validity in time
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
