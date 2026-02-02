import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionStatus {
  active,
  pastDue,
  canceled,
  trialing,
  incomplete,
  unknown,
}

class Subscription {
  final String id;
  final SubscriptionStatus status;
  final DateTime? currentPeriodEnd;
  final String? planId;

  const Subscription({
    required this.id,
    required this.status,
    this.currentPeriodEnd,
    this.planId,
  });

  bool get isActive =>
      status == SubscriptionStatus.active ||
      status == SubscriptionStatus.trialing;

  /// Returns true if the subscription is technically active but needs attention
  bool get isWarningState => status == SubscriptionStatus.pastDue;

  factory Subscription.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists) return Subscription.empty();

    final data = doc.data() as Map<String, dynamic>;
    return Subscription(
      id: doc.id,
      status: _mapStatus(data['status']),
      currentPeriodEnd: (data['currentPeriodEnd'] as Timestamp?)?.toDate(),
      planId: data['planId'],
    );
  }

  factory Subscription.empty() =>
      const Subscription(id: '', status: SubscriptionStatus.unknown);

  static SubscriptionStatus _mapStatus(String? status) {
    switch (status) {
      case 'active':
        return SubscriptionStatus.active;
      case 'past_due':
        return SubscriptionStatus.pastDue;
      case 'canceled':
        return SubscriptionStatus.canceled;
      case 'trialing':
        return SubscriptionStatus.trialing;
      case 'incomplete':
        return SubscriptionStatus.incomplete;
      default:
        return SubscriptionStatus.unknown;
    }
  }
}
