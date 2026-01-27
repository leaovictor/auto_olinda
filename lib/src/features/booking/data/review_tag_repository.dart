import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/review_tag.dart';

/// Repository para gerenciar tags de avaliação
class ReviewTagRepository {
  final FirebaseFirestore _firestore;

  ReviewTagRepository(this._firestore);

  static const String _collectionName = 'reviewTags';

  /// Stream de tags ativas ordenadas por displayOrder
  Stream<List<ReviewTag>> getActiveTagsStream() {
    return _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: true)
        .orderBy('displayOrder')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data();
                  return ReviewTag.fromJson({
                    ...data,
                    'id': doc.id,
                    'createdAt':
                        (data['createdAt'] as Timestamp?)?.toDate() ??
                        DateTime.now(),
                    'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate(),
                  });
                } catch (e) {
                  print('Error parsing review tag ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<ReviewTag>()
              .toList();
        });
  }

  /// Stream de todas as tags (ativas e inativas) para tela de gerenciamento
  Stream<List<ReviewTag>> getAllTagsStream() {
    return _firestore
        .collection(_collectionName)
        .orderBy('displayOrder')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data();
                  return ReviewTag.fromJson({
                    ...data,
                    'id': doc.id,
                    'createdAt':
                        (data['createdAt'] as Timestamp?)?.toDate() ??
                        DateTime.now(),
                    'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate(),
                  });
                } catch (e) {
                  print('Error parsing review tag ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<ReviewTag>()
              .toList();
        });
  }

  /// Criar nova tag
  Future<String> createTag(ReviewTag tag) async {
    final docRef = await _firestore.collection(_collectionName).add({
      'label': tag.label,
      'emoji': tag.emoji,
      'isActive': tag.isActive,
      'displayOrder': tag.displayOrder,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': null,
    });
    return docRef.id;
  }

  /// Atualizar tag existente
  Future<void> updateTag(ReviewTag tag) async {
    await _firestore.collection(_collectionName).doc(tag.id).update({
      'label': tag.label,
      'emoji': tag.emoji,
      'isActive': tag.isActive,
      'displayOrder': tag.displayOrder,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deletar tag
  Future<void> deleteTag(String tagId) async {
    await _firestore.collection(_collectionName).doc(tagId).delete();
  }

  /// Ativar/desativar tag
  Future<void> toggleTagActive(String tagId, bool isActive) async {
    await _firestore.collection(_collectionName).doc(tagId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Atualizar ordem de múltiplas tags (batch update para drag-and-drop)
  Future<void> updateTagsOrder(
    List<({String tagId, int displayOrder})> updates,
  ) async {
    if (updates.isEmpty) return;

    final batch = _firestore.batch();

    for (final update in updates) {
      final docRef = _firestore.collection(_collectionName).doc(update.tagId);
      batch.update(docRef, {
        'displayOrder': update.displayOrder,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Buscar tag por ID
  Future<ReviewTag?> getTag(String tagId) async {
    final doc = await _firestore.collection(_collectionName).doc(tagId).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return ReviewTag.fromJson({
      ...data,
      'id': doc.id,
      'createdAt':
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate(),
    });
  }
}

// Providers
final reviewTagRepositoryProvider = Provider<ReviewTagRepository>((ref) {
  return ReviewTagRepository(FirebaseFirestore.instance);
});

final activeReviewTagsProvider = StreamProvider<List<ReviewTag>>((ref) {
  return ref.watch(reviewTagRepositoryProvider).getActiveTagsStream();
});

final allReviewTagsProvider = StreamProvider<List<ReviewTag>>((ref) {
  return ref.watch(reviewTagRepositoryProvider).getAllTagsStream();
});
