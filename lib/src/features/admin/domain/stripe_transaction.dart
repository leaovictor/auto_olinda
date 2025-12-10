import 'package:freezed_annotation/freezed_annotation.dart';

part 'stripe_transaction.freezed.dart';
part 'stripe_transaction.g.dart';

/// Represents a Stripe transaction (charge) for financial reporting.
@freezed
abstract class StripeTransaction with _$StripeTransaction {
  const factory StripeTransaction({
    required String id,
    String? customerId,
    String? customerEmail,
    required double amount,
    required String currency,
    required String status,
    String? description,
    required int createdAt,
    required bool paid,
    required bool refunded,
    String? receiptUrl,
  }) = _StripeTransaction;

  factory StripeTransaction.fromJson(Map<String, dynamic> json) =>
      _$StripeTransactionFromJson(json);
}
