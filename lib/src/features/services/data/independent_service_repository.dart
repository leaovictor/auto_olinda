import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../domain/independent_service.dart';
import '../domain/service_availability.dart';
import '../domain/service_booking.dart';

/// Repository for managing independent services
class IndependentServiceRepository {
  final FirebaseFirestore _firestore;

  IndependentServiceRepository(this._firestore);

  // ==================== SERVICES ====================

  /// Get all active independent services
  Stream<List<IndependentService>> getServicesStream() {
    return _firestore
        .collection('independent_services')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data();
                  return IndependentService.fromJson({
                    ...data,
                    'id': doc.id,
                    'createdAt': data['createdAt'] != null
                        ? (data['createdAt'] as Timestamp)
                              .toDate()
                              .toIso8601String()
                        : null,
                  });
                } catch (e) {
                  print('Error parsing independent service ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<IndependentService>()
              .toList();
        });
  }

  /// Get all services (including inactive) for admin
  Stream<List<IndependentService>> getAllServicesStream() {
    return _firestore.collection('independent_services').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              return IndependentService.fromJson({
                ...data,
                'id': doc.id,
                'createdAt': data['createdAt'] != null
                    ? (data['createdAt'] as Timestamp)
                          .toDate()
                          .toIso8601String()
                    : null,
              });
            } catch (e) {
              print('Error parsing independent service ${doc.id}: $e');
              return null;
            }
          })
          .whereType<IndependentService>()
          .toList();
    });
  }

  /// Get a single service by ID
  Future<IndependentService?> getService(String serviceId) async {
    final doc = await _firestore
        .collection('independent_services')
        .doc(serviceId)
        .get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return IndependentService.fromJson({
      ...data,
      'id': doc.id,
      'createdAt': data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
          : null,
    });
  }

  /// Create a new independent service
  Future<String> createService(IndependentService service) async {
    final data = service.toJson();
    data.remove('id');
    data['createdAt'] = FieldValue.serverTimestamp();
    final docRef = await _firestore
        .collection('independent_services')
        .add(data);
    return docRef.id;
  }

  /// Update an existing service
  Future<void> updateService(IndependentService service) async {
    final data = service.toJson();
    data.remove('id');
    await _firestore
        .collection('independent_services')
        .doc(service.id)
        .update(data);
  }

  /// Toggle service active status
  Future<void> toggleServiceActive(String serviceId, bool isActive) async {
    await _firestore.collection('independent_services').doc(serviceId).update({
      'isActive': isActive,
    });
  }

  /// Delete a service
  Future<void> deleteService(String serviceId) async {
    await _firestore.collection('independent_services').doc(serviceId).delete();
  }

  // ==================== AVAILABILITY ====================

  /// Get availability for a specific date and service
  Future<ServiceAvailability?> getAvailability(
    String date,
    String serviceId,
  ) async {
    final docId = '${date}_$serviceId';
    final doc = await _firestore
        .collection('service_availability')
        .doc(docId)
        .get();
    if (!doc.exists) return null;
    return ServiceAvailability.fromJson(doc.data()!);
  }

  /// Get available slots for a date and service
  Future<Map<String, int>> getAvailableSlots(
    DateTime date,
    String serviceId,
  ) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final availability = await getAvailability(dateStr, serviceId);

    if (availability == null || !availability.isOpen) {
      return {}; // No slots available
    }

    // Get existing bookings for this date and service
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final bookingsQuery = await _firestore
        .collection('service_bookings')
        .where('serviceId', isEqualTo: serviceId)
        .where(
          'scheduledTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('scheduledTime', isLessThan: Timestamp.fromDate(endOfDay))
        .where('status', whereNotIn: ['cancelled', 'no_show'])
        .get();

    // Count bookings per time slot
    final bookedSlots = <String, int>{};
    for (final doc in bookingsQuery.docs) {
      final data = doc.data();
      final scheduledTime = (data['scheduledTime'] as Timestamp).toDate();
      final timeStr = DateFormat('HH:mm').format(scheduledTime);
      bookedSlots[timeStr] = (bookedSlots[timeStr] ?? 0) + 1;
    }

    // Calculate remaining slots
    final availableSlots = <String, int>{};
    for (final entry in availability.slots.entries) {
      final remaining = entry.value - (bookedSlots[entry.key] ?? 0);
      if (remaining > 0) {
        availableSlots[entry.key] = remaining;
      }
    }

    return availableSlots;
  }

  /// Save availability configuration
  Future<void> saveAvailability(ServiceAvailability availability) async {
    final docId = '${availability.date}_${availability.serviceId}';
    await _firestore
        .collection('service_availability')
        .doc(docId)
        .set(availability.toJson());
  }

  /// Get all availability configs for a service (admin view)
  Stream<List<ServiceAvailability>> getServiceAvailabilityStream(
    String serviceId,
  ) {
    return _firestore
        .collection('service_availability')
        .where('serviceId', isEqualTo: serviceId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  return ServiceAvailability.fromJson(doc.data());
                } catch (e) {
                  print('Error parsing availability ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<ServiceAvailability>()
              .toList();
        });
  }

  // ==================== BOOKINGS ====================

  /// Create a new service booking
  Future<String> createBooking(ServiceBooking booking) async {
    // Verify availability first
    final timeStr = DateFormat('HH:mm').format(booking.scheduledTime);

    final availableSlots = await getAvailableSlots(
      booking.scheduledTime,
      booking.serviceId,
    );

    if (!availableSlots.containsKey(timeStr) || availableSlots[timeStr]! <= 0) {
      throw Exception('Horário não disponível');
    }

    final data = booking.toJson();
    data.remove('id');
    data['createdAt'] = FieldValue.serverTimestamp();
    data['scheduledTime'] = Timestamp.fromDate(booking.scheduledTime);

    final docRef = await _firestore.collection('service_bookings').add(data);
    return docRef.id;
  }

  /// Get user's service bookings
  Stream<List<ServiceBooking>> getUserBookingsStream(String userId) {
    return _firestore
        .collection('service_bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('scheduledTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data();
                  return ServiceBooking.fromJson({
                    ...data,
                    'id': doc.id,
                    'scheduledTime': (data['scheduledTime'] as Timestamp)
                        .toDate()
                        .toIso8601String(),
                    'createdAt': data['createdAt'] != null
                        ? (data['createdAt'] as Timestamp)
                              .toDate()
                              .toIso8601String()
                        : null,
                  });
                } catch (e) {
                  print('Error parsing service booking ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<ServiceBooking>()
              .toList();
        });
  }

  /// Get all service bookings (admin)
  Stream<List<ServiceBooking>> getAllBookingsStream() {
    return _firestore
        .collection('service_bookings')
        .orderBy('scheduledTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data();
                  return ServiceBooking.fromJson({
                    ...data,
                    'id': doc.id,
                    'scheduledTime': (data['scheduledTime'] as Timestamp)
                        .toDate()
                        .toIso8601String(),
                  });
                } catch (e) {
                  print('Error parsing service booking ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<ServiceBooking>()
              .toList();
        });
  }

  /// Get bookings for a specific date
  Stream<List<ServiceBooking>> getBookingsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('service_bookings')
        .where(
          'scheduledTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('scheduledTime', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('scheduledTime')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data();
                  return ServiceBooking.fromJson({
                    ...data,
                    'id': doc.id,
                    'scheduledTime': (data['scheduledTime'] as Timestamp)
                        .toDate()
                        .toIso8601String(),
                  });
                } catch (e) {
                  print('Error parsing service booking ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<ServiceBooking>()
              .toList();
        });
  }

  /// Update booking status
  Future<void> updateBookingStatus(
    String bookingId,
    ServiceBookingStatus status,
  ) async {
    await _firestore.collection('service_bookings').doc(bookingId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Cancel a booking
  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(bookingId, ServiceBookingStatus.cancelled);
  }

  /// Get a single booking
  Future<ServiceBooking?> getBooking(String bookingId) async {
    final doc = await _firestore
        .collection('service_bookings')
        .doc(bookingId)
        .get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return ServiceBooking.fromJson({
      ...data,
      'id': doc.id,
      'scheduledTime': (data['scheduledTime'] as Timestamp)
          .toDate()
          .toIso8601String(),
    });
  }
}

