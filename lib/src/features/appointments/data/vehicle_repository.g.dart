// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$vehicleRepositoryHash() => r'9033c24cd65e23cee01a846b594fef08486b659b';

/// See also [vehicleRepository].
@ProviderFor(vehicleRepository)
final vehicleRepositoryProvider = Provider<VehicleRepository>.internal(
  vehicleRepository,
  name: r'vehicleRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$vehicleRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VehicleRepositoryRef = ProviderRef<VehicleRepository>;
String _$userVehiclesHash() => r'57e8180783e922ae91c515d620fe7d6217565575';

/// See also [userVehicles].
@ProviderFor(userVehicles)
final userVehiclesProvider = AutoDisposeStreamProvider<List<Vehicle>>.internal(
  userVehicles,
  name: r'userVehiclesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userVehiclesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserVehiclesRef = AutoDisposeStreamProviderRef<List<Vehicle>>;
String _$vehicleByIdHash() => r'6c378ee45cf1dec6d050f7401f9dde8959655d2c';

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

/// See also [vehicleById].
@ProviderFor(vehicleById)
const vehicleByIdProvider = VehicleByIdFamily();

/// See also [vehicleById].
class VehicleByIdFamily extends Family<AsyncValue<Vehicle?>> {
  /// See also [vehicleById].
  const VehicleByIdFamily();

  /// See also [vehicleById].
  VehicleByIdProvider call(String vehicleId) {
    return VehicleByIdProvider(vehicleId);
  }

  @override
  VehicleByIdProvider getProviderOverride(
    covariant VehicleByIdProvider provider,
  ) {
    return call(provider.vehicleId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'vehicleByIdProvider';
}

/// See also [vehicleById].
class VehicleByIdProvider extends AutoDisposeFutureProvider<Vehicle?> {
  /// See also [vehicleById].
  VehicleByIdProvider(String vehicleId)
    : this._internal(
        (ref) => vehicleById(ref as VehicleByIdRef, vehicleId),
        from: vehicleByIdProvider,
        name: r'vehicleByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$vehicleByIdHash,
        dependencies: VehicleByIdFamily._dependencies,
        allTransitiveDependencies: VehicleByIdFamily._allTransitiveDependencies,
        vehicleId: vehicleId,
      );

  VehicleByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.vehicleId,
  }) : super.internal();

  final String vehicleId;

  @override
  Override overrideWith(
    FutureOr<Vehicle?> Function(VehicleByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VehicleByIdProvider._internal(
        (ref) => create(ref as VehicleByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        vehicleId: vehicleId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Vehicle?> createElement() {
    return _VehicleByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VehicleByIdProvider && other.vehicleId == vehicleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, vehicleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VehicleByIdRef on AutoDisposeFutureProviderRef<Vehicle?> {
  /// The parameter `vehicleId` of this provider.
  String get vehicleId;
}

class _VehicleByIdProviderElement
    extends AutoDisposeFutureProviderElement<Vehicle?>
    with VehicleByIdRef {
  _VehicleByIdProviderElement(super.provider);

  @override
  String get vehicleId => (origin as VehicleByIdProvider).vehicleId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
