import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Métricas de análise de avaliações e sentimento dos clientes
class ReviewAnalytics {
  final double averageRating; // Média geral
  final int totalReviews; // Total de avaliações
  final double npsScore; // Net Promoter Score
  final double responseRate; // Taxa de resposta (% de lavagens avaliadas)
  final double positiveRate; // % de avaliações 4-5 estrelas
  final Map<int, int>
  ratingDistribution; // Distribuição por estrelas {1: count, 2: count, ...}
  final List<TagStat> topTags; // Tags mais selecionadas
  final int
  totalFinishedBookings; // Total de lavagens finalizadas (para calcular responseRate)

  ReviewAnalytics({
    required this.averageRating,
    required this.totalReviews,
    required this.npsScore,
    required this.responseRate,
    required this.positiveRate,
    required this.ratingDistribution,
    required this.topTags,
    required this.totalFinishedBookings,
  });

  factory ReviewAnalytics.empty() {
    return ReviewAnalytics(
      averageRating: 0.0,
      totalReviews: 0,
      npsScore: 0.0,
      responseRate: 0.0,
      positiveRate: 0.0,
      ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      topTags: [],
      totalFinishedBookings: 0,
    );
  }
}

class MonthlyRating {
  final DateTime month; // First day of the month
  final double averageRating;
  final int reviewCount;

  MonthlyRating({
    required this.month,
    required this.averageRating,
    required this.reviewCount,
  });
}

class TagStat {
  final String tagId;
  final String label;
  final String emoji;
  final int count;

  TagStat({
    required this.tagId,
    required this.label,
    required this.emoji,
    required this.count,
  });
}

class ReviewItem {
  final String bookingId;
  final DateTime ratedAt;
  final int rating;
  final String? comment;
  final List<String> selectedTags;
  final String? clientName;
  final String? vehicleModel;
  final String? adminResponse;
  final DateTime? adminResponseAt;

  ReviewItem({
    required this.bookingId,
    required this.ratedAt,
    required this.rating,
    this.comment,
    required this.selectedTags,
    this.clientName,
    this.vehicleModel,
    this.adminResponse,
    this.adminResponseAt,
  });
}

/// Repository para buscar analytics de avaliações
class ReviewAnalyticsRepository {
  final FirebaseFirestore _firestore;

  ReviewAnalyticsRepository(this._firestore);

