import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/lead_client.dart';

class QuickEntryRepository {
  final FirebaseFirestore _firestore;

  QuickEntryRepository(this._firestore);

  CollectionReference get _leadsCollection =>
      _firestore.collection('leads_clients');

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

  // Create Active Service (Quick Entry) -> Now creates a Booking
  Future<String> createActiveService({
    required String plate,
    required String staffId,
    required String serviceType,
    required String vehicleModel,
  }) async {
    final docRef = _firestore.collection('appointments').doc();
    final bookingId = docRef.id;

    // Create a guest booking
    // Using a special format for vehicleId to store guest details: "GUEST:PLATE:MODEL"
    // This allows us to display it correctly without a real vehicle record
    final guestVehicleId = 'GUEST:$plate:$vehicleModel';

    final booking = {
      'id': bookingId,
      'userId': 'guest',
      'vehicleId': guestVehicleId,
      'serviceIds': [serviceType],
      'status': 'checkIn', // Start at Check-In (formerly 'fila')
      'paymentStatus': 'pending',
      'totalPrice': 0.0, // Will be calculated later or updated
      'scheduledTime': Timestamp.fromDate(DateTime.now()),
      'createdAt': FieldValue.serverTimestamp(),
      'staffNotes': 'Entrada Rápida por $staffId',
      'staffId': staffId,
      'isGuest': true, // Flag to identify guest bookings
    };

    await docRef.set(booking);

    // Also update Lead (Capture potential client)
    await _leadsCollection.doc(plate).set({
      'plate': plate,
      'vehicleModel': vehicleModel,
      'lastServiceAt': FieldValue.serverTimestamp(),
      'status': 'lead_nao_cadastrado',
    }, SetOptions(merge: true));

    return bookingId;
  }
}

final quickEntryRepositoryProvider = Provider<QuickEntryRepository>((ref) {
  return QuickEntryRepository(FirebaseFirestore.instance);
});
