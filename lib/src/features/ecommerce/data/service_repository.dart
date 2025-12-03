import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/service.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository();
});

final activeServicesProvider = StreamProvider<List<Service>>((ref) {
  return ref.watch(serviceRepositoryProvider).watchActiveServices();
});

class ServiceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Get all active services
  Stream<List<Service>> watchActiveServices() {
    return _firestore
        .collection('services')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Service.fromJson(data);
          }).toList();
        });
  }

  /// Get service by ID
  Future<Service?> getService(String serviceId) async {
    final doc = await _firestore.collection('services').doc(serviceId).get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    data['id'] = doc.id;
    return Service.fromJson(data);
  }

  /// Create service (Admin only)
  Future<void> createService(Service service) async {
    final data = service.toJson();
    data.remove('id');

    final docRef = await _firestore.collection('services').add(data);

    // Sync with Stripe
    try {
      await _functions.httpsCallable('syncServiceWithStripe').call({
        'serviceId': docRef.id,
        'name': service.name,
        'description': service.description,
        'price': service.price,
        'imageUrl': service.imageUrl,
      });
    } catch (e) {
      print('Error syncing service with Stripe: $e');
    }
  }

  /// Update service (Admin only)
  Future<void> updateService(Service service) async {
    final data = service.toJson();
    data.remove('id');

    await _firestore.collection('services').doc(service.id).update(data);

    // Sync with Stripe
    try {
      await _functions.httpsCallable('syncServiceWithStripe').call({
        'serviceId': service.id,
        'name': service.name,
        'description': service.description,
        'price': service.price,
        'imageUrl': service.imageUrl,
      });
    } catch (e) {
      print('Error syncing service with Stripe: $e');
    }
  }

  /// Delete service (Admin only)
  Future<void> deleteService(String serviceId) async {
    await _firestore.collection('services').doc(serviceId).delete();
  }
}
