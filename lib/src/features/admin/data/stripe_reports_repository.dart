import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/stripe_subscription.dart';
import '../domain/stripe_transaction.dart';

part 'stripe_reports_repository.g.dart';

/// Repository for fetching Stripe data for financial reports.
class StripeReportsRepository {
  final FirebaseFunctions _functions;

  StripeReportsRepository({FirebaseFunctions? functions})
    : _functions =
          functions ??
          FirebaseFunctions.instanceFor(region: 'southamerica-east1');

  /// Fetches list of Stripe subscriptions.
  /// [status] - Optional filter: 'active', 'canceled', 'past_due', etc.
  /// [limit] - Maximum number of results (max 100).
  /// [startingAfter] - Pagination cursor (last subscription ID).
  Future<StripeSubscriptionsResult> getSubscriptions({
    String? status,
    int limit = 100,
    String? startingAfter,
  }) async {
    final callable = _functions.httpsCallable('getStripeSubscriptions');
    final result = await callable.call({
      'status': status,
      'limit': limit,
      'startingAfter': startingAfter,
    });

    final data = result.data as Map<String, dynamic>;
    final subscriptions = (data['subscriptions'] as List)
        .map((e) => StripeSubscription.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return StripeSubscriptionsResult(
      subscriptions: subscriptions,
      hasMore: data['hasMore'] ?? false,
      lastId: data['lastId'],
    );
  }

  /// Fetches list of Stripe transactions (charges).
  /// [startDate] - Optional filter start date.
  /// [endDate] - Optional filter end date.
  /// [limit] - Maximum number of results (max 100).
  /// [startingAfter] - Pagination cursor (last transaction ID).
  Future<StripeTransactionsResult> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
    String? startingAfter,
  }) async {
    final callable = _functions.httpsCallable('getStripeTransactions');
    final result = await callable.call({
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'limit': limit,
      'startingAfter': startingAfter,
    });

    final data = result.data as Map<String, dynamic>;
    final transactions = (data['transactions'] as List)
        .map((e) => StripeTransaction.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return StripeTransactionsResult(
      transactions: transactions,
      hasMore: data['hasMore'] ?? false,
      lastId: data['lastId'],
    );
  }
}

/// Result class for subscriptions query with pagination info.
class StripeSubscriptionsResult {
  final List<StripeSubscription> subscriptions;
  final bool hasMore;
  final String? lastId;

  StripeSubscriptionsResult({
    required this.subscriptions,
    required this.hasMore,
    this.lastId,
  });
}

/// Result class for transactions query with pagination info.
class StripeTransactionsResult {
  final List<StripeTransaction> transactions;
  final bool hasMore;
  final String? lastId;

  StripeTransactionsResult({
    required this.transactions,
    required this.hasMore,
    this.lastId,
  });
}

@Riverpod(keepAlive: true)
StripeReportsRepository stripeReportsRepository(Ref ref) {
  return StripeReportsRepository();
}

@riverpod
Future<StripeSubscriptionsResult> stripeSubscriptions(
  Ref ref, {
  String? status,
}) async {
  final repository = ref.watch(stripeReportsRepositoryProvider);
  return repository.getSubscriptions(status: status);
}

@riverpod
Future<StripeTransactionsResult> stripeTransactions(
  Ref ref, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final repository = ref.watch(stripeReportsRepositoryProvider);
  return repository.getTransactions(startDate: startDate, endDate: endDate);
}
