import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/subscription_status_log.dart';
import '../domain/wash_log.dart';
import '../domain/fcm_notification_log.dart';
import '../../auth/data/auth_repository.dart';
import '../../../core/firestore/tenant_firestore.dart';

part 'analytics_repository.g.dart';

/// Repository for analytics data: subscription logs, wash logs, FCM logs.
/// Uses efficient Firestore queries and aggregation to minimize read costs.
class AnalyticsRepository {
  final FirebaseFirestore _firestore;
  final String tenantId;

  AnalyticsRepository(this._firestore, {this.tenantId = ''});

  // ==================== SUBSCRIPTION STATUS LOGS ====================

  /// Log a subscription status change
  Future<void> logSubscriptionStatusChange({
    required String subscriptionId,
    required String userId,
    required String previousStatus,
    required String newStatus,
    String? reason,
    String? planId,
    double? planValue,
  }) async {
    final colRef = tenantId.isNotEmpty
        ? _firestore.tenantCol(tenantId, 'subscription_status_logs')
        : _firestore.collection('subscription_status_logs');
    final docRef = colRef.doc();
    final log = SubscriptionStatusLog(
      id: docRef.id,
      subscriptionId: subscriptionId,
      userId: userId,
      previousStatus: previousStatus,
      newStatus: newStatus,
      timestamp: DateTime.now(),
      reason: reason,
      planId: planId,
      planValue: planValue,
    );
    await docRef.set(log.toJson());

    // Update aggregated metrics
    await _updateMonthlyAggregation(newStatus, previousStatus, planValue);
  }

  /// Get subscription status logs for a date range
  Stream<List<SubscriptionStatusLog>> getSubscriptionStatusLogs({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query query = tenantId.isNotEmpty
        ? _firestore.tenantCol(tenantId, 'subscription_status_logs')
        : _firestore.collection('subscription_status_logs');

    if (startDate != null) {
      query = query.where(
        'timestamp',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }
    if (endDate != null) {
      query = query.where(
        'timestamp',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    return query
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => SubscriptionStatusLog.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }),
              )
              .toList(),
        );
  }

  // ==================== WASH LOGS ====================

  /// Log a wash completion
  Future<void> logWash({
    required String bookingId,
    required String serviceType,
    required double value,
    String? userId,
    String? planId,
    List<String>? serviceIds,
    String? vehicleType,
  }) async {
    final colRef = tenantId.isNotEmpty
        ? _firestore.tenantCol(tenantId, 'wash_logs')
        : _firestore.collection('wash_logs');
    final docRef = colRef.doc();
    final log = WashLog(
      id: docRef.id,
      userId: userId,
      bookingId: bookingId,
      serviceType: serviceType,
      value: value,
      timestamp: DateTime.now(),
      planId: planId,
      serviceIds: serviceIds ?? [],
      vehicleType: vehicleType,
    );
    await docRef.set(log.toJson());

    // Update today's wash count in aggregation
    await _updateDailyWashCount(value, serviceType);
  }

  /// Get wash logs for today
  Stream<List<WashLog>> getWashLogsToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final col = tenantId.isNotEmpty
        ? _firestore.tenantCol(tenantId, 'wash_logs')
        : _firestore.collection('wash_logs');
    return col
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WashLog.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  /// Get wash frequency metrics
  Future<WashFrequencyMetrics> getWashFrequencyMetrics() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfMonth = DateTime(now.year, now.month, 1);
    final col = tenantId.isNotEmpty
        ? _firestore.tenantCol(tenantId, 'wash_logs')
        : _firestore.collection('wash_logs');

    final todaySnapshot = await col
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .get();

    final todayLogs = todaySnapshot.docs
        .map((doc) => WashLog.fromJson({...doc.data(), 'id': doc.id}))
        .toList();

    final subscriberWashesToday = todayLogs
        .where((l) => l.serviceType == 'subscription')
        .length;
    final singleWashesToday = todayLogs
        .where((l) => l.serviceType == 'single')
        .length;
    final totalRevenueToday = todayLogs.fold(0.0, (sum, l) => sum + l.value);

