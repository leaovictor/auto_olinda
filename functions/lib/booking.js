"use strict";
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
exports.autoExpireUnconfirmedBookings = exports.cancelBooking = exports.createBooking = void 0;
const https_1 = require("firebase-functions/v2/https");
const scheduler_1 = require("firebase-functions/v2/scheduler");
const admin = __importStar(require("firebase-admin"));
/**
 * Creates a new booking with security checks.
 * Enforces:
 * 1. Schema Validation
 * 2. Lead Time (min 2 hours)
 * 3. Subscription Limits (Excessive Wash)
 * 4. Concurrency Anti-spam
 */
exports.createBooking = (0, https_1.onCall)(async (request) => {
    console.log("==== createBooking function started ====");
    if (!request.auth) {
        console.log("ERROR: No authentication!");
        throw new https_1.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    console.log("Authenticated user:", request.auth.uid);
    console.log("Request data:", JSON.stringify(request.data));
    const { vehicleId, serviceIds, scheduledTime, staffNotes } = request.data;
    const userId = request.auth.uid;
    console.log("vehicleId:", vehicleId);
    console.log("serviceIds:", serviceIds);
    console.log("scheduledTime:", scheduledTime);
    // 1. Validation
    if (!vehicleId || !serviceIds || !Array.isArray(serviceIds) || serviceIds.length === 0 || !scheduledTime) {
        console.log("ERROR: Missing required fields!");
        throw new https_1.HttpsError("invalid-argument", "Missing required fields (vehicleId, serviceIds, scheduledTime).");
    }
    console.log("✓ Validation passed");
    const db = admin.firestore();
    // Parse Scheduled Time
    const bookingDate = new Date(scheduledTime);
    const now = new Date();
    console.log("Parsed bookingDate:", bookingDate.toISOString());
    console.log("Current time:", now.toISOString());
    if (isNaN(bookingDate.getTime())) {
        console.log("ERROR: Invalid date format!");
        throw new https_1.HttpsError("invalid-argument", "Invalid date format.");
    }
    // 2. Lead Time Rule: 2 Hours minimum
    // TODO: Make this configurable via Firestore 'config'
    const MIN_LEAD_HOURS = 2;
    const diffHours = (bookingDate.getTime() - now.getTime()) / (1000 * 60 * 60);
    console.log("Lead time check - diffHours:", diffHours, "MIN_LEAD_HOURS:", MIN_LEAD_HOURS);
    if (diffHours < MIN_LEAD_HOURS) {
        console.log("ERROR: Lead time too short!");
        throw new https_1.HttpsError("failed-precondition", `Agendamentos devem ser feitos com no mínimo ${MIN_LEAD_HOURS} horas de antecedência.`);
    }
    console.log("✓ Lead time check passed");
    try {
        // 3. User & Subscription Check
        // Check if user is blocked or suspended (optional)
        console.log("Fetching user document...");
        const userDoc = await db.collection("users").doc(userId).get();
        const userData = userDoc.data();
        console.log("User exists:", userDoc.exists, "userData:", userData ? "found" : "null");
        if (userData?.status === 'suspended') {
            console.log("ERROR: User is suspended!");
            throw new https_1.HttpsError("permission-denied", "Sua conta está suspensa. Entre em contato com o suporte.");
        }
        // Check for Strike (Blocking)
        if (userData?.strikeUntil) {
            let strikeUntil;
            // Robust Timestamp parsing
            if (userData.strikeUntil.toDate && typeof userData.strikeUntil.toDate === 'function') {
                strikeUntil = userData.strikeUntil.toDate();
            }
            else if (userData.strikeUntil instanceof admin.firestore.Timestamp) {
                strikeUntil = userData.strikeUntil.toDate();
            }
            else {
                strikeUntil = new Date(userData.strikeUntil);
            }
            console.log(`Checking strike: ${strikeUntil.toISOString()} vs Now: ${now.toISOString()}`);
            if (!isNaN(strikeUntil.getTime()) && strikeUntil > now) {
                console.log("ERROR: User is in Strike mode until", strikeUntil.toISOString());
                const formattedTime = strikeUntil.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
                const formattedDate = strikeUntil.toLocaleDateString('pt-BR');
                throw new https_1.HttpsError("permission-denied", `Agendamento bloqueado por falta/atraso. Sua conta será liberada em ${formattedDate} às ${formattedTime}.`);
            }
        }
        console.log("✓ User check passed");
        // 3. User & Subscription Check (Reordered)
        // Fetch Subscription First
        console.log("Checking subscription status...");
        const subsQuery = await db.collection("subscriptions")
            .where("userId", "==", userId)
            .where("status", "==", "active")
            .limit(1)
            .get();
        let isSubscriptionVehicle = false;
        if (!subsQuery.empty) {
            const subData = subsQuery.docs[0].data();
            if (subData.vehicleId === vehicleId) {
                isSubscriptionVehicle = true;
            }
        }
        // Check Active Bookings (Only if Subscription Vehicle)
        if (isSubscriptionVehicle) {
            console.log("Checking for active appointments (Subscription Restriction)...");
            const activeStatuses = ['scheduled', 'confirmed', 'checkIn', 'washing', 'vacuuming', 'drying', 'polishing'];
            const activeBookingsQuery = await db.collection("appointments")
                .where("userId", "==", userId)
                .get();
            const activeBookings = activeBookingsQuery.docs.filter(doc => {
                const data = doc.data();
                return activeStatuses.includes(data.status) && data.vehicleId === vehicleId;
            });
            if (activeBookings.length > 0) {
                console.log(`ERROR: Subscription vehicle already has active booking.`);
                throw new https_1.HttpsError("failed-precondition", "Este veículo já possui um agendamento ativo. Aguarde a conclusão da lavagem atual.");
            }
        }
        else {
            console.log("Pay-Per-Use: Skipping single active booking restriction.");
        }
        console.log("✓ Active appointment check passed");
        // Subscription Limits Logic (reuses subsQuery)
        console.log("Checking subscription limits...");
        console.log("Subscription query returned:", subsQuery.size, "documents");
        if (!subsQuery.empty) {
            const sub = subsQuery.docs[0].data();
            const planId = sub.planId; // This is actually a Stripe price ID like "price_xxx"
            console.log("User has subscription with planId (Stripe Price ID):", planId);
            if (planId) {
                // planId is a Stripe price ID, so we need to query plans by stripePriceId field
                // First, try to find by stripePriceId field
                let planData = null;
                const planQuery = await db.collection("plans")
                    .where("stripePriceId", "==", planId)
                    .limit(1)
                    .get();
                if (!planQuery.empty) {
                    planData = planQuery.docs[0].data();
                    console.log("Found plan by stripePriceId:", planQuery.docs[0].id);
                }
                else {
                    // Fallback: try by document ID (for backwards compatibility)
                    const planDoc = await db.collection("plans").doc(planId).get();
                    if (planDoc.exists) {
                        planData = planDoc.data();
                        console.log("Found plan by document ID:", planId);
                    }
                }
                if (!planData) {
                    console.log("WARNING: No plan found for planId:", planId, "- Allowing booking (no limit check)");
                }
                else {
                    const limit = planData.washesPerMonth || 0;
                    const bonusWashes = sub.bonusWashes || 0;
                    const effectiveLimit = limit === -1 ? -1 : limit + bonusWashes;
                    console.log("Plan limit:", limit, "washesPerMonth (-1 = unlimited)");
                    console.log("Bonus washes:", bonusWashes, "Effective limit:", effectiveLimit);
                    if (effectiveLimit !== -1) { // -1 means unlimited
                        // Calculate cycle based on subscription start date (not calendar month)
                        // This prevents clients from getting double washes when subscription starts mid-month
                        // Example: If subscription starts on day 15, cycle is 15th to 14th of next month
                        const subStartDate = sub.startDate.toDate();
                        const cycleDay = subStartDate.getDate();
                        // Calculate current cycle start
                        let cycleStart = new Date(bookingDate.getFullYear(), bookingDate.getMonth(), cycleDay);
                        if (bookingDate < cycleStart) {
                            // Booking is before cycle start, use previous month's cycle
                            cycleStart = new Date(bookingDate.getFullYear(), bookingDate.getMonth() - 1, cycleDay);
                        }
                        // Calculate cycle end (day before next cycle starts)
                        const cycleEnd = new Date(cycleStart);
                        cycleEnd.setMonth(cycleEnd.getMonth() + 1);
                        cycleEnd.setDate(cycleEnd.getDate() - 1);
                        cycleEnd.setHours(23, 59, 59, 999);
                        console.log("Subscription cycle day:", cycleDay);
                        console.log("Checking bookings between:", cycleStart.toISOString(), "and", cycleEnd.toISOString());
                        const countQuery = await db.collection("appointments")
                            .where("userId", "==", userId)
                            .where("scheduledTime", ">=", admin.firestore.Timestamp.fromDate(cycleStart))
                            .where("scheduledTime", "<=", admin.firestore.Timestamp.fromDate(cycleEnd))
                            .get();
                        console.log("Found", countQuery.size, "bookings in date range");
                        // Filter out cancelled bookings (client-side filtering because of compound query limitations usually)
                        // Or we can rely on index if we add 'status' to the query, but let's filter here for simplicity and robustness
                        // Filter out cancelled bookings, UNLESS they have a penalty (consumed credit)
                        const validBookings = countQuery.docs.filter(d => {
                            const data = d.data();
                            // Count if NOT cancelled OR (cancelled AND penaltyApplied is true)
                            return data.status !== 'cancelled' || data.penaltyApplied === true;
                        });
                        console.log("Valid (non-cancelled) bookings:", validBookings.length);
                        if (validBookings.length >= effectiveLimit) {
                            console.log("ERROR: Monthly booking limit reached!");
                            throw new https_1.HttpsError("resource-exhausted", `Você atingiu o limite de ${effectiveLimit} lavagens do seu plano para este mês.`);
                        }
                    }
                }
            }
        }
        else {
            console.log("User has no active subscription (non-premium)");
        }
        console.log("✓ Subscription check passed");
        // 4. Calculate Total Price
        // Fetch services to validate IDs and sum price
        console.log("Fetching services with IDs:", serviceIds);
        let totalPrice = 0;
        const servicesSnap = await db.collection("services").where(admin.firestore.FieldPath.documentId(), "in", serviceIds).get();
        console.log("Services found:", servicesSnap.size, "of", serviceIds.length, "requested");
        // Fetch Vehicle to get Category (for dynamic pricing)
        const vehicleDoc = await db.collection("vehicles").doc(vehicleId).get();
        const vehicleData = vehicleDoc.data();
        // Default to 'sedan' or 'hatch' if missing, but should exist.
        // Assuming Frontend uses 'hatch', 'sedan', 'suv', 'pickup'.
        // If vehicleData.category is missing, check vehicleData.type (old field)
        let vehicleCategory = (vehicleData?.category || vehicleData?.type || 'sedan').toLowerCase();
        // Normalize category (safe fallback)
        if (!['hatch', 'sedan', 'suv', 'pickup'].includes(vehicleCategory)) {
            vehicleCategory = 'sedan';
        }
        console.log(`Vehicle category: ${vehicleCategory}`);
        // Fetch Pricing Matrix
        let pricingMatrix = null;
        const pricingMatrixDoc = await db.collection("prices").doc("pricing_matrix").get();
        if (pricingMatrixDoc.exists) {
            pricingMatrix = pricingMatrixDoc.data();
        }
        // Calculation Loop
        for (const serviceId of serviceIds) {
            let servicePrice = 0;
            let serviceFound = false;
            // 1. Try Legacy Services Collection
            const serviceDoc = servicesSnap.docs.find(d => d.id === serviceId);
            if (serviceDoc) {
                servicePrice = serviceDoc.data().price || 0;
                serviceFound = true;
                console.log(`Service ${serviceId} found in collection. Price: ${servicePrice}`);
            }
            // 2. Try Dynamic Pricing Matrix
            if (!serviceFound && pricingMatrix && pricingMatrix.prices) {
                // Matrix structure: prices[category][serviceId] = number
                const categoryPrices = pricingMatrix.prices[vehicleCategory];
                if (categoryPrices && categoryPrices[serviceId] !== undefined) {
                    servicePrice = Number(categoryPrices[serviceId]);
                    serviceFound = true;
                    console.log(`Service ${serviceId} found in PricingMatrix for ${vehicleCategory}. Price: ${servicePrice}`);
                }
            }
            if (serviceFound) {
                totalPrice += servicePrice;
            }
            else {
                console.warn(`WARNING: Service ${serviceId} not found in collection OR matrix. Assuming price 0.`);
            }
        }
        console.log("Total price calculated:", totalPrice);
        // 4. Concurrency & Capacity Checks
        // A. Check Schedule / Slots Configuration
        console.log("Fetching calendar config...");
        const calendarConfigDoc = await db.collection("config").doc("calendar").get();
        // Default capacity if no config found or error
        let slotCapacity = 2; // Default fallback
        let isSlotBlocked = false;
        if (calendarConfigDoc.exists) {
            const configData = calendarConfigDoc.data();
            if (configData && configData.weeklySchedule) {
                // weekDay: 0 (Sun) - 6 (Sat)
                // configData.weeklySchedule usually 1-7 or 0-6. 
                // In Flutter code: Monday=1, Sunday=7.
                // JS getDay(): Sunday=0, Monday=1. 
                // TIMEZONE FIX: Convert UTC Booking Date to Shop Timezone (America/Sao_Paulo)
                // This ensures we check the correct Day and Hour for the shop location
                const shopTimeZone = "America/Sao_Paulo";
                const shopDate = new Date(bookingDate.toLocaleString("en-US", { timeZone: shopTimeZone }));
                const jsDay = shopDate.getDay();
                const scheduleDay = jsDay === 0 ? 7 : jsDay; // Convert 0 (Sun) to 7
                const hour = shopDate.getHours();
                const daySchedule = configData.weeklySchedule.find((s) => s.dayOfWeek === scheduleDay);
                if (daySchedule) {
                    if (!daySchedule.isOpen) {
                        console.log("ERROR: Day is closed!");
                        throw new https_1.HttpsError("failed-precondition", "Estabelecimento fechado neste dia.");
                    }
                    // Check Slots
                    // We need to find the slot matching "HH:mm"
                    // const hour = bookingDate.getHours(); // <-- OLD BUGGY CODE (UTC)
                    // Ensure double digit format for matching: "08:00"
                    const timeStr = `${hour.toString().padStart(2, '0')}:00`;
                    // Check if time is within open hours just in case
                    if (hour < daySchedule.startHour || hour >= daySchedule.endHour) {
                        console.log(`ERROR: Time ${timeStr} outside operating hours (${daySchedule.startHour}-${daySchedule.endHour})`);
                        throw new https_1.HttpsError("failed-precondition", "Horário fora do funcionamento.");
                    }
                    console.log(`Checking slot for ${timeStr} on day ${scheduleDay}...`);
                    if (daySchedule.slots && Array.isArray(daySchedule.slots)) {
                        const slot = daySchedule.slots.find((s) => s.time === timeStr);
                        if (slot) {
                            console.log("Found slot config:", JSON.stringify(slot));
                            if (slot.isBlocked) {
                                isSlotBlocked = true;
                            }
                            slotCapacity = slot.capacity;
                            // Check Allowed Categories
                            if (slot.allowedCategories && Array.isArray(slot.allowedCategories) && slot.allowedCategories.length > 0) {
                                console.log(`Slot has restrictions: ${slot.allowedCategories}`);
                                // Fetch categories for the requested services
                                // We already fetched servicesSnap earlier for price calculation.
                                // We need to iterate and check categories.
                                // BUT, we fetched servicesSnap AFTER this block in the original code order?
                                // No, looking at line 205, servicesSnap is fetched before this capacity check (Lines 225+).
                                // Let's verify... 
                                // Yes, in the provided file, step 4 (Price calculation at line 201) comes BEFORE step 4 (Concurrency at line 224). 
                                // Wait, both are labeled "4."? Yes, likely a typo in comments. Line 201 is Price. Line 224 is Concurrency.
                                // So servicesSnap is available.
                                const invalidServices = servicesSnap.docs.filter(doc => {
                                    const serviceData = doc.data();
                                    const serviceCategory = serviceData.category || 'general'; // Default category if missing
                                    return !slot.allowedCategories.includes(serviceCategory);
                                });
                                if (invalidServices.length > 0) {
                                    console.log("ERROR: Services not allowed in this slot:", invalidServices.map(d => d.id));
                                    throw new https_1.HttpsError("permission-denied", `Este horário é exclusivo para serviços de: ${slot.allowedCategories.join(', ')}.`);
                                }
                            }
                        }
                        else {
                            console.log("No specific slot found, falling back to legacy capacityPerHour or default.");
                            // Fallback to day defaults if slot missing (e.g. resized hours)
                            // If capacityPerHour exists (legacy), use it, else default.
                            if (daySchedule.capacityPerHour !== undefined) {
                                slotCapacity = daySchedule.capacityPerHour;
                            }
                        }
                    }
                    else {
                        // Legacy fallback
                        if (daySchedule.capacityPerHour !== undefined) {
                            slotCapacity = daySchedule.capacityPerHour;
                        }
                    }
                }
            }
        }
        if (isSlotBlocked) {
            console.log("ERROR: Slot is manually blocked!");
            throw new https_1.HttpsError("resource-exhausted", "Este horário está bloqueado pelo estabelecimento.");
        }
        // B. Check if THIS vehicle is already booked at this time (Prevent double booking same car)
        console.log("Checking vehicle conflict for vehicleId:", vehicleId, "at time:", bookingDate.toISOString());
        const vehicleConflictQuery = await db.collection("appointments")
            .where("vehicleId", "==", vehicleId)
            .where("scheduledTime", "==", admin.firestore.Timestamp.fromDate(bookingDate)) // Exact match probably enough for slots
            .get();
        console.log("Vehicle conflict query returned:", vehicleConflictQuery.size, "documents");
        const activeVehicleConflict = vehicleConflictQuery.docs.find(d => d.data().status !== 'cancelled');
        if (activeVehicleConflict) {
            console.log("ERROR: Vehicle already booked at this time!");
            throw new https_1.HttpsError("already-exists", "Este veículo já possui um agendamento neste horário.");
        }
        console.log("✓ Vehicle conflict check passed");
        // C. Check Global Shop Capacity based on Slot
        console.log(`Checking time slot capacity (Max: ${slotCapacity})...`);
        const timeSlotQuery = await db.collection("appointments")
            .where("scheduledTime", "==", admin.firestore.Timestamp.fromDate(bookingDate))
            .get();
        // Filter active jobs (not cancelled)
        const activeJobsInSlot = timeSlotQuery.docs.filter(d => d.data().status !== 'cancelled').length;
        console.log("Active jobs in slot:", activeJobsInSlot, "of", slotCapacity, "max");
        if (activeJobsInSlot >= slotCapacity) {
            console.log("ERROR: Time slot capacity reached!");
            throw new https_1.HttpsError("resource-exhausted", "Horário esgotado! Por favor selecione outro horário or entre na fila de espera.");
        }
        console.log("✓ Capacity check passed");
        // 5. Create Booking
        console.log("Creating booking...");
        const bookingData = {
            userId,
            vehicleId,
            serviceIds,
            scheduledTime: admin.firestore.Timestamp.fromDate(bookingDate),
            status: "scheduled",
            totalPrice,
            paymentStatus: isSubscriptionVehicle ? "subscription" : "pending", // Premium users use subscription credit
            staffNotes: staffNotes || "",
            beforePhotos: [],
            afterPhotos: [],
            isRated: false,
            logs: [],
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        };
        console.log("Booking data:", JSON.stringify({ ...bookingData, scheduledTime: bookingDate.toISOString() }));
        const bookingRef = await db.collection("appointments").add(bookingData);
        console.log("✓ Booking created successfully! ID:", bookingRef.id);
        return { bookingId: bookingRef.id, status: "success", totalPrice };
    }
    catch (error) {
        if (error instanceof https_1.HttpsError)
            throw error;
        console.error("ERROR creating booking:", error);
        console.error("Error stack:", error.stack);
        throw new https_1.HttpsError("internal", "Não foi possível criar o agendamento.", error);
    }
});
/**
 * Cancels a booking with window validation.
 */
exports.cancelBooking = (0, https_1.onCall)(async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Auth required.");
    }
    const { bookingId } = request.data;
    const userId = request.auth.uid;
    if (!bookingId) {
        throw new https_1.HttpsError("invalid-argument", "Missing bookingId.");
    }
    const db = admin.firestore();
    const bookingRef = db.collection("appointments").doc(bookingId);
    const bookingDoc = await bookingRef.get();
    if (!bookingDoc.exists) {
        throw new https_1.HttpsError("not-found", "Agendamento não encontrado.");
    }
    const booking = bookingDoc.data();
    // Security: Only owner or admin can cancel
    // We assume admin check is done via role but simple check here:
    if (booking?.userId !== userId) {
        // Check if user is admin? For now, strict owner check or error.
        // If needed, check user role.
        const userRoleDoc = await db.collection("users").doc(userId).get();
        if (userRoleDoc.data()?.role !== 'admin' && userRoleDoc.data()?.role !== 'staff') {
            throw new https_1.HttpsError("permission-denied", "Não autorizado.");
        }
    }
    if (booking?.status === 'cancelled') {
        throw new https_1.HttpsError("failed-precondition", "Agendamento já cancelado.");
    }
    if (booking?.status === 'finished') {
        throw new https_1.HttpsError("failed-precondition", "Não é possível cancelar um agendamento finalizado.");
    }
    // Validation: Cancellation Window (e.g., 4 hours)
    const scheduledTime = booking?.scheduledTime instanceof admin.firestore.Timestamp
        ? booking.scheduledTime.toDate()
        : new Date(booking?.scheduledTime);
    const now = new Date();
    const diffHours = (scheduledTime.getTime() - now.getTime()) / (1000 * 60 * 60);
    // 1. Safe Cancellation (> 12h): Refund credit (standard cancellation)
    // 2. Critical Cancellation (< 4h): Consume credit + Warning
    // 3. Immediate Cancellation (< 2h): Consume credit + Strike (24h block)
    // Note: Between 12h and 4h -> currently treating as Safe based on "Cancelamento Crítico (-4h)" description implied > 4h is safe?
    // Text says: "Cancelamento Seguro (+12h)". 
    // Text says: "Cancelamento Crítico (-4h)".
    // Gap between 12h and 4h? Usually strict rules imply:
    // > 12h: Safe.
    // < 12h but > 4h: Maybe just consume credit? Or safe?
    // Let's assume the user meant:
    // > 12h: Safe.
    // < 12h (implied): Maybe small penalty?
    // But let's stick to EXPLICIT rules first.
    // Rule 4 says: "Cancelamento Seguro (+12h)".
    // Rule 4 says: "Cancelamento Crítico (-4h)".
    // Let's assume < 12h starts to be non-safe? Or is 12h just the Lead time?
    // Lead time is for CREATION.
    // For CANCELLATION:
    // "Cancelamento Seguro (+12h)" -> If diffHours > 12.0
    // "Cancelamento Crítico (-4h)" -> If diffHours < 4.0
    // "Cancelamento Imediato (-2h)" -> If diffHours < 2.0
    // We will assume [4h - 12h] is Warning or Reduced Penalty?
    // Given strictness, maybe [4h - 12h] consumes credit but no strike?
    // Or maybe it is safe? "Cancelamento Seguro (+12h)" implies <12h is NOT safe.
    // Let's implement:
    // > 12h: FREE.
    // 4h - 12h: CONSUME CREDIT (Implicit strictness).
    // 2h - 4h: CONSUME CREDIT + WARNING.
    // < 2h: CONSUME CREDIT + STRIKE.
    let penaltyApplied = false;
    let strikeApplied = false;
    let warningMessage = "";
    if (diffHours >= 12) {
        console.log("Cancellation > 12h. Safe.");
    }
    else if (diffHours < 2) {
        console.log("Cancellation < 2h. IMMEDIATE STRIKE.");
        penaltyApplied = true;
        strikeApplied = true;
        warningMessage = "Cancelamento com menos de 2h. Strike aplicado (24h de bloqueio).";
    }
    else if (diffHours < 4) {
        console.log("Cancellation < 4h. CRITICAL.");
        penaltyApplied = true;
        // Warning for reoccurrence?
        warningMessage = "Cancelamento com menos de 4h. Crédito consumido. Reincidência gera bloqueio.";
    }
    else {
        // Between 4h and 12h
        // If we strictly follow "Cancelamento Seguro (+12h)", then this range is NOT safe.
        // We will consume credit.
        console.log("Cancellation between 4h and 12h. Consuming credit.");
        penaltyApplied = true;
        warningMessage = "Cancelamento com menos de 12h. Crédito consumido.";
    }
    // Update logic to apply Strike
    if (strikeApplied) {
        const strikeDurationHours = 24;
        const strikeUntil = new Date(now.getTime() + strikeDurationHours * 60 * 60 * 1000);
        await db.collection("users").doc(userId).update({
            strikeUntil: admin.firestore.Timestamp.fromDate(strikeUntil),
            lastStrikeReason: "Cancelamento Imediato (<2h)"
        });
    }
    await bookingRef.update({
        status: "cancelled",
        cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
        cancelledBy: userId,
        penaltyApplied: penaltyApplied,
        strikeApplied: strikeApplied,
        cancellationWarning: warningMessage
    });
    return { success: true };
});
/**
 * Scheduled function that runs every 5 minutes.
 * Automatically cancels bookings that are past their deadline:
 * 1. Status 'scheduled' (awaiting confirmation) - Cancelled WITHOUT penalty
 * 2. Status 'confirmed' (confirmed but no check-in) - Cancelled WITH strike
 */