  /// Calcular tendência mensal dos últimos 6 meses
  Future<List<MonthlyRating>> getMonthlyTrendLast6Months() async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 5, 1); // 6 months ago

    final reviewsSnapshot = await _firestore
        .collection('appointments')
        .where('isRated', isEqualTo: true)
        .where('ratedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .get();

    // Group reviews by month
    final Map<String, List<int>> monthlyRatings = {};

    for (var doc in reviewsSnapshot.docs) {
      final data = doc.data();
      final ratedAt = (data['ratedAt'] as Timestamp?)?.toDate();
      final rating = data['rating'] as int?;

      if (ratedAt == null || rating == null) continue;

      // Group by year-month
      final monthKey =
          '${ratedAt.year}-${ratedAt.month.toString().padLeft(2, '0')}';
      monthlyRatings.putIfAbsent(monthKey, () => []).add(rating);
    }

    // Create MonthlyRating objects for last 6 months
    final List<MonthlyRating> result = [];
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey =
          '${month.year}-${month.month.toString().padLeft(2, '0')}';
      final ratings = monthlyRatings[monthKey] ?? [];

      final avgRating = ratings.isEmpty
          ? 0.0
          : ratings.reduce((a, b) => a + b) / ratings.length;

      result.add(
        MonthlyRating(
          month: month,
          averageRating: avgRating,
          reviewCount: ratings.length,
        ),
      );
    }

    return result;
  }

  /// Calcular métricas de avaliações para um período
  Future<ReviewAnalytics> calculateAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Query para buscar agendamentos avaliados
    Query reviewsQuery = _firestore
        .collection('appointments')
        .where('isRated', isEqualTo: true);

    // Query para contar todos os agendamentos finalizados (para taxa de resposta)
    Query finishedQuery = _firestore
        .collection('appointments')
        .where('status', isEqualTo: 'finished');

    if (startDate != null) {
      reviewsQuery = reviewsQuery.where(
        'ratedAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
      finishedQuery = finishedQuery.where(
        'ratedAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }
    if (endDate != null) {
      reviewsQuery = reviewsQuery.where(
        'ratedAt',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
      finishedQuery = finishedQuery.where(
        'ratedAt',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    final reviewsSnapshot = await reviewsQuery.get();
    final finishedSnapshot = await finishedQuery.get();

    if (reviewsSnapshot.docs.isEmpty) {
      return ReviewAnalytics.empty();
    }

    // Calcular métricas
    int totalReviews = reviewsSnapshot.docs.length;
    int totalFinished = finishedSnapshot.docs.length;
    double sumRatings = 0;
    Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    Map<String, int> tagCounts = {};
    int promoters = 0; // 4-5 stars
    int detractors = 0; // 1-3 stars

    for (var doc in reviewsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final rating = data['rating'] as int? ?? 0;
      final tags =
          (data['selectedTags'] as List<dynamic>?)?.cast<String>() ?? [];

      sumRatings += rating;
      distribution[rating] = (distribution[rating] ?? 0) + 1;

      // NPS calculation
      if (rating >= 4) {
        promoters++;
      } else {
        detractors++;
      }

      // Count tags
      for (var tagId in tags) {
        tagCounts[tagId] = (tagCounts[tagId] ?? 0) + 1;
      }
    }

    double averageRating = sumRatings / totalReviews;
    double npsScore = ((promoters - detractors) / totalReviews) * 100;
    double responseRate = totalFinished > 0
        ? (totalReviews / totalFinished) * 100
        : 0;
    double positiveRate = (promoters / totalReviews) * 100;

    // Get top tags (need to fetch tag details)
    List<TagStat> topTags = [];
    if (tagCounts.isNotEmpty) {
      final tagIds = tagCounts.keys.toList();
      final tagsSnapshot = await _firestore
          .collection('reviewTags')
          .where(FieldPath.documentId, whereIn: tagIds.take(10).toList())
          .get();

      final tagMap = Map.fromEntries(
        tagsSnapshot.docs.map((doc) {
          final data = doc.data();
          return MapEntry(doc.id, {
            'label': data['label'] as String,
            'emoji': data['emoji'] as String,
          });
        }),
      );

      topTags =
          tagCounts.entries
              .map((entry) {
                final tagInfo = tagMap[entry.key];
                if (tagInfo == null) return null;
                return TagStat(
                  tagId: entry.key,
                  label: tagInfo['label']!,
                  emoji: tagInfo['emoji']!,
                  count: entry.value,
                );
              })
              .whereType<TagStat>()
              .toList()
            ..sort((a, b) => b.count.compareTo(a.count));
    }

    return ReviewAnalytics(
      averageRating: averageRating,
      totalReviews: totalReviews,
      npsScore: npsScore,
      responseRate: responseRate,
      positiveRate: positiveRate,
      ratingDistribution: distribution,
      topTags: topTags.take(10).toList(),
      totalFinishedBookings: totalFinished,
    );
  }

  /// Stream de avaliações com filtros
  Stream<List<ReviewItem>> getReviewsStream({
    DateTime? startDate,
    DateTime? endDate,
    int? minRating,
    List<String>? tagIds,
  }) {
    Query query = _firestore
        .collection('appointments')
        .where('isRated', isEqualTo: true)
        .orderBy('ratedAt', descending: true)
        .limit(100);

    if (startDate != null) {
      query = query.where(
        'ratedAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }
    if (endDate != null) {
      query = query.where(
        'ratedAt',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }
    if (minRating != null) {
      query = query.where('rating', isGreaterThanOrEqualTo: minRating);
    }

    return query.snapshots().asyncMap((snapshot) async {
      List<ReviewItem> reviews = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final selectedTags =
            (data['selectedTags'] as List<dynamic>?)?.cast<String>() ?? [];

        // Filter by tags if specified
        if (tagIds != null && tagIds.isNotEmpty) {
          if (!tagIds.any((tagId) => selectedTags.contains(tagId))) {
            continue; // Skip if none of the required tags are present
          }
        }

        reviews.add(
          ReviewItem(
            bookingId: doc.id,
            ratedAt:
                (data['ratedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            rating: data['rating'] as int? ?? 0,
            comment: data['ratingComment'] as String?,
            selectedTags: selectedTags,
            adminResponse: data['adminResponse'] as String?,
            adminResponseAt: (data['adminResponseAt'] as Timestamp?)?.toDate(),
            // These fields would require joins, we'll populate them as needed
            clientName: null,
            vehicleModel: null,
          ),
        );
      }

      return reviews;
    });
  }
}

// Providers
final reviewAnalyticsRepositoryProvider = Provider<ReviewAnalyticsRepository>((
  ref,
) {
  return ReviewAnalyticsRepository(FirebaseFirestore.instance);
});

final reviewAnalyticsProvider =
    FutureProvider.family<
      ReviewAnalytics,
      ({DateTime? startDate, DateTime? endDate})
    >((ref, params) {
      return ref
          .read(reviewAnalyticsRepositoryProvider)
          .calculateAnalytics(
            startDate: params.startDate,
            endDate: params.endDate,
          );
    });

final reviewsListProvider =
    StreamProvider.family<
      List<ReviewItem>,
      ({
        DateTime? startDate,
        DateTime? endDate,
        int? minRating,
        List<String>? tagIds,
      })
    >((ref, params) {
      return ref
          .read(reviewAnalyticsRepositoryProvider)
          .getReviewsStream(
            startDate: params.startDate,
            endDate: params.endDate,
            minRating: params.minRating,
            tagIds: params.tagIds,
          );
    });

final monthlyRatingsTrendProvider = FutureProvider<List<MonthlyRating>>((ref) {
  return ref.read(reviewAnalyticsRepositoryProvider).getMonthlyTrendLast6Months();
});
