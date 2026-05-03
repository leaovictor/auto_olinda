import '../service_repository.dart';

class DeleteService {
  final ServiceRepository _repo;
  DeleteService(this._repo);

  Future<void> call(String tenantId, String serviceId) async {
    await _repo.deleteService(tenantId, serviceId);
  }
}