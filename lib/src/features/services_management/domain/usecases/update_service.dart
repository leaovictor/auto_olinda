import '../models/service.dart';
import '../service_repository.dart';

class UpdateService {
  final ServiceRepository _repo;
  UpdateService(this._repo);

  Future<void> call(String tenantId, Service service) async {
    if (service.price <= 0) throw ArgumentError('Invalid price');
    await _repo.updateService(tenantId, service);
  }
}