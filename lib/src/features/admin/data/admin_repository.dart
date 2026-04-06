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
import '../../../core/tenant/tenant_firestore.dart';
import '../../../core/tenant/tenant_service.dart';

part 'admin_repository.g.dart';

class AdminRepository {
  final FirebaseFirestore _firestore;
  final String _tenantId;

  AdminRepository(this._firestore, this._tenantId);

  Stream<List<SubscriptionPlan>> getPlans() {
    return TenantFirestore.col('plans', _tenantId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return SubscriptionPlan.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  Future<void> addPlan(SubscriptionPlan plan) async {
    final data = plan.toJson();
    data.remove('id');
    final docRef = await TenantFirestore.col('plans', _tenantId).add(data);

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
    await TenantFirestore.doc('plans', plan.id, _tenantId).update(data);

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
    final activeSubscribersQuery = await TenantFirestore.col('subscriptions', _tenantId)
        .where('planId', isEqualTo: planId)
        .where('status', whereIn: ['active', 'trialing'])
        .count()
        .get();

    if (activeSubscribersQuery.count != null &&
        activeSubscribersQuery.count! > 0) {
      return TenantFirestore.doc('plans', planId, _tenantId).update({
        'isActive': false,
        'deactivatedAt': FieldValue.serverTimestamp(),
      });
    }

    return TenantFirestore.doc('plans', planId, _tenantId).delete();
  }

  Future<int> getActivePlanSubscriberCount(String planId) async {
    final snapshot = await TenantFirestore.col('subscriptions', _tenantId)
        .where('planId', isEqualTo: planId)
        .where('status', whereIn: ['active', 'trialing'])
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<Map<String, dynamic>> getPlanSubscriberDetails(String planId) async {
    final activeSnapshot = await TenantFirestore.col('subscriptions', _tenantId)
        .where('planId', isEqualTo: planId)
        .where('status', whereIn: ['active', 'trialing'])
        .get();

    final allSnapshot = await TenantFirestore.col('subscriptions', _tenantId)
        .where('planId', isEqualTo: planId)
        .get();

    return {
      'activeCount': activeSnapshot.docs.length,
      'totalCount': allSnapshot.docs.length,
      'canceledCount': allSnapshot.docs.length - activeSnapshot.docs.length,
    };
  }

  Stream<List<Subscriber>> getSubscribers() {
    return TenantFirestore.col('subscriptions', _tenantId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Subscriber.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  Future<void> deleteSubscription(String userId) {
    return TenantFirestore.doc('subscriptions', userId, _tenantId).delete();
  }

  Stream<List<Vehicle>> getAllVehicles() {
    return TenantFirestore.col('vehicles', _tenantId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Vehicle.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  Stream<Availability?> getAvailability(String date) {
    return TenantFirestore.doc('availability', date, _tenantId).snapshots().map(
      (doc) {
        if (!doc.exists) return null;
        return Availability.fromJson({...doc.data()!, 'date': date});
      },
    );
  }

  Future<void> saveAvailability(Availability availability) {
    return TenantFirestore.doc('availability', availability.date, _tenantId)
        .set(availability.toJson());
  }

  Stream<List<Booking>> getBookings() {
    return TenantFirestore.col('appointments', _tenantId)
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
    return TenantFirestore.col('appointments', _tenantId)
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

    await TenantFirestore.doc('appointments', bookingId, _tenantId)
        .update(updateData);

    // Log wash completion for analytics
    if (status == BookingStatus.finished) {
      try {
        final bookingDoc = await TenantFirestore.doc(
          'appointments',
          bookingId,
          _tenantId,
        ).get();
        if (bookingDoc.exists) {
          final bookingData = bookingDoc.data()!;
          final userId = bookingData['userId'] as String?;
          final totalPrice =
              (bookingData['totalPrice'] as num?)?.toDouble() ?? 0.0;
          final serviceIds =
              (bookingData['serviceIds'] as List?)?.cast<String>() ?? [];

          // Determine if subscriber or single
          final paymentStatus = bookingData['paymentStatus'] as String?;
          final serviceType = paymentStatus == 'subscription'
              ? 'subscription'
              : 'single';

          final analyticsRepo = AnalyticsRepository(_firestore, _tenantId);
          await analyticsRepo.logWash(
            bookingId: bookingId,
            serviceType: serviceType,
            value: totalPrice,
            userId: userId,
            serviceIds: serviceIds,
          );
          // print('📊 Wash logged for booking $bookingId');
        }
      } catch (e) {
        // print('📊 Error logging wash: $e');
      }
    }
  }

  Stream<List<AdminEvent>> getEvents() {
    return TenantFirestore.col('admin_events', _tenantId).snapshots().map((snapshot) {
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
    return TenantFirestore.col('admin_events', _tenantId).add(data);
  }

  Future<void> updateEvent(AdminEvent event) {
    final data = event.toJson();
    data.remove('id');
    return TenantFirestore.doc('admin_events', event.id, _tenantId).update(data);
  }

  Future<void> deleteEvent(String eventId) {
    return TenantFirestore.doc('admin_events', eventId, _tenantId).delete();
  }

  Future<void> toggleEventStatus(String eventId, bool isDone) {
    return TenantFirestore.doc('admin_events', eventId, _tenantId).update({
      'isDone': isDone,
    });
  }

  Stream<List<AppUser>> getUsers() {
    return TenantFirestore.col('users', _tenantId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppUser.fromJson({...doc.data(), 'uid': doc.id});
      }).toList();
    });
  }

  Future<void> updateUserStatus(String uid, String status) {
    return TenantFirestore.doc('users', uid, _tenantId)
        .update({'status': status});
  }

  Future<void> updateUserRole(String uid, String role) {
    return TenantFirestore.doc('users', uid, _tenantId)
        .update({'role': role});
  }

  Future<void> createUser(AppUser user) {
    final data = user.toJson();
    return TenantFirestore.doc('users', user.uid, _tenantId).set(data);
  }

  Future<void> updateUser(AppUser user) {
    final data = user.toJson();
    data.remove('uid');
    return TenantFirestore.doc('users', user.uid, _tenantId).update(data);
  }

  Stream<Map<String, dynamic>?> getSettings() {
    return TenantFirestore.doc('settings', 'admin', _tenantId)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  Future<void> saveSettings(Map<String, dynamic> settings) {
    return TenantFirestore.doc('settings', 'admin', _tenantId)
        .set(settings, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>?> getPaymentSettings() {
    return TenantFirestore.doc('admin_settings', 'payments', _tenantId)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  Future<void> savePaymentSettings(Map<String, dynamic> settings) {
    return TenantFirestore.doc('admin_settings', 'payments', _tenantId)
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
      ref.watch(tenantServiceProvider).valueOrNull?.tenantId ?? '';
  return AdminRepository(
    ref.watch(firebaseFirestoreProvider),
    tenantId,
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
