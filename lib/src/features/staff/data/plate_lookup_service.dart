import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../booking/domain/booking.dart';
import '../../profile/domain/vehicle.dart';

/// Service for looking up active bookings by vehicle plate
class PlateLookupService {
  final FirebaseFirestore _firestore;

  PlateLookupService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Search for vehicles by plate (partial match, case insensitive)
  /// Returns list of matching vehicles with their IDs
  Future<List<Vehicle>> searchVehiclesByPlate(String plateQuery) async {
    if (plateQuery.trim().isEmpty) return [];

    final normalizedQuery = plateQuery.toUpperCase().replaceAll('-', '').trim();
    if (normalizedQuery.length < 3) return []; // Require at least 3 chars

    // Query vehicles from root collection (staff has permission to read)
    final snapshot = await _firestore.collection('vehicles').get();

    final vehicles = <Vehicle>[];
    for (final doc in snapshot.docs) {
      try {
        final data = doc.data();
        final plate = (data['plate'] as String? ?? '').toUpperCase().replaceAll(
          '-',
          '',
        );
        if (plate.contains(normalizedQuery)) {
          vehicles.add(
            Vehicle(
              id: doc.id,
              brand: data['brand'] ?? '',
              model: data['model'] ?? '',
              plate: data['plate'] ?? '',
              color: data['color'] ?? '',
              type: data['type'] ?? 'sedan',
              photoUrl: data['photoUrl'],
            ),
          );
        }
      } catch (_) {
        // Skip malformed documents
      }
    }

    return vehicles;
  }

  /// Find the active booking for a specific vehicle
  /// Active = not finished, not cancelled, not noShow
  Future<Booking?> findActiveBookingForVehicle(String vehicleId) async {
    // print('🔍 findActiveBookingForVehicle: vehicleId = $vehicleId');

    // Simple query without complex composite index requirements
    final snapshot = await _firestore
        .collection('appointments')
        .where('vehicleId', isEqualTo: vehicleId)
        .get();

    // print('🔍 Found ${snapshot.docs.length} appointments for this vehicle');

    if (snapshot.docs.isEmpty) return null;

    // Filter active bookings in memory and get the most recent
    final activeStatuses = [
      'scheduled',
      'confirmed',
      'checkIn',
      'washing',
      'vacuuming',
      'drying',
      'polishing',
    ];

    Booking? latestBooking;
    DateTime? latestTime;

    for (final doc in snapshot.docs) {
      try {
        final data = doc.data();
        final status = data['status'] as String?;
        // print('🔍 Appointment ${doc.id}: status = $status');

        if (status != null && activeStatuses.contains(status)) {
          // Handle scheduledTime as Timestamp or String
          final scheduledTime = data['scheduledTime'];
          String scheduledTimeStr;
          if (scheduledTime is Timestamp) {
            scheduledTimeStr = scheduledTime.toDate().toIso8601String();
          } else if (scheduledTime is String) {
            scheduledTimeStr = scheduledTime;
          } else {
            scheduledTimeStr = DateTime.now().toIso8601String();
          }

          final booking = Booking.fromJson({
            'id': doc.id,
            ...data,
            'scheduledTime': scheduledTimeStr,
          });

          if (latestTime == null || booking.scheduledTime.isAfter(latestTime)) {
            latestBooking = booking;
            latestTime = booking.scheduledTime;
          }
        }
      } catch (e) {
        // print('🔍 Error parsing appointment: $e');
      }
    }

    // print('🔍 Returning booking: ${latestBooking?.id}');
    return latestBooking;
  }

  /// Find active booking by plate directly
  /// Returns the booking if found, null otherwise
  Future<BookingSearchResult?> findActiveBookingByPlate(String plate) async {
    // print('🔍 findActiveBookingByPlate: plate = $plate');
    final normalizedPlate = plate.toUpperCase().replaceAll('-', '').trim();
    // print('🔍 Normalized plate: $normalizedPlate');
    if (normalizedPlate.isEmpty) return null;

    // Query vehicles from root collection
    // print('🔍 Querying vehicles collection...');
    final vehicleSnapshot = await _firestore.collection('vehicles').get();
    // print('🔍 Found ${vehicleSnapshot.docs.length} total vehicles');

    Vehicle? matchedVehicle;
    for (final doc in vehicleSnapshot.docs) {
      try {
        final data = doc.data();
        final vehiclePlate = (data['plate'] as String? ?? '')
            .toUpperCase()
            .replaceAll('-', '');
        // print(
        //   '🔍 Checking vehicle: plate=$vehiclePlate (raw: ${data['plate']})',
        // );
        if (vehiclePlate == normalizedPlate) {
          // print('🔍 Found matching vehicle: ${doc.id}');
          matchedVehicle = Vehicle(
            id: doc.id,
            brand: data['brand'] ?? '',
            model: data['model'] ?? '',
            plate: data['plate'] ?? '',
            color: data['color'] ?? '',
            type: data['type'] ?? 'sedan',
            photoUrl: data['photoUrl'],
          );
          break;
        }
      } catch (e) {
        // print('🔍 Error parsing vehicle: $e');
      }
    }

    if (matchedVehicle == null) {
      // print('🔍 No vehicle found with this plate');
      return null;
    }

    // print('🔍 Searching for active booking for vehicle ${matchedVehicle.id}');
    // Now find active booking for this vehicle
    final booking = await findActiveBookingForVehicle(matchedVehicle.id);
    if (booking == null) {
      // print('🔍 No active booking found for this vehicle');
      return null;
    }

    // print('🔍 Found booking: ${booking.id}');
    return BookingSearchResult(booking: booking, vehicle: matchedVehicle);
  }

  /// Get today's bookings for quick stats
  Future<TodayStats> getTodayStats() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('appointments')
        .where(
          'scheduledTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('scheduledTime', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    int queue = 0;
    int inProgress = 0;
    int finished = 0;

    for (final doc in snapshot.docs) {
      final status = doc.data()['status'] as String?;
      switch (status) {
        case 'scheduled':
        case 'confirmed':
        case 'checkIn':
          queue++;
          break;
        case 'washing':
        case 'vacuuming':
        case 'drying':
        case 'polishing':
          inProgress++;
          break;
        case 'finished':
          finished++;
          break;
      }
    }

    return TodayStats(queue: queue, inProgress: inProgress, finished: finished);
  }
}

/// Result of a booking search including the vehicle info
class BookingSearchResult {
  final Booking booking;
  final Vehicle vehicle;

  BookingSearchResult({required this.booking, required this.vehicle});
}

/// Today's booking statistics
class TodayStats {
  final int queue;
  final int inProgress;
  final int finished;

  TodayStats({
    required this.queue,
    required this.inProgress,
    required this.finished,
  });

  int get total => queue + inProgress + finished;
}

// Providers
final plateLookupServiceProvider = Provider<PlateLookupService>((ref) {
  return PlateLookupService();
});

final todayStatsProvider = FutureProvider<TodayStats>((ref) {
  return ref.watch(plateLookupServiceProvider).getTodayStats();
});
