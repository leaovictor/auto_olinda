import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../booking/domain/booking.dart';

/// Stats for the staff dashboard
class StaffDayStats {
  final int queue;
  final int inProgress;
  final int finished;
  final double revenue;
  final int totalToday;

  const StaffDayStats({
    required this.queue,
    required this.inProgress,
    required this.finished,
    required this.revenue,
    required this.totalToday,
  });

  factory StaffDayStats.empty() => const StaffDayStats(
    queue: 0,
    inProgress: 0,
    finished: 0,
    revenue: 0,
    totalToday: 0,
  );
}

/// Provider for today's staff statistics including revenue
final staffDayStatsProvider = StreamProvider<StaffDayStats>((ref) {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  print(
    '📊 [StaffStats] Provider starting - querying for $startOfDay to $endOfDay',
  );

  return FirebaseFirestore.instance
      .collection('appointments')
      .where(
        'scheduledTime',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
      )
      .where('scheduledTime', isLessThan: Timestamp.fromDate(endOfDay))
      .snapshots()
      .map((snapshot) {
        print('📊 [StaffStats] Received ${snapshot.docs.length} documents');

        final bookings = snapshot.docs
            .map((doc) {
              try {
                final data = doc.data();

                // Convert Timestamp to ISO8601 string for Booking.fromJson
                final scheduledTime = data['scheduledTime'];
                String scheduledTimeStr;
                if (scheduledTime is Timestamp) {
                  scheduledTimeStr = scheduledTime.toDate().toIso8601String();
                } else if (scheduledTime is String) {
                  scheduledTimeStr = scheduledTime;
                } else {
                  scheduledTimeStr = DateTime.now().toIso8601String();
                }

                final mappedData = {
                  ...data,
                  'id': doc.id,
                  'scheduledTime': scheduledTimeStr,
                  'status': data['status'] ?? 'scheduled',
                  'totalPrice': (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
                };

                return Booking.fromJson(mappedData);
              } catch (e) {
                print('❌ [StaffStats] Error parsing booking ${doc.id}: $e');
                return null;
              }
            })
            .whereType<Booking>()
            .toList();

        // Calculate stats
        int queue = 0;
        int inProgress = 0;
        int finished = 0;
        double revenue = 0;

        for (final booking in bookings) {
          switch (booking.status) {
            case BookingStatus.scheduled:
            case BookingStatus.confirmed:
            case BookingStatus.checkIn:
              queue++;
              break;
            case BookingStatus.washing:
            case BookingStatus.vacuuming:
            case BookingStatus.drying:
            case BookingStatus.polishing:
              inProgress++;
              break;
            case BookingStatus.finished:
              finished++;
              revenue += booking.totalPrice;
              break;
            case BookingStatus.cancelled:
            case BookingStatus.noShow:
              // Don't count
              break;
          }
        }

        print(
          '📊 [StaffStats] Calculated: queue=$queue, inProgress=$inProgress, finished=$finished, revenue=$revenue',
        );

        return StaffDayStats(
          queue: queue,
          inProgress: inProgress,
          finished: finished,
          revenue: revenue,
          totalToday: queue + inProgress + finished,
        );
      })
      .handleError((error, stackTrace) {
        print('❌ [StaffStats] Stream ERROR: $error');
        print('❌ [StaffStats] Stack: $stackTrace');
        throw error;
      });
});
