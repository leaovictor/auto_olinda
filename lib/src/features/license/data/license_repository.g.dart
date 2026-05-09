// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'license_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$licenseRepositoryHash() => r'003f22f55dbd7a001e66d90e036a1ecfbfec5889';

/// See also [licenseRepository].
@ProviderFor(licenseRepository)
final licenseRepositoryProvider = Provider<LicenseRepository>.internal(
  licenseRepository,
  name: r'licenseRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$licenseRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LicenseRepositoryRef = ProviderRef<LicenseRepository>;
String _$currentStoreIdHash() => r'8b413d0497e8d48d7544810ce60801da75aeefe2';

/// Provider for the current storeId (Option A: hardcoded).
///
/// Copied from [currentStoreId].
@ProviderFor(currentStoreId)
final currentStoreIdProvider = Provider<String>.internal(
  currentStoreId,
  name: r'currentStoreIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentStoreIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentStoreIdRef = ProviderRef<String>;
String _$currentStoreLicenseHash() =>
    r'1ff66be94d8510702b6cccfba84a3a8fd561d138';

/// Real-time stream of the current store's license.
///
/// Copied from [currentStoreLicense].
@ProviderFor(currentStoreLicense)
final currentStoreLicenseProvider = StreamProvider<StoreLicense?>.internal(
  currentStoreLicense,
  name: r'currentStoreLicenseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentStoreLicenseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentStoreLicenseRef = StreamProviderRef<StoreLicense?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
