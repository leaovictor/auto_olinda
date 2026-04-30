import 'package:aquaclean_mobile/src/shared/utils/timestamp_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'address.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// Roles (RBAC):
/// - superAdmin   → Platform owner (you). Cross-tenant access.
/// - tenantOwner  → Car wash owner. Full access to their tenant.
/// - admin        → Legacy alias for tenantOwner; kept for backward compat.
/// - staff        → Employee. Scoped to their tenant's staff dashboard.
/// - customer     → End user. Scoped to their tenant's booking/subscription.
/// - client       → Legacy alias for customer.
@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    // Role: superAdmin | tenantOwner | admin (legacy) | staff | customer | client (legacy)
    @Default('customer') String role,
    // Which tenant this user belongs to. Null for superAdmin.
    String? tenantId,
    String? fcmToken,
    String? phoneNumber,
    String? cpf,
    @Default(false) bool isWhatsApp,
    @Default('active') String status, // active, suspended, cancelled
    @Default('none')
    String subscriptionStatus, // none, active, inactive, cancelled
    @TimestampConverter() DateTime? subscriptionUpdatedAt,
    Address? address,
    String? ndaAcceptedVersion,
    @TimestampConverter() DateTime? ndaAcceptedAt,
    @TimestampConverter() DateTime? lastAccessAt,
    @TimestampConverter() DateTime? strikeUntil,
    String? lastStrikeReason,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}

/// Role-check helpers (use on AppUser instances).
extension AppUserRoles on AppUser {
  bool get isSuperAdmin => role == 'superAdmin';
  // tenantOwner + legacy 'admin' both get admin-level access
  bool get isTenantAdmin => role == 'tenantOwner' || role == 'admin';
  bool get isStaff => role == 'staff';
  // customer + legacy 'client'
  bool get isCustomer => role == 'customer' || role == 'client';

  /// Whether the user has any kind of administrative access.
  bool get hasAdminAccess => isSuperAdmin || isTenantAdmin;
}
