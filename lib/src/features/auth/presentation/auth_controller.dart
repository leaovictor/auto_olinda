import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/auth_repository.dart';
import '../domain/app_user.dart';
import '../../notifications/data/notification_service.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // nothing to do
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        ref.read(authRepositoryProvider).signInWithEmailAndPassword(email, password));
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    String role = 'customer',
    String? tenantId,
    String? serviceLink,
    String? plate,
  }) async {
    state = const AsyncValue.loading();
    try {
      final appUser = await ref
          .read(authRepositoryProvider)
          .createUserWithEmailAndPassword(
            email,
            password,
            displayName: displayName,
            tenantId: tenantId,
            role: role,
          );

      if (serviceLink != null && plate != null) {
        await ref
            .read(authRepositoryProvider)
            .linkServiceToUser(appUser.uid, serviceLink, plate);
      }

      await ref.read(notificationServiceProvider).saveCurrentToken();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        ref.read(authRepositoryProvider).sendPasswordResetEmail(email));
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(authRepositoryProvider).signOut());
  }
}
