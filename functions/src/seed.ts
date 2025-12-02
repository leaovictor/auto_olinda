import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

/**
 * Seeds the database with initial data (plans, config, etc.)
 * Can be called by any authenticated user on first setup.
 */
export const seedDatabase = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }

  const db = admin.firestore();

  try {
    // Check if already seeded
    const plansSnapshot = await db.collection("plans").limit(1).get();
    if (!plansSnapshot.empty) {
      return {
        success: false,
        message: "Database already seeded. Delete to re-seed.",
      };
    }

    console.log("Starting database seed...");

    // Seed Plans
    await seedPlans(db);

    // Seed Config
    await seedConfig(db);

    console.log("Database seeded successfully");
    return {success: true, message: "Database seeded successfully"};
  } catch (error) {
    console.error("Error seeding database:", error);
    throw new HttpsError("internal", "Failed to seed database.");
  }
});

/**
 * Seeds subscription plans
 * @param {admin.firestore.Firestore} db - Firestore instance
 */
async function seedPlans(db: admin.firestore.Firestore) {
  const plans = [
    {
      id: "basic",
      name: "Básico",
      description: "Ideal para quem lava o carro ocasionalmente",
      price: 99.90,
      credits: 4,
      features: [
        "4 lavagens por mês",
        "Lavagem externa completa",
        "Aspiração interna",
        "Limpeza dos vidros",
      ],
      isPopular: false,
    },
    {
      id: "premium",
      name: "Premium",
      description: "Para quem quer manter o carro sempre limpo",
      price: 179.90,
      credits: 8,
      features: [
        "8 lavagens por mês",
        "Lavagem externa completa",
        "Aspiração interna",
        "Limpeza dos vidros",
        "Cera protetora",
        "Pretinho nos pneus",
      ],
      isPopular: true,
    },
    {
      id: "unlimited",
      name: "Ilimitado",
      description: "Lave quantas vezes quiser",
      price: 299.90,
      credits: 999,
      features: [
        "Lavagens ilimitadas",
        "Lavagem externa completa",
        "Aspiração interna",
        "Limpeza dos vidros",
        "Cera protetora",
        "Pretinho nos pneus",
        "Limpeza de estofados (1x/mês)",
        "Prioridade no agendamento",
      ],
      isPopular: false,
    },
  ];

  const batch = db.batch();
  for (const plan of plans) {
    const docRef = db.collection("plans").doc(plan.id);
    batch.set(docRef, {
      ...plan,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
  await batch.commit();
  console.log("Plans seeded successfully");
}

/**
 * Seeds calendar configuration
 * @param {admin.firestore.Firestore} db - Firestore instance
 */
async function seedConfig(db: admin.firestore.Firestore) {
  // Create default weekly schedule (Mon-Fri, 8am-6pm)
  const weeklySchedule = [];
  for (let day = 1; day <= 7; day++) {
    weeklySchedule.push({
      dayOfWeek: day,
      isOpen: day <= 5, // Mon-Fri open
      startHour: 8,
      endHour: 18,
      capacityPerHour: 3,
    });
  }

  await db.collection("config").doc("calendar").set({
    weeklySchedule,
    blockedDates: [],
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log("Config seeded successfully");
}
