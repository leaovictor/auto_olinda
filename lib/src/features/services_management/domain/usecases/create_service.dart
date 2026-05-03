import '../models/service.dart';
import '../service_repository.dart';

class CreateService {
  final ServiceRepository _repo;
  CreateService(this._repo);

  Future<String> call({
    required String tenantId,
    required String name,
    required double price,
    required int durationMinutes,
    String? description,
    String? category,
    String? imageUrl,
  }) async {
    if (price <= 0) throw ArgumentError('Price must be positive');
    if (durationMinutes <= 0) throw ArgumentError('Duration must be positive');

    final service = Service(
      id: '',
      tenantId: tenantId,
      name: name,
      price: price,
      durationMinutes: durationMinutes,
      description: description,
      category: category,
      imageUrl: imageUrl,
    );

    return await _repo.createService(tenantId, service);
  }
}