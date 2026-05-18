import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../features/booking/domain/booking.dart';
import '../../../features/subscription/domain/subscription_plan.dart';
import '../../../features/subscription/domain/subscriber.dart';
import '../../../features/booking/domain/availability.dart';
import '../../../features/profile/domain/vehicle.dart';

import '../../auth/data/auth_repository.dart';
import '../../booking/data/booking_repository.dart';
import '../../auth/domain/app_user.dart';
import '../domain/admin_event.dart';
import '../domain/booking_with_details.dart';
import '../../../features/booking/domain/service_package.dart';
import 'analytics_repository.dart';
import '../../store/data/current_store_provider.dart';

part 'admin_repository.g.dart';

class AdminRepository {
  final FirebaseFirestore _firestore;
  final String? _storeId;

  AdminRepository(this._firestore, [this._storeId]);

  // Plans
  Stream<List<SubscriptionPlan>> getPlans() {
    var query = _firestore.collection('plans').where('isActive', isEqualTo: true);
    if (_storeId != null) {
      query = query.where('storeId', isEqualTo: _storeId);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return SubscriptionPlan.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  Future<void> addPlan(SubscriptionPlan plan) async {
    final data = plan.toJson();
    data.remove('id');
    if (_storeId != null) {
      data['storeId'] = _storeId;
    }
    final docRef = await _firestore.collection('plans').add(data);

    try {
      await FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      ).httpsCallable('syncPlanWithStripe').call({
        'planId': docRef.id,
        'name': plan.name,
        'price': plan.price,
        'features': plan.features,
        'category': plan.category,
        'storeId': _storeId,
      });
    } catch (e) {}
  }

  Future<void> updatePlan(SubscriptionPlan plan) async {
    final data = plan.toJson();
    data.remove('id');
    await _firestore.collection('plans').doc(plan.id).update(data);

    try {
      await FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      ).httpsCallable('syncPlanWithStripe').call({
        'planId': plan.id,
        'name': plan.name,
        'price': plan.price,
        'features': plan.features,
        'category': plan.category,
        'storeId': _storeId,
      });
    } catch (e) {}
  }

  Future<void> deletePlan(String planId) async {
    final activeSubscribersQuery = await _firestore
        .collection('subscriptions')
        .where('planId', isEqualTo: planId)
        .where('status', whereIn: ['active', 'trialing'])
        .count()
        .get();

    if (activeSubscribersQuery.count != null &&
        activeSubscribersQuery.count! > 0) {
      return _firestore.collection('plans').doc(planId).update({
        'isActive': false,
        'deactivatedAt': FieldValue.serverTimestamp(),
      });
    }

    return _firestore.collection('plans').doc(planId).delete();
  }

