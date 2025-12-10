// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stripe_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StripeTransaction _$StripeTransactionFromJson(Map<String, dynamic> json) =>
    _StripeTransaction(
      id: json['id'] as String,
      customerId: json['customerId'] as String?,
      customerEmail: json['customerEmail'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      description: json['description'] as String?,
      createdAt: (json['createdAt'] as num).toInt(),
      paid: json['paid'] as bool,
      refunded: json['refunded'] as bool,
      receiptUrl: json['receiptUrl'] as String?,
    );

Map<String, dynamic> _$StripeTransactionToJson(_StripeTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'customerEmail': instance.customerEmail,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.status,
      'description': instance.description,
      'createdAt': instance.createdAt,
      'paid': instance.paid,
      'refunded': instance.refunded,
      'receiptUrl': instance.receiptUrl,
    };
