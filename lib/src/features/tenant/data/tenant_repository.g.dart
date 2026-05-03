// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tenantRepositoryHash() => r'871415ebce5964ea1a6ea573d7a501421e430301';

/// See also [tenantRepository].
@ProviderFor(tenantRepository)
final tenantRepositoryProvider = Provider<TenantRepository>.internal(
  tenantRepository,
  name: r'tenantRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tenantRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TenantRepositoryRef = ProviderRef<TenantRepository>;
String _$currentTenantHash() => r'7806f5e37f44b522fd384ec378b0cf2bb3796ed2';

/// Streams the current user's tenant document.
/// Returns null if user has no tenantId (superAdmin, unauthenticated).
///
/// Copied from [currentTenant].
@ProviderFor(currentTenant)
final currentTenantProvider = StreamProvider<Tenant?>.internal(
  currentTenant,
  name: r'currentTenantProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentTenantHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentTenantRef = StreamProviderRef<Tenant?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
