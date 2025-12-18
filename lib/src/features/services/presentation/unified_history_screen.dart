import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../auth/data/auth_repository.dart';
import '../../booking/data/booking_repository.dart';
import '../../booking/domain/booking.dart';
import '../../subscription/data/subscription_repository.dart';
import '../../dashboard/presentation/shell/client_shell.dart';
import '../data/independent_service_repository.dart';
import '../domain/service_booking.dart';
import '../../../common_widgets/atoms/app_loader.dart';
import '../../../shared/utils/app_toast.dart';

/// Unified screen showing all user's service history
/// Combines car wash bookings and aesthetic service bookings
class UnifiedHistoryScreen extends ConsumerStatefulWidget {
  const UnifiedHistoryScreen({super.key});

  @override
  ConsumerState<UnifiedHistoryScreen> createState() =>
      _UnifiedHistoryScreenState();
}

class _UnifiedHistoryScreenState extends ConsumerState<UnifiedHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _statusFilter = 'all';
  bool _sortNewestFirst = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateChangesProvider).value;
    final subscriptionAsync = ref.watch(userSubscriptionProvider);
    final isPremium = subscriptionAsync.valueOrNull?.isActive ?? false;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/dashboard');
                }
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  final toggle = ref.read(drawerToggleProvider);
                  toggle?.call();
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Meu Histórico',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPremium
                        ? [const Color(0xFFB8860B), const Color(0xFFFFD700)]
                        : [Colors.blue.shade700, Colors.cyan.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(icon: Icon(Icons.local_car_wash), text: 'Lavagem'),
                Tab(icon: Icon(Icons.auto_awesome), text: 'Estética'),
              ],
            ),
          ),
        ],
        body: Column(
          children: [
            // Filters bar
            _buildFiltersBar(theme),
            const Divider(height: 1),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Wash bookings tab
                  _WashBookingsTab(
                    userId: user?.uid,
                    statusFilter: _statusFilter,
                    sortNewestFirst: _sortNewestFirst,
                  ),
                  // Aesthetic services tab
                  _AestheticBookingsTab(
                    userId: user?.uid,
                    statusFilter: _statusFilter,
                    sortNewestFirst: _sortNewestFirst,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersBar(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          // Status filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Todos',
                  icon: Icons.all_inclusive,
                  isSelected: _statusFilter == 'all',
                  color: Colors.grey,
                  onTap: () => setState(() => _statusFilter = 'all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Agendados',
                  icon: Icons.schedule,
                  isSelected: _statusFilter == 'scheduled',
                  color: Colors.orange,
                  onTap: () => setState(() => _statusFilter = 'scheduled'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Em Andamento',
                  icon: Icons.play_circle_outline,
                  isSelected: _statusFilter == 'in_progress',
                  color: Colors.purple,
                  onTap: () => setState(() => _statusFilter = 'in_progress'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Finalizados',
                  icon: Icons.check_circle_outline,
                  isSelected: _statusFilter == 'finished',
                  color: Colors.green,
                  onTap: () => setState(() => _statusFilter = 'finished'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Cancelados',
                  icon: Icons.cancel_outlined,
                  isSelected: _statusFilter == 'cancelled',
                  color: Colors.red,
                  onTap: () => setState(() => _statusFilter = 'cancelled'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Sort row
          Row(
            children: [
              Icon(Icons.sort, size: 20, color: theme.colorScheme.outline),
              const SizedBox(width: 8),
              Expanded(
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      label: Text('Recentes'),
                      icon: Icon(Icons.arrow_downward, size: 16),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text('Antigos'),
                      icon: Icon(Icons.arrow_upward, size: 16),
                    ),
                  ],
                  selected: {_sortNewestFirst},
                  onSelectionChanged: (selection) {
                    setState(() => _sortNewestFirst = selection.first);
                  },
                  style: ButtonStyle(visualDensity: VisualDensity.compact),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// WASH BOOKINGS TAB
// ============================================================================

class _WashBookingsTab extends ConsumerWidget {
  final String? userId;
  final String statusFilter;
  final bool sortNewestFirst;

  const _WashBookingsTab({
    required this.userId,
    required this.statusFilter,
    required this.sortNewestFirst,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId == null) {
      return const Center(child: Text('Faça login para ver seu histórico'));
    }

    final bookingsAsync = ref.watch(userBookingsProvider(userId!));

    return bookingsAsync.when(
      data: (bookings) {
        var filtered = _filterBookings(bookings);
        filtered = _sortBookings(filtered);

        if (filtered.isEmpty) {
          return _EmptyState(
            icon: Icons.local_car_wash,
            message: 'Nenhum agendamento de lavagem',
            actionLabel: 'Agendar lavagem',
            onAction: () => context.push('/booking'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userBookingsProvider(userId!));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return _WashBookingCard(booking: filtered[index], index: index);
            },
          ),
        );
      },
      loading: () => const Center(child: AppLoader()),
      error: (e, _) => Center(child: Text('Erro: $e')),
    );
  }

  List<Booking> _filterBookings(List<Booking> bookings) {
    if (statusFilter == 'all') return bookings;

    return bookings.where((b) {
      switch (statusFilter) {
        case 'scheduled':
          return b.status == BookingStatus.scheduled ||
              b.status == BookingStatus.confirmed;
        case 'in_progress':
          return b.status == BookingStatus.checkIn ||
              b.status == BookingStatus.washing ||
              b.status == BookingStatus.vacuuming ||
              b.status == BookingStatus.drying ||
              b.status == BookingStatus.polishing;
        case 'finished':
          return b.status == BookingStatus.finished;
        case 'cancelled':
          return b.status == BookingStatus.cancelled ||
              b.status == BookingStatus.noShow;
        default:
          return true;
      }
    }).toList();
  }

  List<Booking> _sortBookings(List<Booking> bookings) {
    final sorted = List<Booking>.from(bookings);
    sorted.sort((a, b) {
      final cmp = a.scheduledTime.compareTo(b.scheduledTime);
      return sortNewestFirst ? -cmp : cmp;
    });
    return sorted;
  }
}

class _WashBookingCard extends ConsumerWidget {
  final Booking booking;
  final int index;

  const _WashBookingCard({required this.booking, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('/booking/${booking.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_car_wash,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lavagem',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat(
                            'EEEE, dd/MM/yyyy',
                            'pt_BR',
                          ).format(booking.scheduledTime),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(
                    label: _getStatusLabel(booking.status),
                    color: _getStatusColor(booking.status),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('HH:mm').format(booking.scheduledTime),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'R\$ ${booking.totalPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.05);
  }

  String _getStatusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.scheduled:
        return 'Agendado';
      case BookingStatus.confirmed:
        return 'Confirmado';
      case BookingStatus.checkIn:
        return 'Check-in';
      case BookingStatus.washing:
        return 'Lavando';
      case BookingStatus.vacuuming:
        return 'Aspirando';
      case BookingStatus.drying:
        return 'Secando';
      case BookingStatus.polishing:
        return 'Polindo';
      case BookingStatus.finished:
        return 'Finalizado';
      case BookingStatus.cancelled:
        return 'Cancelado';
      case BookingStatus.noShow:
        return 'Não compareceu';
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.scheduled:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.checkIn:
      case BookingStatus.washing:
      case BookingStatus.vacuuming:
      case BookingStatus.drying:
      case BookingStatus.polishing:
        return Colors.purple;
      case BookingStatus.finished:
        return Colors.green;
      case BookingStatus.cancelled:
      case BookingStatus.noShow:
        return Colors.red;
    }
  }
}

// ============================================================================
// AESTHETIC BOOKINGS TAB
// ============================================================================

class _AestheticBookingsTab extends ConsumerWidget {
  final String? userId;
  final String statusFilter;
  final bool sortNewestFirst;

  const _AestheticBookingsTab({
    required this.userId,
    required this.statusFilter,
    required this.sortNewestFirst,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId == null) {
      return const Center(child: Text('Faça login para ver seu histórico'));
    }

    final bookingsAsync = ref.watch(userServiceBookingsProvider(userId!));

    return bookingsAsync.when(
      data: (bookings) {
        var filtered = _filterBookings(bookings);
        filtered = _sortBookings(filtered);

        if (filtered.isEmpty) {
          return _EmptyState(
            icon: Icons.auto_awesome,
            message: 'Nenhum serviço de estética',
            actionLabel: 'Ver serviços',
            onAction: () => context.push('/services'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userServiceBookingsProvider(userId!));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return _AestheticBookingCard(
                booking: filtered[index],
                index: index,
              );
            },
          ),
        );
      },
      loading: () => const Center(child: AppLoader()),
      error: (e, _) => Center(child: Text('Erro: $e')),
    );
  }

  List<ServiceBooking> _filterBookings(List<ServiceBooking> bookings) {
    if (statusFilter == 'all') return bookings;

    return bookings.where((b) {
      switch (statusFilter) {
        case 'scheduled':
          return b.status == ServiceBookingStatus.scheduled ||
              b.status == ServiceBookingStatus.confirmed;
        case 'in_progress':
          return b.status == ServiceBookingStatus.inProgress;
        case 'finished':
          return b.status == ServiceBookingStatus.finished;
        case 'cancelled':
          return b.status == ServiceBookingStatus.cancelled ||
              b.status == ServiceBookingStatus.noShow;
        default:
          return true;
      }
    }).toList();
  }

  List<ServiceBooking> _sortBookings(List<ServiceBooking> bookings) {
    final sorted = List<ServiceBooking>.from(bookings);
    sorted.sort((a, b) {
      final cmp = a.scheduledTime.compareTo(b.scheduledTime);
      return sortNewestFirst ? -cmp : cmp;
    });
    return sorted;
  }
}

class _AestheticBookingCard extends ConsumerWidget {
  final ServiceBooking booking;
  final int index;

  const _AestheticBookingCard({required this.booking, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final serviceAsync = ref.watch(
      independentServiceProvider(booking.serviceId),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade100, Colors.pink.shade100],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.purple.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      serviceAsync.when(
                        data: (service) => Text(
                          service?.title ?? 'Serviço de Estética',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        loading: () => Text(
                          'Serviço de Estética',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        error: (_, __) => Text(
                          'Serviço de Estética',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat(
                          'EEEE, dd/MM/yyyy',
                          'pt_BR',
                        ).format(booking.scheduledTime),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(
                  label: _getStatusLabel(booking.status),
                  color: _getStatusColor(booking.status),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('HH:mm').format(booking.scheduledTime),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'R\$ ${booking.totalPrice.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade600,
                  ),
                ),
                if (booking.status == ServiceBookingStatus.scheduled)
                  TextButton(
                    onPressed: () => _cancelBooking(context, ref),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.05);
  }

  void _cancelBooking(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Agendamento'),
        content: const Text('Deseja cancelar este agendamento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(independentServiceRepositoryProvider)
            .cancelBooking(booking.id);
        if (context.mounted) {
          AppToast.success(context, message: 'Agendamento cancelado');
        }
      } catch (e) {
        if (context.mounted) {
          AppToast.error(context, message: 'Erro: $e');
        }
      }
    }
  }

  String _getStatusLabel(ServiceBookingStatus status) {
    switch (status) {
      case ServiceBookingStatus.scheduled:
        return 'Agendado';
      case ServiceBookingStatus.confirmed:
        return 'Confirmado';
      case ServiceBookingStatus.inProgress:
        return 'Em andamento';
      case ServiceBookingStatus.finished:
        return 'Finalizado';
      case ServiceBookingStatus.cancelled:
        return 'Cancelado';
      case ServiceBookingStatus.noShow:
        return 'Não compareceu';
    }
  }

  Color _getStatusColor(ServiceBookingStatus status) {
    switch (status) {
      case ServiceBookingStatus.scheduled:
        return Colors.orange;
      case ServiceBookingStatus.confirmed:
        return Colors.blue;
      case ServiceBookingStatus.inProgress:
        return Colors.purple;
      case ServiceBookingStatus.finished:
        return Colors.green;
      case ServiceBookingStatus.cancelled:
      case ServiceBookingStatus.noShow:
        return Colors.red;
    }
  }
}

// ============================================================================
// SHARED WIDGETS
// ============================================================================

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
