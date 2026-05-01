import 'package:aquaclean_mobile/src/features/onboarding/presentation/splash_screen.dart';
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
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/booking/presentation/booking_screen.dart';
import '../features/booking/presentation/booking_detail_screen.dart';
import '../features/booking/presentation/payment_success_screen.dart';
import '../features/admin/presentation/admin_dashboard_screen.dart';
import '../features/booking/presentation/vehicle/add_vehicle_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/admin/presentation/appointments/admin_appointments_screen.dart';
import '../features/admin/presentation/admin_setup_screen.dart';
import '../features/admin/presentation/shell/admin_shell.dart';
import '../features/admin/presentation/plans/plans_screen.dart';
import '../features/admin/presentation/subscribers/subscribers_screen.dart';
import '../features/admin/presentation/calendar/admin_calendar_screen.dart';
import '../features/admin/presentation/calendar/calendar_config_screen.dart';
import '../features/admin/presentation/reports/financial_reports_screen.dart';
import '../features/admin/presentation/services/admin_services_screen.dart';
// catalog, products imports removed (ecommerce not in SaaS scope)

import '../features/admin/presentation/customers/admin_customers_screen.dart';
import '../features/admin/presentation/notifications/admin_notifications_screen.dart';
import '../features/admin/presentation/notifications/admin_inbox_screen.dart';
import '../features/admin/presentation/vehicles/admin_vehicles_screen.dart';
import '../features/admin/presentation/settings/admin_settings_screen.dart';
import '../features/admin/presentation/staff/admin_staff_screen.dart';
import '../features/admin/presentation/staff/admin_staff_detail_screen.dart';
import '../features/subscription/presentation/customer_plans_screen.dart';
import '../features/subscription/presentation/processing_subscription_screen.dart';
import '../features/staff/presentation/staff_dashboard_screen.dart';
import '../features/staff/presentation/staff_history_screen.dart';
import '../features/staff/presentation/staff_profile_screen.dart';
import '../features/staff/presentation/plate_search_screen.dart';
import '../features/staff/presentation/quick_entry/quick_entry_screen.dart';
import '../features/staff/presentation/booking/staff_booking_detail_screen.dart';
// ecommerce removed — PaidOrdersScreen, product shop, and cart are not part of SaaS scope
import '../features/dashboard/presentation/shell/client_shell.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/onboarding/data/onboarding_repository.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/dashboard/presentation/screens/services_screen.dart';
import '../features/services/presentation/service_booking_screen.dart';
import '../features/services/presentation/service_detail_screen.dart';
import '../features/services/presentation/my_service_bookings_screen.dart';
import '../features/services/presentation/unified_history_screen.dart';
import '../features/subscription/presentation/manage_subscription_screen.dart';
import '../features/dashboard/presentation/screens/vehicle_history_screen.dart';
import '../features/auth/presentation/privacy_policy_screen.dart';
import '../features/admin/presentation/services/create_service_screen.dart';
import '../features/profile/domain/vehicle.dart';
import '../features/subscription/domain/subscriber.dart';
import '../features/subscription/domain/subscription_plan.dart';
import '../features/booking/domain/service_package.dart';
import '../features/marketing/presentation/landing_screen.dart';
import '../features/staff/presentation/check_in/client_check_in_screen.dart';
import '../features/booking/domain/booking.dart';
import '../features/smart_map/presentation/smart_map_screen.dart';
import '../features/admin/presentation/super_admin/super_admin_screen.dart';
import '../features/admin/presentation/settings/tenant_branding_screen.dart';

