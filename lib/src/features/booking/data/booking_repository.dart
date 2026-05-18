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
import '../../store/data/current_store_provider.dart';

class BookingRepository {
  final FirebaseFirestore _firestore;
  final String? _storeId;
  final AnalyticsRepository _analytics;

  BookingRepository(this._firestore, [this._storeId])
    : _analytics = AnalyticsRepository(_firestore);

  // Services
  Stream<List<ServicePackage>> getServicesStream() {
    Query query = _firestore.collection('services');
    if (_storeId != null) {
      query = query.where('storeId', isEqualTo: _storeId);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>;
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
    if (_storeId != null) data['storeId'] = _storeId;
    await _firestore.collection('services').add(data);
  }

  Future<void> updateService(ServicePackage service) async {
    final data = service.toJson();
    data.remove('id');
    await _firestore.collection('services').doc(service.id).update(data);
  }

  Future<void> deleteService(String serviceId) async {
    await _firestore.collection('services').doc(serviceId).delete();
  }

  Future<ServicePackage?> getService(String serviceId) async {
    final doc = await _firestore.collection('services').doc(serviceId).get();
    if (!doc.exists) return null;
    return ServicePackage.fromJson({...doc.data()!, 'id': doc.id});
  }

  // Vehicles (Scoped by User, not Store)
  Stream<List<Vehicle>> getUserVehicles(String userId) {
    return _firestore
        .collection('vehicles')
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
    return _firestore.collection('vehicles').add({
      ...data,
      'userId': userId,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<Vehicle?> getVehicle(String vehicleId) async {
    final doc = await _firestore.collection('vehicles').doc(vehicleId).get();
    if (!doc.exists) return null;
    return Vehicle.fromJson({...doc.data()!, 'id': doc.id});
  }

  Future<String> uploadPhotoBytes(List<int> bytes, String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      final uploadTask = ref.putData(Uint8List.fromList(bytes), SettableMetadata(contentType: 'image/jpeg'));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<void> addBookingPhoto(String bookingId, String photoUrl, bool isBefore) async {
    final field = isBefore ? 'beforePhotos' : 'afterPhotos';
    await _firestore.collection('appointments').doc(bookingId).update({
      field: FieldValue.arrayUnion([photoUrl]),
    });
  }

  Future<void> removeBookingPhoto(String bookingId, String photoUrl, bool isBefore) async {
    final field = isBefore ? 'beforePhotos' : 'afterPhotos';
    await _firestore.collection('appointments').doc(bookingId).update({
      field: FieldValue.arrayRemove([photoUrl]),
    });
  }

  // Appointments / Bookings
  Future<bool> checkAvailability(DateTime startTime) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(startTime);
    final timeStr = DateFormat('HH:mm').format(startTime);
    final docId = _storeId != null ? '${_storeId}_$dateStr' : dateStr;

    final availabilityDoc = await _firestore.collection('availability').doc(docId).get();
    if (!availabilityDoc.exists) return true;

    final availability = Availability.fromJson(availabilityDoc.data()!);
    if (!availability.isOpen) return false;

    final maxSlots = availability.slots[timeStr] ?? 2;

    Query query = _firestore.collection('appointments');
    if (_storeId != null) {
      query = query.where('storeId', isEqualTo: _storeId);
    }
    
    final appointmentsQuery = await query
        .where('scheduledTime', isEqualTo: startTime.toIso8601String())
        .where('status', isNotEqualTo: 'cancelled')
        .get();

    return appointmentsQuery.docs.length < maxSlots;
  }

  Future<String> createBooking(Booking booking) async {
    try {
      final functions = FirebaseFunctions.instanceFor(region: 'southamerica-east1');
      final callable = functions.httpsCallable('createBooking');
      final payload = {
        'vehicleId': booking.vehicleId,
        'serviceIds': booking.serviceIds,
        'scheduledTime': booking.scheduledTime.toUtc().toIso8601String(),
        'staffNotes': booking.staffNotes,
        'storeId': _storeId,
      };
      final result = await callable.call(payload);
      final data = result.data as Map<String, dynamic>;
      return data['bookingId'] as String;
    } catch (e) {
      throw Exception('Erro ao processar agendamento: $e');
    }
  }

  Map<String, dynamic> _mapBookingData(String id, Map<String, dynamic> data) {
    try {
      final scheduledTime = data['scheduledTime'];
      String scheduledTimeStr;
      if (scheduledTime is Timestamp) scheduledTimeStr = scheduledTime.toDate().toIso8601String();
      else if (scheduledTime is String) scheduledTimeStr = scheduledTime;
      else scheduledTimeStr = DateTime.now().toIso8601String();

      String? cancelledAtStr;
      final cancelledAt = data['cancelledAt'];
      if (cancelledAt is Timestamp) cancelledAtStr = cancelledAt.toDate().toIso8601String();
      else if (cancelledAt is String) cancelledAtStr = cancelledAt;

      String? paidAtStr;
      final paidAt = data['paidAt'];
      if (paidAt is Timestamp) paidAtStr = paidAt.toDate().toIso8601String();
      else if (paidAt is String) paidAtStr = paidAt;

      String? createdAtStr;
      final createdAt = data['createdAt'] ?? data['created_at'];
      if (createdAt is Timestamp) createdAtStr = createdAt.toDate().toIso8601String();
      else if (createdAt is String) createdAtStr = createdAt;

      List<Map<String, dynamic>>? mappedLogs;
      final rawLogs = data['logs'];
      if (rawLogs != null && rawLogs is List) {
        mappedLogs = rawLogs.map((log) {
          if (log is Map) {
            final logMap = Map<String, dynamic>.from(log);
            final logTimestamp = logMap['timestamp'];
            if (logTimestamp is Timestamp) logMap['timestamp'] = logTimestamp.toDate().toIso8601String();
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
      rethrow;
    }
  }

  Stream<List<Booking>> getUserBookings(String userId) {
    Query query = _firestore.collection('appointments').where('userId', isEqualTo: userId);
    if (_storeId != null) {
      query = query.where('storeId', isEqualTo: _storeId);
    }
    return query
        .orderBy('scheduledTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  return Booking.fromJson(_mapBookingData(doc.id, doc.data() as Map<String, dynamic>));
                } catch (e) {
                  return null;
                }
              })
              .whereType<Booking>()
              .toList();
        });
  }

  Stream<List<Booking>> getAllBookings() {
    Query query = _firestore.collection('appointments');
    if (_storeId != null) {
      query = query.where('storeId', isEqualTo: _storeId);
    }
    return query
        .orderBy('scheduledTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  return Booking.fromJson(_mapBookingData(doc.id, doc.data() as Map<String, dynamic>));
                } catch (e) {
                  return null;
                }
              })
              .whereType<Booking>()
              .toList();
        });
  }