    // Get this month's washes for averages
    final monthSnapshot = await col
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        )
        .get();

    final monthLogs = monthSnapshot.docs
        .map((doc) => WashLog.fromJson({...doc.data(), 'id': doc.id}))
        .toList();

    // Calculate averages (per unique user)
    final subscriberLogs = monthLogs
        .where((l) => l.serviceType == 'subscription')
        .toList();
    final singleLogs = monthLogs
        .where((l) => l.serviceType == 'single')
        .toList();

    final subscriberUsers = subscriberLogs
        .map((l) => l.userId)
        .where((u) => u != null)
        .toSet();
    final singleUsers = singleLogs
        .map((l) => l.userId)
        .where((u) => u != null)
        .toSet();

    final subscriberAverage = subscriberUsers.isNotEmpty
        ? subscriberLogs.length / subscriberUsers.length
        : 0.0;
    final nonSubscriberAverage = singleUsers.isNotEmpty
        ? singleLogs.length / singleUsers.length
        : 0.0;

    return WashFrequencyMetrics(
      subscriberAverage: subscriberAverage,
      nonSubscriberAverage: nonSubscriberAverage,
      totalWashesToday: todayLogs.length,
      subscriberWashesToday: subscriberWashesToday,
      singleWashesToday: singleWashesToday,
      totalRevenueToday: totalRevenueToday,
    );
  }

  // ==================== FCM NOTIFICATION LOGS ====================

  /// Log an FCM notification
  Future<void> logFcmNotification({
    required String userId,
    required String notificationType,
    String? bookingId,
    String? title,
    String? body,
  }) async {
    final colRef = tenantId.isNotEmpty
        ? _firestore.tenantCol(tenantId, 'fcm_notification_logs')
        : _firestore.collection('fcm_notification_logs');
    final docRef = colRef.doc();
    final log = FcmNotificationLog(
      id: docRef.id,
      userId: userId,
      notificationType: notificationType,
      bookingId: bookingId,
      sentAt: DateTime.now(),
      title: title,
      body: body,
    );
    await docRef.set(log.toJson());

    // Update monthly FCM count
    await _updateMonthlyFcmCount();
  }

  /// Get FCM logs for the current month
  Stream<List<FcmNotificationLog>> getFcmLogsThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final col = tenantId.isNotEmpty
        ? _firestore.tenantCol(tenantId, 'fcm_notification_logs')
        : _firestore.collection('fcm_notification_logs');
    return col
        .where(
          'sentAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        )
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    FcmNotificationLog.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  /// Get FCM efficiency metrics for the current month
  Future<FcmEfficiencyMetrics> getFcmEfficiencyMetrics() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final col = tenantId.isNotEmpty
        ? _firestore.tenantCol(tenantId, 'fcm_notification_logs')
        : _firestore.collection('fcm_notification_logs');
    final snapshot = await col
        .where(
          'sentAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        )
        .get();

    final logs = snapshot.docs
        .map(
          (doc) => FcmNotificationLog.fromJson({...doc.data(), 'id': doc.id}),
        )
        .toList();

    return FcmEfficiencyMetrics.fromLogs(logs);
  }

  // ==================== AGGREGATION HELPERS ====================

  Future<void> _updateMonthlyAggregation(
    String newStatus,
    String previousStatus,
    double? planValue,
  ) async {
    final now = DateTime.now();
    final monthKey =
        'monthly_${now.year}-${now.month.toString().padLeft(2, '0')}';
    final col = tenantId.isNotEmpty
        ? _firestore.tenantCol(tenantId, 'aggregated_metrics')
        : _firestore.collection('aggregated_metrics');
    final docRef = col.doc(monthKey);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      final data = doc.data() ?? {};

      int newSubscriptions = data['newSubscriptions'] ?? 0;
      int canceledSubscriptions = data['canceledSubscriptions'] ?? 0;
      double mrr = (data['mrr'] ?? 0).toDouble();

      if (newStatus == 'active' && previousStatus != 'active') {
        newSubscriptions++;
        if (planValue != null) mrr += planValue;
      } else if (newStatus == 'canceled' && previousStatus == 'active') {
        canceledSubscriptions++;
        if (planValue != null) mrr -= planValue;
      }

      transaction.set(docRef, {
        ...data,
        'newSubscriptions': newSubscriptions,
        'canceledSubscriptions': canceledSubscriptions,
        'mrr': mrr,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> _updateDailyWashCount(double value, String serviceType) async {
    final now = DateTime.now();
    final monthKey =
        'monthly_${now.year}-${now.month.toString().padLeft(2, '0')}';
    final col = tenantId.isNotEmpty
        ? _firestore.tenantCol(tenantId, 'aggregated_metrics')
        : _firestore.collection('aggregated_metrics');
    await col.doc(monthKey).set({
      'washCount': FieldValue.increment(1),
      'washRevenue': FieldValue.increment(value),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _updateMonthlyFcmCount() async {
    final now = DateTime.now();
    final monthKey =
        'monthly_${now.year}-${now.month.toString().padLeft(2, '0')}';
    final col = tenantId.isNotEmpty
        ? _firestore.tenantCol(tenantId, 'aggregated_metrics')
        : _firestore.collection('aggregated_metrics');
    await col.doc(monthKey).set({
      'fcmNotificationCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Get aggregated metrics for a month (efficient - single read)
  Future<Map<String, dynamic>> getMonthlyAggregatedMetrics({
    int? year,
    int? month,
  }) async {
    final now = DateTime.now();
    year ??= now.year;
    month ??= now.month;
    final monthKey = 'monthly_$year-${month.toString().padLeft(2, '0')}';
    final col = tenantId.isNotEmpty
        ? _firestore.tenantCol(tenantId, 'aggregated_metrics')
        : _firestore.collection('aggregated_metrics');
    final doc = await col.doc(monthKey).get();
    return doc.data() ?? {};
  }
}

@Riverpod(keepAlive: true)
AnalyticsRepository analyticsRepository(Ref ref) {
  final tenantId =
      ref.watch(currentUserProfileProvider).valueOrNull?.tenantId ?? '';
  return AnalyticsRepository(
    ref.watch(firebaseFirestoreProvider),
    tenantId: tenantId,
  );
}

@riverpod
Stream<List<WashLog>> washLogsToday(Ref ref) {
  return ref.watch(analyticsRepositoryProvider).getWashLogsToday();
}

@riverpod
Stream<List<FcmNotificationLog>> fcmLogsThisMonth(Ref ref) {
  return ref.watch(analyticsRepositoryProvider).getFcmLogsThisMonth();
}

@riverpod
Future<WashFrequencyMetrics> washFrequencyMetrics(Ref ref) {
  return ref.watch(analyticsRepositoryProvider).getWashFrequencyMetrics();
}

@riverpod
Future<FcmEfficiencyMetrics> fcmEfficiencyMetrics(Ref ref) {
  return ref.watch(analyticsRepositoryProvider).getFcmEfficiencyMetrics();
}
