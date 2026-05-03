import '../models/service.dart';
import '../service_repository.dart';

class GetServices {
  final ServiceRepository _repo;
  GetServices(this._repo);

  Stream<List<Service>> call(String tenantId) {
    return _repo.watchServices(tenantId);
  }
}