import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/subscription_status_log.dart';
import '../domain/wash_log.dart';
import '../domain/fcm_notification_log.dart';
import '../../auth/data/auth_repository.dart';
import '../../store/data/current_store_provider.dart';

part 'analytics_repository.g.dart';

class AnalyticsRepository {
  final FirebaseFirestore _firestore;
  final String? _storeId;

  AnalyticsRepository(this._firestore, [this._storeId]);

  // ==================== SUBSCRIPTION STATUS LOGS ====================

  Future<void> logSubscriptionStatusChange({
    required String subscriptionId,
    required String userId,
    required String previousStatus,
    required String newStatus,
    String? reason,
    String? planId,
    double? planValue,
  }) async {
    final docRef = _firestore.collection('subscription_status_logs').doc();
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
    final data = log.toJson();
    if (_storeId != null) data['storeId'] = _storeId;
    await docRef.set(data);

    await _updateMonthlyAggregation(newStatus, previousStatus, planValue);
  }

  Stream<List<SubscriptionStatusLog>> getSubscriptionStatusLogs({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query query = _firestore.collection('subscription_status_logs');
    if (_storeId != null) query = query.where('storeId', isEqualTo: _storeId);

    if (startDate != null) {
      query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    return query.orderBy('timestamp', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => SubscriptionStatusLog.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id})).toList(),
        );
  }

  // ==================== WASH LOGS ====================

  Future<void> logWash({
    required String bookingId,
    required String serviceType,
    required double value,
    String? userId,
    String? planId,
    List<String>? serviceIds,
    String? vehicleType,
    String? storeId,
  }) async {
    final effectiveStoreId = storeId ?? _storeId;
    final docRef = _firestore.collection('wash_logs').doc();
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
    final data = log.toJson();
    if (effectiveStoreId != null) data['storeId'] = effectiveStoreId;
    await docRef.set(data);

    await _updateDailyWashCount(value, serviceType, effectiveStoreId);
  }

  Stream<List<WashLog>> getWashLogsToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    Query query = _firestore.collection('wash_logs').where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay));
    if (_storeId != null) query = query.where('storeId', isEqualTo: _storeId);

    return query.orderBy('timestamp', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => WashLog.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id})).toList(),
        );
  }

  Future<WashFrequencyMetrics> getWashFrequencyMetrics() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfMonth = DateTime(now.year, now.month, 1);

    Query todayQuery = _firestore.collection('wash_logs').where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay));
    if (_storeId != null) todayQuery = todayQuery.where('storeId', isEqualTo: _storeId);
    final todaySnapshot = await todayQuery.get();
    final todayLogs = todaySnapshot.docs.map((doc) => WashLog.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id})).toList();

    final subscriberWashesToday = todayLogs.where((l) => l.serviceType == 'subscription').length;
    final singleWashesToday = todayLogs.where((l) => l.serviceType == 'single').length;
    final totalRevenueToday = todayLogs.fold(0.0, (sum, l) => sum + l.value);

    Query monthQuery = _firestore.collection('wash_logs').where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth));
    if (_storeId != null) monthQuery = monthQuery.where('storeId', isEqualTo: _storeId);
    final monthSnapshot = await monthQuery.get();
    final monthLogs = monthSnapshot.docs.map((doc) => WashLog.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id})).toList();

    final subscriberLogs = monthLogs.where((l) => l.serviceType == 'subscription').toList();
    final singleLogs = monthLogs.where((l) => l.serviceType == 'single').toList();
    final subscriberUsers = subscriberLogs.map((l) => l.userId).where((u) => u != null).toSet();
    final singleUsers = singleLogs.map((l) => l.userId).where((u) => u != null).toSet();

    final subscriberAverage = subscriberUsers.isNotEmpty ? subscriberLogs.length / subscriberUsers.length : 0.0;
    final nonSubscriberAverage = singleUsers.isNotEmpty ? singleLogs.length / singleUsers.length : 0.0;

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

  Future<void> logFcmNotification({
    required String userId,
    required String notificationType,
    String? bookingId,
    String? title,
    String? body,
  }) async {
    final docRef = _firestore.collection('fcm_notification_logs').doc();
    final log = FcmNotificationLog(
      id: docRef.id,
      userId: userId,
      notificationType: notificationType,
      bookingId: bookingId,
      sentAt: DateTime.now(),
      title: title,
      body: body,
    );
    final data = log.toJson();
    if (_storeId != null) data['storeId'] = _storeId;
    await docRef.set(data);

    await _updateMonthlyFcmCount();
  }

  Stream<List<FcmNotificationLog>> getFcmLogsThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    Query query = _firestore.collection('fcm_notification_logs').where('sentAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth));
    if (_storeId != null) query = query.where('storeId', isEqualTo: _storeId);

    return query.orderBy('sentAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => FcmNotificationLog.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id})).toList(),
        );
  }

  Future<FcmEfficiencyMetrics> getFcmEfficiencyMetrics() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    Query query = _firestore.collection('fcm_notification_logs').where('sentAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth));
    if (_storeId != null) query = query.where('storeId', isEqualTo: _storeId);
    final snapshot = await query.get();
    final logs = snapshot.docs.map((doc) => FcmNotificationLog.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id})).toList();
    return FcmEfficiencyMetrics.fromLogs(logs);
  }

  // ==================== AGGREGATION HELPERS ====================

  Future<void> _updateMonthlyAggregation(String newStatus, String previousStatus, double? planValue) async {
    final now = DateTime.now();
    final monthKey = 'monthly_${now.year}-${now.month.toString().padLeft(2, '0')}${_storeId != null ? '_$_storeId' : ''}';
    final docRef = _firestore.collection('aggregated_metrics').doc(monthKey);

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
        'storeId': _storeId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> _updateDailyWashCount(double value, String serviceType, [String? storeId]) async {
    final now = DateTime.now();
    final effectiveStoreId = storeId ?? _storeId;
    final monthKey = 'monthly_${now.year}-${now.month.toString().padLeft(2, '0')}${effectiveStoreId != null ? '_$effectiveStoreId' : ''}';
    final docRef = _firestore.collection('aggregated_metrics').doc(monthKey);

    await docRef.set({
      'washCount': FieldValue.increment(1),
      'washRevenue': FieldValue.increment(value),
      'storeId': effectiveStoreId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _updateMonthlyFcmCount() async {
    final now = DateTime.now();
    final monthKey = 'monthly_${now.year}-${now.month.toString().padLeft(2, '0')}${_storeId != null ? '_$_storeId' : ''}';
    final docRef = _firestore.collection('aggregated_metrics').doc(monthKey);

    await docRef.set({
      'fcmNotificationCount': FieldValue.increment(1),
      'storeId': _storeId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> getMonthlyAggregatedMetrics({int? year, int? month}) async {
    final now = DateTime.now();
    year ??= now.year;
    month ??= now.month;
    final monthKey = 'monthly_$year-${month.toString().padLeft(2, '0')}${_storeId != null ? '_$_storeId' : ''}';
    final doc = await _firestore.collection('aggregated_metrics').doc(monthKey).get();
    return doc.data() ?? {};
  }
}

@Riverpod(keepAlive: true)
AnalyticsRepository analyticsRepository(AnalyticsRepositoryRef ref) {
  final currentStore = ref.watch(currentStoreProvider).value;
  return AnalyticsRepository(FirebaseFirestore.instance, currentStore?.id);
}

@riverpod
Stream<List<WashLog>> washLogsToday(WashLogsTodayRef ref) {
  return ref.watch(analyticsRepositoryProvider).getWashLogsToday();
}

@riverpod
Stream<List<FcmNotificationLog>> fcmLogsThisMonth(FcmLogsThisMonthRef ref) {
  return ref.watch(analyticsRepositoryProvider).getFcmLogsThisMonth();
}

@riverpod
Future<WashFrequencyMetrics> washFrequencyMetrics(WashFrequencyMetricsRef ref) {
  return ref.watch(analyticsRepositoryProvider).getWashFrequencyMetrics();
}

@riverpod
Future<FcmEfficiencyMetrics> fcmEfficiencyMetrics(FcmEfficiencyMetricsRef ref) {
  return ref.watch(analyticsRepositoryProvider).getFcmEfficiencyMetrics();
}
