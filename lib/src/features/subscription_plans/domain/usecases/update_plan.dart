import '../models/tenant_plan.dart';
import '../plan_repository.dart';

class UpdatePlan {
  final PlanRepository _repo;
  UpdatePlan(this._repo);

  Future<void> call(String tenantId, TenantPlan plan) async {
    if (plan.price <= 0) throw ArgumentError('Invalid price');
    await _repo.updatePlan(tenantId, plan);
  }
}