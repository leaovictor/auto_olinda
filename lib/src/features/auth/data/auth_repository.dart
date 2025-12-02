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

    // Fetch or create user profile
    final profile = await getUserProfile(credential.user!.uid);
    if (profile != null) return profile;

    // Create profile if doesn't exist
    final newUser = AppUser(
      uid: credential.user!.uid,
      email: credential.user!.email!,
      displayName: credential.user!.displayName,
      photoUrl: credential.user!.photoURL,
    );

    await _firestore.collection('users').doc(newUser.uid).set(newUser.toJson());
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

    // Create user profile in Firestore
    final newUser = AppUser(
      uid: credential.user!.uid,
      email: email,
      displayName: displayName ?? credential.user!.displayName,
      photoUrl: credential.user!.photoURL,
    );

    await _firestore.collection('users').doc(newUser.uid).set(newUser.toJson());
    return newUser;
  }

  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  Future<void> updateUserProfile(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toJson());
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
Stream<AppUser?> currentUserProfile(Ref ref) async* {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    yield null;
  } else {
    yield await ref.watch(authRepositoryProvider).getUserProfile(user.uid);
  }
}
