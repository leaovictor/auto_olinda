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

    // Query all vehicles and filter in memory (Firestore doesn't support LIKE)
    // This is acceptable because vehicles collection is relatively small
    final snapshot = await _firestore.collectionGroup('vehicles').get();

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
    final snapshot = await _firestore
        .collection('appointments')
        .where('vehicleId', isEqualTo: vehicleId)
        .where('status', whereNotIn: ['finished', 'cancelled', 'noShow'])
        .orderBy('status')
        .orderBy('scheduledTime', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    try {
      final doc = snapshot.docs.first;
      final data = doc.data();
      return Booking.fromJson({
        'id': doc.id,
        ...data,
        'scheduledTime': (data['scheduledTime'] as Timestamp)
            .toDate()
            .toIso8601String(),
      });
    } catch (e) {
      return null;
    }
  }

  /// Find active booking by plate directly
  /// Returns the booking if found, null otherwise
  Future<BookingSearchResult?> findActiveBookingByPlate(String plate) async {
    final normalizedPlate = plate.toUpperCase().replaceAll('-', '').trim();
    if (normalizedPlate.isEmpty) return null;

    // First find the vehicle with this exact plate
    final vehicleSnapshot = await _firestore.collectionGroup('vehicles').get();

    Vehicle? matchedVehicle;
    for (final doc in vehicleSnapshot.docs) {
      try {
        final data = doc.data();
        final vehiclePlate = (data['plate'] as String? ?? '')
            .toUpperCase()
            .replaceAll('-', '');
        if (vehiclePlate == normalizedPlate) {
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
      } catch (_) {
        // Skip malformed documents
      }
    }

    if (matchedVehicle == null) return null;

    // Now find active booking for this vehicle
    final booking = await findActiveBookingForVehicle(matchedVehicle.id);
    if (booking == null) return null;

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
