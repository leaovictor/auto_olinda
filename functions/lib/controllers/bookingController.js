"use strict";
/**
 * @file controllers/bookingController.ts
 * Multi-tenant booking functions — hardened v2.
 *
 * Hardening changes:
 *  1. Tenant status check (assertTenantActive) at function entry
 *  2. Explicit tenantId mismatch guard: auth claim tenantId vs. Firestore
 *     (enforced implicitly via extractTenantContext — cannot be spoofed)
 *  3. User suspended check (guard against users bypassing Firestore rules)
 *  4. Per-tenant audit logging via tenantLogger
 *  5. Collection name standardized: only "bookings" (not "appointments")
 *  6. Removed all `any` casts — typed Firestore document reads
 *  7. Added TenantContext validation: every operation validates that
 *     the booking's tenantId matches the caller's tenantId claim
 */
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.cancelBookingV2 = exports.createBookingV2 = void 0;
const https_1 = require("firebase-functions/v2/https");
const admin = __importStar(require("firebase-admin"));
const tenantAuth_1 = require("../middleware/tenantAuth");
const tenantRepository_1 = require("../repositories/tenantRepository");
const logger_1 = require("../services/logger");
// ─────────────────────────────────────────────────────────────────────────────
// createBookingV2
// ─────────────────────────────────────────────────────────────────────────────
exports.createBookingV2 = (0, https_1.onCall)(async (request) => {
    const ctx = (0, tenantAuth_1.extractTenantContext)(request);
    const log = (0, logger_1.tenantLogger)(ctx.tenantId, "createBookingV2");
    const { vehicleId, serviceIds, scheduledTime, staffNotes } = request.data;
    // ── Input validation ──────────────────────────────────────────────────
    if (!vehicleId?.trim() ||
        !Array.isArray(serviceIds) ||
        serviceIds.length === 0 ||
        !scheduledTime) {
        throw new https_1.HttpsError("invalid-argument", "Campos obrigatórios ausentes: vehicleId, serviceIds, scheduledTime.");
    }
    const bookingDate = new Date(scheduledTime);
    const now = new Date();
    if (isNaN(bookingDate.getTime())) {
        throw new https_1.HttpsError("invalid-argument", "Formato de data inválido.");
    }
    // ── Tenant status check ───────────────────────────────────────────────
    const tenantConfig = await (0, tenantRepository_1.getTenantConfig)(ctx.tenantId);
    (0, tenantRepository_1.assertTenantActive)(tenantConfig, ctx.tenantId);
    // ── Lead time check ───────────────────────────────────────────────────
    const MIN_LEAD_HOURS = 2;
    const diffHours = (bookingDate.getTime() - now.getTime()) / (1000 * 60 * 60);
    if (diffHours < MIN_LEAD_HOURS) {
        throw new https_1.HttpsError("failed-precondition", `Agendamentos devem ser feitos com no mínimo ${MIN_LEAD_HOURS} horas de antecedência.`);
    }
    try {
        // ── User validation ───────────────────────────────────────────────────
        const userDoc = await tenantRepository_1.Paths.user(ctx.tenantId, ctx.userId).get();
        // Guard: user must exist in this tenant's subcollection
        if (!userDoc.exists) {
            throw new https_1.HttpsError("permission-denied", "Perfil de usuário não encontrado neste tenant.");
        }
        const userData = userDoc.data();
        // Guard: explicit tenantId mismatch check (defense in depth)
        if (userData.tenantId !== ctx.tenantId) {
            log.warn("TenantId mismatch detected on user document", {
                claimedTenantId: ctx.tenantId,
                docTenantId: userData.tenantId,
                userId: ctx.userId,
            });
            throw new https_1.HttpsError("permission-denied", "Acesso negado: inconsistência de tenant detectada.");
        }
        if (userData.status === "suspended") {
            throw new https_1.HttpsError("permission-denied", "Sua conta está suspensa. Entre em contato com o suporte.");
        }
        if (userData.strikeUntil) {
            const strikeUntil = userData.strikeUntil instanceof admin.firestore.Timestamp
                ? userData.strikeUntil.toDate()
                : new Date(userData.strikeUntil);
            if (!isNaN(strikeUntil.getTime()) && strikeUntil > now) {
                const formatted = strikeUntil.toLocaleDateString("pt-BR", {
                    day: "2-digit",
                    month: "2-digit",
                    hour: "2-digit",
                    minute: "2-digit",
                });
                throw new https_1.HttpsError("permission-denied", `Agendamento bloqueado por falta/atraso. Liberado em ${formatted}.`);
            }
        }
        // ── Subscription check and wash limit enforcement ──────────────────────
        let isSubscriptionVehicle = false;
        const subsSnap = await tenantRepository_1.Paths.tenantCollection(ctx.tenantId, "subscriptions")
            .where("userId", "==", ctx.userId)
            .where("status", "==", "active")
            .limit(1)
            .get();
        if (!subsSnap.empty) {
            const subData = subsSnap.docs[0].data();
            if (subData.vehicleId === vehicleId) {
                isSubscriptionVehicle = true;
            }
            const planId = subData.planId;
            if (planId) {
                const planDoc = await tenantRepository_1.Paths.plan(ctx.tenantId, planId).get();
                if (planDoc.exists) {
                    const planData = planDoc.data();
                    const limit = planData.washesPerMonth;
                    const bonusWashes = subData.bonusWashes ?? 0;
                    const effectiveLimit = limit === -1 ? -1 : limit + bonusWashes;
                    if (effectiveLimit !== -1) {
                        const subStartDate = subData.startDate instanceof admin.firestore.Timestamp
                            ? subData.startDate.toDate()
                            : new Date(subData.startDate);
                        const cycleDay = subStartDate.getDate();
                        let cycleStart = new Date(bookingDate.getFullYear(), bookingDate.getMonth(), cycleDay);
                        if (bookingDate < cycleStart) {
                            cycleStart = new Date(bookingDate.getFullYear(), bookingDate.getMonth() - 1, cycleDay);
                        }
                        const cycleEnd = new Date(cycleStart);
                        cycleEnd.setMonth(cycleEnd.getMonth() + 1);
                        cycleEnd.setDate(cycleEnd.getDate() - 1);
                        cycleEnd.setHours(23, 59, 59, 999);
                        const countSnap = await tenantRepository_1.Paths.tenantCollection(ctx.tenantId, "bookings")
                            .where("userId", "==", ctx.userId)
                            .where("scheduledTime", ">=", admin.firestore.Timestamp.fromDate(cycleStart))
                            .where("scheduledTime", "<=", admin.firestore.Timestamp.fromDate(cycleEnd))
                            .get();
                        const validBookings = countSnap.docs.filter((d) => {
                            const data = d.data();
                            return data.status !== "cancelled" || data.penaltyApplied === true;
                        });
                        if (validBookings.length >= effectiveLimit) {
                            throw new https_1.HttpsError("resource-exhausted", `Você atingiu o limite de ${effectiveLimit} lavagens do seu plano para este período.`);
                        }
                    }
                }
            }
            // Prevent double active booking for subscription vehicle
            if (isSubscriptionVehicle) {
                const activeStatuses = [
                    "scheduled", "confirmed", "checkIn", "washing",
                    "vacuuming", "drying", "polishing",
                ];
                const activeSnap = await tenantRepository_1.Paths.tenantCollection(ctx.tenantId, "bookings")
                    .where("userId", "==", ctx.userId)
                    .where("vehicleId", "==", vehicleId)
                    .get();
                const hasActive = activeSnap.docs.some((d) => activeStatuses.includes(d.data().status));
                if (hasActive) {
                    throw new https_1.HttpsError("failed-precondition", "Este veículo já possui um agendamento ativo.");
                }
            }
        }
        // ── Price calculation ──────────────────────────────────────────────────
        let totalPrice = 0;
        const servicesSnap = await tenantRepository_1.Paths.tenantCollection(ctx.tenantId, "services")
            .where(admin.firestore.FieldPath.documentId(), "in", serviceIds)
            .get();
        const vehicleDoc = await tenantRepository_1.Paths.vehicle(ctx.tenantId, vehicleId).get();
        const vehicleData = vehicleDoc.data();
        let vehicleCategory = (vehicleData?.category ||
            vehicleData?.type ||
            "sedan").toLowerCase();
        if (!["hatch", "sedan", "suv", "pickup"].includes(vehicleCategory)) {
            vehicleCategory = "sedan";
        }
        const pricingDoc = await tenantRepository_1.Paths.tenantCollection(ctx.tenantId, "prices")
            .doc("pricing_matrix")
            .get();
        const pricingMatrix = pricingDoc.exists ? pricingDoc.data() : null;
        for (const serviceId of serviceIds) {
            let servicePrice = 0;
            let found = false;
            const svcDoc = servicesSnap.docs.find((d) => d.id === serviceId);
            if (svcDoc) {
                servicePrice = svcDoc.data().price ?? 0;
                found = true;
            }
            if (!found && pricingMatrix?.prices) {
                const catPrices = pricingMatrix.prices[vehicleCategory];
                if (catPrices?.[serviceId] !== undefined) {
                    servicePrice = Number(catPrices[serviceId]);
                    found = true;
                }
            }
            if (found) {
                totalPrice += servicePrice;
            }
            else {
                log.warn(`Service "${serviceId}" not found for pricing`, { vehicleCategory });
            }
        }
        // ── Calendar / capacity check ──────────────────────────────────────────
        const calConfigDoc = await tenantRepository_1.Paths.config(ctx.tenantId, "calendar").get();
        let slotCapacity = 2;
        let isSlotBlocked = false;
        if (calConfigDoc.exists) {
            const configData = calConfigDoc.data();
            if (configData.weeklySchedule) {
                const shopTZ = "America/Sao_Paulo";
                const shopDate = new Date(bookingDate.toLocaleString("en-US", { timeZone: shopTZ }));
                const jsDay = shopDate.getDay();
                const scheduleDay = jsDay === 0 ? 7 : jsDay;
                const hour = shopDate.getHours();
                const daySchedule = configData.weeklySchedule.find((s) => s.dayOfWeek === scheduleDay);
                if (daySchedule) {
                    if (!daySchedule.isOpen) {
                        throw new https_1.HttpsError("failed-precondition", "Estabelecimento fechado neste dia.");
                    }
                    if (hour < daySchedule.startHour || hour >= daySchedule.endHour) {
                        throw new https_1.HttpsError("failed-precondition", "Horário fora do funcionamento.");
                    }
                    const timeStr = `${hour.toString().padStart(2, "0")}:00`;
                    if (daySchedule.slots) {
                        const slot = daySchedule.slots.find((s) => s.time === timeStr);
                        if (slot) {
                            if (slot.isBlocked)
                                isSlotBlocked = true;
                            slotCapacity = slot.capacity ?? slotCapacity;
                        }
                        else if (daySchedule.capacityPerHour !== undefined) {
                            slotCapacity = daySchedule.capacityPerHour;
                        }
                    }
                    else if (daySchedule.capacityPerHour !== undefined) {
                        slotCapacity = daySchedule.capacityPerHour;
                    }
                }
            }
            else if (configData.defaultSlotCapacity !== undefined) {
                slotCapacity = configData.defaultSlotCapacity;
            }
        }
        if (isSlotBlocked) {
            throw new https_1.HttpsError("resource-exhausted", "Este horário está bloqueado pelo estabelecimento.");
        }
        // ── Vehicle conflict check ─────────────────────────────────────────────
        const vehicleConflictSnap = await tenantRepository_1.Paths.tenantCollection(ctx.tenantId, "bookings")
            .where("vehicleId", "==", vehicleId)
            .where("scheduledTime", "==", admin.firestore.Timestamp.fromDate(bookingDate))
            .get();
        const hasConflict = vehicleConflictSnap.docs.some((d) => d.data().status !== "cancelled");
        if (hasConflict) {
            throw new https_1.HttpsError("already-exists", "Este veículo já possui um agendamento neste horário.");
        }
        // ── Slot capacity check ────────────────────────────────────────────────
        const timeSlotSnap = await tenantRepository_1.Paths.tenantCollection(ctx.tenantId, "bookings")
            .where("scheduledTime", "==", admin.firestore.Timestamp.fromDate(bookingDate))
            .get();
        const activeInSlot = timeSlotSnap.docs.filter((d) => d.data().status !== "cancelled").length;
        if (activeInSlot >= slotCapacity) {
            throw new https_1.HttpsError("resource-exhausted", "Horário esgotado! Selecione outro horário.");
        }
        // ── Create booking ─────────────────────────────────────────────────────
        const bookingData = {
            tenantId: ctx.tenantId,
            userId: ctx.userId,
            vehicleId,
            serviceIds,
            scheduledTime: admin.firestore.Timestamp.fromDate(bookingDate),
            status: "scheduled",
            totalPrice,
            paymentStatus: isSubscriptionVehicle ? "subscription" : "pending",
            staffNotes: staffNotes ?? "",
            beforePhotos: [],
            afterPhotos: [],
            isRated: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        };
        const bookingRef = await tenantRepository_1.Paths.tenantCollection(ctx.tenantId, "bookings").add(bookingData);
        log.info("Booking created", {
            bookingId: bookingRef.id,
            vehicleId,
            serviceIds,
            totalPrice,
            scheduledTime: bookingDate.toISOString(),
        }, ctx.userId);
        return { bookingId: bookingRef.id, status: "success", totalPrice };
    }
    catch (err) {
        if (err instanceof https_1.HttpsError)
            throw err;
        log.error("createBookingV2 failed", { error: err.message }, ctx.userId);
        throw new https_1.HttpsError("internal", "Não foi possível criar o agendamento.");
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// cancelBookingV2
// ─────────────────────────────────────────────────────────────────────────────
exports.cancelBookingV2 = (0, https_1.onCall)(async (request) => {
    const ctx = (0, tenantAuth_1.extractTenantContext)(request);
    const log = (0, logger_1.tenantLogger)(ctx.tenantId, "cancelBookingV2");
    const { bookingId } = request.data;
    if (!bookingId?.trim()) {
        throw new https_1.HttpsError("invalid-argument", "bookingId é obrigatório.");
    }
    const tenantConfig = await (0, tenantRepository_1.getTenantConfig)(ctx.tenantId);
    (0, tenantRepository_1.assertTenantActive)(tenantConfig, ctx.tenantId);
    const bookingRef = tenantRepository_1.Paths.booking(ctx.tenantId, bookingId);
    const bookingDoc = await bookingRef.get();
    if (!bookingDoc.exists) {
        throw new https_1.HttpsError("not-found", "Agendamento não encontrado.");
    }
    const booking = bookingDoc.data();
    // ── Tenant isolation guard ────────────────────────────────────────────
    if (booking.tenantId !== ctx.tenantId) {
        log.warn("Cross-tenant booking cancel attempt", {
            bookingTenantId: booking.tenantId,
            callerTenantId: ctx.tenantId,
        }, ctx.userId);
        throw new https_1.HttpsError("permission-denied", "Acesso negado.");
    }
    // ── Authorization check ───────────────────────────────────────────────
    if (booking.userId !== ctx.userId && ctx.role === "customer") {
        throw new https_1.HttpsError("permission-denied", "Não autorizado a cancelar este agendamento.");
    }
    if (booking.status === "cancelled") {
        throw new https_1.HttpsError("failed-precondition", "Agendamento já cancelado.");
    }
    if (booking.status === "finished") {
        throw new https_1.HttpsError("failed-precondition", "Não é possível cancelar um agendamento finalizado.");
    }
    const scheduledTime = booking.scheduledTime instanceof admin.firestore.Timestamp
        ? booking.scheduledTime.toDate()
        : new Date(booking.scheduledTime);
    const now = new Date();
    const diffHours = (scheduledTime.getTime() - now.getTime()) / (1000 * 60 * 60);
    let penaltyApplied = false;
    let strikeApplied = false;
    let warningMessage = "";
    if (diffHours < 2) {
        penaltyApplied = true;
        strikeApplied = true;
        warningMessage = "Cancelamento <2h: strike aplicado (bloqueio de 24h).";
    }
    else if (diffHours < 4) {
        penaltyApplied = true;
        warningMessage = "Cancelamento <4h: crédito consumido.";
    }
    else if (diffHours < 12) {
        penaltyApplied = true;
        warningMessage = "Cancelamento <12h: crédito consumido.";
    }
    if (strikeApplied) {
        const strikeUntil = new Date(now.getTime() + 24 * 60 * 60 * 1000);
        await tenantRepository_1.Paths.user(ctx.tenantId, booking.userId).update({
            strikeUntil: admin.firestore.Timestamp.fromDate(strikeUntil),
            lastStrikeReason: "Cancelamento Imediato (<2h)",
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
    }
    await bookingRef.update({
        status: "cancelled",
        cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
        cancelledBy: ctx.userId,
        penaltyApplied,
        strikeApplied,
        cancellationWarning: warningMessage,
    });
    log.info("Booking cancelled", { bookingId, penaltyApplied, strikeApplied }, ctx.userId);
    return { success: true };
});
//# sourceMappingURL=bookingController.js.map