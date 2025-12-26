// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$staffRepositoryHash() => r'9acdf02dbebdd7ca0ab57d54fffec0c14dce1b9c';

/// See also [staffRepository].
@ProviderFor(staffRepository)
final staffRepositoryProvider = Provider<StaffRepository>.internal(
  staffRepository,
  name: r'staffRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$staffRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StaffRepositoryRef = ProviderRef<StaffRepository>;
String _$staffMembersHash() => r'ec2102adc3e0f94d1afc3a8dfa66d3da0f155fb9';

/// See also [staffMembers].
@ProviderFor(staffMembers)
final staffMembersProvider =
    AutoDisposeStreamProvider<List<StaffMember>>.internal(
      staffMembers,
      name: r'staffMembersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$staffMembersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StaffMembersRef = AutoDisposeStreamProviderRef<List<StaffMember>>;
String _$onShiftStaffHash() => r'a8b90849f17f0249fce32fcb0f3fe0d47e8322ba';

/// See also [onShiftStaff].
@ProviderFor(onShiftStaff)
final onShiftStaffProvider =
    AutoDisposeStreamProvider<List<StaffMember>>.internal(
      onShiftStaff,
      name: r'onShiftStaffProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$onShiftStaffHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OnShiftStaffRef = AutoDisposeStreamProviderRef<List<StaffMember>>;
String _$staffPerformanceHash() => r'b1640b2f2e6dbe0bc5efb42ed36e3d4acfe0ccd4';

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

/// See also [staffPerformance].
@ProviderFor(staffPerformance)
const staffPerformanceProvider = StaffPerformanceFamily();

/// See also [staffPerformance].
class StaffPerformanceFamily extends Family<AsyncValue<StaffPerformance>> {
  /// See also [staffPerformance].
  const StaffPerformanceFamily();

  /// See also [staffPerformance].
  StaffPerformanceProvider call(
    String staffId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return StaffPerformanceProvider(staffId, startDate, endDate);
  }

  @override
  StaffPerformanceProvider getProviderOverride(
    covariant StaffPerformanceProvider provider,
  ) {
    return call(provider.staffId, provider.startDate, provider.endDate);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'staffPerformanceProvider';
}

/// See also [staffPerformance].
class StaffPerformanceProvider
    extends AutoDisposeFutureProvider<StaffPerformance> {
  /// See also [staffPerformance].
  StaffPerformanceProvider(String staffId, DateTime startDate, DateTime endDate)
    : this._internal(
        (ref) => staffPerformance(
          ref as StaffPerformanceRef,
          staffId,
          startDate,
          endDate,
        ),
        from: staffPerformanceProvider,
        name: r'staffPerformanceProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$staffPerformanceHash,
        dependencies: StaffPerformanceFamily._dependencies,
        allTransitiveDependencies:
            StaffPerformanceFamily._allTransitiveDependencies,
        staffId: staffId,
        startDate: startDate,
        endDate: endDate,
      );

  StaffPerformanceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.staffId,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final String staffId;
  final DateTime startDate;
  final DateTime endDate;

  @override
  Override overrideWith(
    FutureOr<StaffPerformance> Function(StaffPerformanceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StaffPerformanceProvider._internal(
        (ref) => create(ref as StaffPerformanceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        staffId: staffId,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<StaffPerformance> createElement() {
    return _StaffPerformanceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StaffPerformanceProvider &&
        other.staffId == staffId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, staffId.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StaffPerformanceRef on AutoDisposeFutureProviderRef<StaffPerformance> {
  /// The parameter `staffId` of this provider.
  String get staffId;

  /// The parameter `startDate` of this provider.
  DateTime get startDate;

  /// The parameter `endDate` of this provider.
  DateTime get endDate;
}

class _StaffPerformanceProviderElement
    extends AutoDisposeFutureProviderElement<StaffPerformance>
    with StaffPerformanceRef {
  _StaffPerformanceProviderElement(super.provider);

  @override
  String get staffId => (origin as StaffPerformanceProvider).staffId;
  @override
  DateTime get startDate => (origin as StaffPerformanceProvider).startDate;
  @override
  DateTime get endDate => (origin as StaffPerformanceProvider).endDate;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
