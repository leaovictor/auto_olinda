import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_metrics.freezed.dart';
part 'dashboard_metrics.g.dart';

@freezed
abstract class DashboardMetrics with _$DashboardMetrics {
  const factory DashboardMetrics({
    required String tenantId,
    required DateTime date,
    
    // Revenue
    @Default(0.0) double todayRevenue,
    @Default(0.0) double weekRevenue,
    @Default(0.0) double monthRevenue,
    
    // Appointments
    @Default(0) int todayAppointments,
    @Default(0) int pendingAppointments,
    @Default(0) int completedToday,
    @Default(0) int cancelledToday,
    
    // Customers
    @Default(0) int newCustomersToday,
    @Default(0) int totalCustomers,
    @Default(0.0) double avgCustomerLTV,
    
    // Staff
    @Default(0) int activeStaffCount,
    Map<String, StaffPerformance>? staffPerformance, // staffId -> metrics
    
    // Top services
    @Default([]) List<TopService> topServices,
    
    // Subscription metrics
    @Default(0) int activeSubscriptions,
    @Default(0) int subscriptionMRR, // Monthly Recurring Revenue
    
    // Comparison (vs yesterday/last week)
    @Default(0.0) double revenueGrowthPercent,
    @Default(0.0) double appointmentGrowthPercent,
  }) = _DashboardMetrics;

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) => _$DashboardMetricsFromJson(json);
}

@freezed
abstract class StaffPerformance with _$StaffPerformance {
  const factory StaffPerformance({
    required String staffId,
    required String staffName,
    @Default(0) int appointmentsToday,
    @Default(0) int appointmentsWeek,
    @Default(0) int completedAppointments,
    @Default(0.0) double revenueGenerated,
    @Default(0.0) double avgRating,
  }) = _StaffPerformance;
}

@freezed
abstract class TopService with _$TopService {
  const factory TopService({
    required String serviceId,
    required String serviceName,
    @Default(0) int count,
    @Default(0.0) double revenue,
  }) = _TopService;
}
