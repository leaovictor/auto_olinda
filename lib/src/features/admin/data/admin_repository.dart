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
import '../../../core/firestore/tenant_firestore.dart';
import 'analytics_repository.dart';

part 'admin_repository.g.dart';

class AdminRepository {
  final FirebaseFirestore _firestore;
  final String tenantId;

  AdminRepository(this._firestore, {required this.tenantId});

  CollectionReference<Map<String, dynamic>> _col(String name) =>
      _firestore.tenantCol(tenantId, name);

  // Plans
  Stream<List<SubscriptionPlan>> getPlans() {
    return _col('plans').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return SubscriptionPlan.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  Future<void> addPlan(SubscriptionPlan plan) async {
    final data = plan.toJson();
    data.remove('id');
    final docRef = await _col('plans').add(data);

    // Sync with Stripe
    try {
      await FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      ).httpsCallable('syncPlanWithStripe').call({
        'planId': docRef.id,
        'name': plan.name,
        'price': plan.price,
        'features': plan.features,
        'category': plan.category, // Pass category
      });
      // print('Plan synced with Stripe successfully');
    } catch (e) {
      // print('Error syncing with Stripe: $e');
      // Don't throw - plan is created in Firestore, Stripe sync can be retried
    }
  }

  Future<void> updatePlan(SubscriptionPlan plan) async {
    final data = plan.toJson();
    data.remove('id');
    await _col('plans').doc(plan.id).update(data);

    // Sync with Stripe
    try {
      await FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      ).httpsCallable('syncPlanWithStripe').call({
        'planId': plan.id,
        'name': plan.name,
        'price': plan.price,
        'features': plan.features,
        'category': plan.category, // Pass category
      });
      // print('Plan synced with Stripe successfully');
    } catch (e) {
      // print('Error syncing with Stripe: $e');
      // Don't throw - plan is updated in Firestore, Stripe sync can be retried
    }
  }

  Future<void> deletePlan(String planId) async {
    final activeSubscribersQuery = await _col('subscriptions')
        .where('planId', isEqualTo: planId)
        .where('status', whereIn: ['active', 'trialing'])
        .count()
        .get();

    if (activeSubscribersQuery.count != null &&
        activeSubscribersQuery.count! > 0) {
      return _col('plans').doc(planId).update({
        'isActive': false,
        'deactivatedAt': FieldValue.serverTimestamp(),
      });
    }

    return _col('plans').doc(planId).delete();
  }

  /// Get count of active subscribers for a specific plan
  Future<int> getActivePlanSubscriberCount(String planId) async {
    final snapshot = await _col('subscriptions')
        .where('planId', isEqualTo: planId)
        .where('status', whereIn: ['active', 'trialing'])
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  /// Get detailed subscriber info for a plan
  Future<Map<String, dynamic>> getPlanSubscriberDetails(String planId) async {
    final activeSnapshot = await _col('subscriptions')
        .where('planId', isEqualTo: planId)
        .where('status', whereIn: ['active', 'trialing'])
        .get();

    final allSnapshot = await _col('subscriptions')
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
    return _col('subscriptions').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Subscriber.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  Future<void> deleteSubscription(String userId) {
    return _col('subscriptions').doc(userId).delete();
  }

  Stream<List<Vehicle>> getAllVehicles() {
    return _col('vehicles').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Vehicle.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  // Availability
  Stream<Availability?> getAvailability(String date) {
    return _col('availability').doc(date).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Availability.fromJson({...doc.data()!, 'date': date});
    });
  }

  Future<void> saveAvailability(Availability availability) {
    return _col('availability')
        .doc(availability.date)
        .set(availability.toJson());
  }

  Stream<List<Booking>> getBookings() {
    return _col('appointments')
        .orderBy('scheduledTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data();
                  // Use robust mapping to handle Timestamp -> String conversion
                  final mappedData = _mapBookingData(doc.id, data);
                  return Booking.fromJson(mappedData);
                } catch (e) {
                  // print('Error parsing booking ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<Booking>()
              .toList();
        });
  }

  Stream<List<Booking>> getRecentBookings({int limit = 10}) {
    return _col('appointments')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data();
                  final mappedData = _mapBookingData(doc.id, data);
                  return Booking.fromJson(mappedData);
                } catch (e) {
                  // print('Error parsing recent booking ${doc.id}: $e');
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

    // Base update data
    final updateData = <String, dynamic>{
      'status': status.name,
      'logs': FieldValue.arrayUnion([log.toJson()]),
    };

    // If cancelled, save cancellation info at booking level for easy access
    if (status == BookingStatus.cancelled) {
      updateData['cancellationReason'] = message;
      updateData['cancelledBy'] = actorRole.name;
      updateData['cancelledAt'] = FieldValue.serverTimestamp();
    }

    await _col('appointments').doc(bookingId).update(updateData);

    if (status == BookingStatus.finished) {
      try {
        final bookingDoc = await _col('appointments').doc(bookingId).get();
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
          final analyticsRepo =
              AnalyticsRepository(_firestore, tenantId: tenantId);
          await analyticsRepo.logWash(
            bookingId: bookingId,
            serviceType: serviceType,
            value: totalPrice,
            userId: userId,
            serviceIds: serviceIds,
          );
        }
      } catch (e) {
        // non-critical
      }
    }
  }

  Stream<List<AdminEvent>> getEvents() {
    return _col('admin_events').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              final data = _mapEventData(doc.id, doc.data());
              return AdminEvent.fromJson(data);
            } catch (e) {
              // print('Error parsing admin event ${doc.id}: $e');
              // Return a placeholder or null if we changed the return type to nullable?
              // Since we are mapping inside a list, we can't easily filter nulls unless we change the structure like above.
              // For now, let's try-catch and maybe return a dummy or rethrow if safe.
              // Better approach: filter map like bookings.
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
    return _col('admin_events').add(data);
  }

  Future<void> updateEvent(AdminEvent event) {
    final data = event.toJson();
    data.remove('id');
    return _col('admin_events').doc(event.id).update(data);
  }

  Future<void> deleteEvent(String eventId) {
    return _col('admin_events').doc(eventId).delete();
  }

  Future<void> toggleEventStatus(String eventId, bool isDone) {
    return _col('admin_events').doc(eventId).update({'isDone': isDone});
  }

  // Users
  Stream<List<AppUser>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppUser.fromJson({...doc.data(), 'uid': doc.id});
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
    // Ensure uid is set in document ID
    return _firestore.collection('users').doc(user.uid).set(data);
  }

  Future<void> updateUser(AppUser user) {
    final data = user.toJson();
    data.remove('uid'); // Remove uid before updating
    return _firestore.collection('users').doc(user.uid).update(data);
  }

  // Admin Settings
  Stream<Map<String, dynamic>?> getSettings() {
    return _firestore
        .collection('settings')
        .doc('admin')
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  Future<void> saveSettings(Map<String, dynamic> settings) {
    return _firestore
        .collection('settings')
        .doc('admin')
        .set(settings, SetOptions(merge: true));
  }

  // Payment Settings (Matches Cloud Functions)
  Stream<Map<String, dynamic>?> getPaymentSettings() {
    return _firestore
        .collection('admin_settings')
        .doc('payments')
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  Future<void> savePaymentSettings(Map<String, dynamic> settings) {
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

      // Map createdAt
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
AdminRepository adminRepository(Ref ref) {
  final tenantId =
      ref.watch(currentUserProfileProvider).valueOrNull?.tenantId ?? '';
  return AdminRepository(
    ref.watch(firebaseFirestoreProvider),
    tenantId: tenantId,
  );
}

@riverpod
Stream<List<SubscriptionPlan>> adminPlans(Ref ref) {
  return ref.watch(adminRepositoryProvider).getPlans();
}

@riverpod
Stream<List<Subscriber>> subscribers(Ref ref) {
  return ref.watch(adminRepositoryProvider).getSubscribers();
}

@riverpod
Stream<List<Booking>> adminBookings(Ref ref) {
  // print('🔍 adminBookingsProvider: Subscribing to stream...');
  return ref.watch(adminRepositoryProvider).getBookings().map((bookings) {
    // print(
    //   '🔍 adminBookingsProvider: Received ${bookings.length} bookings from repository.',
    // );
    return bookings;
  });
}

@riverpod
Stream<List<Vehicle>> adminVehicles(Ref ref) {
  return ref.watch(adminRepositoryProvider).getAllVehicles();
}

@riverpod
Stream<List<AdminEvent>> adminEvents(Ref ref) {
  return ref.watch(adminRepositoryProvider).getEvents();
}

@riverpod
Stream<List<BookingWithDetails>> adminBookingsWithDetails(Ref ref) {
  final adminRepo = ref.watch(adminRepositoryProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  final bookingRepo = ref.watch(bookingRepositoryProvider);

  // Get the stream directly from the repository, bypassing the intermediate provider.
  return adminRepo.getBookings().asyncMap((bookings) async {
    if (bookings.isEmpty) {
      return <BookingWithDetails>[];
    }

    final detailsFutures = bookings.map((booking) async {
      AppUser? user;
      Vehicle? vehicle;
      List<ServicePackage> services = []; // Initialize an empty list

      // Fetch user and vehicle details (with timeouts)
      try {
        user = await authRepo
            .getUserProfile(booking.userId)
            .timeout(const Duration(seconds: 15));
      } catch (e) {
        // print('⚠️ Error fetching user ${booking.userId}: $e');
      }

      try {
        vehicle = await bookingRepo
            .getVehicle(booking.vehicleId)
            .timeout(const Duration(seconds: 15));
      } catch (e) {
        // print('⚠️ Error fetching vehicle ${booking.vehicleId}: $e');
      }

      // Fetch service details for each serviceId
      try {
        final serviceFutures = booking.serviceIds.map(
          (id) =>
              bookingRepo.getService(id).timeout(const Duration(seconds: 15)),
        );
        final fetchedServices = await Future.wait(serviceFutures);
        services = fetchedServices.whereType<ServicePackage>().toList();
      } catch (e) {
        // print('⚠️ Error fetching services for booking ${booking.id}: $e');
      }

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
Stream<List<BookingWithDetails>> adminRecentBookingsWithDetails(Ref ref) {
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
      } catch (e) {
        // print('⚠️ Error fetching user ${booking.userId}: $e');
      }

      try {
        vehicle = await bookingRepo
            .getVehicle(booking.vehicleId)
            .timeout(const Duration(seconds: 15));
      } catch (e) {
        // print('⚠️ Error fetching vehicle ${booking.vehicleId}: $e');
      }

      try {
        final serviceFutures = booking.serviceIds.map(
          (id) =>
              bookingRepo.getService(id).timeout(const Duration(seconds: 15)),
        );
        final fetchedServices = await Future.wait(serviceFutures);
        services = fetchedServices.whereType<ServicePackage>().toList();
      } catch (e) {
        // print('⚠️ Error fetching services for booking ${booking.id}: $e');
      }

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
Stream<List<AppUser>> adminUsers(Ref ref) {
  return ref.watch(adminRepositoryProvider).getUsers();
}
