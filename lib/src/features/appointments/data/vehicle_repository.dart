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
    // Security: Prevent changing critical fields of subscription vehicles
    final currentVehicle = await getVehicleById(vehicle.id);

    if (currentVehicle?.isSubscriptionVehicle ?? false) {
      // Validate that critical fields haven't changed
      if (currentVehicle!.type != vehicle.type) {
        throw Exception(
          'Não é possível alterar a categoria de um veículo com assinatura ativa. '
          'Entre em contato com o lava-jato para atualizar sua assinatura.',
        );
      }
      if (currentVehicle.plate.toUpperCase() != vehicle.plate.toUpperCase()) {
        throw Exception(
          'Não é possível alterar a placa de um veículo com assinatura ativa. '
          'Entre em contato com o lava-jato para atualizar sua assinatura.',
        );
      }
    }

    final data = vehicle.toJson();
    data.remove('id');
    await _firestore.collection('vehicles').doc(vehicle.id).update(data);
  }

  Future<void> deleteVehicle(String id) async {
    // Security: Prevent deletion of subscription vehicles
    final vehicle = await getVehicleById(id);

    if (vehicle == null) {
      throw Exception('Veículo não encontrado.');
    }

    if (vehicle.isSubscriptionVehicle) {
      throw Exception(
        'Não é possível remover um veículo vinculado a uma assinatura ativa.\n\n'
        'Para remover este veículo, primeiro cancele sua assinatura premium ou '
        'vincule outro veículo à assinatura.\n\n'
        'Entre em contato com o lava-jato para mais informações.',
      );
    }

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

  /// Checks Firestore for an active or trialing subscription matching [plate]
  /// for [userId] and, if found, re-links [vehicleId] to that subscription.
  ///
  /// Returns `true` if Premium was restored, `false` otherwise.
  Future<bool> restorePremiumIfSubscriptionExists({
    required String userId,
    required String vehicleId,
    required String plate,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('subscriptions')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: ['active', 'trialing'])
          .get();

      if (snapshot.docs.isEmpty) return false;

      final normalizedPlate = plate.toUpperCase();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final linkedPlate = (data['linkedPlate'] as String? ?? '')
            .toUpperCase();
        final isMultiVehicle = data['isMultiVehicle'] as bool? ?? false;

        if (linkedPlate == normalizedPlate || isMultiVehicle) {
          // Re-link the new vehicle document to the existing subscription
          await linkVehicleToSubscription(vehicleId, doc.id);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('DEBUG: Error restoring premium by plate: $e');
      return false;
    }
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