exports.autoExpireUnconfirmedBookings = (0, scheduler_1.onSchedule)({
    schedule: "every 5 minutes",
    timeZone: "America/Sao_Paulo",
    retryCount: 0,
}, async () => {
    const db = admin.firestore();
    const now = new Date();
    // Deadline: 15 minutes tolerance after scheduled time
    // We want to find bookings where (scheduledTime + 15min) < now
    // Which means: scheduledTime < (now - 15min)
    const deadlineThreshold = new Date(now.getTime() - 15 * 60 * 1000);
    console.log(`[AutoExpire] Running at ${now.toISOString()}`);
    console.log(`[AutoExpire] Looking for expired bookings with scheduledTime < ${deadlineThreshold.toISOString()}`);
    try {
        // Query 1: Scheduled bookings (awaiting confirmation from lavajato)
        // These are cancelled WITHOUT penalty - it's the lavajato's responsibility to confirm
        const scheduledQuery = await db.collection("appointments")
            .where("status", "==", "scheduled")
            .where("scheduledTime", "<", admin.firestore.Timestamp.fromDate(deadlineThreshold))
            .get();
        // Query 2: Confirmed bookings (confirmed but client didn't check-in)
        // These are cancelled WITH strike - it's the client's responsibility to show up
        const confirmedQuery = await db.collection("appointments")
            .where("status", "==", "confirmed")
            .where("scheduledTime", "<", admin.firestore.Timestamp.fromDate(deadlineThreshold))
            .get();
        const totalExpired = scheduledQuery.size + confirmedQuery.size;
        if (totalExpired === 0) {
            console.log("[AutoExpire] No expired bookings found.");
            return;
        }
        console.log(`[AutoExpire] Found ${scheduledQuery.size} scheduled and ${confirmedQuery.size} confirmed expired booking(s).`);
        const batch = db.batch();
        const usersToNotify = [];
        // Process SCHEDULED bookings (no penalty)
        for (const doc of scheduledQuery.docs) {
            const booking = doc.data();
            const bookingId = doc.id;
            const userId = booking.userId;
            const scheduledTime = booking.scheduledTime instanceof admin.firestore.Timestamp
                ? booking.scheduledTime.toDate()
                : new Date(booking.scheduledTime);
            console.log(`[AutoExpire] Cancelling SCHEDULED booking ${bookingId} (scheduled for ${scheduledTime.toISOString()}) - NO PENALTY`);
            // Update booking status WITHOUT penalties
            batch.update(doc.ref, {
                status: "cancelled",
                cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
                cancelledBy: "system",
                cancellationReason: "awaiting_confirmation_timeout",
                penaltyApplied: false, // NO penalty
                strikeApplied: false, // NO strike
            });
            usersToNotify.push({ userId, bookingId, scheduledTime, isNoShow: false });
        }
        // Process CONFIRMED bookings (WITH strike)
        for (const doc of confirmedQuery.docs) {
            const booking = doc.data();
            const bookingId = doc.id;
            const userId = booking.userId;
            const scheduledTime = booking.scheduledTime instanceof admin.firestore.Timestamp
                ? booking.scheduledTime.toDate()
                : new Date(booking.scheduledTime);
            console.log(`[AutoExpire] Cancelling CONFIRMED booking ${bookingId} (scheduled for ${scheduledTime.toISOString()}) - WITH STRIKE`);
            // Update booking status WITH penalties
            batch.update(doc.ref, {
                status: "cancelled",
                cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
                cancelledBy: "system",
                cancellationReason: "no_show",
                penaltyApplied: true, // Consumes credit
                strikeApplied: true, // Applies strike
            });
            // Apply Strike to User (24h block)
            const strikeDurationHours = 24;
            const strikeUntil = new Date(now.getTime() + strikeDurationHours * 60 * 60 * 1000);
            const userRef = db.collection("users").doc(userId);
            // Note: If multiple bookings expire for same user, this overwrites. Acceptable.
            batch.update(userRef, {
                strikeUntil: admin.firestore.Timestamp.fromDate(strikeUntil),
                lastStrikeReason: "No-Show (>15min atraso)"
            });
            usersToNotify.push({ userId, bookingId, scheduledTime, isNoShow: true });
        }
        await batch.commit();
        console.log(`[AutoExpire] Successfully processed ${totalExpired} booking(s).`);
        // Send notifications to affected users
        for (const { userId, bookingId, scheduledTime: _scheduledTime, isNoShow } of usersToNotify) {
            try {
                if (isNoShow) {
                    // Notification for NO-SHOW (confirmed but didn't check-in)
                    await db.collection("users").doc(userId).collection("notifications").add({
                        title: "Strike Aplicado (No-Show)",
                        body: "Você não compareceu ao seu agendamento confirmado. Sua conta está bloqueada por 24h.",
                        timestamp: admin.firestore.FieldValue.serverTimestamp(),
                        bookingId: bookingId,
                        isRead: false,
                        type: "strike_alert",
                    });
                    // Get user's FCM token for push notification
                    const userDoc = await db.collection("users").doc(userId).get();
                    const fcmToken = userDoc.data()?.fcmToken;
                    if (fcmToken) {
                        await admin.messaging().send({
                            token: fcmToken,
                            data: {
                                bookingId: bookingId,
                                type: "strike_alert",
                                title: "Strike Aplicado 🚫",
                                body: "Ausência detectada. Agendamentos bloqueados por 24h.",
                            },
                            android: {
                                notification: {
                                    title: "Strike Aplicado 🚫",
                                    body: "Ausência detectada. Agendamentos bloqueados por 24h.",
                                    channelId: "high_importance_channel",
                                },
                            },
                            apns: {
                                payload: {
                                    aps: {
                                        alert: {
                                            title: "Strike Aplicado",
                                            body: "Ausência detectada. Agendamentos bloqueados por 24h.",
                                        },
                                        sound: "default",
                                    },
                                },
                            },
                            webpush: {
                                headers: { Urgency: "high", TTL: "86400" },
                            },
                        });
                        console.log(`[AutoExpire] Push notification sent to user ${userId}`);
                    }
                }
                else {
                    // Notification for SCHEDULED timeout (no penalty)
                    await db.collection("users").doc(userId).collection("notifications").add({
                        title: "Agendamento Cancelado",
                        body: "Seu agendamento foi cancelado pois não foi confirmado pelo estabelecimento.",
                        timestamp: admin.firestore.FieldValue.serverTimestamp(),
                        bookingId: bookingId,
                        isRead: false,
                        type: "booking_cancelled",
                    });
                }
            }
            catch (notifError) {
                console.error(`[AutoExpire] Failed to notify user ${userId}:`, notifError);
            }
        }
    }
    catch (error) {
        console.error("[AutoExpire] Critical error:", error);
    }
});
//# sourceMappingURL=booking.js.map