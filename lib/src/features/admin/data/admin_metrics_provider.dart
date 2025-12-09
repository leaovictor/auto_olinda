import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../features/booking/domain/booking.dart';
import 'admin_repository.dart';

part 'admin_metrics_provider.g.dart';

/// Holds aggregated metrics for a specific date range
class AdminDashboardMetrics {
  final double totalRevenue;
  final int totalBookings;
  final double averageTicket;
  final double revenueChangePercent;
  final double bookingsChangePercent;
  final double ticketChangePercent;
  final List<MonthlyRevenue> monthlyRevenueData;

  const AdminDashboardMetrics({
    required this.totalRevenue,
    required this.totalBookings,
    required this.averageTicket,
    required this.revenueChangePercent,
    required this.bookingsChangePercent,
    required this.ticketChangePercent,
    required this.monthlyRevenueData,
  });

  static const empty = AdminDashboardMetrics(
    totalRevenue: 0,
    totalBookings: 0,
    averageTicket: 0,
    revenueChangePercent: 0,
    bookingsChangePercent: 0,
    ticketChangePercent: 0,
    monthlyRevenueData: [],
  );
}

/// Represents revenue for a specific month
class MonthlyRevenue {
  final int year;
  final int month;
  final double revenue;

  const MonthlyRevenue({
    required this.year,
    required this.month,
    required this.revenue,
  });

  String get monthLabel {
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    return months[month - 1];
  }
}

/// Provider for aggregated admin dashboard metrics
@riverpod
Stream<AdminDashboardMetrics> adminDashboardMetrics(
  Ref ref, {
  DateTime? startDate,
  DateTime? endDate,
}) {
  final adminRepo = ref.watch(adminRepositoryProvider);

  return adminRepo.getBookings().map((bookings) {
    final now = DateTime.now();

    // Default to current month if no dates provided
    final effectiveStart = startDate ?? DateTime(now.year, now.month, 1);
    final effectiveEnd = endDate ?? now;

    // Previous period for comparison (same duration, before start date)
    final duration = effectiveEnd.difference(effectiveStart);
    final previousStart = effectiveStart.subtract(duration);
    final previousEnd = effectiveStart.subtract(const Duration(days: 1));

    // Filter bookings by period
    final currentPeriodBookings = bookings.where((b) {
      return b.scheduledTime.isAfter(effectiveStart) &&
          b.scheduledTime.isBefore(effectiveEnd.add(const Duration(days: 1)));
    }).toList();

    final previousPeriodBookings = bookings.where((b) {
      return b.scheduledTime.isAfter(previousStart) &&
          b.scheduledTime.isBefore(previousEnd.add(const Duration(days: 1)));
    }).toList();

    // Calculate current period metrics (only finished bookings for revenue)
    final finishedCurrent = currentPeriodBookings
        .where((b) => b.status == BookingStatus.finished)
        .toList();
    final currentRevenue = finishedCurrent.fold(
      0.0,
      (sum, b) => sum + b.totalPrice,
    );
    final currentBookingsCount = currentPeriodBookings.length;
    final currentAvgTicket = finishedCurrent.isNotEmpty
        ? currentRevenue / finishedCurrent.length
        : 0.0;

    // Calculate previous period metrics
    final finishedPrevious = previousPeriodBookings
        .where((b) => b.status == BookingStatus.finished)
        .toList();
    final previousRevenue = finishedPrevious.fold(
      0.0,
      (sum, b) => sum + b.totalPrice,
    );
    final previousBookingsCount = previousPeriodBookings.length;
    final previousAvgTicket = finishedPrevious.isNotEmpty
        ? previousRevenue / finishedPrevious.length
        : 0.0;

    // Calculate percentage changes
    double calcChange(double current, double previous) {
      if (previous == 0) return current > 0 ? 100.0 : 0.0;
      return ((current - previous) / previous) * 100;
    }

    final revenueChange = calcChange(currentRevenue, previousRevenue);
    final bookingsChange = calcChange(
      currentBookingsCount.toDouble(),
      previousBookingsCount.toDouble(),
    );
    final ticketChange = calcChange(currentAvgTicket, previousAvgTicket);

    // Generate monthly revenue data (last 12 months)
    final monthlyData = <MonthlyRevenue>[];
    for (int i = 11; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthStart = DateTime(monthDate.year, monthDate.month, 1);
      final monthEnd = DateTime(monthDate.year, monthDate.month + 1, 0);

      final monthBookings = bookings.where((b) {
        return b.status == BookingStatus.finished &&
            b.scheduledTime.isAfter(
              monthStart.subtract(const Duration(days: 1)),
            ) &&
            b.scheduledTime.isBefore(monthEnd.add(const Duration(days: 1)));
      });

      final monthRevenue = monthBookings.fold(
        0.0,
        (sum, b) => sum + b.totalPrice,
      );

      monthlyData.add(
        MonthlyRevenue(
          year: monthDate.year,
          month: monthDate.month,
          revenue: monthRevenue,
        ),
      );
    }

    return AdminDashboardMetrics(
      totalRevenue: currentRevenue,
      totalBookings: currentBookingsCount,
      averageTicket: currentAvgTicket,
      revenueChangePercent: revenueChange,
      bookingsChangePercent: bookingsChange,
      ticketChangePercent: ticketChange,
      monthlyRevenueData: monthlyData,
    );
  });
}
