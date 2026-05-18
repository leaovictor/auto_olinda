import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:laavei_mobile/src/shared/utils/timestamp_converter.dart';

part 'store_license.freezed.dart';
part 'store_license.g.dart';

/// Represents a lavajato's software license issued by Victor (the founder).
/// Document path: /store_licenses/{storeId}
@freezed
abstract class StoreLicense with _$StoreLicense {
  const factory StoreLicense({
    required String storeId,
    required String storeName,
    @Default('') String ownerName,
    @Default('') String ownerEmail,
    @Default('') String ownerPhone,

    /// 'anual' | 'royalties'
    @Default('anual') String modalidade,

    /// 'active' | 'expired' | 'suspended' | 'trial'
    @Default('trial') String status,

    @TimestampConverter() DateTime? trialEndsAt,
    @TimestampConverter() DateTime? licenseStartDate,
    @TimestampConverter() DateTime? licenseExpiresAt,

    // Royalties
    @Default(15.0) double royaltiesPercentage,
    @TimestampConverter() DateTime? lastRoyaltiesPaymentAt,

    // Contract
    @TimestampConverter() DateTime? contractSignedAt,
    @Default(15000.0) double contractValue,

    // Metadata
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @Default('') String notes,
  }) = _StoreLicense;

  factory StoreLicense.fromJson(Map<String, dynamic> json) =>
      _$StoreLicenseFromJson(json);
}

extension StoreLicenseX on StoreLicense {
  bool get isActive => status == 'active' || status == 'trial';

  bool get isExpired {
    if (status == 'expired' || status == 'suspended') return true;
    if (status == 'trial' && trialEndsAt != null) {
      return DateTime.now().isAfter(trialEndsAt!);
    }
    if (status == 'active' && licenseExpiresAt != null) {
      return DateTime.now().isAfter(licenseExpiresAt!);
    }
    return false;
  }

  int? get daysUntilExpiry {
    final expiry = licenseExpiresAt ?? trialEndsAt;
    if (expiry == null) return null;
    return expiry.difference(DateTime.now()).inDays;
  }

  String get statusLabel {
    switch (status) {
      case 'active':
        return 'Ativa';
      case 'trial':
        return 'Período Trial';
      case 'expired':
        return 'Expirada';
      case 'suspended':
        return 'Suspensa';
      default:
        return status;
    }
  }

  String get modalidadeLabel {
    switch (modalidade) {
      case 'anual':
        return 'Licença Anual';
      case 'royalties':
        return 'Royalties (${royaltiesPercentage.toInt()}%)';
      default:
        return modalidade;
    }
  }
}
