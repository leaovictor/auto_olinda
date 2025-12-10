// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stripe_reports_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$stripeReportsRepositoryHash() =>
    r'fa4d3f66e911cbcab4399fbb9a7b7564b1e32804';

/// See also [stripeReportsRepository].
@ProviderFor(stripeReportsRepository)
final stripeReportsRepositoryProvider =
    Provider<StripeReportsRepository>.internal(
      stripeReportsRepository,
      name: r'stripeReportsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$stripeReportsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StripeReportsRepositoryRef = ProviderRef<StripeReportsRepository>;
String _$stripeSubscriptionsHash() =>
    r'a5237036924e86c819b888f304a72d1ac59ea8b8';

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

/// See also [stripeSubscriptions].
@ProviderFor(stripeSubscriptions)
const stripeSubscriptionsProvider = StripeSubscriptionsFamily();

/// See also [stripeSubscriptions].
class StripeSubscriptionsFamily
    extends Family<AsyncValue<StripeSubscriptionsResult>> {
  /// See also [stripeSubscriptions].
  const StripeSubscriptionsFamily();

  /// See also [stripeSubscriptions].
  StripeSubscriptionsProvider call({String? status}) {
    return StripeSubscriptionsProvider(status: status);
  }

  @override
  StripeSubscriptionsProvider getProviderOverride(
    covariant StripeSubscriptionsProvider provider,
  ) {
    return call(status: provider.status);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'stripeSubscriptionsProvider';
}

/// See also [stripeSubscriptions].
class StripeSubscriptionsProvider
    extends AutoDisposeFutureProvider<StripeSubscriptionsResult> {
  /// See also [stripeSubscriptions].
  StripeSubscriptionsProvider({String? status})
    : this._internal(
        (ref) =>
            stripeSubscriptions(ref as StripeSubscriptionsRef, status: status),
        from: stripeSubscriptionsProvider,
        name: r'stripeSubscriptionsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$stripeSubscriptionsHash,
        dependencies: StripeSubscriptionsFamily._dependencies,
        allTransitiveDependencies:
            StripeSubscriptionsFamily._allTransitiveDependencies,
        status: status,
      );

  StripeSubscriptionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final String? status;

  @override
  Override overrideWith(
    FutureOr<StripeSubscriptionsResult> Function(
      StripeSubscriptionsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StripeSubscriptionsProvider._internal(
        (ref) => create(ref as StripeSubscriptionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<StripeSubscriptionsResult> createElement() {
    return _StripeSubscriptionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StripeSubscriptionsProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StripeSubscriptionsRef
    on AutoDisposeFutureProviderRef<StripeSubscriptionsResult> {
  /// The parameter `status` of this provider.
  String? get status;
}

class _StripeSubscriptionsProviderElement
    extends AutoDisposeFutureProviderElement<StripeSubscriptionsResult>
    with StripeSubscriptionsRef {
  _StripeSubscriptionsProviderElement(super.provider);

  @override
  String? get status => (origin as StripeSubscriptionsProvider).status;
}

String _$stripeTransactionsHash() =>
    r'd1ea524f0ad95702c6dcbe3efc18680e5ce5cb0a';

/// See also [stripeTransactions].
@ProviderFor(stripeTransactions)
const stripeTransactionsProvider = StripeTransactionsFamily();

/// See also [stripeTransactions].
class StripeTransactionsFamily
    extends Family<AsyncValue<StripeTransactionsResult>> {
  /// See also [stripeTransactions].
  const StripeTransactionsFamily();

  /// See also [stripeTransactions].
  StripeTransactionsProvider call({DateTime? startDate, DateTime? endDate}) {
    return StripeTransactionsProvider(startDate: startDate, endDate: endDate);
  }

  @override
  StripeTransactionsProvider getProviderOverride(
    covariant StripeTransactionsProvider provider,
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
  String? get name => r'stripeTransactionsProvider';
}

/// See also [stripeTransactions].
class StripeTransactionsProvider
    extends AutoDisposeFutureProvider<StripeTransactionsResult> {
  /// See also [stripeTransactions].
  StripeTransactionsProvider({DateTime? startDate, DateTime? endDate})
    : this._internal(
        (ref) => stripeTransactions(
          ref as StripeTransactionsRef,
          startDate: startDate,
          endDate: endDate,
        ),
        from: stripeTransactionsProvider,
        name: r'stripeTransactionsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$stripeTransactionsHash,
        dependencies: StripeTransactionsFamily._dependencies,
        allTransitiveDependencies:
            StripeTransactionsFamily._allTransitiveDependencies,
        startDate: startDate,
        endDate: endDate,
      );

  StripeTransactionsProvider._internal(
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
    FutureOr<StripeTransactionsResult> Function(StripeTransactionsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StripeTransactionsProvider._internal(
        (ref) => create(ref as StripeTransactionsRef),
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
  AutoDisposeFutureProviderElement<StripeTransactionsResult> createElement() {
    return _StripeTransactionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StripeTransactionsProvider &&
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
mixin StripeTransactionsRef
    on AutoDisposeFutureProviderRef<StripeTransactionsResult> {
  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;
}

class _StripeTransactionsProviderElement
    extends AutoDisposeFutureProviderElement<StripeTransactionsResult>
    with StripeTransactionsRef {
  _StripeTransactionsProviderElement(super.provider);

  @override
  DateTime? get startDate => (origin as StripeTransactionsProvider).startDate;
  @override
  DateTime? get endDate => (origin as StripeTransactionsProvider).endDate;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
