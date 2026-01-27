/**
 * Script to initialize default review tags for the review system
 * Run this once to populate the database with initial tags
 * 
 * Usage: npm run init-review-tags (add this to package.json scripts)
 */

import * as admin from 'firebase-admin';

// Initialize if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

const defaultTags = [
  {
    label: 'Serviço Rápido',
    emoji: '⭐',
    isActive: true,
    displayOrder: 1,
  },
  {
    label: 'Lavagem Impecável',
    emoji: '💧',
    isActive: true,
    displayOrder: 2,
  },
  {
    label: 'Equipe Atenciosa',
    emoji: '😊',
    isActive: true,
    displayOrder: 3,
  },
  {
    label: 'Ótimo Custo-Benefício',
    emoji: '💰',
    isActive: true,
    displayOrder: 4,
  },
  {
    label: 'Carro Muito Limpo',
    emoji: '🚗',
    isActive: true,
    displayOrder: 5,
  },
  {
    label: 'Excelente Acabamento',
    emoji: '🏆',
    isActive: true,
    displayOrder: 6,
  },
];

async function initializeReviewTags() {
  console.log('🏷️  Initializing review tags...');

  const reviewTagsRef = db.collection('reviewTags');

  // Check if tags already exist
  const existing = await reviewTagsRef.limit(1).get();
  if (!existing.empty) {
    console.log('⚠️  Tags already exist. Skipping initialization.');
    console.log('💡 To re-initialize, delete the reviewTags collection first.');
    return;
  }

  // Create batch write
  const batch = db.batch();

  defaultTags.forEach((tag) => {
    const docRef = reviewTagsRef.doc(); // Auto-generate ID
    batch.set(docRef, {
      ...tag,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: null,
    });
  });

  // Commit batch
  await batch.commit();

  console.log(`✅ Successfully created ${defaultTags.length} review tags!`);
  console.log('📋 Tags created:');
  defaultTags.forEach((tag, index) => {
    console.log(`   ${index + 1}. ${tag.emoji} ${tag.label}`);
  });
}

// Run the initialization
initializeReviewTags()
  .then(() => {
    console.log('\n🎉 Initialization complete!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Error initializing tags:', error);
    process.exit(1);
  });
