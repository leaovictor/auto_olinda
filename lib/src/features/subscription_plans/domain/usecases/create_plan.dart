import '../models/tenant_plan.dart';
import '../plan_repository.dart';

class CreatePlan {
  final PlanRepository _repo;
  CreatePlan(this._repo);

  Future<String> call({
    required String tenantId,
    required String name,
    required double price,
    required int washesIncluded,
    required String period,
  }) async {
    if (price <= 0) throw ArgumentError('Invalid price');
    if (washesIncluded <= 0) throw ArgumentError('Must include at least 1 wash');

    final plan = TenantPlan(
      id: '',
      tenantId: tenantId,
      name: name,
      price: price,
      washesIncluded: washesIncluded,
      period: period,
    );

    return await _repo.createPlan(tenantId, plan);
  }
}