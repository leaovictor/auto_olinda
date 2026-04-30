import 'package:freezed_annotation/freezed_annotation.dart';

part 'tenant.freezed.dart';
part 'tenant.g.dart';

@freezed
abstract class Tenant with _$Tenant {
  const factory Tenant({
    required String id,
    required String name,
    required String ownerUid,
    @Default('active') String status, // active | suspended | cancelled
    @Default('starter') String plan,  // starter | pro | enterprise
    String? logoUrl,
    @Default('#1A73E8') String primaryColor,
    String? stripeConnectAccountId,
    @Default(false) bool stripeConnectOnboarded,
    @Default(5) int platformFeePercent,
    String? phone,
    String? address,
    String? city,
    String? state,
    Map<String, dynamic>? settings, // openingHours, maxSlotsPerHour, etc.
  }) = _Tenant;

  factory Tenant.fromJson(Map<String, dynamic> json) => _$TenantFromJson(json);
}
