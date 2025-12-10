// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_metrics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminDashboardMetricsHash() =>
    r'aa099debb704e35faf923c2b4a5896f237eacebf';

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

/// Provider for aggregated admin dashboard metrics
///
/// Copied from [adminDashboardMetrics].
@ProviderFor(adminDashboardMetrics)
const adminDashboardMetricsProvider = AdminDashboardMetricsFamily();

/// Provider for aggregated admin dashboard metrics
///
/// Copied from [adminDashboardMetrics].
class AdminDashboardMetricsFamily
    extends Family<AsyncValue<AdminDashboardMetrics>> {
  /// Provider for aggregated admin dashboard metrics
  ///
  /// Copied from [adminDashboardMetrics].
  const AdminDashboardMetricsFamily();

  /// Provider for aggregated admin dashboard metrics
  ///
  /// Copied from [adminDashboardMetrics].
  AdminDashboardMetricsProvider call({DateTime? startDate, DateTime? endDate}) {
    return AdminDashboardMetricsProvider(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  AdminDashboardMetricsProvider getProviderOverride(
    covariant AdminDashboardMetricsProvider provider,
  ) {
    return call(startDate: provider.startDate, endDate: provider.endDate);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'adminDashboardMetricsProvider';
}

/// Provider for aggregated admin dashboard metrics
///
/// Copied from [adminDashboardMetrics].
class AdminDashboardMetricsProvider
    extends AutoDisposeStreamProvider<AdminDashboardMetrics> {
  /// Provider for aggregated admin dashboard metrics
  ///
  /// Copied from [adminDashboardMetrics].
  AdminDashboardMetricsProvider({DateTime? startDate, DateTime? endDate})
    : this._internal(
        (ref) => adminDashboardMetrics(
          ref as AdminDashboardMetricsRef,
          startDate: startDate,
          endDate: endDate,
        ),
        from: adminDashboardMetricsProvider,
        name: r'adminDashboardMetricsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$adminDashboardMetricsHash,
        dependencies: AdminDashboardMetricsFamily._dependencies,
        allTransitiveDependencies:
            AdminDashboardMetricsFamily._allTransitiveDependencies,
        startDate: startDate,
        endDate: endDate,
      );

  AdminDashboardMetricsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final DateTime? startDate;
  final DateTime? endDate;

  @override
  Override overrideWith(
    Stream<AdminDashboardMetrics> Function(AdminDashboardMetricsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminDashboardMetricsProvider._internal(
        (ref) => create(ref as AdminDashboardMetricsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<AdminDashboardMetrics> createElement() {
    return _AdminDashboardMetricsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminDashboardMetricsProvider &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AdminDashboardMetricsRef
    on AutoDisposeStreamProviderRef<AdminDashboardMetrics> {
  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;
}

class _AdminDashboardMetricsProviderElement
    extends AutoDisposeStreamProviderElement<AdminDashboardMetrics>
    with AdminDashboardMetricsRef {
  _AdminDashboardMetricsProviderElement(super.provider);

  @override
  DateTime? get startDate =>
      (origin as AdminDashboardMetricsProvider).startDate;
  @override
  DateTime? get endDate => (origin as AdminDashboardMetricsProvider).endDate;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
