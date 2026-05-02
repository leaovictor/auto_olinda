import 'package:freezed_annotation/freezed_annotation.dart';

part 'tenant_plan.freezed.dart';
part 'tenant_plan.g.dart';

@freezed
abstract class TenantPlan with _$TenantPlan {
  const factory TenantPlan({
    required String id,
    required String tenantId,
    required String name,
    String? description,
    required double price,
    String? currency, // 'brl', 'usd'
    required int washesIncluded, // Number of washes per period
    required String period, // 'weekly' | 'biweekly' | 'monthly' | 'yearly'
    @Default(false) bool rollover, // Carry over unused washes?
    @Default(0) int rolloverLimit, // Max rollover washes
    @Default(0) int minContractMonths, // Minimum commitment
    @Default(true) bool autoRenew,
    @Default(true) bool isActive,
    @Default(0) int sortOrder,
    List<String>? includedServiceIds, // Which services count
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TenantPlan;

  factory TenantPlan.fromJson(Map<String, dynamic> json) => _$TenantPlanFromJson(json);
}
