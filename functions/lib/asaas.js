"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createAsaasSubscription = exports.createAsaasPixPayment = exports.createAsaasCustomer = exports.asaasApiKey = void 0;
const https_1 = require("firebase-functions/v2/https");
const params_1 = require("firebase-functions/params");
const admin = require("firebase-admin");
exports.asaasApiKey = (0, params_1.defineSecret)("ASAAS_API_KEY");
const getAsaasUrl = () => {
    // We could use an env var for this, but default to production for now
    // if you want sandbox, change to https://sandbox.asaas.com/api/v3
    return "https://www.asaas.com/api/v3";
};
/**
 * Utility to call Asaas API
 */
const callAsaas = async (path, method, body) => {
    var _a, _b;
    const apiKey = exports.asaasApiKey.value();
    const url = `${getAsaasUrl()}${path}`;
    const response = await fetch(url, {
        method,
        headers: {
            "Content-Type": "application/json",
            "access_token": apiKey,
        },
        body: body ? JSON.stringify(body) : undefined,
    });
    const data = await response.json();
    if (!response.ok) {
        console.error("Asaas API Error:", data);
        throw new Error(((_b = (_a = data.errors) === null || _a === void 0 ? void 0 : _a[0]) === null || _b === void 0 ? void 0 : _b.description) || "Asaas API request failed");
    }
    return data;
};
/**
 * Creates or retrieves an Asaas Customer
 */
exports.createAsaasCustomer = (0, https_1.onCall)({ secrets: [exports.asaasApiKey], cors: true }, async (request) => {
    var _a;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "User must be authenticated.");
    }
    const userId = request.auth.uid;
    const { name, cpfCnpj, email, phone } = request.data;
    if (!name || !cpfCnpj || !email) {
        throw new https_1.HttpsError("invalid-argument", "Name, CPF/CNPJ and Email are required.");
    }
    try {
        const userDoc = await admin.firestore().collection("users").doc(userId).get();
        let asaasCustomerId = (_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a.asaasCustomerId;
        if (asaasCustomerId) {
            return { customerId: asaasCustomerId };
        }
        // Create in Asaas
        const customer = await callAsaas("/customers", "POST", {
            name,
            cpfCnpj,
            email,
            mobilePhone: phone,
            externalReference: userId,
        });
        asaasCustomerId = customer.id;
        // Save to Firestore
        await userDoc.ref.update({ asaasCustomerId });
        return { customerId: asaasCustomerId };
    }
    catch (error) {
        throw new https_1.HttpsError("internal", error.message);
    }
});
/**
 * Creates a Pix Charge (Immediate)
 */
exports.createAsaasPixPayment = (0, https_1.onCall)({ secrets: [exports.asaasApiKey], cors: true }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "User must be authenticated.");
    }
    const { customerId, value, description, externalReference } = request.data;
    try {
        const payment = await callAsaas("/payments", "POST", {
            customer: customerId,
            billingType: "PIX",
            value,
            dueDate: new Date().toISOString().split('T')[0],
            description,
            externalReference,
        });
        // Get Pix QR Code
        const pixData = await callAsaas(`/payments/${payment.id}/pixQrCode`, "GET");
        return {
            paymentId: payment.id,
            invoiceUrl: payment.invoiceUrl,
            pixCode: pixData.payload,
            pixImage: pixData.encodedImage,
        };
    }
    catch (error) {
        throw new https_1.HttpsError("internal", error.message);
    }
});
/**
 * Creates a Recurring Subscription (Credit Card)
 */
exports.createAsaasSubscription = (0, https_1.onCall)({ secrets: [exports.asaasApiKey], cors: true }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "User must be authenticated.");
    }
    const { customerId, value, cycle, nextDueDate, creditCard, creditCardHolderInfo } = request.data;
    try {
        const subscription = await callAsaas("/subscriptions", "POST", {
            customer: customerId,
            billingType: "CREDIT_CARD",
            value,
            nextDueDate,
            cycle: cycle || "MONTHLY",
            description: "Assinatura Auto Olinda",
            creditCard,
            creditCardHolderInfo,
        });
        return {
            subscriptionId: subscription.id,
            status: subscription.status,
        };
    }
    catch (error) {
        throw new https_1.HttpsError("internal", error.message);
    }
});
//# sourceMappingURL=asaas.js.map