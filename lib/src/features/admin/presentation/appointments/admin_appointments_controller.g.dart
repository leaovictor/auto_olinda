// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_appointments_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredCarWashBookingsHash() =>
    r'b4a279c2d79b48312685f8acc642f2836b06791a';

/// Filtered car wash bookings based on current filter state
///
/// Copied from [filteredCarWashBookings].
@ProviderFor(filteredCarWashBookings)
final filteredCarWashBookingsProvider =
    AutoDisposeProvider<List<BookingWithDetails>>.internal(
      filteredCarWashBookings,
      name: r'filteredCarWashBookingsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredCarWashBookingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredCarWashBookingsRef =
    AutoDisposeProviderRef<List<BookingWithDetails>>;
String _$filteredAestheticBookingsHash() =>
    r'dc14f606cf5707bd9913bfd9702dd069f62f5470';

/// Filtered aesthetic bookings based on current filter state
///
/// Copied from [filteredAestheticBookings].
@ProviderFor(filteredAestheticBookings)
final filteredAestheticBookingsProvider =
    AutoDisposeProvider<List<ServiceBooking>>.internal(
      filteredAestheticBookings,
      name: r'filteredAestheticBookingsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredAestheticBookingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredAestheticBookingsRef =
    AutoDisposeProviderRef<List<ServiceBooking>>;
String _$carWashStatusCountsHash() =>
    r'f3464691e7b2fc59b91d823744fb12b081b0e942';

/// Status counts for car wash bookings (for filter badges)
///
/// Copied from [carWashStatusCounts].
@ProviderFor(carWashStatusCounts)
final carWashStatusCountsProvider =
    AutoDisposeProvider<Map<String, int>>.internal(
      carWashStatusCounts,
      name: r'carWashStatusCountsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$carWashStatusCountsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CarWashStatusCountsRef = AutoDisposeProviderRef<Map<String, int>>;
String _$aestheticStatusCountsHash() =>
    r'4851c6defe1772bc726d3722d81a23f863641c14';

/// Status counts for aesthetic bookings (for filter badges)
///
/// Copied from [aestheticStatusCounts].
@ProviderFor(aestheticStatusCounts)
final aestheticStatusCountsProvider =
    AutoDisposeProvider<Map<String, int>>.internal(
      aestheticStatusCounts,
      name: r'aestheticStatusCountsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$aestheticStatusCountsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AestheticStatusCountsRef = AutoDisposeProviderRef<Map<String, int>>;
String _$adminAppointmentsControllerHash() =>
    r'132c4911b6b8ba4d1e59139c7a16b3a640e719d3';

/// Controller for admin appointments screen
/// Centralizes all state management and business logic
///
/// Copied from [AdminAppointmentsController].
@ProviderFor(AdminAppointmentsController)
final adminAppointmentsControllerProvider =
    AutoDisposeNotifierProvider<
      AdminAppointmentsController,
      AdminAppointmentsState
    >.internal(
      AdminAppointmentsController.new,
      name: r'adminAppointmentsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminAppointmentsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdminAppointmentsController =
    AutoDisposeNotifier<AdminAppointmentsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
