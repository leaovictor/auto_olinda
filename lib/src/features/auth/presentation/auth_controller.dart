import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../notifications/data/notification_service.dart';
import '../data/auth_repository.dart';
import '../data/nda_repository.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // No initial state to load
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signInWithEmailAndPassword(email, password);

      // Trigger NDA Self-Healing immediately
      // This checks if they accepted (even if profile is desynced) and updates profile if needed
      await ref.read(ndaRepositoryProvider).hasAcceptedCurrentVersion(user.uid);

      // Set success state BEFORE trying to save token
      // This prevents race conditions with async token saving
      state = const AsyncValue.data(null);

      // Save FCM Token in background (fire-and-forget)
      // Don't await - this prevents "Future already completed" errors
      // and makes login faster
      _saveTokenInBackground();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Saves FCM token in background without blocking or affecting state
  void _saveTokenInBackground() {
    Future(() async {
      try {
        await ref.read(notificationServiceProvider).saveCurrentToken();
      } catch (e) {
        // Silently ignore - token will be saved on next app start
        // This is non-critical for the login flow
      }
    });
  }

  Future<void> signUp(
    String email,
    String password,
    String displayName,
    String ndaText,
  ) async {
    state = const AsyncValue.loading();
    try {
      final appUser = await ref
          .read(authRepositoryProvider)
          .createUserWithEmailAndPassword(
            email,
            password,
            displayName: displayName,
          );

      // Record NDA Acceptance
      await ref
          .read(ndaRepositoryProvider)
          .recordNdaAcceptance(
            userId: appUser.uid,
            userEmail: email,
            ndaText: ndaText,
          );

      // Save FCM Token
      await ref.read(notificationServiceProvider).saveCurrentToken();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> acceptNda(String ndaText) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Record NDA Acceptance
      await ref
          .read(ndaRepositoryProvider)
          .recordNdaAcceptance(
            userId: user.uid,
            userEmail: user.email!,
            ndaText: ndaText,
          );

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
