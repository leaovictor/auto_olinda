import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../features/profile/domain/vehicle.dart';
import '../../auth/data/auth_repository.dart';

part 'vehicle_repository.g.dart';

class VehicleRepository {
  final FirebaseFirestore _firestore;

  VehicleRepository(this._firestore);

  Stream<List<Vehicle>> getUserVehicles(String userId) {
    return _firestore
        .collection('vehicles')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Vehicle.fromJson({...doc.data(), 'id': doc.id});
          }).toList();
        });
  }

  Future<Vehicle?> getVehicleById(String id) async {
    try {
      final doc = await _firestore.collection('vehicles').doc(id).get();
      if (!doc.exists) return null;
      return Vehicle.fromJson({...doc.data()!, 'id': id});
    } catch (e) {
      return null;
    }
  }

  Future<String> createVehicle(Vehicle vehicle, String userId) async {
    final data = {...vehicle.toJson(), 'userId': userId};
    data.remove('id'); // Let Firestore generate the ID

    final docRef = await _firestore.collection('vehicles').add(data);
    return docRef.id;
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    final data = vehicle.toJson();
    data.remove('id');
    await _firestore.collection('vehicles').doc(vehicle.id).update(data);
  }

  Future<void> deleteVehicle(String id) async {
    await _firestore.collection('vehicles').doc(id).delete();
  }

  Future<void> linkVehicleToSubscription(
    String vehicleId,
    String subscriptionId,
  ) async {
    await _firestore.collection('vehicles').doc(vehicleId).update({
      'isSubscriptionVehicle': true,
      'linkedSubscriptionId': subscriptionId,
    });
  }

  Future<void> unlinkVehicleFromSubscription(String vehicleId) async {
    await _firestore.collection('vehicles').doc(vehicleId).update({
      'isSubscriptionVehicle': false,
      'linkedSubscriptionId': null,
    });
  }

  Future<Vehicle?> getSubscriptionVehicleForUser(String userId) async {
    final snapshot = await _firestore
        .collection('vehicles')
        .where('userId', isEqualTo: userId)
        .where('isSubscriptionVehicle', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return Vehicle.fromJson({
      ...snapshot.docs.first.data(),
      'id': snapshot.docs.first.id,
    });
  }
}

@Riverpod(keepAlive: true)
VehicleRepository vehicleRepository(Ref ref) {
  return VehicleRepository(ref.watch(firebaseFirestoreProvider));
}

@riverpod
Stream<List<Vehicle>> userVehicles(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(vehicleRepositoryProvider).getUserVehicles(user.uid);
}

@riverpod
Future<Vehicle?> vehicleById(Ref ref, String vehicleId) {
  return ref.watch(vehicleRepositoryProvider).getVehicleById(vehicleId);
}
