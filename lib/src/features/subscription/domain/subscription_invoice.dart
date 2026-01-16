import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_invoice.freezed.dart';
part 'subscription_invoice.g.dart';

@freezed
sealed class SubscriptionInvoice with _$SubscriptionInvoice {
  const factory SubscriptionInvoice({
    required String id,
    required int amountPaid,
    required int created,
    required String status,
    String? invoicePdf,
    String? paymentMethodBrand,
    String? paymentMethodLast4,
  }) = _SubscriptionInvoice;

  factory SubscriptionInvoice.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionInvoiceFromJson(json);
}
