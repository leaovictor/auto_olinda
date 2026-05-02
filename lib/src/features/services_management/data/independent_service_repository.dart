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
                  // print('Error parsing independent service ${doc.id}: $e');
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
              // print('Error parsing independent service ${doc.id}: $e');
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
    // Simplified query without whereNotIn to avoid composite index requirement
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
        .get();

    // Count bookings per time slot (filter cancelled/no_show in code)
    final bookedSlots = <String, int>{};
    for (final doc in bookingsQuery.docs) {
      final data = doc.data();
      final status = data['status'] as String?;

      // Skip cancelled and no_show bookings
      if (status == 'cancelled' || status == 'no_show') continue;

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
                  // print('Error parsing availability ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<ServiceAvailability>()
              .toList();
        });
  }

  /// Get default weekly availability schedule for a service
  /// Returns a map where key = day of week (1-7), value = list of time slots with capacity
  Future<Map<int, List<Map<String, dynamic>>>> getServiceDefaultAvailability(
    String serviceId,
  ) async {
    final doc = await _firestore
        .collection('independent_services')
        .doc(serviceId)
        .get();

    if (!doc.exists) return {};

    final data = doc.data();
    final weeklySchedule = data?['weeklySchedule'] as Map<String, dynamic>?;

    if (weeklySchedule == null) return {};

    final result = <int, List<Map<String, dynamic>>>{};
    for (final entry in weeklySchedule.entries) {
      final dayIndex = int.tryParse(entry.key);
      if (dayIndex != null && entry.value is List) {
        result[dayIndex] = (entry.value as List)
            .map((slot) => Map<String, dynamic>.from(slot as Map))
            .toList();
      }
    }
    return result;
  }

  /// Save default weekly availability schedule for a service
  Future<void> saveServiceDefaultAvailability(
    String serviceId,
    Map<int, List<Map<String, dynamic>>> availability,
  ) async {
    // Convert int keys to strings for Firestore
    final weeklySchedule = <String, dynamic>{};
    for (final entry in availability.entries) {
      weeklySchedule[entry.key.toString()] = entry.value;
    }

    await _firestore.collection('independent_services').doc(serviceId).update({
      'weeklySchedule': weeklySchedule,
    });

    // Also generate availability entries for the next 60 days
    await _generateAvailabilityFromSchedule(serviceId, weeklySchedule);
  }

  /// Generate daily availability entries from weekly schedule
  Future<void> _generateAvailabilityFromSchedule(
    String serviceId,
    Map<String, dynamic> weeklySchedule,
  ) async {
    final batch = _firestore.batch();
    final now = DateTime.now();

    for (int i = 0; i < 60; i++) {
      final date = now.add(Duration(days: i));
      final dayOfWeek = date.weekday; // 1 = Monday, 7 = Sunday
      final daySchedule = weeklySchedule[dayOfWeek.toString()] as List?;

      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final docId = '${dateStr}_$serviceId';
      final docRef = _firestore.collection('service_availability').doc(docId);

      if (daySchedule != null && daySchedule.isNotEmpty) {
        final slots = <String, int>{};
        for (final slot in daySchedule) {
          if (slot is Map) {
            slots[slot['time'] as String] = slot['capacity'] as int;
          }
        }
        batch.set(docRef, {
          'serviceId': serviceId,
          'date': dateStr,
          'slots': slots,
          'isOpen': true,
        });
      } else {
        batch.set(docRef, {
          'serviceId': serviceId,
          'date': dateStr,
          'slots': <String, int>{},
          'isOpen': false,
        });
      }
    }

    await batch.commit();
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
                    'updatedAt': data['updatedAt'] != null
                        ? (data['updatedAt'] as Timestamp)
                              .toDate()
                              .toIso8601String()
                        : null,
                  });
                } catch (e) {
                  // print('Error parsing service booking ${doc.id}: $e');
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
                    'createdAt': data['createdAt'] != null
                        ? (data['createdAt'] as Timestamp)
                              .toDate()
                              .toIso8601String()
                        : null,
                    'updatedAt': data['updatedAt'] != null
                        ? (data['updatedAt'] as Timestamp)
                              .toDate()
                              .toIso8601String()
                        : null,
                  });
                } catch (e) {
                  // print('Error parsing service booking ${doc.id}: $e');
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
                  // print('Error parsing service booking ${doc.id}: $e');
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

  /// Update payment status
  Future<void> updatePaymentStatus(
    String bookingId,
    PaymentStatus status, {
    double? paidAmount,
  }) async {
    final updates = <String, dynamic>{
      'paymentStatus': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (paidAmount != null) {
      updates['paidAmount'] = paidAmount;
    }

    await _firestore
        .collection('service_bookings')
        .doc(bookingId)
        .update(updates);
  }

  /// Cancel a booking
  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(bookingId, ServiceBookingStatus.cancelled);
  }

  /// Approve a pending booking (admin action)
  Future<void> approveBooking(String bookingId) async {
    await _firestore.collection('service_bookings').doc(bookingId).update({
      'status': 'scheduled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Reject a pending booking with reason (admin action)
  Future<void> rejectBooking(String bookingId, String reason) async {
    await _firestore.collection('service_bookings').doc(bookingId).update({
      'status': 'rejected',
      'rejectionReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get pending approval bookings stream (for admin alerts)
  Stream<List<ServiceBooking>> getPendingApprovalBookingsStream() {
    return _firestore
        .collection('service_bookings')
        .where('status', isEqualTo: 'pending_approval')
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
                    'createdAt': data['createdAt'] != null
                        ? (data['createdAt'] as Timestamp)
                              .toDate()
                              .toIso8601String()
                        : null,
                  });
                } catch (e) {
                  // print('Error parsing pending booking ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<ServiceBooking>()
              .toList();
        });
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

/// Provider for fetching a single service by ID
final independentServiceProvider =
    FutureProvider.family<IndependentService?, String>((ref, serviceId) {
      return ref
          .watch(independentServiceRepositoryProvider)
          .getService(serviceId);
    });

/// Provider for pending approval bookings (admin alerts)
final pendingApprovalBookingsProvider = StreamProvider<List<ServiceBooking>>((
  ref,
) {
  return ref
      .watch(independentServiceRepositoryProvider)
      .getPendingApprovalBookingsStream();
});