  Stream<Booking> getBookingStream(String bookingId) {
    return _firestore.collection('appointments').doc(bookingId).snapshots().map((doc) {
      if (!doc.exists) throw Exception('Agendamento não encontrado');
      return Booking.fromJson(_mapBookingData(doc.id, doc.data()!));
    });
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status, {String? message, String? actorId}) {
    final Map<String, dynamic> updates = {'status': status.name};
    if (actorId != null) {
      final log = BookingLog(message: message ?? 'Status updated to ${status.name}', timestamp: DateTime.now(), actorId: actorId, status: status);
      updates['logs'] = FieldValue.arrayUnion([log.toJson()]);
    }
    return _firestore.collection('appointments').doc(bookingId).update(updates).then((_) async {
      if (status == BookingStatus.finished) {
        try {
          final bookingDoc = await _firestore.collection('appointments').doc(bookingId).get();
          if (bookingDoc.exists && bookingDoc.data() != null) {
            final data = bookingDoc.data()!;
            final userId = data['userId'] as String?;
            final totalPrice = (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
            final serviceIds = (data['serviceIds'] as List?)?.cast<String>();
            final paymentStatus = data['paymentStatus'] as String?;
            final serviceType = paymentStatus == 'subscription' ? 'subscription' : 'single';
            await _analytics.logWash(bookingId: bookingId, serviceType: serviceType, value: totalPrice, userId: userId, serviceIds: serviceIds, storeId: _storeId);
          }
        } catch (e) {}
      }
    });
  }

  Future<void> updatePaymentStatus(String bookingId, BookingPaymentStatus paymentStatus, {String? paymentMethod, String? staffId}) {
    final Map<String, dynamic> updates = {
      'paymentStatus': paymentStatus.name,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (staffId != null) 'paidByStaffId': staffId,
      if (paymentStatus != BookingPaymentStatus.pending) 'paidAt': FieldValue.serverTimestamp(),
    };
    return _firestore.collection('appointments').doc(bookingId).update(updates);
  }

  Future<void> cancelBooking(String bookingId, {required String actorId, String actorRole = 'client', String? cancellationReason}) async {
    try {
      final functions = FirebaseFunctions.instanceFor(region: 'southamerica-east1');
      final callable = functions.httpsCallable('cancelBooking');
      await callable.call({'bookingId': bookingId, 'actorId': actorId, 'cancelledBy': actorRole, 'reason': cancellationReason, 'storeId': _storeId});
    } catch (e) {
      throw Exception('Erro ao cancelar agendamento: $e');
    }
  }

  Future<void> markAsRated(String bookingId, int rating, String? comment, List<String> selectedTags) {
    return _firestore.collection('appointments').doc(bookingId).update({
      'isRated': true,
      'rating': rating,
      'ratingComment': comment,
      'selectedTags': selectedTags,
      'ratedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAdminResponse(String bookingId, String adminResponse, String adminResponderId) async {
    await _firestore.collection('appointments').doc(bookingId).update({
      'adminResponse': adminResponse,
      'adminResponseAt': FieldValue.serverTimestamp(),
      'adminResponderId': adminResponderId,
    });
  }

  Stream<List<Booking>> getBookingsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    Query query = _firestore.collection('appointments')
        .where('scheduledTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('scheduledTime', isLessThan: Timestamp.fromDate(endOfDay));
    
    if (_storeId != null) {
      query = query.where('storeId', isEqualTo: _storeId);
    }

    return query.orderBy('scheduledTime').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return Booking.fromJson(_mapBookingData(doc.id, doc.data() as Map<String, dynamic>));
        } catch (e) {
          return null;
        }
      }).whereType<Booking>().toList();
    });
  }

  Future<List<Booking>> getBookingsInRange(DateTime start, DateTime end) async {
    final startOfDay = DateTime(start.year, start.month, start.day);
    final endOfDay = DateTime(end.year, end.month, end.day).add(const Duration(days: 1));
    Query query = _firestore.collection('appointments')
        .where('scheduledTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('scheduledTime', isLessThan: Timestamp.fromDate(endOfDay));
    
    if (_storeId != null) {
      query = query.where('storeId', isEqualTo: _storeId);
    }

    final snapshot = await query.orderBy('scheduledTime', descending: true).get();
    return snapshot.docs.map((doc) {
      try {
        return Booking.fromJson(_mapBookingData(doc.id, doc.data() as Map<String, dynamic>));
      } catch (e) {
        return null;
      }
    }).whereType<Booking>().toList();
  }

  Future<Booking?> getLastFinishedBookingForVehicle(String vehicleId, String userId) async {
    try {
      Query query = _firestore.collection('appointments')
          .where('userId', isEqualTo: userId)
          .where('vehicleId', isEqualTo: vehicleId)
          .where('status', isEqualTo: 'finished');
      
      if (_storeId != null) {
        query = query.where('storeId', isEqualTo: _storeId);
      }

      final result = await query.orderBy('scheduledTime', descending: true).limit(1).get();
      if (result.docs.isEmpty) return null;
      return Booking.fromJson(_mapBookingData(result.docs.first.id, result.docs.first.data() as Map<String, dynamic>));
    } catch (e) {
      return null;
    }
  }

  Future<Booking?> fetchLatestBooking(String userId) async {
    try {
      Query query = _firestore.collection('appointments').where('userId', isEqualTo: userId);
      if (_storeId != null) {
        query = query.where('storeId', isEqualTo: _storeId);
      }
      final result = await query.orderBy('scheduledTime', descending: true).limit(1).get();
      if (result.docs.isEmpty) return null;
      return Booking.fromJson(_mapBookingData(result.docs.first.id, result.docs.first.data() as Map<String, dynamic>));
    } catch (e) {
      return null;
    }
  }

  Stream<List<Booking>> getVehicleBookings(String vehicleId, String userId) {
    Query query = _firestore.collection('appointments')
        .where('userId', isEqualTo: userId)
        .where('vehicleId', isEqualTo: vehicleId);
    
    if (_storeId != null) {
      query = query.where('storeId', isEqualTo: _storeId);
    }

    return query.snapshots().map((snapshot) {
      final bookings = snapshot.docs.map((doc) {
        try {
          return Booking.fromJson(_mapBookingData(doc.id, doc.data() as Map<String, dynamic>));
        } catch (e) {
          return null;
        }
      }).whereType<Booking>().toList();
      bookings.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
      return bookings;
    });
  }
}

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final currentStore = ref.watch(currentStoreProvider).value;
  return BookingRepository(FirebaseFirestore.instance, currentStore?.id);
});

final servicesProvider = StreamProvider<List<ServicePackage>>((ref) {
  return ref.watch(bookingRepositoryProvider).getServicesStream();
});

final userVehiclesProvider = StreamProvider.family<List<Vehicle>, String>((ref, userId) {
  return ref.watch(bookingRepositoryProvider).getUserVehicles(userId);
});

final userBookingsProvider = StreamProvider.family<List<Booking>, String>((ref, userId) {
  return ref.watch(bookingRepositoryProvider).getUserBookings(userId);
});

final allBookingsProvider = StreamProvider<List<Booking>>((ref) {
  return ref.watch(bookingRepositoryProvider).getAllBookings();
});

final bookingStreamProvider = StreamProvider.family<Booking, String>((ref, bookingId) {
  return ref.watch(bookingRepositoryProvider).getBookingStream(bookingId);
});
