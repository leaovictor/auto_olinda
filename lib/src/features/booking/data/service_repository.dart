import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../features/booking/domain/service_package.dart';
import '../../auth/data/auth_repository.dart';

part 'service_repository.g.dart';

class ServiceRepository {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );

  ServiceRepository(this._firestore);

  Stream<List<ServicePackage>> getServices() {
    return _firestore.collection('services').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ServicePackage.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  Future<ServicePackage?> getServiceById(String id) async {
    try {
      final doc = await _firestore.collection('services').doc(id).get();
      if (!doc.exists) return null;
      return ServicePackage.fromJson({...doc.data()!, 'id': id});
    } catch (e) {
      return null;
    }
  }

  Future<void> createService(ServicePackage service) async {
    final data = service.toJson();
    data.remove('id'); // Remove id from data, let Firestore generate it
    final docRef = await _firestore.collection('services').add(data);

    // Sync with Stripe
    try {
      await _functions.httpsCallable('syncServiceWithStripe').call({
        'serviceId': docRef.id,
        'name': service.title,
        'description': service.description,
        'price': service.price,
        'imageUrl': service.iconUrl,
      });
    } catch (e) {
      print('Error syncing service with Stripe: $e');
    }
  }

  Future<void> updateService(ServicePackage service) async {
    final data = service.toJson();
    data.remove('id');
    await _firestore.collection('services').doc(service.id).update(data);

    // Sync with Stripe
    try {
      await _functions.httpsCallable('syncServiceWithStripe').call({
        'serviceId': service.id,
        'name': service.title,
        'description': service.description,
        'price': service.price,
        'imageUrl': service.iconUrl,
      });
    } catch (e) {
      print('Error syncing service with Stripe: $e');
    }
  }

  Future<void> deleteService(String id) async {
    await _firestore.collection('services').doc(id).delete();
  }
}

@Riverpod(keepAlive: true)
ServiceRepository serviceRepository(Ref ref) {
  return ServiceRepository(ref.watch(firebaseFirestoreProvider));
}

@riverpod
Stream<List<ServicePackage>> services(Ref ref) {
  return ref.watch(serviceRepositoryProvider).getServices();
}

@riverpod
Future<ServicePackage?> serviceById(Ref ref, String serviceId) {
  return ref.watch(serviceRepositoryProvider).getServiceById(serviceId);
}
