import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/data/auth_repository.dart';
import '../../subscription/domain/subscriber.dart';
import '../../subscription/domain/subscription_plan.dart';

part 'subscription_metrics_provider.g.dart';

/// Holds subscription-related metrics for the dashboard
class SubscriptionMetrics {
  final int activeSubscribers;
  final double mrr; // Monthly Recurring Revenue
  final double churnRate; // (cancelados / total início) * 100
  final double conversionRate; // avulsos -> assinantes (30 dias)
  final int delinquent; // past_due count
  final List<MonthlySubscriberGrowth> growthLast6Months;
  final double mrrChangePercent;
  final int newSubscribersThisMonth;
  final int canceledThisMonth;

  const SubscriptionMetrics({
    required this.activeSubscribers,
    required this.mrr,
    required this.churnRate,
    required this.conversionRate,
    required this.delinquent,
    required this.growthLast6Months,
    required this.mrrChangePercent,
    required this.newSubscribersThisMonth,
    required this.canceledThisMonth,
  });

  static const empty = SubscriptionMetrics(
    activeSubscribers: 0,
    mrr: 0,
    churnRate: 0,
    conversionRate: 0,
    delinquent: 0,
    growthLast6Months: [],
    mrrChangePercent: 0,
    newSubscribersThisMonth: 0,
    canceledThisMonth: 0,
  );
}

/// Represents subscriber count for a specific month
class MonthlySubscriberGrowth {
  final int year;
  final int month;
  final int subscriberCount;

  const MonthlySubscriberGrowth({
    required this.year,
    required this.month,
    required this.subscriberCount,
  });

  String get monthLabel {
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    return months[month - 1];
  }
}

/// Provider for subscription metrics
@riverpod
Stream<SubscriptionMetrics> subscriptionMetrics(Ref ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  // Stream all active subscriptions
  return firestore.collection('subscriptions').snapshots().asyncMap((
    subsSnapshot,
  ) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    // Parse all subscriptions
    final allSubscriptions = subsSnapshot.docs.map((doc) {
      return Subscriber.fromJson({...doc.data(), 'id': doc.id});
    }).toList();

    // Count active and delinquent
    final activeSubscriptions = allSubscriptions
        .where((s) => s.status == 'active' || s.status == 'trialing')
        .toList();
    final delinquent = allSubscriptions
        .where((s) => s.status == 'past_due')
        .length;

    // Get plans to calculate MRR
    final plansSnapshot = await firestore.collection('plans').get();
    final plans = <String, SubscriptionPlan>{};
    for (final doc in plansSnapshot.docs) {
      final plan = SubscriptionPlan.fromJson({...doc.data(), 'id': doc.id});
      plans[plan.id] = plan;
    }

    // Calculate MRR
    double mrr = 0;
    for (final sub in activeSubscriptions) {
      final plan = plans[sub.planId];
      if (plan != null) {
        mrr += plan.price;
      }
    }

    // Get subscription status logs for this month (for churn calculation)
    final logsSnapshot = await firestore
        .collection('subscription_status_logs')
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        )
        .get();

    int newSubscribers = 0;
    int canceledSubscribers = 0;
    for (final doc in logsSnapshot.docs) {
      final data = doc.data();
      final newStatus = data['newStatus'] as String? ?? '';
      final previousStatus = data['previousStatus'] as String? ?? '';

      if (newStatus == 'active' && previousStatus != 'active') {
        newSubscribers++;
      } else if (newStatus == 'canceled' && previousStatus == 'active') {
        canceledSubscribers++;
      }
    }

    // Calculate churn rate
    // (Cancelled this month / Active at start of month) * 100
    // We approximate "active at start" as current - new + canceled
    final activeAtStart =
        activeSubscriptions.length - newSubscribers + canceledSubscribers;
    final churnRate = activeAtStart > 0
        ? (canceledSubscribers / activeAtStart) * 100
        : 0.0;

    // Calculate conversion rate (users who did single wash -> became subscribers in 30 days)
    // This requires comparing wash_logs with subscription_status_logs
    // For efficiency, we'll use the aggregated metrics or estimate
    final conversionRate = await _calculateConversionRate(firestore);

    // Get subscriber growth for last 6 months
    final growthData = await _getSubscriberGrowthLast6Months(firestore);

    // Calculate MRR change from previous month
    final previousMonthKey =
        'monthly_${now.year}-${(now.month - 1).toString().padLeft(2, '0')}';
    final previousAggDoc = await firestore
        .collection('aggregated_metrics')
        .doc(previousMonthKey)
        .get();
    final previousMrr = (previousAggDoc.data()?['mrr'] ?? 0).toDouble();
    final mrrChangePercent = previousMrr > 0
        ? ((mrr - previousMrr) / previousMrr) * 100
        : (mrr > 0 ? 100.0 : 0.0);

    return SubscriptionMetrics(
      activeSubscribers: activeSubscriptions.length,
      mrr: mrr,
      churnRate: churnRate,
      conversionRate: conversionRate,
      delinquent: delinquent,
      growthLast6Months: growthData,
      mrrChangePercent: mrrChangePercent,
      newSubscribersThisMonth: newSubscribers,
      canceledThisMonth: canceledSubscribers,
    );
  });
}

Future<double> _calculateConversionRate(FirebaseFirestore firestore) async {
  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));

  try {
    // Get users who did single washes in the last 30 days
    final singleWashSnapshot = await firestore
        .collection('wash_logs')
        .where('serviceType', isEqualTo: 'single')
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo),
        )
        .get();

    final singleWashUsers = singleWashSnapshot.docs
        .map((doc) => doc.data()['userId'] as String?)
        .where((u) => u != null)
        .cast<String>()
        .toSet();

    if (singleWashUsers.isEmpty) return 0.0;

    // Check how many of these users became subscribers
    final newSubsSnapshot = await firestore
        .collection('subscription_status_logs')
        .where('newStatus', isEqualTo: 'active')
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo),
        )
        .get();

    final newSubsUsers = newSubsSnapshot.docs
        .map((doc) => doc.data()['userId'] as String?)
        .where((u) => u != null)
        .cast<String>()
        .toSet();

    final convertedUsers = singleWashUsers.intersection(newSubsUsers);
    return (convertedUsers.length / singleWashUsers.length) * 100;
  } catch (e) {
    // If collections don't exist yet, return 0
    return 0.0;
  }
}

Future<List<MonthlySubscriberGrowth>> _getSubscriberGrowthLast6Months(
  FirebaseFirestore firestore,
) async {
  final now = DateTime.now();
  final growthData = <MonthlySubscriberGrowth>[];

  for (int i = 5; i >= 0; i--) {
    final monthDate = DateTime(now.year, now.month - i, 1);
    final monthKey =
        'monthly_${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}';

    try {
      final doc = await firestore
          .collection('aggregated_metrics')
          .doc(monthKey)
          .get();
      final data = doc.data();
      final count = data?['activeSubscribersEnd'] ?? 0;

      growthData.add(
        MonthlySubscriberGrowth(
          year: monthDate.year,
          month: monthDate.month,
          subscriberCount: count is int ? count : (count as num).toInt(),
        ),
      );
    } catch (e) {
      // If document doesn't exist, add zero
      growthData.add(
        MonthlySubscriberGrowth(
          year: monthDate.year,
          month: monthDate.month,
          subscriberCount: 0,
        ),
      );
    }
  }

  return growthData;
}

/// Provider to get the current active subscriber count (efficient single query)
@riverpod
Stream<int> activeSubscriberCount(Ref ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('subscriptions')
      .where('status', whereIn: ['active', 'trialing'])
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
}