/// List of public routes that don't require authentication
const List<String> _publicRoutes = [
  '/check-in',
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
  // Exact match or starts with (for query params)
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
  // Use ref.read to access providers inside redirect without triggering rebuilds of the GoRouter instance
  // The refreshListenable will handle triggering re-evaluation of redirects

  return GoRouter(
    // IMPORTANT: Don't set initialLocation to allow deep-linking to work
    // The redirect logic will handle sending users to splash if needed
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);
      final userProfileAsync = ref.read(currentUserProfileProvider);

      final decision = _getRedirectDecision(
        state,
        authState,
        userProfileAsync,
        ref,
      );

      // debugPrint('Redirect Decision: $decision');
      return decision;
    },
    // Use the provider that strictly listens to state changes
    refreshListenable: ref.watch(goRouterRefreshListenableProvider),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingScreen(),
      ),

      // ==========================================
      // PUBLIC ROUTES (no auth required)
      // ==========================================

      // Client Check-in Screen - PUBLIC ACCESS for tracking
      GoRoute(
        path: '/check-in',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? '';
          return ClientCheckInScreen(serviceId: id);
        },
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
      // STAFF ROUTES
      // ==========================================
      GoRoute(
        path: '/staff',
        builder: (context, state) => const StaffDashboardScreen(),
        routes: [
          GoRoute(
            path: 'scan',
            builder: (context, state) => const PlateSearchScreen(),
          ),
          GoRoute(
            path: 'quick-entry',
            builder: (context, state) => const QuickEntryScreen(),
          ),
          GoRoute(
            path: 'booking/:id',
            builder: (context, state) {
              final bookingId = state.pathParameters['id']!;
              return StaffBookingDetailScreen(bookingId: bookingId);
            },
          ),
          GoRoute(
            path: 'history',
            builder: (context, state) => const StaffHistoryScreen(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const StaffProfileScreen(),
          ),
        ],
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
              const DashboardScreen(),
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
          GoRoute(
            path: '/smart-map',
            builder: (context, state) {
              final booking = state.extra as Booking;
              return SmartMapScreen(booking: booking);
            },
          ),
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

              // On Flutter Web, GoRouter may deserialize `extra` as a raw Map
              // instead of the original Dart object. We handle both cases.
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

      // ==========================================
      // ADMIN ROUTES (with shell)
      // ==========================================
      ShellRoute(
        builder: (context, state, child) {
          return AdminShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/appointments',
            builder: (context, state) => const AdminAppointmentsScreen(),
          ),
          GoRoute(
            path: '/admin/plans',
            builder: (context, state) => const PlansScreen(),
          ),
          GoRoute(
            path: '/admin/subscribers',
            builder: (context, state) => const SubscribersScreen(),
          ),
          GoRoute(
            path: '/admin/calendar',
            builder: (context, state) => const AdminCalendarScreen(),
            routes: [
              GoRoute(
                path: 'config',
                builder: (context, state) => const CalendarConfigScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/admin/reports',
            builder: (context, state) => const FinancialReportsScreen(),
          ),
          GoRoute(
            path: '/admin/services',
            builder: (context, state) => const AdminServicesScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateServiceScreen(),
              ),
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  final service = state.extra as ServicePackage?;
                  return CreateServiceScreen(serviceToEdit: service);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/admin/customers',
            builder: (context, state) => const AdminCustomersScreen(),
          ),
          GoRoute(
            path: '/admin/inbox',
            builder: (context, state) => const AdminInboxScreen(),
          ),
          GoRoute(
            path: '/admin/notifications',
            builder: (context, state) => const AdminNotificationsScreen(),
          ),
          GoRoute(
            path: '/admin/vehicles',
            builder: (context, state) => const AdminVehiclesScreen(),
          ),
          GoRoute(
            path: '/admin/subscriptions',
            builder: (context, state) => const SubscribersScreen(),
          ),
          GoRoute(
            path: '/admin/setup',
            builder: (context, state) => const AdminSetupScreen(),
          ),
          GoRoute(
            path: '/admin/staff',
            builder: (context, state) => const AdminStaffScreen(),
          ),
          GoRoute(
            path: '/admin/staff/:staffId',
            builder: (context, state) {
              final staffId = state.pathParameters['staffId']!;
              return AdminStaffDetailScreen(staffId: staffId);
            },
          ),
          GoRoute(
            path: '/admin/branding',
            builder: (context, state) => const TenantBrandingScreen(),
          ),
          GoRoute(
            path: '/admin/settings',
            builder: (context, state) => const AdminSettingsScreen(),
          ),
        ],
      ),
      _superAdminRoute,
    ],
  );
});

// Super-admin screen (outside admin shell — full-page, no bottom nav)
final GoRoute _superAdminRoute = GoRoute(
  path: '/super-admin',
  builder: (context, state) => const SuperAdminScreen(),
);

