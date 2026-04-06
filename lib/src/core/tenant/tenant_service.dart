import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the resolved tenant context extracted from Firebase Auth custom claims.
class TenantContext {
  final String tenantId;
  final String role;

  const TenantContext({required this.tenantId, required this.role});

  @override
  String toString() => 'TenantContext(tenantId: $tenantId, role: $role)';
}

/// Notifier that holds and initialises the tenant context from custom claims.
///
/// Call [init] immediately after a successful login (before any Firestore
/// access) so that every repository using [TenantFirestore] can resolve the
/// correct tenant path.
class TenantServiceNotifier extends AsyncNotifier<TenantContext?> {
  @override
  Future<TenantContext?> build() async {
    // Try to restore from the currently-signed-in user on cold start.
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return _extractFromUser(user);
  }

  /// Must be called after login succeeds (e.g. in the app.dart auth listener).
  Future<void> init(User user) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _extractFromUser(user));
  }

  /// Called on sign-out to clear the cached context.
  void clear() {
    state = const AsyncData(null);
  }

  Future<TenantContext?> _extractFromUser(User user) async {
    // Force-refresh to always get the latest claims.
    final idTokenResult = await user.getIdTokenResult(true);
    final claims = idTokenResult.claims;

    if (claims == null) return null;

    final tenantId = claims['tenantId'] as String?;
    final role = claims['role'] as String? ?? 'client';

    if (tenantId == null || tenantId.isEmpty) {
      // Graceful degradation: warn in debug builds but don't crash.
      assert(false, '⚠️  TenantService: No tenantId claim found for ${user.uid}');
      return null;
    }

    return TenantContext(tenantId: tenantId, role: role);
  }
}

/// Riverpod provider — keep alive so every downstream consumer stays in sync.
final tenantServiceProvider =
    AsyncNotifierProvider<TenantServiceNotifier, TenantContext?>(
  TenantServiceNotifier.new,
  // keepAlive: true is automatic for AsyncNotifierProvider
);

/// Convenience: synchronously reads the current tenantId.
///
/// Throws if not yet initialised — callers inside repositories should always
/// be reached after [TenantService.init] has completed.
String requireTenantId(Ref ref) {
  final ctx = ref.read(tenantServiceProvider).valueOrNull;
  if (ctx == null) {
    throw StateError(
      'TenantService not initialised. Call TenantService.init() after login.',
    );
  }
  return ctx.tenantId;
}
