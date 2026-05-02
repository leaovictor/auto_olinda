// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubscriptionInvoice _$SubscriptionInvoiceFromJson(Map<String, dynamic> json) =>
    _SubscriptionInvoice(
      id: json['id'] as String,
      amountPaid: (json['amountPaid'] as num).toInt(),
      created: (json['created'] as num).toInt(),
      status: json['status'] as String,
      invoicePdf: json['invoicePdf'] as String?,
      paymentMethodBrand: json['paymentMethodBrand'] as String?,
      paymentMethodLast4: json['paymentMethodLast4'] as String?,
    );

Map<String, dynamic> _$SubscriptionInvoiceToJson(
  _SubscriptionInvoice instance,
) => <String, dynamic>{
  'id': instance.id,
  'amountPaid': instance.amountPaid,
  'created': instance.created,
  'status': instance.status,
  'invoicePdf': instance.invoicePdf,
  'paymentMethodBrand': instance.paymentMethodBrand,
  'paymentMethodLast4': instance.paymentMethodLast4,
};