String? _getRedirectDecision(
  GoRouterState state,
  AsyncValue<dynamic> authState,
  AsyncValue<dynamic> userProfileAsync,
  Ref ref,
) {
  final currentPath = state.uri.path;

  // debugPrint('--- ROUTER REDIRECT ---');
  // debugPrint('Path: $currentPath');
  // debugPrint('Auth Loading: ${authState.isLoading}');
  // debugPrint('Is Logged In: ${authState.valueOrNull != null}');
  // debugPrint('Profile Loading: ${userProfileAsync.isLoading}');
  // debugPrint('Profile Value: ${userProfileAsync.value}');

  // ==========================================
  // STEP 1: PUBLIC ROUTES - Always allow access
  // ==========================================
  if (_isPublicRoute(currentPath)) {
    // For check-in, never redirect - this is a public tracking page
    if (currentPath == '/check-in') {
      return null;
    }

    final isLoggedIn = authState.valueOrNull != null;

    // SPECIAL CASE: If logged in and on Login/Signup, DO NOT return null.
    // Let the logic proceed so we can redirect them to Dashboard/Admin.
    final isAuthPage = currentPath == '/login' || currentPath == '/signup';
    if (isLoggedIn && isAuthPage) {
      // debugPrint(
      //   'Public Route but Logged In on Auth Page -> Proceeding to consistency checks',
      // );
      // Do NOT return null here. Fall through.
    } else {
      // Not logged in OR not on auth page (e.g. privacy policy) -> Allow
      return null;
    }
  }

  // ==========================================
  // STEP 2: Handle auth state loading
  // ==========================================
  final isAuthLoading = authState.isLoading;
  final isLoggedIn = authState.valueOrNull != null;

  // If auth is still loading and not on splash, go to splash
  if (isAuthLoading) {
    if (state.matchedLocation != '/splash') {
      return '/splash';
    }
    return null;
  }

  // ==========================================
  // STEP 3: Not logged in - redirect to login
  // ==========================================
  if (!isLoggedIn) {
    // If trying to access protected route, go to login
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

  // ==========================================
  // STEP 4: Logged in - check profile loading
  // ==========================================
  if (userProfileAsync.isLoading) {
    return null; // Wait for profile to load
  }

  final user = userProfileAsync.value;
  if (user == null) {
    return null; // Still loading
  }



  // ==========================================
  // STEP 5.5: Check Strike Status (Blocked)
  // ==========================================
  if (user.strikeUntil != null && user.strikeUntil!.isAfter(DateTime.now())) {
    // If user is blocked, they can ONLY access /blocked
    // (Unless they are accessing support maybe? But let's be strict for now)
    if (state.matchedLocation != '/blocked') {
      return '/blocked';
    }
    return null;
  }

  // If NOT blocked but trying to access /blocked, redirect back
  if (state.matchedLocation == '/blocked' &&
      (user.strikeUntil == null ||
          user.strikeUntil!.isBefore(DateTime.now()))) {
    return '/dashboard';
  }

  // ==========================================
  // STEP 6: Role-based routing (check role FIRST)
  // ==========================================
  // Role helpers use the new AppUserRoles extension (backward-compat with 'admin'/'client')
  final isSuperAdmin = user.isSuperAdmin;
  final isTenantAdmin = user.isTenantAdmin; // tenantOwner OR legacy 'admin'
  final isStaff = user.isStaff;

  // ==========================================
  // STEP 7: Onboarding check (ONLY for clients)
  // ==========================================
  // Skip onboarding for admin and staff users
  if (!isSuperAdmin && !isTenantAdmin && !isStaff) {
    final isOnboardingComplete = ref
        .read(onboardingRepositoryProvider)
        .isOnboardingComplete();

    if (!isOnboardingComplete && state.matchedLocation != '/onboarding') {
      return '/onboarding';
    }

    // ==========================================
    // STEP 7.5: SUBSCRIPTION GUARD (Clients only)
    // ==========================================
    // Enforce subscription requirement - Linear flow:
    // 1. Check if user has vehicle registered
    // 2. Check if user has active subscription
    // 3. Redirect to appropriate step if not complete

    final hasActiveSubscription = user.subscriptionStatus == 'active';

    // Allow access to subscription-related routes
    final isSubscriptionRoute =
        state.matchedLocation == '/add-vehicle' ||
        state.matchedLocation == '/plans' ||
        state.matchedLocation == '/processing-subscription' ||
        state.matchedLocation == '/manage-subscription' ||
        state.matchedLocation.startsWith('/payment');

    // If no active subscription and not on a subscription route, redirect to plans
    if (!hasActiveSubscription && !isSubscriptionRoute) {
      return '/plans';
    }
  }

  // Redirect from login/signup if already logged in
  if (state.matchedLocation == '/login' ||
      state.matchedLocation == '/signup' ||
      state.matchedLocation == '/splash') {
    if (isSuperAdmin) return '/super-admin';
    if (isTenantAdmin) {
      // If owner has no tenant yet, force setup
      if (user.tenantId == null || user.tenantId!.isEmpty) {
        return '/admin/setup';
      }
      return '/admin';
    }
    if (isStaff) return '/staff';
    return '/dashboard';
  }

  // If owner is logged in but has no tenant, force setup (unless already on setup)
  if (isTenantAdmin && (user.tenantId == null || user.tenantId!.isEmpty)) {
    if (state.matchedLocation != '/admin/setup') {
      return '/admin/setup';
    }
    return null;
  }

  // Role-based route protection
  final isAdminRoute = currentPath.startsWith('/admin');
  final isStaffRoute = currentPath.startsWith('/staff');

  if (isStaff) {
    if (!isStaffRoute && !currentPath.startsWith('/booking')) {
      return '/staff';
    }
  } else if (isTenantAdmin || isSuperAdmin) {
    if (currentPath == '/dashboard') return '/admin';
  } else {
    if (isAdminRoute || isStaffRoute) return '/dashboard';
  }

  return null;
}

/// A Listenable that notifies when relevant providers change
final goRouterRefreshListenableProvider = Provider<Listenable>((ref) {
  final notifier = GoRouterRefreshNotifier();

  // Listen to Auth State changes
  ref.listen(authStateChangesProvider, (_, __) {
    notifier.notify();
  });

  // Listen to User Profile changes
  ref.listen(currentUserProfileProvider, (_, __) {
    notifier.notify();
  });

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
