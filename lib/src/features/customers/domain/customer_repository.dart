import '../models/customer.dart';

abstract class CustomerRepository {
  Stream<List<Customer>> watchCustomers(String tenantId);
  Future<Customer?> getCustomer(String tenantId, String customerId);
  Future<String> createCustomer(String tenantId, Customer customer);
  Future<void> updateCustomer(String tenantId, Customer customer);
  Future<void> deleteCustomer(String tenantId, String customerId);
  Future<List<Customer>> searchCustomers(String tenantId, String query);
  
  // Vehicle operations
  Future<void> addVehicle(String tenantId, String customerId, CustomerVehicle vehicle);
  Future<void> updateVehicle(String tenantId, String customerId, CustomerVehicle vehicle);
  Future<void> deleteVehicle(String tenantId, String customerId, String vehicleId);
}