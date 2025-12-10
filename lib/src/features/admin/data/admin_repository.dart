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

part 'admin_repository.g.dart';

class AdminRepository {
  final FirebaseFirestore _firestore;

  AdminRepository(this._firestore);

  // Plans
  Stream<List<SubscriptionPlan>> getPlans() {
    return _firestore.collection('plans').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return SubscriptionPlan.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  Future<void> addPlan(SubscriptionPlan plan) async {
    final data = plan.toJson();
    data.remove('id'); // Remove id before adding
    final docRef = await _firestore.collection('plans').add(data);

    // Sync with Stripe
    try {
      await FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      ).httpsCallable('syncPlanWithStripe').call({
        'planId': docRef.id,
        'name': plan.name,
        'price': plan.price,
        'features': plan.features,
      });
      print('Plan synced with Stripe successfully');
    } catch (e) {
      print('Error syncing with Stripe: $e');
      // Don't throw - plan is created in Firestore, Stripe sync can be retried
    }
  }

  Future<void> updatePlan(SubscriptionPlan plan) async {
    final data = plan.toJson();
    data.remove('id'); // Remove id before updating
    await _firestore.collection('plans').doc(plan.id).update(data);

    // Sync with Stripe
    try {
      await FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      ).httpsCallable('syncPlanWithStripe').call({
        'planId': plan.id,
        'name': plan.name,
        'price': plan.price,
        'features': plan.features,
      });
      print('Plan synced with Stripe successfully');
    } catch (e) {
      print('Error syncing with Stripe: $e');
      // Don't throw - plan is updated in Firestore, Stripe sync can be retried
    }
  }

  Future<void> deletePlan(String planId) {
    return _firestore.collection('plans').doc(planId).delete();
  }

  // Subscribers
  Stream<List<Subscriber>> getSubscribers() {
    return _firestore.collection('subscriptions').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Subscriber.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  Future<void> deleteSubscription(String userId) {
    return _firestore.collection('subscriptions').doc(userId).delete();
  }

  // Vehicles
  Stream<List<Vehicle>> getAllVehicles() {
    return _firestore.collection('vehicles').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Vehicle.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  // Availability
  Stream<Availability?> getAvailability(String date) {
    return _firestore.collection('availability').doc(date).snapshots().map((
      doc,
    ) {
      if (!doc.exists) return null;
      return Availability.fromJson({...doc.data()!, 'date': date});
    });
  }

  Future<void> saveAvailability(Availability availability) {
    return _firestore
        .collection('availability')
        .doc(availability.date)
        .set(availability.toJson());
  }

  // Bookings
  Stream<List<Booking>> getBookings() {
    return _firestore
        .collection('appointments')
        .orderBy('scheduledTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data();
                  return Booking.fromJson({...data, 'id': doc.id});
                } catch (e) {
                  print('Error parsing booking ${doc.id}: $e');
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
  }) {
    final log = BookingLog(
      message: message ?? 'Status updated to ${status.name}',
      timestamp: DateTime.now(),
      actorId: actorId,
      status: status,
    );

    return _firestore.collection('appointments').doc(bookingId).update({
      'status': status.name,
      'logs': FieldValue.arrayUnion([log.toJson()]),
    });
  }

  // Admin Events
  Stream<List<AdminEvent>> getEvents() {
    return _firestore.collection('admin_events').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AdminEvent.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  Future<void> addEvent(AdminEvent event) {
    final data = event.toJson();
    data.remove('id');
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
}

@Riverpod(keepAlive: true)
AdminRepository adminRepository(Ref ref) {
  return AdminRepository(ref.watch(firebaseFirestoreProvider));
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
  print('🔍 adminBookingsProvider: Subscribing to stream...');
  return ref.watch(adminRepositoryProvider).getBookings().map((bookings) {
    print(
      '🔍 adminBookingsProvider: Received ${bookings.length} bookings from repository.',
    );
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
        print('⚠️ Error fetching user ${booking.userId}: $e');
      }

      try {
        vehicle = await bookingRepo
            .getVehicle(booking.vehicleId)
            .timeout(const Duration(seconds: 15));
      } catch (e) {
        print('⚠️ Error fetching vehicle ${booking.vehicleId}: $e');
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
        print('⚠️ Error fetching services for booking ${booking.id}: $e');
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
