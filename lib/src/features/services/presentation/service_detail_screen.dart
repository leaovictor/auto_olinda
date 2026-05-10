import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/independent_service_repository.dart';
import '../domain/independent_service.dart';
import '../../../common_widgets/atoms/app_loader.dart';
import '../../../common_widgets/atoms/primary_button.dart';

/// Screen showing detailed information about an aesthetic service
class ServiceDetailScreen extends ConsumerWidget {
  final String serviceId;

  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final serviceAsync = ref.watch(independentServiceProvider(serviceId));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      floatingActionButton: serviceAsync.maybeWhen(
        data: (service) => service != null
            ? Container(
                width: MediaQuery.of(context).size.width - 32,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade600, Colors.pink.shade400],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push('/services/$serviceId/book'),
                    borderRadius: BorderRadius.circular(16),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Agendar Serviço',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : null,
        orElse: () => null,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: serviceAsync.when(
        data: (service) {
          if (service == null) {
            return const Center(child: Text('Serviço não encontrado'));
          }
          return _buildContent(context, theme, service);
        },
        loading: () => const Center(child: AppLoader()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    IndependentService service,
  ) {
    return CustomScrollView(
      slivers: [
        // App Bar with gradient
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              service.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.purple.shade600, Colors.pink.shade400],
                ),
              ),
              child: Center(
                child: Icon(
                  _getIconForService(service.iconName),
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price and duration badges
                Row(
                  children: [
                    _buildBadge(
                      theme,
                      icon: Icons.attach_money,
                      label: 'R\$ ${service.price.toStringAsFixed(2)}',
                      color: Colors.green,
                    ),
                    const SizedBox(width: 12),
                    _buildBadge(
                      theme,
                      icon: Icons.access_time,
                      label: '${service.durationMinutes} min',
                      color: Colors.blue,
                    ),
                    if (service.requiresVehicle) ...[
                      const SizedBox(width: 12),
                      _buildBadge(
                        theme,
                        icon: Icons.directions_car,
                        label: 'Veículo',
                        color: Colors.orange,
                      ),
                    ],
                  ],
                ).animate().fadeIn().slideY(begin: 0.2),

                const SizedBox(height: 24),

                // Description
                Text(
                  'Descrição',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 8),
                Text(
                  service.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: 32),

                // Info card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Informações',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          theme,
                          'Duração estimada',
                          '${service.durationMinutes} minutos',
                        ),
                        const Divider(height: 16),
                        _buildInfoRow(
                          theme,
                          'Pagamento',
                          'Via cartão (Stripe)',
                        ),
                        if (service.requiresVehicle) ...[
                          const Divider(height: 16),
                          _buildInfoRow(
                            theme,
                            'Requisito',
                            'Necessário informar veículo',
                          ),
                        ],
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                const SizedBox(height: 100), // Space for button
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  IconData _getIconForService(String iconName) {
    switch (iconName) {
      case 'build':
        return Icons.build;
      case 'auto_fix_high':
        return Icons.auto_fix_high;
      case 'car_repair':
        return Icons.car_repair;
      case 'brush':
        return Icons.brush;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'shield':
        return Icons.shield;
      case 'local_car_wash':
        return Icons.local_car_wash;
      case 'layers':
        return Icons.layers;
      case 'grade':
        return Icons.grade;
      default:
        return Icons.auto_awesome;
    }
  }
}

/// Bottom sheet version for quick preview
class ServiceDetailBottomSheet extends ConsumerWidget {
  final String serviceId;

  const ServiceDetailBottomSheet({super.key, required this.serviceId});

  static Future<void> show(BuildContext context, String serviceId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceDetailBottomSheet(serviceId: serviceId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final serviceAsync = ref.watch(independentServiceProvider(serviceId));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: serviceAsync.when(
        data: (service) {
          if (service == null) {
            return const Center(child: Text('Serviço não encontrado'));
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header with gradient
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.purple.shade600, Colors.pink.shade400],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconForService(service.iconName),
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${service.durationMinutes} min • R\$ ${service.price.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  service.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Book button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: PrimaryButton(
                  text: 'Agendar Serviço',
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/services/${service.id}/book');
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(48),
          child: Center(child: AppLoader()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(48),
          child: Center(child: Text('Erro: $e')),
        ),
      ),
    );
  }

  IconData _getIconForService(String iconName) {
    switch (iconName) {
      case 'build':
        return Icons.build;
      case 'auto_fix_high':
        return Icons.auto_fix_high;
      case 'car_repair':
        return Icons.car_repair;
      case 'brush':
        return Icons.brush;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'shield':
        return Icons.shield;
      case 'local_car_wash':
        return Icons.local_car_wash;
      case 'layers':
        return Icons.layers;
      case 'grade':
        return Icons.grade;
      default:
        return Icons.auto_awesome;
    }
  }
}
