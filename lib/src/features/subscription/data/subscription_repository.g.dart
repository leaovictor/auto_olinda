// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subscriptionRepositoryHash() =>
    r'75d0b363fc8e99d5348716927a8105865f1dea7a';

/// See also [subscriptionRepository].
@ProviderFor(subscriptionRepository)
final subscriptionRepositoryProvider =
    Provider<SubscriptionRepository>.internal(
      subscriptionRepository,
      name: r'subscriptionRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$subscriptionRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SubscriptionRepositoryRef = ProviderRef<SubscriptionRepository>;
String _$activePlansHash() => r'74b771691e43b07f252768cf622f3fb1df1b3a81';

/// See also [activePlans].
@ProviderFor(activePlans)
final activePlansProvider =
    AutoDisposeStreamProvider<List<SubscriptionPlan>>.internal(
      activePlans,
      name: r'activePlansProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activePlansHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActivePlansRef = AutoDisposeStreamProviderRef<List<SubscriptionPlan>>;
String _$userSubscriptionHash() => r'10b89c07651f09d67a0a2a66739c95821c469980';

/// See also [userSubscription].
@ProviderFor(userSubscription)
final userSubscriptionProvider =
    AutoDisposeStreamProvider<Subscriber?>.internal(
      userSubscription,
      name: r'userSubscriptionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userSubscriptionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserSubscriptionRef = AutoDisposeStreamProviderRef<Subscriber?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
