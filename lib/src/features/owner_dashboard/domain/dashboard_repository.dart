import '../models/dashboard_metrics.dart';

abstract class DashboardRepository {
  Future<DashboardMetrics> getMetrics(String tenantId, {
    required DateTime startDate,
    required DateTime endDate,
  });
  
  Stream<DashboardMetrics> watchMetrics(String tenantId, {
    required DateTime startDate,
    required DateTime endDate,
  });
  
  Future<Map<String, dynamic>> getRevenueSummary(String tenantId, String period); // 'week' | 'month' | 'year'
  Future<List<Map<String, dynamic>>> getTopServices(String tenantId, int limit);
}