import 'package:aquaclean_mobile/src/features/onboarding/presentation/splash_screen.dart';
import 'package:aquaclean_mobile/src/features/onboarding/presentation/landing_screen.dart';
import 'package:aquaclean_mobile/src/features/auth/presentation/business_signup_screen.dart';
import 'package:aquaclean_mobile/src/features/superadmin/presentation/super_admin_dashboard_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/auth/presentation/sign_up_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/nda_check_screen.dart';
import '../features/auth/domain/nda_acceptance.dart';
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
import '../features/admin/presentation/shell/admin_shell.dart';
import '../features/admin/presentation/plans/plans_screen.dart';
import '../features/admin/presentation/subscribers/subscribers_screen.dart';
import '../features/admin/presentation/calendar/admin_calendar_screen.dart';
import '../features/admin/presentation/calendar/calendar_config_screen.dart';
import '../features/admin/presentation/reports/financial_reports_screen.dart';
import '../features/admin/presentation/services/admin_services_screen.dart';
import '../features/admin/presentation/catalog/catalog_management_screen.dart';
import '../features/admin/presentation/license/license_screen.dart';
import '../features/admin/presentation/products/admin_products_screen.dart';
import '../features/admin/presentation/products/create_product_screen.dart';
import '../features/ecommerce/domain/product.dart';

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
import '../features/ecommerce/presentation/orders/paid_orders_screen.dart';
// REMOVED: Cart and Shop imports - subscription-only model
// import '../features/ecommerce/presentation/shop/product_shop_screen.dart';
// import '../features/ecommerce/presentation/cart/cart_screen.dart';
import '../features/dashboard/presentation/shell/client_shell.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/onboarding/data/onboarding_repository.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/dashboard/presentation/screens/services_screen.dart';
import '../features/services/presentation/service_booking_screen.dart';
import '../features/services/presentation/service_detail_screen.dart';
import '../features/services/presentation/my_service_bookings_screen.dart';
import '../features/services/presentation/unified_history_screen.dart';
import '../features/admin/presentation/independent_services/admin_independent_services_screen.dart';
import '../features/admin/presentation/screens/pricing_matrix_screen.dart';
import '../features/admin/presentation/reviews/admin_reviews_analytics_screen.dart';
import '../features/admin/presentation/reviews/admin_review_tags_screen.dart';
import '../features/subscription/presentation/manage_subscription_screen.dart';
import '../features/dashboard/presentation/screens/vehicle_history_screen.dart';
import '../features/auth/presentation/privacy_policy_screen.dart';
import '../features/admin/presentation/services/create_service_screen.dart';
import '../features/profile/domain/vehicle.dart';
import '../features/subscription/domain/subscriber.dart';
import '../features/subscription/domain/subscription_plan.dart';
import '../features/booking/domain/service_package.dart';
import '../features/staff/presentation/check_in/client_check_in_screen.dart';
import '../features/booking/domain/booking.dart';
import '../features/smart_map/presentation/smart_map_screen.dart';

