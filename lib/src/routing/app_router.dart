import 'package:aquaclean_mobile/src/features/tenant/onboarding/presentation/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/domain/app_user.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/auth/presentation/sign_up_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/strike_screen.dart';
import '../features/owner_dashboard/presentation/subscriber_dashboard.dart';
import '../features/owner_dashboard/presentation/shell/client_shell.dart';
import '../features/owner_dashboard/presentation/screens/services_screen.dart';
import '../features/owner_dashboard/presentation/screens/vehicle_history_screen.dart';
import '../features/marketing_owner/presentation/landing_screen.dart';
import '../features/appointments/domain/booking.dart';
// TODO: SmartMapScreen feature missing - reimplement under owner_dashboard or dedicated map feature
// import '../features/smart_map/presentation/smart_map_screen.dart';

/// List of public routes that don't require authentication
const List<String> _publicRoutes = [
  '/splash',
  '/login',
  '/signup',
  '/forgot-password',
  '/onboarding',
  '/privacy-policy',
  '/payment-success',
  '/',
];

/// Check if a path is a public route (no auth required)
bool _isPublicRoute(String path) {
  for (final route in _publicRoutes) {
    if (path == route ||
        path.startsWith('$route?') ||
        path.startsWith('$route/')) {
      return true;
    }
  }
  return false;
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);
      final userProfileAsync = ref.read(currentUserProfileProvider);

      return _getRedirectDecision(
        state,
        authState,
        userProfileAsync,
        ref,
      );
    },
    refreshListenable: ref.watch(goRouterRefreshListenableProvider),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingScreen(),
      ),

      // Splash Screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            _buildPageWithTransition(context, state, const SignInScreen()),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) =>
            _buildPageWithTransition(context, state, const SignUpScreen()),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context,
          state,
          const ForgotPasswordScreen(),
        ),
      ),

      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),

      // Blocked Screen
      GoRoute(
        path: '/blocked',
        builder: (context, state) => const StrikeScreen(),
      ),

      // ==========================================
      // CLIENT ROUTES (with shell)
      // ==========================================
      ShellRoute(
        builder: (context, state, child) {
          return ClientShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context,
              state,
              const SubscriberDashboard(),
            ),
          ),
          GoRoute(
            path: '/booking',
            pageBuilder: (context, state) =>
                _buildPageWithTransition(context, state, const BookingScreen()),
          ),
          GoRoute(
            path: '/booking/:id',
            builder: (context, state) {
              final bookingId = state.pathParameters['id']!;
              return BookingDetailScreen(bookingId: bookingId);
            },
          ),
          GoRoute(
            path: '/my-bookings',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context,
              state,
              const UnifiedHistoryScreen(),
            ),
          ),
