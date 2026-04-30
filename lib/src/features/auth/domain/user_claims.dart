import 'package:firebase_auth/firebase_auth.dart';

/// Typed wrapper around Firebase Auth Custom Claims.
///
/// Claims are set server-side via the `setUserRole` Cloud Function.
/// Always call [fromCurrentUser] after a role change to force-refresh the token.
class UserClaims {
  final String role;
  final String? tenantId;

  const UserClaims({required this.role, this.tenantId});

  // ─── Role predicates ───────────────────────────────────────────────────────

  bool get isSuperAdmin => role == 'superAdmin';

  /// tenantOwner or legacy 'admin'
  bool get isTenantAdmin => role == 'tenantOwner' || role == 'admin';

  bool get isStaff => role == 'staff';

  /// customer or legacy 'client'
  bool get isCustomer => role == 'customer' || role == 'client';

  bool get hasAdminAccess => isSuperAdmin || isTenantAdmin;

  // ─── Factory ───────────────────────────────────────────────────────────────

  /// Reads claims from the current user's ID token.
  ///
  /// Pass [forceRefresh: true] immediately after a role change so the new
  /// claims propagate without waiting for the 1-hour token expiry.
  static Future<UserClaims> fromCurrentUser({bool forceRefresh = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const UserClaims(role: 'customer');
    }
    final token = await user.getIdTokenResult(forceRefresh);
    return UserClaims(
      role: token.claims?['role'] as String? ?? 'customer',
      tenantId: token.claims?['tenantId'] as String?,
    );
  }

  @override
  String toString() => 'UserClaims(role: $role, tenantId: $tenantId)';
}
