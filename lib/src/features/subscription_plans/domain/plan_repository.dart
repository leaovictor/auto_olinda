import '../models/tenant_plan.dart';

abstract class PlanRepository {
  Stream<List<TenantPlan>> watchPlans(String tenantId);
  Future<TenantPlan?> getPlan(String tenantId, String planId);
  Future<String> createPlan(String tenantId, TenantPlan plan);
  Future<void> updatePlan(String tenantId, TenantPlan plan);
  Future<void> deletePlan(String tenantId, String planId);
  Future<void> togglePlanActive(String tenantId, String planId, bool isActive);
}