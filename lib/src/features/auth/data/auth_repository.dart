import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/app_user.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._firebaseAuth, this._firestore);

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return AppUser.fromJson({...doc.data()!, 'uid': uid});
    } catch (e) {
      return null;
    }
  }

  Stream<AppUser?> watchUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromJson({...doc.data()!, 'uid': uid});
    });
  }

  Future<AppUser> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user == null) {
      throw Exception('Sign in failed');
    }

    // Update last access timestamp
    await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .update({'lastAccessAt': FieldValue.serverTimestamp()})
        .catchError((_) {
          // Ignore if document doesn't exist yet
        });

    // Fetch or create user profile
    final profile = await getUserProfile(credential.user!.uid);
    if (profile != null) return profile;

    // Create profile if doesn't exist
    final newUser = AppUser(
      uid: credential.user!.uid,
      email: credential.user!.email!,
      displayName: credential.user!.displayName,
      photoUrl: credential.user!.photoURL,
      lastAccessAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(newUser.uid).set(newUser.toJson());
    return newUser;
  }

  Future<AppUser> createUserWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
    String? tenantId,
    String role = 'customer',
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user == null) {
      throw Exception('User creation failed');
    }

    // Update display name if provided
    if (displayName != null) {
      await credential.user!.updateDisplayName(displayName);
    }

    // Create user profile in Firestore
    final newUser = AppUser(
      uid: credential.user!.uid,
      email: email,
      displayName: displayName ?? credential.user!.displayName,
      photoUrl: credential.user!.photoURL,
      tenantId: tenantId,
      role: role,
    );

    await _firestore.collection('users').doc(newUser.uid).set({
      ...newUser.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return newUser;
  }

  Future<void> signOut() async {
    // Remove FCM token before signing out to prevent notifications
    // from being sent to this device for the old user
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      try {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'fcmToken': FieldValue.delete(),
        });
      } catch (e) {
        // Ignore errors - user might not have a document yet
      }
    }
    return _firebaseAuth.signOut();
  }

  Future<void> updateUserProfile(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toJson());
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> linkServiceToUser(
    String userId,
    String serviceId,
    String plate,
  ) async {
    final batch = _firestore.batch();

    // Link Active Service (Booking) to User
    final serviceRef = _firestore.collection('appointments').doc(serviceId);
    batch.update(serviceRef, {'userId': userId});

    // Convert Lead to User
    final leadRef = _firestore.collection('leads_clients').doc(plate);
    batch.update(leadRef, {'uid': userId, 'status': 'converted'});

    await batch.commit();
  }
}

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) {
  return FirebaseAuth.instance;
}

@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(Ref ref) {
  return FirebaseFirestore.instance;
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firebaseFirestoreProvider),
  );
}

@Riverpod(keepAlive: true)
Stream<User?> authStateChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}

@Riverpod(keepAlive: true)
Stream<AppUser?> currentUserProfile(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    return Stream.value(null);
  }
  return ref.watch(authRepositoryProvider).watchUserProfile(user.uid);
}

/// Provider to get users in the current tenant (customers only).
/// Replaces the old global allUsersProvider which queried ALL users.
final allUsersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final tenantId =
      ref.watch(currentUserProfileProvider).valueOrNull?.tenantId ?? '';
  if (tenantId.isEmpty) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('users')
      .where('tenantId', isEqualTo: tenantId)
      .where('role', whereIn: ['customer', 'client'])
      .orderBy('displayName')
      .limit(200)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return {'id': doc.id, ...doc.data()};
        }).toList();
      });
});
