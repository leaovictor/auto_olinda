// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_license.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StoreLicense _$StoreLicenseFromJson(Map<String, dynamic> json) =>
    _StoreLicense(
      storeId: json['storeId'] as String,
      storeName: json['storeName'] as String,
      ownerName: json['ownerName'] as String? ?? '',
      ownerEmail: json['ownerEmail'] as String? ?? '',
      ownerPhone: json['ownerPhone'] as String? ?? '',
      modalidade: json['modalidade'] as String? ?? 'anual',
      status: json['status'] as String? ?? 'trial',
      trialEndsAt: const TimestampConverter().fromJson(json['trialEndsAt']),
      licenseStartDate: const TimestampConverter().fromJson(
        json['licenseStartDate'],
      ),
      licenseExpiresAt: const TimestampConverter().fromJson(
        json['licenseExpiresAt'],
      ),
      royaltiesPercentage:
          (json['royaltiesPercentage'] as num?)?.toDouble() ?? 15.0,
      lastRoyaltiesPaymentAt: const TimestampConverter().fromJson(
        json['lastRoyaltiesPaymentAt'],
      ),
      contractSignedAt: const TimestampConverter().fromJson(
        json['contractSignedAt'],
      ),
      contractValue: (json['contractValue'] as num?)?.toDouble() ?? 15000.0,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      notes: json['notes'] as String? ?? '',
    );

Map<String, dynamic> _$StoreLicenseToJson(_StoreLicense instance) =>
    <String, dynamic>{
      'storeId': instance.storeId,
      'storeName': instance.storeName,
      'ownerName': instance.ownerName,
      'ownerEmail': instance.ownerEmail,
      'ownerPhone': instance.ownerPhone,
      'modalidade': instance.modalidade,
      'status': instance.status,
      'trialEndsAt': _$JsonConverterToJson<dynamic, DateTime>(
        instance.trialEndsAt,
        const TimestampConverter().toJson,
      ),
      'licenseStartDate': _$JsonConverterToJson<dynamic, DateTime>(
        instance.licenseStartDate,
        const TimestampConverter().toJson,
      ),
      'licenseExpiresAt': _$JsonConverterToJson<dynamic, DateTime>(
        instance.licenseExpiresAt,
        const TimestampConverter().toJson,
      ),
      'royaltiesPercentage': instance.royaltiesPercentage,
      'lastRoyaltiesPaymentAt': _$JsonConverterToJson<dynamic, DateTime>(
        instance.lastRoyaltiesPaymentAt,
        const TimestampConverter().toJson,
      ),
      'contractSignedAt': _$JsonConverterToJson<dynamic, DateTime>(
        instance.contractSignedAt,
        const TimestampConverter().toJson,
      ),
      'contractValue': instance.contractValue,
      'createdAt': _$JsonConverterToJson<dynamic, DateTime>(
        instance.createdAt,
        const TimestampConverter().toJson,
      ),
      'updatedAt': _$JsonConverterToJson<dynamic, DateTime>(
        instance.updatedAt,
        const TimestampConverter().toJson,
      ),
      'notes': instance.notes,
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
