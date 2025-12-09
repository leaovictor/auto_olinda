import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../auth/data/auth_repository.dart';
import '../../booking/data/booking_repository.dart';
import '../../../features/booking/domain/booking.dart';
import '../../subscription/data/subscription_repository.dart';
// import 'widgets/weather_widget.dart';
import 'widgets/car_card.dart';
import 'widgets/service_detail_dialog.dart';
import '../../weather/presentation/weather_card.dart';
import 'widgets/active_bookings_carousel.dart';
import 'widgets/upcoming_bookings_section.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../common_widgets/atoms/app_card.dart';
import '../../../common_widgets/molecules/app_refresh_indicator.dart';
import '../../notifications/data/notification_repository.dart';

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
          ref.invalidate(servicesProvider);
          // Wait a bit to show the loading indicator
          await Future.delayed(const Duration(seconds: 1));
        },
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, ref, user?.displayName ?? 'Visitante'),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const WeatherCard(),
                    const SizedBox(height: 24),
                    ActiveBookingsCarousel(bookingsAsync: bookingsAsync),
                    const SizedBox(height: 24),
                    UpcomingBookingsSection(bookingsAsync: bookingsAsync),
                    _buildSectionTitle(context, 'Meus Carros'),
                    const SizedBox(height: 16),
                    _buildCarCarousel(context, vehiclesAsync),
                    const SizedBox(height: 32),
                    _buildSectionTitle(context, 'Serviços Populares'),
                    const SizedBox(height: 16),
                    _buildServicesList(ref, context),
                    const SizedBox(height: 80), // Bottom padding for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        type: ExpandableFabType.up,
        distance: 70,
        openButtonBuilder: RotateFloatingActionButtonBuilder(
          child: const Icon(Icons.add),
          fabSize: ExpandableFabSize.regular,
          foregroundColor: theme.colorScheme.onPrimary,
          backgroundColor: theme.colorScheme.primary,
        ),
        closeButtonBuilder: DefaultFloatingActionButtonBuilder(
          child: const Icon(Icons.close),
          fabSize: ExpandableFabSize.small,
          foregroundColor: theme.colorScheme.onPrimary,
          backgroundColor: theme.colorScheme.primary,
        ),
        children: [
          FloatingActionButton.extended(
            heroTag: 'fab_booking',
            onPressed: () => context.push('/booking'),
            icon: const Icon(Icons.calendar_today),
            label: const Text('Agendar'),
            backgroundColor: theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.onPrimaryContainer,
          ),
        ],
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

    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const WeatherWidget(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Olá, $userName',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        subscriptionAsync.when(
                          data: (sub) {
                            if (sub != null &&
                                sub.isActive &&
                                sub.status != 'canceled') {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Membro Premium', // TODO: Get actual plan name if available in sub or fetch it
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ).animate().fadeIn().slideX(),
                    Text(
                      'Vamos deixar seu carro brilhando?',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideX(),
                  ],
                ),
              ),
            ],
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
        IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.white),
          onPressed: () => context.push('/profile'),
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
            return _buildAddCarButton(context);
          }
          return ListView.builder(
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

  Widget _buildServicesList(WidgetRef ref, BuildContext context) {
    final servicesAsync = ref.watch(servicesProvider);
    final theme = Theme.of(context);

    return servicesAsync.when(
      data: (services) {
        return Column(
          children: services.map((service) {
            return AppCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_car_wash,
                    color: theme.colorScheme.primary,
                  ),
                ),
                title: Text(
                  service.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  service.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onTap: () => ServiceDetailDialog.show(context, service),
              ),
            ).animate().fadeIn().slideY(begin: 0.2);
          }).toList(),
        );
      },
      loading: () => Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: const ShimmerLoading.rectangular(height: 80),
          ),
        ),
      ),
      error: (err, stack) => const SizedBox(),
    );
  }
}
