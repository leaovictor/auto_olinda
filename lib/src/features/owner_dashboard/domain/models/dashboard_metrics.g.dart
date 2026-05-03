// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_metrics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardMetrics _$DashboardMetricsFromJson(
  Map<String, dynamic> json,
) => _DashboardMetrics(
  tenantId: json['tenantId'] as String,
  date: DateTime.parse(json['date'] as String),
  todayRevenue: (json['todayRevenue'] as num?)?.toDouble() ?? 0.0,
  weekRevenue: (json['weekRevenue'] as num?)?.toDouble() ?? 0.0,
  monthRevenue: (json['monthRevenue'] as num?)?.toDouble() ?? 0.0,
  todayAppointments: (json['todayAppointments'] as num?)?.toInt() ?? 0,
  pendingAppointments: (json['pendingAppointments'] as num?)?.toInt() ?? 0,
  completedToday: (json['completedToday'] as num?)?.toInt() ?? 0,
  cancelledToday: (json['cancelledToday'] as num?)?.toInt() ?? 0,
  newCustomersToday: (json['newCustomersToday'] as num?)?.toInt() ?? 0,
  totalCustomers: (json['totalCustomers'] as num?)?.toInt() ?? 0,
  avgCustomerLTV: (json['avgCustomerLTV'] as num?)?.toDouble() ?? 0.0,
  activeStaffCount: (json['activeStaffCount'] as num?)?.toInt() ?? 0,
  staffPerformance: (json['staffPerformance'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, StaffPerformance.fromJson(e as Map<String, dynamic>)),
  ),
  topServices:
      (json['topServices'] as List<dynamic>?)
          ?.map((e) => TopService.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  activeSubscriptions: (json['activeSubscriptions'] as num?)?.toInt() ?? 0,
  subscriptionMRR: (json['subscriptionMRR'] as num?)?.toInt() ?? 0,
  revenueGrowthPercent:
      (json['revenueGrowthPercent'] as num?)?.toDouble() ?? 0.0,
  appointmentGrowthPercent:
      (json['appointmentGrowthPercent'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$DashboardMetricsToJson(_DashboardMetrics instance) =>
    <String, dynamic>{
      'tenantId': instance.tenantId,
      'date': instance.date.toIso8601String(),
      'todayRevenue': instance.todayRevenue,
      'weekRevenue': instance.weekRevenue,
      'monthRevenue': instance.monthRevenue,
      'todayAppointments': instance.todayAppointments,
      'pendingAppointments': instance.pendingAppointments,
      'completedToday': instance.completedToday,
      'cancelledToday': instance.cancelledToday,
      'newCustomersToday': instance.newCustomersToday,
      'totalCustomers': instance.totalCustomers,
      'avgCustomerLTV': instance.avgCustomerLTV,
      'activeStaffCount': instance.activeStaffCount,
      'staffPerformance': instance.staffPerformance?.map(
        (k, e) => MapEntry(k, e.toJson()),
      ),
      'topServices': instance.topServices.map((e) => e.toJson()).toList(),
      'activeSubscriptions': instance.activeSubscriptions,
      'subscriptionMRR': instance.subscriptionMRR,
      'revenueGrowthPercent': instance.revenueGrowthPercent,
      'appointmentGrowthPercent': instance.appointmentGrowthPercent,
    };

_StaffPerformance _$StaffPerformanceFromJson(Map<String, dynamic> json) =>
    _StaffPerformance(
      staffId: json['staffId'] as String,
      staffName: json['staffName'] as String,
      appointmentsToday: (json['appointmentsToday'] as num?)?.toInt() ?? 0,
      appointmentsWeek: (json['appointmentsWeek'] as num?)?.toInt() ?? 0,
      completedAppointments:
          (json['completedAppointments'] as num?)?.toInt() ?? 0,
      revenueGenerated: (json['revenueGenerated'] as num?)?.toDouble() ?? 0.0,
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$StaffPerformanceToJson(_StaffPerformance instance) =>
    <String, dynamic>{
      'staffId': instance.staffId,
      'staffName': instance.staffName,
      'appointmentsToday': instance.appointmentsToday,
      'appointmentsWeek': instance.appointmentsWeek,
      'completedAppointments': instance.completedAppointments,
      'revenueGenerated': instance.revenueGenerated,
      'avgRating': instance.avgRating,
    };

_TopService _$TopServiceFromJson(Map<String, dynamic> json) => _TopService(
  serviceId: json['serviceId'] as String,
  serviceName: json['serviceName'] as String,
  count: (json['count'] as num?)?.toInt() ?? 0,
  revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$TopServiceToJson(_TopService instance) =>
    <String, dynamic>{
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'count': instance.count,
      'revenue': instance.revenue,
    };
