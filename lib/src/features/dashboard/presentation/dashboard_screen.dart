import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../auth/data/auth_repository.dart';
import '../../booking/data/booking_repository.dart';
import '../../../features/booking/domain/booking.dart';
import '../../subscription/data/subscription_repository.dart';
import '../../weather/data/weather_repository.dart';
import '../../weather/domain/weather_theme.dart';
import 'widgets/car_card.dart';
import '../../weather/presentation/weather_card.dart';
import 'widgets/active_bookings_carousel.dart';
import 'widgets/upcoming_bookings_section.dart';
import '../../subscription/domain/subscriber.dart'; // Added for Subscriber type

import '../../subscription/presentation/widgets/subscription_usage_card.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../common_widgets/molecules/app_refresh_indicator.dart';
import '../../notifications/data/notification_repository.dart';
import 'shell/client_shell.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final theme = Theme.of(context);

    final vehiclesAsync = user != null
        ? ref.watch(userVehiclesProvider(user.uid))
        : const AsyncValue.data([]);
    final bookingsAsync = user != null
        ? ref.watch(userBookingsProvider(user.uid))
        : const AsyncValue.data(<Booking>[]);
    final subscriptionsAsync = ref.watch(userSubscriptionsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: AppRefreshIndicator(
        onRefresh: () async {
          if (user != null) {
            ref.invalidate(userVehiclesProvider(user.uid));
            ref.invalidate(userBookingsProvider(user.uid));
            ref.invalidate(
              userSubscriptionsProvider,
            ); // Invalidating subscriptions too
          }
          // Wait a bit to show the loading indicator
          await Future.delayed(const Duration(seconds: 1));
        },
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, ref, user?.displayName ?? 'Visitante'),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WeatherCard(),
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  const SubscriptionUsageCard(),
                  const SizedBox(height: 16),
                  // Cumulative Savings Card
                  bookingsAsync.when(
                    data: (bookings) {
                      final savings = bookings
                          .where(
                            (b) =>
                                b.status == BookingStatus.finished &&
                                b.paymentStatus ==
                                    BookingPaymentStatus.subscription,
                          )
                          .fold(0.0, (sum, b) => sum + b.totalPrice);

                      if (savings > 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.green.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.savings_rounded,
                                    color: Colors.green.shade700,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Economia Total',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              color: Colors.green.shade800,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Você já economizou R\$ ${savings.toStringAsFixed(2)} com a gente!',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: Colors.green.shade900,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),
                  ActiveBookingsCarousel(bookingsAsync: bookingsAsync),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: UpcomingBookingsSection(
                      bookingsAsync: bookingsAsync,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSectionTitle(context, 'Meus Carros'),
                  ),
                  const SizedBox(height: 16),
                  _buildCarCarousel(context, vehiclesAsync, subscriptionsAsync),
                  // Bottom padding for navigation bar
                  const SizedBox(height: 200),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    WidgetRef ref,
    String userName,
  ) {
    final theme = Theme.of(context);
    final subscriptionsAsync = ref.watch(userSubscriptionsProvider);
    final weatherAsync = ref.watch(currentWeatherProvider);
    final vehiclesAsync = ref.watch(authRepositoryProvider).currentUser != null
        ? ref.watch(
            userVehiclesProvider(
              ref.watch(authRepositoryProvider).currentUser!.uid,
            ),
          )
        : const AsyncValue<List<dynamic>>.data([]);

    final bookingsAsync = ref.watch(authRepositoryProvider).currentUser != null
        ? ref.watch(
            userBookingsProvider(
              ref.watch(authRepositoryProvider).currentUser!.uid,
            ),
          )
        : const AsyncValue<List<Booking>>.data([]);

    // Get weather data
    final weather = weatherAsync.valueOrNull;
    final weatherCode = weather?.weatherCode ?? 1;
    final isDay = weather?.isDay ?? true;

    // Get weather theme
    final weatherTheme = WeatherTheme.fromCode(weatherCode, isDay);

    // Contextual greeting based on time of day
    final hour = DateTime.now().hour;
    String greeting;
    String emoji;
    if (hour >= 5 && hour < 12) {
      greeting = 'Bom dia';
      emoji = '☀️';
    } else if (hour >= 12 && hour < 18) {
      greeting = 'Boa tarde';
      emoji = '🌤️';
    } else {
      greeting = 'Boa noite';
      emoji = '🌙';
    }

    // Weather-based contextual message
    String weatherMessage = _getWeatherMessage(weatherCode, isDay);

    return SliverAppBar(
      expandedHeight: 220.0,
      floating: true,
      pinned: false,
      snap: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(gradient: weatherTheme.gradient),
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Glassmorphism overlay for depth
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                  ),
                ),

                // Main Content
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top bar: Actions only (right aligned)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Notification Bell
                            Consumer(
                              builder: (context, ref, child) {
                                final unreadCount = ref.watch(
                                  unreadNotificationCountProvider,
                                );
                                return _buildActionButton(
                                      icon: Icons.notifications_outlined,
                                      badge: unreadCount.valueOrNull ?? 0,
                                      onTap: () =>
                                          context.push('/notifications'),
                                    )
                                    .animate()
                                    .fadeIn(delay: 100.ms)
                                    .scale(begin: const Offset(0.8, 0.8));
                              },
                            ),
                            const SizedBox(width: 8),
                            // Menu Button
                            Consumer(
                              builder: (context, ref, _) {
                                final toggleDrawer = ref.watch(
                                  drawerToggleProvider,
                                );
                                return _buildActionButton(
                                      icon: Icons.menu_rounded,
                                      onTap: toggleDrawer,
                                    )
                                    .animate()
                                    .fadeIn(delay: 200.ms)
                                    .scale(begin: const Offset(0.8, 0.8));
                              },
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Greeting Section
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$greeting, ${userName.split(' ').first}! $emoji',
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.5,
                                        ),
                                  ).animate().fadeIn().slideY(begin: 0.3),
                                  const SizedBox(height: 4),
                                  Text(
                                        weatherMessage,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                              fontWeight: FontWeight.w500,
                                            ),
                                      )
                                      .animate()
                                      .fadeIn(delay: 150.ms)
                                      .slideY(begin: 0.3),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Info Chips Row
                        Row(
                          children: [
                            // Premium Badge & Savings
                            subscriptionsAsync.when(
                              data: (subs) {
                                final isPremium = subs.any(
                                  (sub) => sub.isActive,
                                );

                                if (isPremium) {
                                  // Calculate savings
                                  return bookingsAsync.when(
                                    data: (bookings) {
                                      final savings = bookings
                                          .where(
                                            (b) =>
                                                b.status ==
                                                    BookingStatus.finished &&
                                                b.paymentStatus ==
                                                    BookingPaymentStatus
                                                        .subscription,
                                          )
                                          .fold(
                                            0.0,
                                            (sum, b) => sum + b.totalPrice,
                                          );

                                      if (savings > 0) {
                                        return _buildInfoChip(
                                              icon: Icons.savings_outlined,
                                              iconColor: Colors.white,
                                              label:
                                                  'Economizou R\$ ${savings.toStringAsFixed(2)}',
                                              isPremium: true,
                                              useGlass: true,
                                              customGradient: LinearGradient(
                                                colors: [
                                                  Colors.green.withValues(
                                                    alpha: 0.3,
                                                  ),
                                                  Colors.teal.withValues(
                                                    alpha: 0.3,
                                                  ),
                                                ],
                                              ),
                                              borderColor: Colors.greenAccent
                                                  .withValues(alpha: 0.3),
                                            )
                                            .animate()
                                            .fadeIn(delay: 300.ms)
                                            .slideX(begin: -0.2);
                                      }

                                      // Fallback just Premium badge if no savings yet
                                      return _buildInfoChip(
                                            icon: Icons.workspace_premium,
                                            iconColor: Colors.amber,
                                            label: 'Premium',
                                            isPremium: true,
                                          )
                                          .animate()
                                          .fadeIn(delay: 300.ms)
                                          .slideX(begin: -0.2);
                                    },
                                    loading: () => const SizedBox.shrink(),
                                    error: (_, __) => const SizedBox.shrink(),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                            const SizedBox(width: 8),
                            // Vehicles Count
                            vehiclesAsync.when(
                              data: (vehicles) {
                                final count = vehicles.length;
                                if (count > 0) {
                                  return _buildInfoChip(
                                        icon: Icons.directions_car_rounded,
                                        iconColor: Colors.white,
                                        label:
                                            '$count ${count == 1 ? 'carro' : 'carros'}',
                                      )
                                      .animate()
                                      .fadeIn(delay: 400.ms)
                                      .slideX(begin: -0.2);
                                }
                                return const SizedBox.shrink();
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Action button with glassmorphism
  Widget _buildActionButton({
    required IconData icon,
    int badge = 0,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: badge > 0
            ? Badge(
                label: Text(
                  '$badge',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              )
            : Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  // Info chip (Premium, Vehicle count, etc.)
  Widget _buildInfoChip({
    required IconData icon,
    required Color iconColor,
    required String label,
    bool isPremium = false,
    bool useGlass = false,
    Gradient? customGradient,
    Color? borderColor,
  }) {
    if (useGlass) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: customGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor ?? Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient:
            customGradient ??
            (isPremium
                ? LinearGradient(
                    colors: [
                      Colors.amber.withValues(alpha: 0.3),
                      Colors.orange.withValues(alpha: 0.2),
                    ],
                  )
                : null),
        color: isPremium ? null : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPremium
              ? Colors.amber.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: isPremium ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Weather-based contextual message
  String _getWeatherMessage(int code, bool isDay) {
    // Clear sky
    if (code == 0 || code == 1) {
      if (isDay) {
        return 'Dia perfeito para deixar seu carro brilhando! ✨';
      } else {
        return 'Noite tranquila, que tal agendar para amanhã?';
      }
    }
    // Partly cloudy
    else if (code == 2) {
      return 'Clima agradável, ótimo para uma lavagem! 🚗';
    }
    // Overcast
    else if (code == 3) {
      return 'Tempo nublado, mas sem chuva à vista 👀';
    }
    // Fog
    else if (code >= 45 && code <= 48) {
      return 'Neblina lá fora, perfeito para ficar no lava-jato! 🌫️';
    }
    // Rain or drizzle
    else if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) {
      return 'Chovendo? Relaxe, a gente cuida do seu carro! 🌧️';
    }
    // Thunderstorm
    else if (code >= 95) {
      return 'Tempestade lá fora! Fique seguro 🌩️';
    }
    // Snow
    else if (code >= 71 && code <= 77) {
      return 'Tempo gelado! Mantenha seu carro protegido ❄️';
    }
    return 'Pronto para uma lavagem hoje? 🚿';
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCarCarousel(
    BuildContext context,
    AsyncValue vehiclesAsync,
    AsyncValue<List<Subscriber>> subscriptionsAsync,
  ) {
    if (subscriptionsAsync.hasValue) {
      final subs = subscriptionsAsync.value!;
      print('DEBUG: Active Subscriptions: ${subs.length}');
      for (final s in subs) {
        print('DEBUG: Sub ${s.id} for vehicle ${s.vehicleId} (${s.status})');
      }
    }

    return SizedBox(
      height: 220,
      child: vehiclesAsync.when(
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildAddCarButton(context),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: vehicles.length + 1,
            itemBuilder: (context, index) {
              if (index == vehicles.length) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: _buildAddCarButton(context, isSmall: true),
                );
              }
              final vehicle = vehicles[index];
              // Find active subscription for this vehicle
              final subscription = subscriptionsAsync.valueOrNull
                  ?.cast<Subscriber?>()
                  .firstWhere(
                    (s) => s?.vehicleId == vehicle.id && s?.isActive == true,
                    orElse: () => null,
                  );

              return CarCard(
                vehicle: vehicle,
                subscription: subscription,
                onTap: () {},
              ).animate().fadeIn(delay: (100 * index).ms).slideX();
            },
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: const ShimmerLoading.rectangular(width: 280, height: 220),
          ),
        ),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
    );
  }

  Widget _buildAddCarButton(BuildContext context, {bool isSmall = false}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => context.push('/add-vehicle'),
      child: Container(
        width: isSmall ? 100 : 280,
        height: 220,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: theme.colorScheme.primary,
                size: 32,
              ),
            ),
            if (!isSmall) ...[
              const SizedBox(height: 16),
              Text(
                'Adicionar Carro',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