const List<String> _publicRoutes = [
  '/check-in',
  '/landing',
  '/splash',
  '/login',
  '/signup',
  '/business-signup',
  '/forgot-password',
  '/onboarding',
  '/privacy-policy',
  '/payment-success',
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
      // ==========================================
      // ROOT ROUTE - Redirect to splash
      // ==========================================
      GoRoute(path: '/', redirect: (context, state) => '/splash'),

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

      // Signup Screen
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) =>
            _buildPageWithTransition(context, state, const SignUpScreen()),
      ),

      // Business Signup Screen (Lead form)
      GoRoute(
        path: '/business-signup',
        pageBuilder: (context, state) =>
            _buildPageWithTransition(context, state, const BusinessSignUpScreen()),
      ),

      // Landing Screen
      GoRoute(
        path: '/landing',
        pageBuilder: (context, state) =>
            _buildPageWithTransition(context, state, const LandingScreen()),
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

      // NDA & Privacy
      GoRoute(
        path: '/accept-nda',
        builder: (context, state) => const NdaCheckScreen(),
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
            path: 'orders',
            builder: (context, state) => const PaidOrdersScreen(),
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
      // ADMIN ROUTES
      // ==========================================
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'schedule',
            builder: (context, state) => const AdminAppointmentsScreen(),
          ),
        ],
      ),

      // ==========================================
      // SUPER ADMIN ROUTES (PLATFORM OWNER)
      // ==========================================
      GoRoute(
        path: '/superadmin',
        builder: (context, state) => const SuperAdminDashboardScreen(),
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
            path: '/admin/catalog',
            builder: (context, state) => const CatalogManagementScreen(),
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
            path: '/admin/settings',
            builder: (context, state) => const AdminSettingsScreen(),
          ),
          GoRoute(
            path: '/admin/products',
            builder: (context, state) => const AdminProductsScreen(),
          ),
          GoRoute(
            path: '/admin/products/create',
            builder: (context, state) => const CreateProductScreen(),
          ),
          GoRoute(
            path: '/admin/products/edit',
            builder: (context, state) {
              final product = state.extra as Product?;
              return CreateProductScreen(productToEdit: product);
            },
          ),
          GoRoute(
            path: '/admin/license',
            builder: (context, state) => const LicenseScreen(),
          ),
          GoRoute(
            path: '/admin/independent-services',
            builder: (context, state) => const AdminIndependentServicesScreen(),
          ),
          GoRoute(
            path: '/admin/pricing',
            builder: (context, state) => const PricingMatrixScreen(),
          ),
          GoRoute(
            path: '/admin/reviews',
            builder: (context, state) => const AdminReviewsAnalyticsScreen(),
            routes: [
              GoRoute(
                path: 'tags',
                builder: (context, state) => const AdminReviewTagsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

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

    final isAuthPage = currentPath == '/login' ||
        currentPath == '/signup' ||
        currentPath == '/business-signup' ||
        currentPath == '/landing';
    if (isLoggedIn && isAuthPage) {
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
  // STEP 3: Not logged in - redirect to landing
  // ==========================================
  if (!isLoggedIn) {
    // If trying to access protected route, go to landing to select profile
    if (state.matchedLocation != '/login' &&
        state.matchedLocation != '/signup' &&
        state.matchedLocation != '/business-signup' &&
        state.matchedLocation != '/forgot-password' &&
        state.matchedLocation != '/splash' &&
        state.matchedLocation != '/landing' &&
        state.matchedLocation != '/onboarding') {
      return '/landing';
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
  // STEP 5: Check NDA acceptance
  // ==========================================
  final ndaAccepted = user.ndaAcceptedVersion == NdaVersions.currentVersion;
  if (!ndaAccepted) {
    if (state.matchedLocation == '/accept-nda') return null;
    return '/accept-nda';
  }

  // If NDA is accepted but trying to access NDA screen, redirect
  if (state.matchedLocation == '/accept-nda') {
    if (user.role == 'superadmin') return '/superadmin';
    if (user.role == 'admin') return '/admin';
    if (user.role == 'staff') return '/staff';
    return '/dashboard';
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
  final isSuperAdmin = user.role == 'superadmin' || user.email == 'victordesouzaf@gmail.com' || user.email == 'victor@autoolinda.com';
  final isAdmin = user.role == 'admin' || isSuperAdmin;
  final isStaff = user.role == 'staff';

  // ==========================================
  // STEP 7: Onboarding check (ONLY for clients)
  // ==========================================
  // Skip onboarding for admin and staff users
  if (!isAdmin && !isStaff) {
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
      state.matchedLocation == '/business-signup' ||
      state.matchedLocation == '/landing' ||
      state.matchedLocation == '/splash') {
    if (isSuperAdmin) return '/superadmin';
    if (isAdmin) return '/admin';
    if (isStaff) return '/staff';
    return '/dashboard';
  }

  // Role-based route protection
  final isSuperAdminRoute = currentPath.startsWith('/superadmin');
  final isAdminRoute = currentPath.startsWith('/admin');
  final isStaffRoute = currentPath.startsWith('/staff');

  if (isSuperAdmin) {
    // SuperAdmin can go anywhere
  } else if (isStaff) {
    if (isSuperAdminRoute) return '/staff';
    // Staff can only access staff routes and booking routes
    if (!isStaffRoute && !currentPath.startsWith('/booking')) {
      return '/staff';
    }
  } else if (isAdmin) {
    if (isSuperAdminRoute) return '/admin';
    // Admin accessing client dashboard -> redirect to admin
    if (currentPath == '/dashboard') return '/admin';
  } else {
    // Regular client cannot access admin, staff or superadmin routes
    if (isAdminRoute || isStaffRoute || isSuperAdminRoute) return '/dashboard';
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