//           GoRoute(
//             path: '/smart-map',
//             builder: (context, state) {
//               final booking = state.extra as Booking;
//               return SmartMapScreen(booking: booking);
//             },
//           ),
          GoRoute(
            path: '/services',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context,
              state,
              const ServicesScreen(),
            ),
          ),
          GoRoute(
            path: '/add-vehicle',
            builder: (context, state) => const AddVehicleScreen(),
          ),
          GoRoute(
            path: '/vehicle-history',
            builder: (context, state) {
              final vehicle = state.extra as Vehicle;
              return VehicleHistoryScreen(vehicle: vehicle);
            },
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                _buildPageWithTransition(context, state, const ProfileScreen()),
          ),
          GoRoute(
            path: '/edit-profile',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context,
              state,
              const EditProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/plans',
            builder: (context, state) => const CustomerPlansScreen(),
          ),
          GoRoute(
            path: '/processing-subscription',
            builder: (context, state) => const ProcessingSubscriptionScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/payment-success',
            builder: (context, state) => const PaymentSuccessScreen(),
          ),
          GoRoute(
            path: '/manage-subscription',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              final rawSub = extra['subscription'];
              final Subscriber subscription = rawSub is Subscriber
                  ? rawSub
                  : Subscriber.fromJson(
                      Map<String, dynamic>.from(rawSub as Map),
                    );

              final rawPlan = extra['currentPlan'];
              final SubscriptionPlan currentPlan = rawPlan is SubscriptionPlan
                  ? rawPlan
                  : SubscriptionPlan.fromJson(
                      Map<String, dynamic>.from(rawPlan as Map),
                    );

              final rawPlans = extra['availablePlans'] as List<dynamic>;
              final List<SubscriptionPlan> availablePlans =
                  rawPlans.map((p) {
                    if (p is SubscriptionPlan) return p;
                    return SubscriptionPlan.fromJson(
                      Map<String, dynamic>.from(p as Map),
                    );
                  }).toList();

              return ManageSubscriptionScreen(
                subscription: subscription,
                currentPlan: currentPlan,
                availablePlans: availablePlans,
              );
            },
          ),
          GoRoute(
            path: '/service/:id',
            builder: (context, state) {
              final serviceId = state.pathParameters['id']!;
              return ServiceDetailScreen(serviceId: serviceId);
            },
          ),
          GoRoute(
            path: '/services/:id/book',
            builder: (context, state) {
              final serviceId = state.pathParameters['id']!;
              return ServiceBookingScreen(serviceId: serviceId);
            },
          ),
          GoRoute(
            path: '/my-services',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context,
              state,
              const MyServiceBookingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

String? _getRedirectDecision(
  GoRouterState state,
  AsyncValue<dynamic> authState,
  AsyncValue<AppUser?> userProfileAsync,
  Ref ref,
) {
  final currentPath = state.uri.path;

  // 1. PUBLIC ROUTES
  if (_isPublicRoute(currentPath)) {
    final isLoggedIn = authState.valueOrNull != null;
    final isAuthPage = currentPath == '/login' || currentPath == '/signup';
    if (isLoggedIn && isAuthPage) {
      // Fall through to dashboard redirect
    } else {
      return null;
    }
  }

  // 2. Auth Loading
  if (authState.isLoading) {
    if (state.matchedLocation != '/splash') return '/splash';
    return null;
  }

  // 3. Not logged in
  if (authState.valueOrNull == null) {
    if (state.matchedLocation != '/login' &&
        state.matchedLocation != '/signup' &&
        state.matchedLocation != '/forgot-password' &&
        state.matchedLocation != '/splash' &&
        state.matchedLocation != '/' &&
        state.matchedLocation != '/onboarding') {
      return '/login';
    }
    return null;
  }

  // 4. Profile loading
  if (userProfileAsync.isLoading) return null;
  final user = userProfileAsync.value;
  if (user == null) return null;

  // 5. Strike check (Blocked)
  if (user.strikeUntil != null && user.strikeUntil!.isAfter(DateTime.now())) {
    if (state.matchedLocation != '/blocked') return '/blocked';
    return null;
  }

  // 6. Onboarding check
  final isOnboardingComplete = ref
      .read(onboardingRepositoryProvider)
      .isOnboardingComplete();

  if (!isOnboardingComplete && state.matchedLocation != '/onboarding') {
    return '/onboarding';
  }

  // 7. Subscription Guard
  final hasActiveSubscription = user.subscriptionStatus == 'active';
  final isSubscriptionRoute =
      state.matchedLocation == '/add-vehicle' ||
      state.matchedLocation == '/plans' ||
      state.matchedLocation == '/processing-subscription' ||
      state.matchedLocation == '/manage-subscription' ||
      state.matchedLocation.startsWith('/payment');

  if (!user.hasAdminAccess && !hasActiveSubscription && !isSubscriptionRoute) {
    return '/plans';
  }

  // Redirect from login/signup if already logged in
  if (state.matchedLocation == '/login' ||
      state.matchedLocation == '/signup' ||
      state.matchedLocation == '/splash') {
    return '/dashboard';
  }

  return null;
}

final goRouterRefreshListenableProvider = Provider<Listenable>((ref) {
  final notifier = GoRouterRefreshNotifier();
  ref.listen(authStateChangesProvider, (_, __) => notifier.notify());
  ref.listen(currentUserProfileProvider, (_, __) => notifier.notify());
  return notifier;
});

class GoRouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

Page<dynamic> _buildPageWithTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}
