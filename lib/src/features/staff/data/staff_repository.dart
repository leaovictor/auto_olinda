import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/staff_member.dart';

part 'staff_repository.g.dart';

/// Repository for staff-related operations with performance tracking
class StaffRepository {
  final FirebaseFirestore _firestore;

  StaffRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get all staff members with their performance metrics
  Stream<List<StaffMember>> getStaffMembers() {
    return _firestore
        .collection('users')
        .where('role', whereIn: ['admin', 'staff'])
        .snapshots()
        .asyncMap((snapshot) async {
          final staffList = <StaffMember>[];

          for (final doc in snapshot.docs) {
            final userData = doc.data();
            final staffId = doc.id;

            // Get today's booking stats
            final todayStats = await _getStaffBookingsForDate(
              staffId,
              DateTime.now(),
            );

            // Get month's booking stats
            final now = DateTime.now();
            final startOfMonth = DateTime(now.year, now.month, 1);
            final monthStats = await _getStaffBookingsInRange(
              staffId,
              startOfMonth,
              now,
            );

            staffList.add(
              StaffMember(
                id: staffId,
                name: userData['displayName'] ?? 'Sem nome',
                email: userData['email'] ?? '',
                photoUrl: userData['photoUrl'],
                role: userData['role'] ?? 'staff',
                status: userData['status'] ?? 'active',
                phoneNumber: userData['phoneNumber'],
                totalBookingsToday: todayStats['count'] ?? 0,
                totalBookingsMonth: monthStats['count'] ?? 0,
                revenueToday: (todayStats['revenue'] ?? 0).toDouble(),
                revenueMonth: (monthStats['revenue'] ?? 0).toDouble(),
                avgRating: (userData['avgRating'] ?? 0).toDouble(),
                totalRatings: userData['totalRatings'] ?? 0,
                isOnShift: userData['isOnShift'] ?? false,
                lastActiveAt: (userData['lastActiveAt'] as Timestamp?)
                    ?.toDate(),
                createdAt: (userData['createdAt'] as Timestamp?)?.toDate(),
              ),
            );
          }

          return staffList;
        });
  }

  /// Get performance stats for a single staff member
  Future<StaffPerformance> getStaffPerformance(
    String staffId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Get staff user data
    final userDoc = await _firestore.collection('users').doc(staffId).get();
    final userData = userDoc.data() ?? {};

    // Get bookings in date range
    final stats = await _getStaffBookingsInRange(staffId, startDate, endDate);

    // Get daily breakdown
    final dailyStats = await _getDailyStatsForStaff(
      staffId,
      startDate,
      endDate,
    );

    return StaffPerformance(
      staffId: staffId,
      staffName: userData['displayName'] ?? 'Sem nome',
      totalBookings: stats['count'] ?? 0,
      totalRevenue: (stats['revenue'] ?? 0).toDouble(),
      avgRating: (userData['avgRating'] ?? 0).toDouble(),
      totalRatings: userData['totalRatings'] ?? 0,
      dailyStats: dailyStats,
    );
  }

  /// Assign a booking to a staff member
  Future<void> assignBookingToStaff(String bookingId, String staffId) async {
    await _firestore.collection('appointments').doc(bookingId).update({
      'assignedStaffId': staffId,
      'assignedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update staff shift status
  Future<void> updateStaffShift(
    String staffId, {
    DateTime? shiftStart,
    DateTime? shiftEnd,
    bool? isOnShift,
  }) async {
    final updates = <String, dynamic>{};

    if (shiftStart != null) {
      updates['shiftStart'] = Timestamp.fromDate(shiftStart);
    }
    if (shiftEnd != null) {
      updates['shiftEnd'] = Timestamp.fromDate(shiftEnd);
    }
    if (isOnShift != null) {
      updates['isOnShift'] = isOnShift;
    }

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(staffId).update(updates);
    }
  }

  /// Start a shift for a staff member
  Future<void> startShift(String staffId) async {
    await _firestore.collection('users').doc(staffId).update({
      'isOnShift': true,
      'shiftStart': FieldValue.serverTimestamp(),
      'lastActiveAt': FieldValue.serverTimestamp(),
    });
  }

  /// End a shift for a staff member
  Future<void> endShift(String staffId) async {
    await _firestore.collection('users').doc(staffId).update({
      'isOnShift': false,
      'shiftEnd': FieldValue.serverTimestamp(),
    });
  }

  /// Get staff members currently on shift
  Stream<List<StaffMember>> getOnShiftStaff() {
    return _firestore
        .collection('users')
        .where('role', whereIn: ['admin', 'staff'])
        .where('isOnShift', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return StaffMember(
              id: doc.id,
              name: data['displayName'] ?? 'Sem nome',
              email: data['email'] ?? '',
              photoUrl: data['photoUrl'],
              role: data['role'] ?? 'staff',
              status: data['status'] ?? 'active',
              isOnShift: true,
              shiftStart: (data['shiftStart'] as Timestamp?)?.toDate(),
            );
          }).toList();
        });
  }

  // Private helper methods

  Future<Map<String, dynamic>> _getStaffBookingsForDate(
    String staffId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _getStaffBookingsInRange(staffId, startOfDay, endOfDay);
  }

  Future<Map<String, dynamic>> _getStaffBookingsInRange(
    String staffId,
    DateTime start,
    DateTime end,
  ) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('assignedStaffId', isEqualTo: staffId)
        .where('status', isEqualTo: 'finished')
        .where(
          'scheduledTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where('scheduledTime', isLessThan: Timestamp.fromDate(end))
        .get();

    int count = snapshot.docs.length;
    double revenue = 0;

    for (final doc in snapshot.docs) {
      revenue += (doc.data()['totalPrice'] as num?)?.toDouble() ?? 0;
    }

    return {'count': count, 'revenue': revenue};
  }

  Future<List<DailyStats>> _getDailyStatsForStaff(
    String staffId,
    DateTime start,
    DateTime end,
  ) async {
    final stats = <DailyStats>[];
    var currentDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      final dayStats = await _getStaffBookingsForDate(staffId, currentDate);
      stats.add(
        DailyStats(
          date: currentDate,
          bookings: dayStats['count'] ?? 0,
          revenue: (dayStats['revenue'] ?? 0).toDouble(),
        ),
      );
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return stats;
  }
}

@Riverpod(keepAlive: true)
StaffRepository staffRepository(Ref ref) {
  return StaffRepository();
}

@riverpod
Stream<List<StaffMember>> staffMembers(Ref ref) {
  return ref.watch(staffRepositoryProvider).getStaffMembers();
}

@riverpod
Stream<List<StaffMember>> onShiftStaff(Ref ref) {
  return ref.watch(staffRepositoryProvider).getOnShiftStaff();
}

@riverpod
Future<StaffPerformance> staffPerformance(
  Ref ref,
  String staffId,
  DateTime startDate,
  DateTime endDate,
) {
  return ref
      .watch(staffRepositoryProvider)
      .getStaffPerformance(staffId, startDate, endDate);
}
