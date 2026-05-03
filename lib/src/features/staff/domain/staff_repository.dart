import '../models/staff_member.dart';

abstract class StaffRepository {
  Stream<List<StaffMember>> watchStaff(String tenantId);
  Future<StaffMember?> getStaff(String tenantId, String staffId);
  Future<String> addStaff(String tenantId, StaffMember staff);
  Future<void> updateStaff(String tenantId, StaffMember staff);
  Future<void> removeStaff(String tenantId, String staffId);
  Future<void> updateSchedule(String tenantId, String staffId, StaffSchedule schedule);
}