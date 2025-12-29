import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/lead_client.dart';
import '../domain/active_service.dart';

class QuickEntryRepository {
  final FirebaseFirestore _firestore;

  QuickEntryRepository(this._firestore);

  CollectionReference get _leadsCollection =>
      _firestore.collection('leads_clients');
  CollectionReference get _servicesCollection =>
      _firestore.collection('servicos_ativos');

  CollectionReference get _servicesConfigCollection =>
      _firestore.collection('services');
  CollectionReference get _independentServicesCollection =>
      _firestore.collection('independent_services');

  // Fetch standard car wash services
  Future<List<Map<String, dynamic>>> fetchServices() async {
    final snapshot = await _servicesConfigCollection.get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  // Fetch aesthetic services
  Future<List<Map<String, dynamic>>> fetchIndependentServices() async {
    final snapshot = await _independentServicesCollection.get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  // Watch active services (real-time updates)
  Stream<List<ActiveService>> watchActiveServices() {
    return _servicesCollection
        .orderBy('startedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            // Manually mapping if needed or update FromJson in model to handle everything active_service.g.dart does
            // For simplicity, let's trust the model's fromJson.
            // We'll need to pass the ID.
            return ActiveService.fromJson({'id': doc.id, ...data});
          }).toList();
        });
  }

  // Find a lead by plate
  Future<LeadClient?> getLeadByPlate(String plate) async {
    final doc = await _leadsCollection.doc(plate).get();
    if (doc.exists) {
      return LeadClient.fromFirestore(doc);
    }
    return null;
  }

  // Create or Update Lead
  Future<void> saveLead(LeadClient lead) async {
    // If it's an update, we might want to merge, but for now we'll set.
    // Spec says: If exists, update lastServiceAt. If not, create.
    // The model passed in should have the updated values.
    await _leadsCollection.doc(lead.plate).set(lead.toJson());
  }

  // Create Active Service
  Future<ActiveService> createActiveService({
    required String plate,
    required String staffId,
    required String serviceType,
    required String vehicleModel, // Needed for message generation potentially
  }) async {
    final docRef = _servicesCollection.doc(); // Auto-generated ID
    final serviceId = docRef.id;
    final clientLink =
        'http://autoolinda-5199e.web.app/check-in?id=${docRef.id}'; // TODO: Make domain configurable?

    final service = ActiveService(
      id: serviceId,
      plate: plate,
      vehicleModel: vehicleModel,
      status: ServiceStatus.fila,
      startedAt: DateTime.now(),
      staffId: staffId,
      serviceType: serviceType,
      clientLink: clientLink,
    );

    // Save using toJson (Freezed)
    // Note: We need to ensure logic handles this if model differs from Firestore map slightly
    // but here we just pass mapped data.
    await docRef.set(service.toJson());

    // Also update Lead
    await _leadsCollection.doc(plate).update({
      'lastServiceAt': FieldValue.serverTimestamp(),
    });

    return service;
  }
}

final quickEntryRepositoryProvider = Provider<QuickEntryRepository>((ref) {
  return QuickEntryRepository(FirebaseFirestore.instance);
});

final activeServicesStreamProvider = StreamProvider<List<ActiveService>>((ref) {
  final repository = ref.watch(quickEntryRepositoryProvider);
  return repository.watchActiveServices();
});
