import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tenant_config.dart';
import 'tenant_firestore.dart';
import 'tenant_service.dart';

/// Streams the tenant document (`tenants/{tenantId}`) and exposes it as a
/// [TenantConfig].  Automatically re-subscribes whenever the tenant context
/// changes (e.g. after login).
///
/// Returns `null` while loading or when no tenant is resolved.
final tenantConfigProvider = StreamProvider<TenantConfig?>((ref) {
  final tenantAsync = ref.watch(tenantServiceProvider);

  return tenantAsync.when(
    data: (ctx) {
      if (ctx == null) return Stream.value(null);

      return TenantFirestore.tenantDoc(ctx.tenantId).snapshots().map((snap) {
        if (!snap.exists || snap.data() == null) return null;
        return TenantConfig.fromJson(snap.id, snap.data()!);
      });
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

/// Convenience: directly fetch the tenant document once (no stream).
Future<TenantConfig?> fetchTenantConfig(String tenantId) async {
  final snap =
      await FirebaseFirestore.instance.collection('tenants').doc(tenantId).get();
  if (!snap.exists || snap.data() == null) return null;
  return TenantConfig.fromJson(snap.id, snap.data()!);
}
