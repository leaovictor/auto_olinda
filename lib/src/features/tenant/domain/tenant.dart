import 'package:lavaflow_app/src/shared/utils/timestamp_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tenant.freezed.dart';
part 'tenant.g.dart';

@freezed
abstract class Tenant with _$Tenant {
  const factory Tenant({
    required String id,
    required String name,
    required String slug,
    required String ownerId,
    String? stripeCustomerId,
    required TenantBranding branding,
    required TenantDomains domains,
    @TimestampConverter() DateTime? createdAt,
  }) = _Tenant;

  factory Tenant.fromJson(Map<String, dynamic> json) => _$TenantFromJson(json);
}

@freezed
abstract class TenantBranding with _$TenantBranding {
  const factory TenantBranding({
    String? logoUrl,
    required String primaryColor,
  }) = _TenantBranding;

  factory TenantBranding.fromJson(Map<String, dynamic> json) =>
      _$TenantBrandingFromJson(json);
}

@freezed
abstract class TenantDomains with _$TenantDomains {
  const factory TenantDomains({
    required String subdomain,
    String? customDomain,
    @Default(false) bool domainVerified,
  }) = _TenantDomains;

  factory TenantDomains.fromJson(Map<String, dynamic> json) =>
      _$TenantDomainsFromJson(json);
}
