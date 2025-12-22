// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_booking_notification_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$newBookingNotificationServiceHash() =>
    r'80f807ddd1198f5c9c91e7a704bb11170f04894e';

/// Service that monitors Firestore for new bookings and triggers notifications
/// Works globally across all admin screens
///
/// Copied from [NewBookingNotificationService].
@ProviderFor(NewBookingNotificationService)
final newBookingNotificationServiceProvider =
    NotifierProvider<NewBookingNotificationService, void>.internal(
      NewBookingNotificationService.new,
      name: r'newBookingNotificationServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$newBookingNotificationServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NewBookingNotificationService = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
