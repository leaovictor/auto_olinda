// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$serviceRepositoryHash() => r'2de45fa37938ce5bf6fa01d29db9d703faebc0de';

/// See also [serviceRepository].
@ProviderFor(serviceRepository)
final serviceRepositoryProvider = Provider<ServiceRepository>.internal(
  serviceRepository,
  name: r'serviceRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$serviceRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ServiceRepositoryRef = ProviderRef<ServiceRepository>;
String _$servicesHash() => r'a74468e1fd83bc19ad7e177d96ea896c0e3474d4';

/// See also [services].
@ProviderFor(services)
final servicesProvider =
    AutoDisposeStreamProvider<List<ServicePackage>>.internal(
      services,
      name: r'servicesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$servicesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ServicesRef = AutoDisposeStreamProviderRef<List<ServicePackage>>;
String _$serviceByIdHash() => r'bc02aad113eec6f047cb32ca533fe1b1e9f068ef';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [serviceById].
@ProviderFor(serviceById)
const serviceByIdProvider = ServiceByIdFamily();

/// See also [serviceById].
class ServiceByIdFamily extends Family<AsyncValue<ServicePackage?>> {
  /// See also [serviceById].
  const ServiceByIdFamily();

  /// See also [serviceById].
  ServiceByIdProvider call(String serviceId) {
    return ServiceByIdProvider(serviceId);
  }

  @override
  ServiceByIdProvider getProviderOverride(
    covariant ServiceByIdProvider provider,
  ) {
    return call(provider.serviceId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'serviceByIdProvider';
}

/// See also [serviceById].
class ServiceByIdProvider extends AutoDisposeFutureProvider<ServicePackage?> {
  /// See also [serviceById].
  ServiceByIdProvider(String serviceId)
    : this._internal(
        (ref) => serviceById(ref as ServiceByIdRef, serviceId),
        from: serviceByIdProvider,
        name: r'serviceByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$serviceByIdHash,
        dependencies: ServiceByIdFamily._dependencies,
        allTransitiveDependencies: ServiceByIdFamily._allTransitiveDependencies,
        serviceId: serviceId,
      );

  ServiceByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.serviceId,
  }) : super.internal();

  final String serviceId;

  @override
  Override overrideWith(
    FutureOr<ServicePackage?> Function(ServiceByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ServiceByIdProvider._internal(
        (ref) => create(ref as ServiceByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        serviceId: serviceId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ServicePackage?> createElement() {
    return _ServiceByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ServiceByIdProvider && other.serviceId == serviceId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, serviceId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ServiceByIdRef on AutoDisposeFutureProviderRef<ServicePackage?> {
  /// The parameter `serviceId` of this provider.
  String get serviceId;
}

class _ServiceByIdProviderElement
    extends AutoDisposeFutureProviderElement<ServicePackage?>
    with ServiceByIdRef {
  _ServiceByIdProviderElement(super.provider);

  @override
  String get serviceId => (origin as ServiceByIdProvider).serviceId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
