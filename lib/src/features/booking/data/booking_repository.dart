// Photo upload and booking management
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../features/booking/domain/availability.dart';
import '../../../features/booking/domain/booking.dart';
import '../../../features/booking/domain/service_package.dart';
import '../../../features/profile/domain/vehicle.dart';
import '../../admin/data/analytics_repository.dart';
import '../../../core/tenant/tenant_firestore.dart';
import '../../../core/tenant/tenant_service.dart';

class BookingRepository {
  final String _tenantId;

  final AnalyticsRepository _analytics;

  BookingRepository(FirebaseFirestore firestore, this._tenantId)
    : _analytics = AnalyticsRepository(firestore, _tenantId);

  // Services
  Stream<List<ServicePackage>> getServicesStream() {
    return TenantFirestore.col('services', _tenantId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              return ServicePackage.fromJson({
                ...data,
                'id': doc.id,
                'title': data['title'] ?? 'Serviço sem título',
                'description': data['description'] ?? '',
                'price': (data['price'] as num?)?.toDouble() ?? 0.0,
                'durationMinutes': data['durationMinutes'] ?? 0,
              });
            } catch (e) {
              return null;
            }
          })
          .whereType<ServicePackage>()
          .toList();
    });
  }

  Future<void> createService(ServicePackage service) async {
    final data = service.toJson();
    data.remove('id');
    await TenantFirestore.col('services', _tenantId).add(data);
  }

  Future<void> updateService(ServicePackage service) async {
    final data = service.toJson();
    data.remove('id');
    await TenantFirestore.doc('services', service.id, _tenantId).update(data);
  }

  Future<void> deleteService(String serviceId) async {
    await TenantFirestore.doc('services', serviceId, _tenantId).delete();
  }

  Future<ServicePackage?> getService(String serviceId) async {
    final doc = await TenantFirestore.doc('services', serviceId, _tenantId).get();
    if (!doc.exists) return null;
    return ServicePackage.fromJson({...doc.data()!, 'id': doc.id});
  }

  // Vehicles
  Stream<List<Vehicle>> getUserVehicles(String userId) {
    return TenantFirestore.col('vehicles', _tenantId)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data();
                  return Vehicle.fromJson({
                    ...data,
                    'id': doc.id,
                    'brand': data['brand'] ?? 'Marca desconhecida',
                    'model': data['model'] ?? 'Modelo desconhecido',
                    'plate': data['plate'] ?? '',
                    'color': data['color'] ?? '',
                    'type': data['type'] ?? 'sedan',
                  });
                } catch (e) {
                  return null;
                }
              })
              .whereType<Vehicle>()
              .toList();
        });
  }

  Future<DocumentReference> createVehicle(Vehicle vehicle, String userId) {
    final data = vehicle.toJson();
    data.remove('id');

    return TenantFirestore.col('vehicles', _tenantId).add({
      ...data,
      'userId': userId,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<Vehicle?> getVehicle(String vehicleId) async {
    final doc = await TenantFirestore.doc('vehicles', vehicleId, _tenantId).get();
    if (!doc.exists) return null;
    return Vehicle.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// Upload photo using bytes (works on web and mobile)
  Future<String> uploadPhotoBytes(List<int> bytes, String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);

      // Upload the bytes
      final uploadTask = ref.putData(
        Uint8List.fromList(bytes),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get and return the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      // print('📷 Photo uploaded (bytes): $downloadUrl');
      return downloadUrl;
    } catch (e) {
      // print('❌ Error uploading photo bytes: $e');
      // Fallback to mock URL for testing if Storage is not configured
      if (e.toString().contains('storage') || e.toString().contains('bucket')) {
        // print('⚠️ Using mock URL - Firebase Storage may not be configured');
        return 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}';
      }
      throw Exception('Erro ao fazer upload da foto: $e');
    }
  }

  Future<void> addBookingPhoto(
    String bookingId,
    String photoUrl,
    bool isBefore,
  ) async {
    final field = isBefore ? 'beforePhotos' : 'afterPhotos';
    await TenantFirestore.doc('appointments', bookingId, _tenantId).update({
      field: FieldValue.arrayUnion([photoUrl]),
    });
  }

  Future<void> removeBookingPhoto(
    String bookingId,
    String photoUrl,
    bool isBefore,
  ) async {
    final field = isBefore ? 'beforePhotos' : 'afterPhotos';
    await TenantFirestore.doc('appointments', bookingId, _tenantId).update({
      field: FieldValue.arrayRemove([photoUrl]),
    });
  }

  // Appointments / Bookings
  Future<bool> checkAvailability(DateTime startTime) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(startTime);
    final timeStr = DateFormat('HH:mm').format(startTime);

    // 1. Get Availability Config
    final availabilityDoc = await TenantFirestore.doc(
      'availability',
      dateStr,
      _tenantId,
    ).get();

    if (!availabilityDoc.exists) {
      // Default: Open, 2 slots
      return true;
    }

    final availability = Availability.fromJson(availabilityDoc.data()!);
    if (!availability.isOpen) return false;

    final maxSlots = availability.slots[timeStr] ?? 2;

    // 2. Count Existing Appointments
    final appointmentsQuery = await TenantFirestore.col('appointments', _tenantId)
        .where('scheduledTime', isEqualTo: startTime.toIso8601String())
        .where('status', isNotEqualTo: 'cancelled')
        .get();

    return appointmentsQuery.docs.length < maxSlots;
  }

  Future<String> createBooking(Booking booking) async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );

      // V2 endpoint: multi-tenant aware
      final callable = functions.httpsCallable('createBookingV2');

      final payload = {
        'vehicleId': booking.vehicleId,
        'serviceIds': booking.serviceIds,
        'scheduledTime': booking.scheduledTime.toUtc().toIso8601String(),
        'staffNotes': booking.staffNotes,
      };

      // print('🟢 Payload to send: $payload');
      // print('   -> serviceIds type: ${booking.serviceIds.runtimeType}');
      // print('   -> serviceIds content: ${booking.serviceIds}');

      // Convert proper types
      final result = await callable.call(payload);

      final data = result.data as Map<String, dynamic>;
      final bookingId = data['bookingId'] as String;

      // print('✅ Repository: Booking created via function! ID: $bookingId');
      return bookingId;
    } on FirebaseFunctionsException catch (e) {
      // print('❌ Cloud Function Error: ${e.code} - ${e.message}');
      // print('❌ Details: ${e.details}');
      // Preserve error code so controller can handle specific errors properly
      throw Exception(
        '[firebase_functions/${e.code}] ${e.message ?? 'Erro ao processar agendamento.'}',
      );
    } catch (e) {
      // print('❌ Repository: Failed to create booking via function - $e');
      throw Exception('Erro ao processar agendamento: $e');
    }
  }

  Map<String, dynamic> _mapBookingData(String id, Map<String, dynamic> data) {
    try {
      final scheduledTime = data['scheduledTime'];
      String scheduledTimeStr;
      if (scheduledTime is Timestamp) {
        scheduledTimeStr = scheduledTime.toDate().toIso8601String();
      } else if (scheduledTime is String) {
        scheduledTimeStr = scheduledTime;
      } else {
        // Fallback for missing/invalid date
        scheduledTimeStr = DateTime.now().toIso8601String();
      }

      // Handle cancelledAt
      String? cancelledAtStr;
      final cancelledAt = data['cancelledAt'];
      if (cancelledAt is Timestamp) {
        cancelledAtStr = cancelledAt.toDate().toIso8601String();
      } else if (cancelledAt is String) {
        cancelledAtStr = cancelledAt;
      }

      // Handle paidAt
      String? paidAtStr;
      final paidAt = data['paidAt'];
      if (paidAt is Timestamp) {
        paidAtStr = paidAt.toDate().toIso8601String();
      } else if (paidAt is String) {
        paidAtStr = paidAt;
      }

      // Handle createdAt
      String? createdAtStr;
      final createdAt = data['createdAt'] ?? data['created_at'];
      if (createdAt is Timestamp) {
        createdAtStr = createdAt.toDate().toIso8601String();
      } else if (createdAt is String) {
        createdAtStr = createdAt;
      }

      // Handle logs - convert each map item properly for minified web builds
      // In minified builds, Firestore returns internal map types that can't be
      // directly cast to Map<String, dynamic>, causing type cast errors.
      List<Map<String, dynamic>>? mappedLogs;
      final rawLogs = data['logs'];
      if (rawLogs != null && rawLogs is List) {
        mappedLogs = rawLogs.map((log) {
          if (log is Map) {
            // Safely convert to Map<String, dynamic>
            final logMap = Map<String, dynamic>.from(log);
            // Also handle timestamp in log entries
            final logTimestamp = logMap['timestamp'];
            if (logTimestamp is Timestamp) {
              logMap['timestamp'] = logTimestamp.toDate().toIso8601String();
            }
            return logMap;
          }
          return <String, dynamic>{};
        }).toList();
      }

      return {
        ...data,
        'id': id,
        'scheduledTime': scheduledTimeStr,
        'cancelledAt': cancelledAtStr,
        'paidAt': paidAtStr,
        'createdAt': createdAtStr,
        'status': data['status'] ?? 'scheduled',
        'totalPrice': (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
        if (mappedLogs != null) 'logs': mappedLogs,
      };
    } catch (e) {
      // Re-throw so the caller can log the specific document ID if needed
      rethrow;
    }
  }

  Stream<List<Booking>> getUserBookings(String userId) {
    return TenantFirestore.col('appointments', _tenantId)
        .where('userId', isEqualTo: userId)
        .orderBy('scheduledTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data();
                  final mappedData = _mapBookingData(doc.id, data);
                  return Booking.fromJson(mappedData);
                } catch (e) {
                  return null;
                }
              })
              .whereType<Booking>()
              .toList();
        });
  }

  Stream<List<Booking>> getAllBookings() {
    return TenantFirestore.col('appointments', _tenantId)
        .orderBy('scheduledTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  return Booking.fromJson(_mapBookingData(doc.id, doc.data()));
                } catch (e) {
                  print('Error parsing booking ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<Booking>()
              .toList();
        });
  }

  Stream<Booking> getBookingStream(String bookingId) {
    return TenantFirestore.doc('appointments', bookingId, _tenantId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            throw Exception('Agendamento não encontrado');
          }
          return Booking.fromJson(_mapBookingData(doc.id, doc.data()!));
        });
  }

  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status, {
    String? message,
    String? actorId,
  }) {
    final Map<String, dynamic> updates = {'status': status.name};

    if (actorId != null) {
      final log = BookingLog(
        message: message ?? 'Status updated to ${status.name}',
        timestamp: DateTime.now(),
        actorId: actorId,
        status: status,
      );
      updates['logs'] = FieldValue.arrayUnion([log.toJson()]);
    }

    return TenantFirestore.doc('appointments', bookingId, _tenantId)
        .update(updates)
        .then((_) async {
          // Log wash completion if status is finished
          if (status == BookingStatus.finished) {
            try {
              final bookingDoc = await TenantFirestore.doc(
                'appointments',
                bookingId,
                _tenantId,
              ).get();
              if (bookingDoc.exists && bookingDoc.data() != null) {
                final data = bookingDoc.data()!;

                // Map data safely
                final userId = data['userId'] as String?;
                final totalPrice =
                    (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
                final serviceIds = (data['serviceIds'] as List?)
                    ?.cast<String>();
                final paymentStatus = data['paymentStatus'] as String?;

                // Determine service type
                final serviceType = paymentStatus == 'subscription'
                    ? 'subscription'
                    : 'single';

                await _analytics.logWash(
                  bookingId: bookingId,
                  serviceType: serviceType,
                  value: totalPrice,
                  userId: userId,
                  serviceIds: serviceIds,
                );
              }
            } catch (e) {
              print('Error logging wash analytics: $e');
            }
          }
        });
  }

  /// Update payment status for a booking (called by staff)
  Future<void> updatePaymentStatus(
    String bookingId,
    BookingPaymentStatus paymentStatus, {
    String? paymentMethod,
    String? staffId,
  }) {
    final Map<String, dynamic> updates = {
      'paymentStatus': paymentStatus.name,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (staffId != null) 'paidByStaffId': staffId,
      if (paymentStatus != BookingPaymentStatus.pending)
        'paidAt': FieldValue.serverTimestamp(),
    };

    return TenantFirestore.doc('appointments', bookingId, _tenantId)
        .update(updates);
  }

  Future<void> cancelBooking(
    String bookingId, {
    required String actorId,
    String actorRole =
        'client', // Default to client, explicitly override for admin
    String? cancellationReason,
  }) async {
    try {
      // print('🟠 Repository.cancelBooking: Calling Cloud Function...');
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      final callable = functions.httpsCallable('cancelBooking');

      final payload = {
        'bookingId': bookingId,
        'actorId': actorId,
        'cancelledBy': actorRole,
        'reason': cancellationReason,
      };

      // print('🟠 Payload: $payload');

      await callable.call(payload);
      // print('✅ Repository: Booking cancelled via function.');
    } on FirebaseFunctionsException catch (e) {
      // print('❌ Cloud Function Error: ${e.code} - ${e.message}');
      // Preserve error code so controller can handle specific errors properly
      throw Exception(
        '[firebase_functions/${e.code}] ${e.message ?? 'Erro ao cancelar agendamento.'}',
      );
    } catch (e) {
      // print('❌ Repository: Failed to cancel booking - $e');
      throw Exception('Erro ao cancelar agendamento: $e');
    }
  }

  Future<void> markAsRated(
    String bookingId,
    int rating,
    String? comment,
    List<String> selectedTags,
  ) {
    return TenantFirestore.doc('appointments', bookingId, _tenantId).update({
      'isRated': true,
      'rating': rating,
      'ratingComment': comment,
      'selectedTags': selectedTags,
      'ratedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAdminResponse(
    String bookingId,
    String adminResponse,
    String adminResponderId,
  ) async {
    await TenantFirestore.doc('appointments', bookingId, _tenantId).update({
      'adminResponse': adminResponse,
      'adminResponseAt': FieldValue.serverTimestamp(),
      'adminResponderId': adminResponderId,
    });
  }

  Stream<List<Booking>> getBookingsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return TenantFirestore.col('appointments', _tenantId)
        .where(
          'scheduledTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('scheduledTime', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('scheduledTime')
        .snapshots()
        .map((snapshot) {
          // print(
          //   '✅ [BookingRepo] Query returned ${snapshot.docs.length} documents',
          // );

          final bookings = snapshot.docs
              .map((doc) {
                try {
                  final booking = Booking.fromJson(
                    _mapBookingData(doc.id, doc.data()),
                  );
                  // print('   📋 Parsed: ${doc.id} - ${booking.status}');
                  return booking;
                } catch (e) {
                  // print('❌ [BookingRepo] Error parsing booking ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<Booking>()
              .toList();

          // print('✅ [BookingRepo] Returning ${bookings.length} valid bookings');
          return bookings;
        })
        .handleError((error, stackTrace) {
          // print('❌ [BookingRepo] Stream ERROR: $error');
          // print('❌ [BookingRepo] Stack: $stackTrace');
          throw error;
        });
  }

  /// Get all bookings within a date range (for history view)
  Future<List<Booking>> getBookingsInRange(DateTime start, DateTime end) async {
    final startOfDay = DateTime(start.year, start.month, start.day);
    final endOfDay = DateTime(
      end.year,
      end.month,
      end.day,
    ).add(const Duration(days: 1));

    final snapshot = await TenantFirestore.col('appointments', _tenantId)
        .where(
          'scheduledTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('scheduledTime', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('scheduledTime', descending: true)
        .get();

    return snapshot.docs
        .map((doc) {
          try {
            return Booking.fromJson(_mapBookingData(doc.id, doc.data()));
          } catch (e) {
            // print('Error parsing booking ${doc.id}: $e');
            return null;
          }
        })
        .whereType<Booking>()
        .toList();
  }

  Future<Booking?> getLastFinishedBookingForVehicle(
    String vehicleId,
    String userId,
  ) async {
    try {
      final query = await TenantFirestore.col('appointments', _tenantId)
          .where('userId', isEqualTo: userId)
          .where('vehicleId', isEqualTo: vehicleId)
          .where('status', isEqualTo: 'finished')
          .orderBy('scheduledTime', descending: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final doc = query.docs.first;
      return Booking.fromJson(_mapBookingData(doc.id, doc.data()));
    } catch (e) {
      return null;
    }
  }

  /// Get the very latest booking for a user (used to detect confirmed payments)
  Future<Booking?> fetchLatestBooking(String userId) async {
    try {
      final query = await TenantFirestore.col('appointments', _tenantId)
          .where('userId', isEqualTo: userId)
          .orderBy('scheduledTime', descending: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final doc = query.docs.first;
      return Booking.fromJson(_mapBookingData(doc.id, doc.data()));
    } catch (e) {
      return null;
    }
  }

  /// Find a specific booking for polling confirmation
  Future<Booking?> findBooking({
    required String userId,
    required String vehicleId,
    required DateTime scheduledTime,
  }) async {
    try {
      final query = await TenantFirestore.col('appointments', _tenantId)
          .where('userId', isEqualTo: userId)
          .where('vehicleId', isEqualTo: vehicleId)
          .get();

      if (query.docs.isEmpty) return null;

      // Filter in memory to handle potential string format differences
      for (final doc in query.docs) {
        final data = doc.data();
        final bookingTimeRaw = data['scheduledTime'];
        DateTime bookingTime;

        if (bookingTimeRaw is Timestamp) {
          bookingTime = bookingTimeRaw.toDate();
        } else if (bookingTimeRaw is String) {
          bookingTime = DateTime.parse(bookingTimeRaw);
        } else {
          continue;
        }

        // Check if times match (same year, month, day, hour, minute)
        // Ignoring seconds/millis which might differ purely due to formatting
        if (bookingTime.year == scheduledTime.year &&
            bookingTime.month == scheduledTime.month &&
            bookingTime.day == scheduledTime.day &&
            bookingTime.hour == scheduledTime.hour &&
            bookingTime.minute == scheduledTime.minute) {
          return Booking.fromJson(_mapBookingData(doc.id, data));
        }
      }

      return null;
    } catch (e) {
      // print('Error finding specific booking: $e');
      return null;
    }
  }

  /// Check if a vehicle already has an active booking at the specified time
  Future<bool> hasExistingBookingForVehicle({
    required String vehicleId,
    required DateTime scheduledTime,
  }) async {
    try {
      final query = await TenantFirestore.col('appointments', _tenantId)
          .where('vehicleId', isEqualTo: vehicleId)
          .get();

      if (query.docs.isEmpty) return false;

      for (final doc in query.docs) {
        final data = doc.data();
        final status = data['status'] as String?;

        // Skip cancelled bookings
        if (status == 'cancelled') continue;

        final bookingTimeRaw = data['scheduledTime'];
        DateTime bookingTime;

        if (bookingTimeRaw is Timestamp) {
          bookingTime = bookingTimeRaw.toDate();
        } else if (bookingTimeRaw is String) {
          bookingTime = DateTime.parse(bookingTimeRaw);
        } else {
          continue;
        }

        // Check if same day and hour
        if (bookingTime.year == scheduledTime.year &&
            bookingTime.month == scheduledTime.month &&
            bookingTime.day == scheduledTime.day &&
            bookingTime.hour == scheduledTime.hour) {
          return true;
        }
      }

      return false;
    } catch (e) {
      // print('Error checking existing booking: $e');
      return false;
    }
  }

  /// Get all bookings for a specific vehicle (for history view)
  Stream<List<Booking>> getVehicleBookings(String vehicleId, String userId) {
    return TenantFirestore.col('appointments', _tenantId)
        .where('userId', isEqualTo: userId)
        .where('vehicleId', isEqualTo: vehicleId)
        .snapshots()
        .map((snapshot) {
          final bookings = snapshot.docs
              .map((doc) {
                try {
                  return Booking.fromJson(_mapBookingData(doc.id, doc.data()));
                } catch (e) {
                  print('Error parsing booking ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<Booking>()
              .toList();

          // Sort in Dart to avoid needing a Firestore composite index
          bookings.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
          return bookings;
        });
  }
}

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final tenantAsync = ref.watch(tenantServiceProvider);
  final tenantId = tenantAsync.valueOrNull?.tenantId ?? '';
  return BookingRepository(FirebaseFirestore.instance, tenantId);
});

final servicesProvider = StreamProvider<List<ServicePackage>>((ref) {
  return ref.watch(bookingRepositoryProvider).getServicesStream();
});

final userVehiclesProvider = StreamProvider.family<List<Vehicle>, String>((
  ref,
  userId,
) {
  return ref.watch(bookingRepositoryProvider).getUserVehicles(userId);
});

final userBookingsProvider = StreamProvider.family<List<Booking>, String>((
  ref,
  userId,
) {
  return ref.watch(bookingRepositoryProvider).getUserBookings(userId);
});

final allBookingsProvider = StreamProvider<List<Booking>>((ref) {
  return ref.watch(bookingRepositoryProvider).getAllBookings();
});

final bookingStreamProvider = StreamProvider.family<Booking, String>((
  ref,
  bookingId,
) {
  return ref.watch(bookingRepositoryProvider).getBookingStream(bookingId);
});

final bookingsForDateProvider = StreamProvider.family<List<Booking>, DateTime>((
  ref,
  date,
) {
  return ref.watch(bookingRepositoryProvider).getBookingsForDate(date);
});

final todayBookingsProvider = StreamProvider<List<Booking>>((ref) {
  return ref
      .watch(bookingRepositoryProvider)
      .getBookingsForDate(DateTime.now());
});

final vehicleProvider = FutureProvider.family<Vehicle?, String>((
  ref,
  vehicleId,
) {
  return ref.watch(bookingRepositoryProvider).getVehicle(vehicleId);
});

final lastVehicleBookingProvider =
    FutureProvider.family<Booking?, (String, String)>((ref, args) {
      final (vehicleId, userId) = args;
      return ref
          .watch(bookingRepositoryProvider)
          .getLastFinishedBookingForVehicle(vehicleId, userId);
    });

/// Provider for streaming all bookings of a specific vehicle (history)
final vehicleBookingsProvider =
    StreamProvider.family<List<Booking>, (String, String)>((ref, args) {
      final (vehicleId, userId) = args;
      return ref
          .watch(bookingRepositoryProvider)
          .getVehicleBookings(vehicleId, userId);
    });
