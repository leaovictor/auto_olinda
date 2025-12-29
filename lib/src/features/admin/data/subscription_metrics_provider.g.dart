// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_metrics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subscriptionMetricsHash() =>
    r'b0f0f33dffae944e72984d0cccc622ea019d5a2f';

/// Provider for subscription metrics
///
/// Copied from [subscriptionMetrics].
@ProviderFor(subscriptionMetrics)
final subscriptionMetricsProvider =
    AutoDisposeStreamProvider<SubscriptionMetrics>.internal(
      subscriptionMetrics,
      name: r'subscriptionMetricsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$subscriptionMetricsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SubscriptionMetricsRef =
    AutoDisposeStreamProviderRef<SubscriptionMetrics>;
String _$activeSubscriberCountHash() =>
    r'0829b7c0e751e5bc223fac735bdaeb72b107783d';

/// Provider to get the current active subscriber count (efficient single query)
///
/// Copied from [activeSubscriberCount].
@ProviderFor(activeSubscriberCount)
final activeSubscriberCountProvider = AutoDisposeStreamProvider<int>.internal(
  activeSubscriberCount,
  name: r'activeSubscriberCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeSubscriberCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveSubscriberCountRef = AutoDisposeStreamProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
