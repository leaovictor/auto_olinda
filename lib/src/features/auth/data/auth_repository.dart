import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/app_user.dart';
import '../../../core/tenant/tenant_firestore.dart';
import '../../../core/tenant/tenant_service.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._firebaseAuth, this._firestore);

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  // ── Tenant-scoped helpers ───────────────────────────────────────────────────

  /// Returns the tenantId from the current user's custom claims.
  /// Falls back to a safe empty string so the app doesn't crash during
  /// the brief window between login and TenantService.init().
  Future<String> _getTenantId() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return '';
    final result = await user.getIdTokenResult();
    return (result.claims?['tenantId'] as String?) ?? '';
  }

  // ── User profile ────────────────────────────────────────────────────────────

  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final tenantId = await _getTenantId();
      if (tenantId.isEmpty) return null;
      final doc = await TenantFirestore.doc('users', uid, tenantId).get();
      if (!doc.exists) return null;
      return AppUser.fromJson({...doc.data()!, 'uid': uid});
    } catch (e) {
      return null;
    }
  }

  Stream<AppUser?> watchUserProfile(String uid) async* {
    final tenantId = await _getTenantId();
    if (tenantId.isEmpty) {
      yield null;
      return;
    }
    yield* TenantFirestore.doc('users', uid, tenantId).snapshots().map((doc) {
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

    // Resolve tenantId from the just-returned token claims.
    final tokenResult = await credential.user!.getIdTokenResult(true);
    final tenantId = (tokenResult.claims?['tenantId'] as String?) ?? '';

    if (tenantId.isNotEmpty) {
      // Update last access timestamp
      await TenantFirestore.doc('users', credential.user!.uid, tenantId)
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

      await TenantFirestore.doc('users', newUser.uid, tenantId)
          .set(newUser.toJson());
      return newUser;
    }

    // Fallback: user without tenant claim (should only happen during migration)
    final newUser = AppUser(
      uid: credential.user!.uid,
      email: credential.user!.email!,
      displayName: credential.user!.displayName,
      photoUrl: credential.user!.photoURL,
      lastAccessAt: DateTime.now(),
    );
    return newUser;
  }

  Future<AppUser> createUserWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
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

    // Resolve tenantId
    final tokenResult = await credential.user!.getIdTokenResult(true);
    final tenantId = (tokenResult.claims?['tenantId'] as String?) ?? '';

    final newUser = AppUser(
      uid: credential.user!.uid,
      email: email,
      displayName: displayName ?? credential.user!.displayName,
      photoUrl: credential.user!.photoURL,
    );

    if (tenantId.isNotEmpty) {
      await TenantFirestore.doc('users', newUser.uid, tenantId)
          .set(newUser.toJson());
    }

    return newUser;
  }

  Future<void> signOut() async {
    // Remove FCM token before signing out
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      try {
        final tenantId = await _getTenantId();
        if (tenantId.isNotEmpty) {
          await TenantFirestore.doc('users', currentUser.uid, tenantId).update({
            'fcmToken': FieldValue.delete(),
          });
        }
      } catch (e) {
        // Ignore errors
      }
    }
    return _firebaseAuth.signOut();
  }

  Future<void> updateUserProfile(AppUser user) async {
    final tenantId = await _getTenantId();
    if (tenantId.isEmpty) return;
    await TenantFirestore.doc('users', user.uid, tenantId).update(user.toJson());
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> linkServiceToUser(
    String userId,
    String serviceId,
    String plate,
  ) async {
    final tenantId = await _getTenantId();
    if (tenantId.isEmpty) return;

    final batch = _firestore.batch();

    // Link Active Service (Booking) to User
    final serviceRef = TenantFirestore.doc('appointments', serviceId, tenantId);
    batch.update(serviceRef, {'userId': userId});

    // Convert Lead to User (leads_clients stays global for now)
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

/// Provider to get all users scoped to the current tenant (admin feature).
final allUsersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final tenantAsync = ref.watch(tenantServiceProvider);
  return tenantAsync.when(
    data: (ctx) {
      if (ctx == null) return Stream.value([]);
      return TenantFirestore.col('users', ctx.tenantId)
          .where('role', isEqualTo: 'client')
          .orderBy('displayName')
          .limit(100)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return {'id': doc.id, ...doc.data()};
            }).toList();
          });
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});
