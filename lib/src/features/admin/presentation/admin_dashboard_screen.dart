import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/admin_repository.dart';
import '../../../features/booking/domain/booking.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscribersAsync = ref.watch(subscribersProvider);
    final bookingsAsync = ref.watch(adminBookingsProvider);
    final vehiclesAsync = ref.watch(adminVehiclesProvider);

    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visão Geral',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          // Stats Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isWide = width > 600;
              final crossAxisCount = isWide ? 4 : 2;
              final childAspectRatio = isWide ? 1.5 : 1.3;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: childAspectRatio,
                children: [
                  // Bookings Today
                  bookingsAsync.when(
                    data: (bookings) {
                      final today = DateTime.now();
                      final count = bookings.where((b) {
                        return b.scheduledTime.year == today.year &&
                            b.scheduledTime.month == today.month &&
                            b.scheduledTime.day == today.day;
                      }).length;
                      return _buildMetricCard(
                        context,
                        title: 'Agendamentos Hoje',
                        value: count.toString(),
                        icon: Icons.today,
                        color: Colors.orange,
                      );
                    },
                    loading: () =>
                        _buildLoadingCard(context, 'Agendamentos Hoje'),
                    error: (_, __) => _buildErrorCard(context, 'Erro'),
                  ),
                  // Monthly Revenue
                  bookingsAsync.when(
                    data: (bookings) {
                      final now = DateTime.now();
                      final revenue = bookings
                          .where(
                            (b) =>
                                b.status == BookingStatus.finished &&
                                b.scheduledTime.year == now.year &&
                                b.scheduledTime.month == now.month,
                          )
                          .fold(0.0, (sum, b) => sum + b.totalPrice);
                      return _buildMetricCard(
                        context,
                        title: 'Receita Mensal',
                        value: NumberFormat.currency(
                          locale: 'pt_BR',
                          symbol: 'R\$',
                        ).format(revenue),
                        icon: Icons.attach_money,
                        color: Colors.green,
                      );
                    },
                    loading: () => _buildLoadingCard(context, 'Receita Mensal'),
                    error: (_, __) => _buildErrorCard(context, 'Erro'),
                  ),
                  // Vehicles
                  vehiclesAsync.when(
                    data: (vehicles) => _buildMetricCard(
                      context,
                      title: 'Veículos',
                      value: vehicles.length.toString(),
                      icon: Icons.directions_car,
                      color: Colors.blue,
                    ),
                    loading: () => _buildLoadingCard(context, 'Veículos'),
                    error: (_, __) => _buildErrorCard(context, 'Erro'),
                  ),
                  // Subscribers
                  subscribersAsync.when(
                    data: (subs) => _buildMetricCard(
                      context,
                      title: 'Assinantes',
                      value: subs.length.toString(),
                      icon: Icons.people,
                      color: Colors.purple,
                    ),
                    loading: () => _buildLoadingCard(context, 'Assinantes'),
                    error: (_, __) => _buildErrorCard(context, 'Erro'),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
          Text(
            'Acesso Rápido',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            context,
            title: 'Gerenciar Agendamentos',
            subtitle: 'Ver todos os agendamentos',
            icon: Icons.calendar_today,
            color: Colors.orange,
            onTap: () => context.push('/admin/appointments'),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context,
            title: 'Gerenciar Planos',
            subtitle: 'Criar e editar planos de assinatura',
            icon: Icons.card_membership,
            color: Colors.blue,
            onTap: () => context.push('/admin/plans'),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context,
            title: 'Ver Assinantes',
            subtitle: 'Listar usuários com assinatura ativa',
            icon: Icons.group,
            color: Colors.green,
            onTap: () => context.push('/admin/subscribers'),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context,
            title: 'Configurar Calendário',
            subtitle: 'Definir dias e horários disponíveis',
            icon: Icons.calendar_month,
            color: Colors.purple,
            onTap: () => context.push('/admin/calendar'),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context,
            title: 'Relatórios Financeiros',
            subtitle: 'Receita, ticket médio e gráficos',
            icon: Icons.bar_chart,
            color: Colors.teal,
            onTap: () => context.push('/admin/reports'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827),
                    fontSize: 20,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context, String title) {
    return _buildMetricCard(
      context,
      title: title,
      value: '...',
      icon: Icons.circle,
      color: Colors.grey,
    );
  }

  Widget _buildErrorCard(BuildContext context, String title) {
    return _buildMetricCard(
      context,
      title: title,
      value: '-',
      icon: Icons.error,
      color: Colors.red,
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