// ==================== PROVIDERS ====================

final independentServiceRepositoryProvider =
    Provider<IndependentServiceRepository>((ref) {
      return IndependentServiceRepository(FirebaseFirestore.instance);
    });

final independentServicesProvider = StreamProvider<List<IndependentService>>((
  ref,
) {
  return ref.watch(independentServiceRepositoryProvider).getServicesStream();
});

final allIndependentServicesProvider = StreamProvider<List<IndependentService>>(
  (ref) {
    return ref
        .watch(independentServiceRepositoryProvider)
        .getAllServicesStream();
  },
);

final serviceAvailableSlotsProvider =
    FutureProvider.family<Map<String, int>, (DateTime, String)>((ref, args) {
      final (date, serviceId) = args;
      return ref
          .watch(independentServiceRepositoryProvider)
          .getAvailableSlots(date, serviceId);
    });

final userServiceBookingsProvider =
    StreamProvider.family<List<ServiceBooking>, String>((ref, userId) {
      return ref
          .watch(independentServiceRepositoryProvider)
          .getUserBookingsStream(userId);
    });

final allServiceBookingsProvider = StreamProvider<List<ServiceBooking>>((ref) {
  return ref.watch(independentServiceRepositoryProvider).getAllBookingsStream();
});

final serviceBookingsForDateProvider =
    StreamProvider.family<List<ServiceBooking>, DateTime>((ref, date) {
      return ref
          .watch(independentServiceRepositoryProvider)
          .getBookingsForDate(date);
    });