  Future<int> getActivePlanSubscriberCount(String planId) async {
    final snapshot = await _firestore
        .collection('subscriptions')
        .where('planId', isEqualTo: planId)
        .where('status', whereIn: ['active', 'trialing'])
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  Future<Map<String, dynamic>> getPlanSubscriberDetails(String planId) async {
    final activeSnapshot = await _firestore
        .collection('subscriptions')
        .where('planId', isEqualTo: planId)
        .where('status', whereIn: ['active', 'trialing'])
        .get();

    final allSnapshot = await _firestore
        .collection('subscriptions')
        .where('planId', isEqualTo: planId)
        .get();

    return {
      'activeCount': activeSnapshot.docs.length,
      'totalCount': allSnapshot.docs.length,
      'canceledCount': allSnapshot.docs.length - activeSnapshot.docs.length,
    };
  }

  // Subscribers
  Stream<List<Subscriber>> getSubscribers() {
    Query query = _firestore.collection('subscriptions');
    if (_storeId != null) {
      query = query.where('storeId', isEqualTo: _storeId);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Subscriber.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }).toList();
    });
  }

  Future<void> deleteSubscription(String userId) {
    return _firestore.collection('subscriptions').doc(userId).delete();
  }

  // Vehicles
  Stream<List<Vehicle>> getAllVehicles() {
    Query query = _firestore.collection('vehicles');
    if (_storeId != null) {
      query = query.where('storeId', isEqualTo: _storeId);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Vehicle.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }).toList();
    });
  }

  // Availability
  Stream<Availability?> getAvailability(String date) {
    final docId = _storeId != null ? '${_storeId}_$date' : date;
    return _firestore.collection('availability').doc(docId).snapshots().map((
      doc,
    ) {
      if (!doc.exists) return null;
      return Availability.fromJson({...doc.data()!, 'date': date});
    });
  }

  Future<void> saveAvailability(Availability availability) {
    final docId = _storeId != null ? '${_storeId}_${availability.date}' : availability.date;
    final data = availability.toJson();
    if (_storeId != null) data['storeId'] = _storeId;
    return _firestore.collection('availability').doc(docId).set(data);
  }

  // Bookings
  Stream<List<Booking>> getBookings() {
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
                  final data = doc.data() as Map<String, dynamic>;
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

  Stream<List<Booking>> getRecentBookings({int limit = 10}) {
    Query query = _firestore.collection('appointments');
    if (_storeId != null) {
      query = query.where('storeId', isEqualTo: _storeId);
    }
    return query
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data() as Map<String, dynamic>;
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

  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status, {
    String? message,
    required String actorId,
    ActorRole actorRole = ActorRole.system,
    String? actorName,
  }) async {
    final log = BookingLog(
      message: message ?? 'Status updated to ${status.name}',
      timestamp: DateTime.now(),
      actorId: actorId,
      status: status,
      actorRole: actorRole,
      actorName: actorName,
    );

    final updateData = <String, dynamic>{
      'status': status.name,
      'logs': FieldValue.arrayUnion([log.toJson()]),
    };

    if (status == BookingStatus.cancelled) {
      updateData['cancellationReason'] = message;
      updateData['cancelledBy'] = actorRole.name;
      updateData['cancelledAt'] = FieldValue.serverTimestamp();
    }

    await _firestore
        .collection('appointments')
        .doc(bookingId)
        .update(updateData);

    if (status == BookingStatus.finished) {
      try {
        final bookingDoc = await _firestore
            .collection('appointments')
            .doc(bookingId)
            .get();
        if (bookingDoc.exists) {
          final bookingData = bookingDoc.data()!;
          final userId = bookingData['userId'] as String?;
          final totalPrice =
              (bookingData['totalPrice'] as num?)?.toDouble() ?? 0.0;
          final serviceIds =
              (bookingData['serviceIds'] as List?)?.cast<String>() ?? [];

          final paymentStatus = bookingData['paymentStatus'] as String?;
          final serviceType = paymentStatus == 'subscription'
              ? 'subscription'
              : 'single';

          final analyticsRepo = AnalyticsRepository(_firestore);
          await analyticsRepo.logWash(
            bookingId: bookingId,
            serviceType: serviceType,
            value: totalPrice,
            userId: userId,
            serviceIds: serviceIds,
            storeId: _storeId,
          );
        }
      } catch (e) {}
    }
  }

  // Admin Events
  Stream<List<AdminEvent>> getEvents() {
    Query query = _firestore.collection('admin_events');
    if (_storeId != null) {
      query = query.where('storeId', isEqualTo: _storeId);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              final data = _mapEventData(doc.id, doc.data() as Map<String, dynamic>);
              return AdminEvent.fromJson(data);
            } catch (e) {
              return null;
            }
          })
          .where((e) => e != null)
          .cast<AdminEvent>()
          .toList();
    });
  }

  Future<void> addEvent(AdminEvent event) {
    final data = event.toJson();
    data.remove('id');
    if (_storeId != null) data['storeId'] = _storeId;
    return _firestore.collection('admin_events').add(data);
  }

  Future<void> updateEvent(AdminEvent event) {
    final data = event.toJson();
    data.remove('id');
    return _firestore.collection('admin_events').doc(event.id).update(data);
  }

  Future<void> deleteEvent(String eventId) {
    return _firestore.collection('admin_events').doc(eventId).delete();
  }

  Future<void> toggleEventStatus(String eventId, bool isDone) {
    return _firestore.collection('admin_events').doc(eventId).update({
      'isDone': isDone,
    });
  }

  // Users
  Stream<List<AppUser>> getUsers() {
    Query query = _firestore.collection('users');
    // If admin, they might want to see users associated with their store
    // For now, let's keep users global but potentially filter by those who have records in this store
    // Better yet, just filter by those whose currentStoreId matches
    if (_storeId != null) {
      query = query.where('currentStoreId', isEqualTo: _storeId);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppUser.fromJson({...doc.data() as Map<String, dynamic>, 'uid': doc.id});
      }).toList();
    });
  }

  Future<void> updateUserStatus(String uid, String status) {
    return _firestore.collection('users').doc(uid).update({'status': status});
  }

  Future<void> updateUserRole(String uid, String role) {
    return _firestore.collection('users').doc(uid).update({'role': role});
  }

  Future<void> createUser(AppUser user) {
    final data = user.toJson();
    return _firestore.collection('users').doc(user.uid).set(data);
  }

  Future<void> updateUser(AppUser user) {
    final data = user.toJson();
    data.remove('uid');
    return _firestore.collection('users').doc(user.uid).update(data);
  }

  Future<String> adminCreateSubscription({
    required String customerEmail,
    required String customerPhone,
    required String customerName,
    required String vehiclePlate,
    required String vehicleModel,
    required String planId,
    required String paymentMethodId,
    String? vehicleCategory,
  }) async {
    final callable = FirebaseFunctions.instanceFor(
      region: 'southamerica-east1',
    ).httpsCallable('registerCustomerByAdmin');

    final response = await callable.call({
      'email': customerEmail,
      'phone': customerPhone,
      'name': customerName,
      'plate': vehiclePlate,
      'model': vehicleModel,
      'planId': planId,
      'paymentMethodId': paymentMethodId,
      'vehicleCategory': vehicleCategory,
      'storeId': _storeId,
    });

    if (response.data['success'] != true) {
      throw Exception('Falha ao criar assinatura');
    }

    return response.data['subscriptionId'] as String;
  }

  // Admin Settings
  Stream<Map<String, dynamic>?> getSettings() {
    if (_storeId != null) {
      return _firestore
          .collection('stores')
          .doc(_storeId)
          .collection('settings')
          .doc('admin')
          .snapshots()
          .map((doc) => doc.exists ? doc.data() : null);
    }
    return _firestore
        .collection('settings')
        .doc('admin')
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  Future<void> saveSettings(Map<String, dynamic> settings) {
    if (_storeId != null) {
      return _firestore
          .collection('stores')
          .doc(_storeId)
          .collection('settings')
          .doc('admin')
          .set(settings, SetOptions(merge: true));
    }
    return _firestore
        .collection('settings')
        .doc('admin')
        .set(settings, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>?> getPaymentSettings() {
    if (_storeId != null) {
       return _firestore
          .collection('stores')
          .doc(_storeId)
          .collection('settings')
          .doc('payments')
          .snapshots()
          .map((doc) => doc.exists ? doc.data() : null);
    }
    return _firestore
        .collection('admin_settings')
        .doc('payments')
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  Future<void> savePaymentSettings(Map<String, dynamic> settings) {
    if (_storeId != null) {
      return _firestore
          .collection('stores')
          .doc(_storeId)
          .collection('settings')
          .doc('payments')
          .set(settings, SetOptions(merge: true));
    }
    return _firestore
        .collection('admin_settings')
        .doc('payments')
        .set(settings, SetOptions(merge: true));
  }

  // Helpers
  Map<String, dynamic> _mapBookingData(String id, Map<String, dynamic> data) {
    try {
      final scheduledTime = data['scheduledTime'];
      String scheduledTimeStr;
      if (scheduledTime is Timestamp) {
        scheduledTimeStr = scheduledTime.toDate().toIso8601String();
      } else if (scheduledTime is String) {
        scheduledTimeStr = scheduledTime;
      } else {
        scheduledTimeStr = DateTime.now().toIso8601String();
      }

      String? createdAtStr;
      final createdAt = data['createdAt'] ?? data['created_at'];
      if (createdAt is Timestamp) {
        createdAtStr = createdAt.toDate().toIso8601String();
      } else if (createdAt is String) {
        createdAtStr = createdAt;
      }

      return {
        ...data,
        'id': id,
        'scheduledTime': scheduledTimeStr,
        'createdAt': createdAtStr,
        'status': data['status'] ?? 'scheduled',
        'totalPrice': (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
      };
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> _mapEventData(String id, Map<String, dynamic> data) {
    final date = data['date'];
    String dateStr;
    if (date is Timestamp) {
      dateStr = date.toDate().toIso8601String();
    } else if (date is String) {
      dateStr = date;
    } else {
      dateStr = DateTime.now().toIso8601String();
    }

    String? remindAtStr;
    if (data['remindAt'] != null) {
      final remindAt = data['remindAt'];
      if (remindAt is Timestamp) {
        remindAtStr = remindAt.toDate().toIso8601String();
      } else if (remindAt is String) {
        remindAtStr = remindAt;
      }
    }

    return {...data, 'id': id, 'date': dateStr, 'remindAt': remindAtStr};
  }
}

@Riverpod(keepAlive: true)
AdminRepository adminRepository(AdminRepositoryRef ref) {
  final currentStore = ref.watch(currentStoreProvider).value;
  return AdminRepository(FirebaseFirestore.instance, currentStore?.id);
}

@riverpod
Stream<List<SubscriptionPlan>> adminPlans(AdminPlansRef ref) {
  return ref.watch(adminRepositoryProvider).getPlans();
}

@riverpod
Stream<List<Subscriber>> subscribers(SubscribersRef ref) {
  return ref.watch(adminRepositoryProvider).getSubscribers();
}

@riverpod
Stream<List<Booking>> adminBookings(AdminBookingsRef ref) {
  return ref.watch(adminRepositoryProvider).getBookings();
}

@riverpod
Stream<List<Vehicle>> adminVehicles(AdminVehiclesRef ref) {
  return ref.watch(adminRepositoryProvider).getAllVehicles();
}

@riverpod
Stream<List<AdminEvent>> adminEvents(AdminEventsRef ref) {
  return ref.watch(adminRepositoryProvider).getEvents();
}

@riverpod
Stream<List<BookingWithDetails>> adminBookingsWithDetails(AdminBookingsWithDetailsRef ref) {
  final adminRepo = ref.watch(adminRepositoryProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  final bookingRepo = ref.watch(bookingRepositoryProvider);

  return adminRepo.getBookings().asyncMap((bookings) async {
    if (bookings.isEmpty) {
      return <BookingWithDetails>[];
    }

    final detailsFutures = bookings.map((booking) async {
      AppUser? user;
      Vehicle? vehicle;
      List<ServicePackage> services = [];

      try {
        user = await authRepo
            .getUserProfile(booking.userId)
            .timeout(const Duration(seconds: 15));
      } catch (e) {}

      try {
        vehicle = await bookingRepo
            .getVehicle(booking.vehicleId)
            .timeout(const Duration(seconds: 15));
      } catch (e) {}

      try {
        final serviceFutures = booking.serviceIds.map(
          (id) =>
              bookingRepo.getService(id).timeout(const Duration(seconds: 15)),
        );
        final fetchedServices = await Future.wait(serviceFutures);
        services = fetchedServices.whereType<ServicePackage>().toList();
      } catch (e) {}

      return BookingWithDetails(
        booking: booking,
        user: user,
        vehicle: vehicle,
        services: services,
      );
    });

    return await Future.wait(detailsFutures);
  });
}

@riverpod
Stream<List<BookingWithDetails>> adminRecentBookingsWithDetails(AdminRecentBookingsWithDetailsRef ref) {
  final adminRepo = ref.watch(adminRepositoryProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  final bookingRepo = ref.watch(bookingRepositoryProvider);

  return adminRepo.getRecentBookings(limit: 5).asyncMap((bookings) async {
    if (bookings.isEmpty) {
      return <BookingWithDetails>[];
    }

    final detailsFutures = bookings.map((booking) async {
      AppUser? user;
      Vehicle? vehicle;
      List<ServicePackage> services = [];

      try {
        user = await authRepo
            .getUserProfile(booking.userId)
            .timeout(const Duration(seconds: 15));
      } catch (e) {}

      try {
        vehicle = await bookingRepo
            .getVehicle(booking.vehicleId)
            .timeout(const Duration(seconds: 15));
      } catch (e) {}

      try {
        final serviceFutures = booking.serviceIds.map(
          (id) =>
              bookingRepo.getService(id).timeout(const Duration(seconds: 15)),
        );
        final fetchedServices = await Future.wait(serviceFutures);
        services = fetchedServices.whereType<ServicePackage>().toList();
      } catch (e) {}

      return BookingWithDetails(
        booking: booking,
        user: user,
        vehicle: vehicle,
        services: services,
      );
    });

    return await Future.wait(detailsFutures);
  });
}

@riverpod
Stream<List<AppUser>> adminUsers(AdminUsersRef ref) {
  return ref.watch(adminRepositoryProvider).getUsers();
}
