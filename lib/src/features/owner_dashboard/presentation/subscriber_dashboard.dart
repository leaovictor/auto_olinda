import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aquaclean_mobile/src/features/auth/data/auth_repository.dart';
import 'package:aquaclean_mobile/src/features/appointments/data/booking_repository.dart';
import 'package:aquaclean_mobile/src/features/appointments/domain/booking.dart';
import 'package:aquaclean_mobile/src/features/subscription_plans/data/subscription_repository.dart';
import 'package:aquaclean_mobile/src/common_widgets/molecules/app_refresh_indicator.dart';
import 'widgets/active_bookings_carousel.dart';
import 'widgets/upcoming_bookings_section.dart';

class SubscriberDashboard extends ConsumerWidget {
  const SubscriberDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final theme = Theme.of(context);

    final bookingsAsync = user != null
        ? ref.watch(userBookingsProvider(user.uid))
        : const AsyncValue.data(<Booking>[]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Painel', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: AppRefreshIndicator(
        onRefresh: () async {
          if (user != null) {
            ref.invalidate(userVehiclesProvider(user.uid));
            ref.invalidate(userBookingsProvider(user.uid));
            ref.invalidate(userSubscriptionsProvider);
          }
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Subscription Status Card
              _buildSubscriptionCard(context, ref),
              const SizedBox(height: 24),

              // 2. Quick Actions
              const Text('Ações Rápidas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context,
                      icon: Icons.add_circle_outline,
                      label: 'Novo Agendamento',
                      color: theme.colorScheme.primary,
                      onTap: () => context.push('/booking'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionCard(
                      context,
                      icon: Icons.directions_car_outlined,
                      label: 'Meus Veículos',
                      color: Colors.orange,
                      onTap: () => context.push('/profile'), // Usually managed in profile/vehicles
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 3. Active/Upcoming Bookings
              const Text('Meus Agendamentos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ActiveBookingsCarousel(bookingsAsync: bookingsAsync),
              const SizedBox(height: 16),
              UpcomingBookingsSection(bookingsAsync: bookingsAsync),
              
              const SizedBox(height: 32),

              // 4. Services Grid
              const Text('Nossos Serviços', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildSimpleServicesGrid(context),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/booking'),
        label: const Text('Agendar Agora'),
        icon: const Icon(Icons.calendar_today),
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, WidgetRef ref) {
    final appUserAsync = ref.watch(currentUserProfileProvider);

    return appUserAsync.when(
      data: (user) {
        final isActive = user?.subscriptionStatus == 'active';
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue.shade700 : Colors.grey.shade800,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isActive ? Colors.blue : Colors.black).withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sua Assinatura',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isActive ? 'ATIVA' : 'INATIVA',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isActive ? 'Plano Premium Ativo' : 'Nenhuma Assinatura Ativa',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (!isActive)
                ElevatedButton(
                  onPressed: () => context.push('/plans'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Ver Planos Disponíveis'),
                )
              else
                const Text(
                  'Você tem lavagens ilimitadas disponíveis este mês!',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
            ],
          ),
        );
      },
      loading: () => Container(
        height: 120,
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildActionCard(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleServicesGrid(BuildContext context) {
    // This could be fetched from a provider, but here's a placeholder grid
    final services = [
      {'name': 'Lavagem Completa', 'icon': Icons.local_car_wash},
      {'name': 'Higienização', 'icon': Icons.cleaning_services},
      {'name': 'Polimento', 'icon': Icons.auto_fix_high},
      {'name': 'Cera Especial', 'icon': Icons.layers},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final svc = services[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(svc['icon'] as IconData, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(svc['name'] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        );
      },
    );
  }
}
