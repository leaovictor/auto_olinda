import 'package:aquaclean_mobile/src/features/onboarding/presentation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/auth/presentation/sign_up_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/nda_check_screen.dart';
import '../features/auth/domain/nda_acceptance.dart';
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
import '../features/admin/presentation/vehicles/admin_vehicles_screen.dart';
import '../features/admin/presentation/settings/admin_settings_screen.dart';
import '../features/admin/presentation/staff/admin_staff_screen.dart';
import '../features/subscription/presentation/customer_plans_screen.dart';
import '../features/staff/presentation/staff_dashboard_screen.dart';
import '../features/staff/presentation/staff_history_screen.dart';
import '../features/staff/presentation/staff_profile_screen.dart';
import '../features/staff/presentation/plate_search_screen.dart';
import '../features/staff/presentation/booking/staff_booking_detail_screen.dart';
import '../features/ecommerce/presentation/orders/paid_orders_screen.dart';
import '../features/ecommerce/presentation/shop/product_shop_screen.dart';
import '../features/ecommerce/presentation/cart/cart_screen.dart';
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
import '../features/subscription/presentation/manage_subscription_screen.dart';
import '../features/dashboard/presentation/screens/vehicle_history_screen.dart';
import '../features/auth/presentation/privacy_policy_screen.dart';
import '../features/admin/presentation/services/create_service_screen.dart';
import '../features/profile/domain/vehicle.dart';
import '../features/subscription/domain/subscriber.dart';
import '../features/subscription/domain/subscription_plan.dart';
import '../features/booking/domain/service_package.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final userProfileAsync = ref.watch(currentUserProfileProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSigningUp = state.matchedLocation == '/signup';
      final isPaymentSuccess = state.matchedLocation == '/payment-success';
      final isSplash = state.matchedLocation == '/splash';
      final isAcceptNda = state.matchedLocation == '/accept-nda';

      // Always allow splash
      if (isSplash) return null;

      // Wait for profile to load if logged in
      if (isLoggedIn && userProfileAsync.isLoading) {
        return null;
      }

      if (!isLoggedIn) {
        final isForgotPassword = state.matchedLocation == '/forgot-password';
        if (isLoggingIn ||
            isSigningUp ||
            isForgotPassword ||
            isPaymentSuccess) {
          return null;
        }
        return '/login';
      }

      // Logged in logic
      final user = userProfileAsync.value;
      if (user == null) return null; // Wait for profile

      // Check NDA acceptance
      final ndaAccepted = user.ndaAcceptedVersion == NdaVersions.currentVersion;
      if (!ndaAccepted) {
        if (isAcceptNda) return null;
        return '/accept-nda';
      } else if (isAcceptNda) {
        // If accepted but trying to access NDA screen, go dashboard
        if (user.role == 'admin') return '/admin';
        if (user.role == 'staff') return '/staff';
        return '/dashboard';
      }

      final isAdmin = user.role == 'admin';
      final isStaff = user.role == 'staff';

      // Onboarding logic
      final isOnboardingComplete = ref
          .read(onboardingRepositoryProvider)
          .isOnboardingComplete();

      // Only redirect to onboarding if we were trying to access protected routes
      // and onboarding isn't done. Splash handles its own navigation.
      if (!isOnboardingComplete && !isLoggingIn && !isSigningUp && !isSplash) {
        return '/onboarding';
      }

      if (isLoggingIn || isSigningUp) {
        if (isAdmin) return '/admin';
        if (isStaff) return '/staff';
        return '/dashboard';
      }

      // Role-based protection
      final isAdminRoute = state.uri.path.startsWith('/admin');
      final isStaffRoute = state.uri.path.startsWith('/staff');

      if (isStaff) {
        if (!isStaffRoute && !state.uri.path.startsWith('/booking')) {
          return '/staff';
        }
      } else if (isAdmin) {
        if (state.uri.path == '/dashboard') return '/admin';
      } else {
        // Client
        if (isAdminRoute || isStaffRoute) return '/dashboard';
      }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(
      ref.read(authRepositoryProvider).authStateChanges(),
    ),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/accept-nda',
        builder: (context, state) => const NdaCheckScreen(),
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      // ... existing routes
      GoRoute(
        path: '/staff',
        builder: (context, state) => const StaffDashboardScreen(),
        routes: [
          GoRoute(
            path: 'scan',
            builder: (context, state) => const PlateSearchScreen(),
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
      // ... existing routes
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
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/payment-success',
            builder: (context, state) => const PaymentSuccessScreen(),
          ),
          GoRoute(
            path: '/shop',
            builder: (context, state) => const ProductShopScreen(),
          ),
          GoRoute(
            path: '/cart',
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: '/manage-subscription',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              return ManageSubscriptionScreen(
                subscription: extra['subscription'] as Subscriber,
                currentPlan: extra['currentPlan'] as SubscriptionPlan,
                availablePlans:
                    extra['availablePlans'] as List<SubscriptionPlan>,
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
            builder: (context, state) => const NotificationsScreen(),
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
        ],
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
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
