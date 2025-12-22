import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_appointments_state.freezed.dart';

/// Sort order for appointments list
enum SortOrder { newestFirst, oldestFirst }

/// Represents the state for admin appointments screen
/// Centralized state management following S.O.L.I.D. principles
@freezed
abstract class AdminAppointmentsState with _$AdminAppointmentsState {
  const factory AdminAppointmentsState({
    // UI State
    @Default(false) bool isCalendarView,
    @Default(0) int currentTabIndex,

    // Car Wash Filters
    @Default('') String carWashSearchQuery,
    @Default('all') String carWashStatusFilter,
    @Default(SortOrder.newestFirst) SortOrder carWashSortOrder,

    // Aesthetic Filters
    @Default('') String aestheticSearchQuery,
    @Default('all') String aestheticStatusFilter,
    @Default(SortOrder.newestFirst) SortOrder aestheticSortOrder,

    // Audio Alert Tracking
    @Default(0) int lastPendingAestheticCount,

    // Calendar State
    DateTime? selectedDay,
    DateTime? focusedDay,
  }) = _AdminAppointmentsState;

  const AdminAppointmentsState._();

  /// Returns the appropriate sort order based on current tab
  SortOrder get currentSortOrder =>
      currentTabIndex == 0 ? carWashSortOrder : aestheticSortOrder;
}
