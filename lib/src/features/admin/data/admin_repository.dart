import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../features/booking/domain/booking.dart';
import '../../../features/subscription/domain/subscription_plan.dart';
import '../../../features/subscription/domain/subscriber.dart';
import '../../../features/booking/domain/availability.dart';
import '../../../features/profile/domain/vehicle.dart';
import '../../auth/data/auth_repository.dart';

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

  Future<void> addPlan(SubscriptionPlan plan) {
    final data = plan.toJson();
    data.remove('id'); // Remove id before adding
    return _firestore.collection('plans').add(data);
  }

  Future<void> updatePlan(SubscriptionPlan plan) {
    final data = plan.toJson();
    data.remove('id'); // Remove id before updating
    return _firestore.collection('plans').doc(plan.id).update(data);
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
          return snapshot.docs.map((doc) {
            return Booking.fromJson({...doc.data(), 'id': doc.id});
          }).toList();
        });
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status) {
    return _firestore.collection('appointments').doc(bookingId).update({
      'status': status.name,
    });
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
  return ref.watch(adminRepositoryProvider).getBookings();
}

@riverpod
Stream<List<Vehicle>> adminVehicles(Ref ref) {
  return ref.watch(adminRepositoryProvider).getAllVehicles();
}
