import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/admin_repository.dart';
import '../../domain/booking_with_details.dart';
import '../../../../features/booking/domain/booking.dart';
import '../../../../features/services/data/independent_service_repository.dart';
import '../../../../features/services/domain/service_booking.dart';
import 'admin_appointments_state.dart';

part 'admin_appointments_controller.g.dart';

/// Controller for admin appointments screen
/// Centralizes all state management and business logic
@riverpod
class AdminAppointmentsController extends _$AdminAppointmentsController {
  AudioPlayer? _audioPlayer;

  @override
  AdminAppointmentsState build() {
    _audioPlayer = AudioPlayer();
    ref.onDispose(() {
      _audioPlayer?.dispose();
      _audioPlayer = null;
    });

    return AdminAppointmentsState(
      focusedDay: DateTime.now(),
      selectedDay: DateTime.now(),
    );
  }

  // ============ UI State Methods ============

  void toggleCalendarView() {
    state = state.copyWith(isCalendarView: !state.isCalendarView);
  }

  void setTabIndex(int index) {
    state = state.copyWith(currentTabIndex: index);
  }

  void setSelectedDay(DateTime day) {
    state = state.copyWith(selectedDay: day);
  }

  void setFocusedDay(DateTime day) {
    state = state.copyWith(focusedDay: day);
  }

  // ============ Car Wash Filter Methods ============

  void setCarWashSearchQuery(String query) {
    state = state.copyWith(carWashSearchQuery: query);
  }

  void setCarWashStatusFilter(String filter) {
    state = state.copyWith(carWashStatusFilter: filter);
  }

  void toggleCarWashSortOrder() {
    state = state.copyWith(
      carWashSortOrder: state.carWashSortOrder == SortOrder.newestFirst
          ? SortOrder.oldestFirst
          : SortOrder.newestFirst,
    );
  }

  // ============ Aesthetic Filter Methods ============

  void setAestheticSearchQuery(String query) {
    state = state.copyWith(aestheticSearchQuery: query);
  }

  void setAestheticStatusFilter(String filter) {
    state = state.copyWith(aestheticStatusFilter: filter);
  }

  void toggleAestheticSortOrder() {
    state = state.copyWith(
      aestheticSortOrder: state.aestheticSortOrder == SortOrder.newestFirst
          ? SortOrder.oldestFirst
          : SortOrder.newestFirst,
    );
  }

  // ============ Sort Order Toggle (based on current tab) ============

  void toggleSortOrder() {
    if (state.currentTabIndex == 0) {
      toggleCarWashSortOrder();
    } else {
      toggleAestheticSortOrder();
    }
  }

  // ============ Audio Alert ============

  /// Check and play alert sound if pending count increased
  void checkPendingAlertSound(int currentPendingCount) {
    if (currentPendingCount > state.lastPendingAestheticCount &&
        currentPendingCount > 0) {
      _playAlertSound();
    }
    if (currentPendingCount != state.lastPendingAestheticCount) {
      state = state.copyWith(lastPendingAestheticCount: currentPendingCount);
    }
  }

  void _playAlertSound() async {
    try {
      await _audioPlayer?.play(AssetSource('audio/agenda.mp3'));
    } catch (e) {
      debugPrint('Error playing alert sound: $e');
    }
  }
}

// ============ Computed Providers ============

/// Filtered car wash bookings based on current filter state
@riverpod
List<BookingWithDetails> filteredCarWashBookings(
  FilteredCarWashBookingsRef ref,
) {
  final controllerState = ref.watch(adminAppointmentsControllerProvider);
  final bookingsAsync = ref.watch(adminBookingsWithDetailsProvider);

  return bookingsAsync.maybeWhen(
    data: (bookings) {
      var filtered = bookings.where((a) {
        final booking = a.booking;
        final user = a.user;
        final vehicle = a.vehicle;

        // Search filter
        final query = controllerState.carWashSearchQuery.toLowerCase();
        final matchesSearch =
            query.isEmpty ||
            (user?.displayName?.toLowerCase() ?? '').contains(query) ||
            (vehicle?.plate.toLowerCase() ?? '').contains(query) ||
            booking.userId.toLowerCase().contains(query) ||
            booking.vehicleId.toLowerCase().contains(query);

        // Status filter
        final matchesStatus =
            controllerState.carWashStatusFilter == 'all' ||
            booking.status.name == controllerState.carWashStatusFilter;

        return matchesSearch && matchesStatus;
      }).toList();

      // Apply sorting
      filtered.sort((a, b) {
        final dateA = a.booking.scheduledTime;
        final dateB = b.booking.scheduledTime;
        return controllerState.carWashSortOrder == SortOrder.newestFirst
            ? dateB.compareTo(dateA)
            : dateA.compareTo(dateB);
      });

      return filtered;
    },
    orElse: () => [],
  );
}

/// Filtered aesthetic bookings based on current filter state
@riverpod
List<ServiceBooking> filteredAestheticBookings(
  FilteredAestheticBookingsRef ref,
) {
  final controllerState = ref.watch(adminAppointmentsControllerProvider);
  final bookingsAsync = ref.watch(allServiceBookingsProvider);

  return bookingsAsync.maybeWhen(
    data: (bookings) {
      var filtered = bookings.where((booking) {
        // Search filter
        final query = controllerState.aestheticSearchQuery.toLowerCase();
        final matchesSearch =
            query.isEmpty ||
            (booking.userName?.toLowerCase() ?? '').contains(query) ||
            (booking.userPhone?.toLowerCase() ?? '').contains(query) ||
            booking.id.toLowerCase().contains(query);

        // Status filter
        final matchesStatus =
            controllerState.aestheticStatusFilter == 'all' ||
            booking.status.name == controllerState.aestheticStatusFilter;

        return matchesSearch && matchesStatus;
      }).toList();

      // Apply sorting
      filtered.sort((a, b) {
        final dateA = a.scheduledTime;
        final dateB = b.scheduledTime;
        return controllerState.aestheticSortOrder == SortOrder.newestFirst
            ? dateB.compareTo(dateA)
            : dateA.compareTo(dateB);
      });

      return filtered;
    },
    orElse: () => [],
  );
}

/// Status counts for car wash bookings (for filter badges)
@riverpod
Map<String, int> carWashStatusCounts(CarWashStatusCountsRef ref) {
  final bookingsAsync = ref.watch(adminBookingsWithDetailsProvider);

  return bookingsAsync.maybeWhen(
    data: (bookings) {
      final counts = <String, int>{'all': bookings.length};
      for (final status in BookingStatus.values) {
        counts[status.name] = bookings
            .where((b) => b.booking.status == status)
            .length;
      }
      return counts;
    },
    orElse: () => <String, int>{},
  );
}

/// Status counts for aesthetic bookings (for filter badges)
@riverpod
Map<String, int> aestheticStatusCounts(AestheticStatusCountsRef ref) {
  final bookingsAsync = ref.watch(allServiceBookingsProvider);

  return bookingsAsync.maybeWhen(
    data: (bookings) {
      final counts = <String, int>{'all': bookings.length};
      for (final status in ServiceBookingStatus.values) {
        counts[status.name] = bookings.where((b) => b.status == status).length;
      }
      return counts;
    },
    orElse: () => <String, int>{},
  );
}
