// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$billingRepositoryHash() => r'd0c15ec471d8cd9fd9e6dfcef09b33e68f261b6f';

/// See also [billingRepository].
@ProviderFor(billingRepository)
final billingRepositoryProvider =
    AutoDisposeProvider<BillingRepository>.internal(
      billingRepository,
      name: r'billingRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$billingRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BillingRepositoryRef = AutoDisposeProviderRef<BillingRepository>;
String _$subscriptionStreamHash() =>
    r'f5fe1d921a361da7d08a7e1c513bb04bccccd2e6';

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

/// See also [subscriptionStream].
@ProviderFor(subscriptionStream)
const subscriptionStreamProvider = SubscriptionStreamFamily();

/// See also [subscriptionStream].
class SubscriptionStreamFamily extends Family<AsyncValue<Subscription>> {
  /// See also [subscriptionStream].
  const SubscriptionStreamFamily();

  /// See also [subscriptionStream].
  SubscriptionStreamProvider call(String tenantId) {
    return SubscriptionStreamProvider(tenantId);
  }

  @override
  SubscriptionStreamProvider getProviderOverride(
    covariant SubscriptionStreamProvider provider,
  ) {
    return call(provider.tenantId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'subscriptionStreamProvider';
}

/// See also [subscriptionStream].
class SubscriptionStreamProvider
    extends AutoDisposeStreamProvider<Subscription> {
  /// See also [subscriptionStream].
  SubscriptionStreamProvider(String tenantId)
    : this._internal(
        (ref) => subscriptionStream(ref as SubscriptionStreamRef, tenantId),
        from: subscriptionStreamProvider,
        name: r'subscriptionStreamProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$subscriptionStreamHash,
        dependencies: SubscriptionStreamFamily._dependencies,
        allTransitiveDependencies:
            SubscriptionStreamFamily._allTransitiveDependencies,
        tenantId: tenantId,
      );

  SubscriptionStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tenantId,
  }) : super.internal();

  final String tenantId;

  @override
  Override overrideWith(
    Stream<Subscription> Function(SubscriptionStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SubscriptionStreamProvider._internal(
        (ref) => create(ref as SubscriptionStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tenantId: tenantId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Subscription> createElement() {
    return _SubscriptionStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubscriptionStreamProvider && other.tenantId == tenantId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tenantId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SubscriptionStreamRef on AutoDisposeStreamProviderRef<Subscription> {
  /// The parameter `tenantId` of this provider.
  String get tenantId;
}

class _SubscriptionStreamProviderElement
    extends AutoDisposeStreamProviderElement<Subscription>
    with SubscriptionStreamRef {
  _SubscriptionStreamProviderElement(super.provider);

  @override
  String get tenantId => (origin as SubscriptionStreamProvider).tenantId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
