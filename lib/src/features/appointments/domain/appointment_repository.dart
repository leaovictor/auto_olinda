import '../models/appointment.dart';
import '../models/appointment_enums.dart';

abstract class AppointmentRepository {
  // Create
  Future<String> createAppointment(String tenantId, Appointment appointment);
  
  // Read
  Stream<Appointment?> watchAppointment(String tenantId, String appointmentId);
  Stream<List<Appointment>> watchAppointments(String tenantId, {
    DateTime? startDate,
    DateTime? endDate,
    String? staffId,
    AppointmentStatus? status,
  });
  Future<Appointment?> getAppointment(String tenantId, String appointmentId);
  
  // Update
  Future<void> updateAppointment(String tenantId, Appointment appointment);
  Future<void> updateStatus(String tenantId, String appointmentId, AppointmentStatus status);
  
  // Delete
  Future<void> deleteAppointment(String tenantId, String appointmentId);
  
  // Availability
  Future<List<DateTime>> getAvailableSlots(String tenantId, DateTime date, String serviceId);
  Future<bool> isSlotAvailable(String tenantId, DateTime startTime, int duration);
}