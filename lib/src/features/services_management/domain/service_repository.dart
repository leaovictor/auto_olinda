import '../models/service.dart';

abstract class ServiceRepository {
  // Stream all services for a tenant
  Stream<List<Service>> watchServices(String tenantId);
  
  // Get single service
  Future<Service?> getService(String tenantId, String serviceId);
  
  // Create service
  Future<String> createService(String tenantId, Service service);
  
  // Update service
  Future<void> updateService(String tenantId, Service service);
  
  // Delete service (soft or hard)
  Future<void> deleteService(String tenantId, String serviceId);
  
  // Reorder services
  Future<void> reorderServices(String tenantId, List<String> orderedIds);
}