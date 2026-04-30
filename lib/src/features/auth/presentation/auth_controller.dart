import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../notifications/data/notification_service.dart';
import '../../subscription/data/subscription_repository.dart';
import '../data/auth_repository.dart';

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

      // NDA logic removed


      // Set success state BEFORE trying to save token
      // This prevents race conditions with async token saving
      state = const AsyncValue.data(null);

      // Sync subscriptions from Stripe in background
      // This ensures the subscription status is up-to-date
      _syncSubscriptionsInBackground();

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

  /// Syncs user subscriptions from Stripe in background
  /// Ensures that even if a plan is deactivated, active subscriptions remain valid
  void _syncSubscriptionsInBackground() {
    Future(() async {
      try {
        await ref
            .read(subscriptionRepositoryProvider)
            .syncUserSubscriptionsFromStripe();
      } catch (e) {
        // Silently ignore - not critical for login flow
        // Subscription status will be updated via webhooks anyway
      }
    });
  }

  Future<void> signUp(
    String email,
    String password,
    String displayName, {
    String? serviceLink,
    String? plate,
    // tenantId from the signup URL (?tenantId=xxx) or app config.
    // If null, user is not scoped to any tenant (superAdmin-only scenario).
    String? tenantId,
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
          );

      // Link Service if provided
      if (serviceLink != null && plate != null) {
        await ref
            .read(authRepositoryProvider)
            .linkServiceToUser(appUser.uid, serviceLink, plate);
      }

      // Save FCM Token
      await ref.read(notificationServiceProvider).saveCurrentToken();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // acceptNda method removed


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
