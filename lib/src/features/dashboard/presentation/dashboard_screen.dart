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
import '../../weather/presentation/weather_decorations.dart';
import 'widgets/car_card.dart';
import '../../weather/presentation/weather_card.dart';
import 'widgets/active_bookings_carousel.dart';
import 'widgets/upcoming_bookings_section.dart';
import 'widgets/services_carousel.dart';
import 'widgets/products_carousel.dart';
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: AppRefreshIndicator(
        onRefresh: () async {
          if (user != null) {
            ref.invalidate(userVehiclesProvider(user.uid));
            ref.invalidate(userBookingsProvider(user.uid));
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
                  ActiveBookingsCarousel(bookingsAsync: bookingsAsync),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: UpcomingBookingsSection(
                      bookingsAsync: bookingsAsync,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const ServicesCarousel(),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: ProductsCarousel(),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSectionTitle(context, 'Meus Carros'),
                  ),
                  const SizedBox(height: 16),
                  _buildCarCarousel(context, vehiclesAsync),
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
    final subscriptionAsync = ref.watch(userSubscriptionProvider);
    final weatherAsync = ref.watch(currentWeatherProvider);

    // Get weather data
    final weather = weatherAsync.valueOrNull;
    final weatherCode = weather?.weatherCode ?? 1;
    final isDay = weather?.isDay ?? true;

    // Get weather theme
    final weatherTheme = WeatherTheme.fromCode(weatherCode, isDay);

    // Get weather decorations
    final decorations = WeatherDecorations.fromCode(weatherCode, isDay);

    return SliverAppBar(
      expandedHeight: 180.0,
      floating: true,
      pinned: false,
      snap: true,
      backgroundColor: weatherTheme.primaryColor,
      leading: Consumer(
        builder: (context, ref, _) {
          final toggleDrawer = ref.watch(drawerToggleProvider);
          return IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.menu_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            onPressed: toggleDrawer,
          ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8));
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(gradient: weatherTheme.gradient),
          child: ClipRect(
            child: Stack(
              children: [
                // Weather decorations (animated)
                ...decorations,

                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 50, 24, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting row with avatar
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Olá, $userName',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Gerencie suas lavagens',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Temperature Display
                          weatherAsync.when(
                            data: (weather) =>
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getWeatherIcon(
                                          weather.weatherCode,
                                          weather.isDay,
                                        ),
                                        color: _getWeatherIconColor(
                                          weather.weatherCode,
                                          weather.isDay,
                                        ),
                                        size: 22,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${weather.temperature.toStringAsFixed(0)}°',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn().scale(
                                  begin: const Offset(0.8, 0.8),
                                ),
                            loading: () => Container(
                              width: 70,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ],
                      ).animate().fadeIn().slideX(),
                      const SizedBox(height: 12),
                      // Subscription badge
                      subscriptionAsync.when(
                        data: (sub) {
                          if (sub != null &&
                              sub.isActive &&
                              sub.status != 'canceled') {
                            return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Membro Premium',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 300.ms)
                                .slideY(begin: 0.2);
                          }
                          return const SizedBox.shrink();
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Consumer(
          builder: (context, ref, child) {
            final unreadCount = ref.watch(unreadNotificationCountProvider);
            return IconButton(
              icon: Badge(
                isLabelVisible:
                    unreadCount.valueOrNull != null &&
                    unreadCount.valueOrNull! > 0,
                label: Text(
                  '${unreadCount.valueOrNull ?? 0}',
                  style: const TextStyle(fontSize: 10),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
              ),
              onPressed: () => context.push('/notifications'),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCarCarousel(BuildContext context, AsyncValue vehiclesAsync) {
    return SizedBox(
      height: 180,
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
              return CarCard(
                vehicle: vehicles[index],
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
            child: const ShimmerLoading.rectangular(width: 280, height: 180),
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
        height: 180,
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

  IconData _getWeatherIcon(int code, bool isDay) {
    // Clear sky or Mainly clear
    if (code == 0 || code == 1) {
      return isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round;
    }
    // Partly cloudy
    else if (code == 2) {
      return isDay ? Icons.wb_cloudy : Icons.nights_stay;
    }
    // Overcast
    else if (code == 3) {
      return Icons.cloud;
    }
    // Fog
    else if (code >= 45 && code <= 48) {
      return Icons.foggy;
    }
    // Drizzle or Rain
    else if ((code >= 51 && code <= 57) ||
        (code >= 61 && code <= 67) ||
        (code >= 80 && code <= 82)) {
      return Icons.water_drop;
    }
    // Thunderstorm
    else if (code >= 95) {
      return Icons.thunderstorm;
    }
    // Snow
    else if (code >= 71 && code <= 77) {
      return Icons.ac_unit;
    }
    return Icons.wb_sunny_rounded;
  }

  Color _getWeatherIconColor(int code, bool isDay) {
    // Clear sky - sunny/moon color
    if (code == 0 || code == 1) {
      return isDay ? Colors.amber : Colors.white;
    }
    // Cloudy
    else if (code >= 2 && code <= 3) {
      return Colors.white70;
    }
    // Fog
    else if (code >= 45 && code <= 48) {
      return Colors.blueGrey.shade200;
    }
    // Rain
    else if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) {
      return Colors.lightBlue.shade200;
    }
    // Thunderstorm
    else if (code >= 95) {
      return Colors.amber;
    }
    // Snow
    else if (code >= 71 && code <= 77) {
      return Colors.white;
    }
    return Colors.amber;
  }
}
