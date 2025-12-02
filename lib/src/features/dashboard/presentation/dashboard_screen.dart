import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../auth/data/auth_repository.dart';
import '../../booking/data/booking_repository.dart';
import '../../../features/booking/domain/booking.dart';
import 'widgets/weather_widget.dart';
import 'widgets/car_card.dart';
import 'widgets/active_bookings_carousel.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../common_widgets/atoms/app_card.dart';

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
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, user?.displayName ?? 'Visitante'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ActiveBookingsCarousel(bookingsAsync: bookingsAsync),
                  const SizedBox(height: 24),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/booking'),
        label: const Text('Agendar Lavagem'),
        icon: const Icon(Icons.calendar_today),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ).animate().scale(delay: 500.ms, duration: 300.ms),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, String userName) {
    final theme = Theme.of(context);
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
                    color: Colors.white.withOpacity(0.1),
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
                    const WeatherWidget(),
                    const SizedBox(height: 8),
                    Text(
                      'Olá, $userName',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn().slideX(),
                    Text(
                      'Vamos deixar seu carro brilhando?',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideX(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () => ZoomDrawer.of(context)?.toggle(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {},
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
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
                onTap: () {},
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
