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
import './widgets/history_booking_card_skeleton.dart';
import './widgets/premium_status_badge.dart';
import './constants/history_colors.dart';
import '../../../shared/utils/app_toast.dart';
import '../../../shared/utils/cancellation_warning_helper.dart';

/// Unified screen showing all user's service history
/// Premium redesign with simplified filters and modern card design
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
            expandedHeight: 200,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
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
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu, color: Colors.white),
                ),
                onPressed: () {
                  final toggle = ref.read(drawerToggleProvider);
                  toggle?.call();
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
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
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 60,
                      left: 20,
                      right: 20,
                    ),
                    child: Text(
                      'Acompanhe seus serviços',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Column(
                children: [
                  // Filter chips row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Todos', 'all', Icons.apps_rounded),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Agendados',
                            'scheduled',
                            Icons.schedule,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Em Andamento',
                            'in_progress',
                            Icons.autorenew,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Concluídos',
                            'finished',
                            Icons.check_circle_outline,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Cancelados',
                            'cancelled',
                            Icons.cancel_outlined,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Tab bar
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: const TextStyle(fontSize: 14),
                    tabs: const [
                      Tab(icon: Icon(Icons.local_car_wash), text: 'Lavagem'),
                      Tab(icon: Icon(Icons.auto_awesome), text: 'Estética'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // Wash bookings tab
            _WashBookingsTab(userId: user?.uid, statusFilter: _statusFilter),
            // Aesthetic services tab
            _AestheticBookingsTab(
              userId: user?.uid,
              statusFilter: _statusFilter,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _statusFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.blue.shade700 : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue.shade700 : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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

  const _WashBookingsTab({required this.userId, required this.statusFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId == null) {
      return const Center(child: Text('Faça login para ver seu histórico'));
    }

    final bookingsAsync = ref.watch(userBookingsProvider(userId!));

    return bookingsAsync.when(
      data: (bookings) {
        var filtered = _filterBookings(bookings);
        // Sort newest first
        filtered.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

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
              return _PremiumWashBookingCard(
                booking: filtered[index],
                index: index,
              );
            },
          ),
        );
      },
      loading: () => const HistorySkeletonList(),
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
}

// ============================================================================
// PREMIUM WASH BOOKING CARD
// ============================================================================

class _PremiumWashBookingCard extends ConsumerWidget {
  final Booking booking;
  final int index;

  const _PremiumWashBookingCard({required this.booking, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      elevation: 0,
      child: InkWell(
        onTap: () => context.push('/booking/${booking.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Service icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.local_car_wash,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Title and date
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
                        const SizedBox(height: 4),
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
                  // Status badge
                  PremiumStatusBadge(
                    label: _getStatusLabel(booking.status),
                    statusKey: booking.status.name,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Divider
              Container(height: 1, color: Colors.grey[100]),
              const SizedBox(height: 16),
              // Footer row
              Row(
                children: [
                  // Time
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 18,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('HH:mm').format(booking.scheduledTime),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Price
                  Text(
                    'R\$ ${booking.totalPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Action button
                  _buildActionButton(context, ref),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (40 * index).ms).slideY(begin: 0.05);
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    switch (booking.status) {
      case BookingStatus.cancelled:
      case BookingStatus.noShow:
        return TextButton(
          onPressed: () => context.push('/booking'),
          style: TextButton.styleFrom(
            foregroundColor: HistoryStatusColors.pendingForeground,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Reagendar'),
        );
      case BookingStatus.finished:
        return TextButton(
          onPressed: () => context.push('/booking/${booking.id}'),
          style: TextButton.styleFrom(
            foregroundColor: HistoryStatusColors.completedForeground,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Detalhes'),
        );
      case BookingStatus.scheduled:
        if (booking.scheduledTime.difference(DateTime.now()).inMinutes > 60) {
          return TextButton(
            onPressed: () => _cancelBooking(context, ref),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Cancelar'),
          );
        }
        return const SizedBox.shrink();
      default:
        return Icon(
          Icons.chevron_right_rounded,
          color: theme.colorScheme.outline,
        );
    }
  }

  Future<void> _cancelBooking(BuildContext context, WidgetRef ref) async {
    // Use cancellation warning helper for consistent penalty warnings
    final confirmed = await CancellationWarningHelper.showCancellationDialog(
      context: context,
      scheduledTime: booking.scheduledTime,
    );

    if (confirmed) {
      try {
        final user = ref.read(authRepositoryProvider).currentUser;
        if (user == null) return;

        await ref
            .read(bookingRepositoryProvider)
            .cancelBooking(booking.id, actorId: user.uid);
        if (context.mounted) {
          final message = CancellationWarningHelper.getCancellationFeedback(
            booking.scheduledTime,
          );
          final isStrike = CancellationWarningHelper.shouldShowStrikeWarning(
            booking.scheduledTime,
          );
          if (isStrike) {
            AppToast.error(context, message: message);
          } else {
            AppToast.success(context, message: message);
          }
        }
      } catch (e) {
        if (context.mounted) {
          AppToast.error(context, message: 'Erro: $e');
        }
      }
    }
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
        return 'Concluído';
      case BookingStatus.cancelled:
        return 'Cancelado';
      case BookingStatus.noShow:
        return 'Não Compareceu';
    }
  }
}

// ============================================================================
// AESTHETIC BOOKINGS TAB
// ============================================================================

class _AestheticBookingsTab extends ConsumerWidget {
  final String? userId;
  final String statusFilter;

  const _AestheticBookingsTab({
    required this.userId,
    required this.statusFilter,
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
        // Sort newest first
        filtered.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

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
              return _PremiumAestheticBookingCard(
                booking: filtered[index],
                index: index,
              );
            },
          ),
        );
      },
      loading: () => const HistorySkeletonList(),
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
}

// ============================================================================
// PREMIUM AESTHETIC BOOKING CARD
// ============================================================================

class _PremiumAestheticBookingCard extends ConsumerWidget {
  final ServiceBooking booking;
  final int index;

  const _PremiumAestheticBookingCard({
    required this.booking,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final serviceAsync = ref.watch(
      independentServiceProvider(booking.serviceId),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      elevation: 0,
      child: InkWell(
        onTap: () {
          // Navigate to service booking details if available
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Service icon with gradient
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade100, Colors.pink.shade100],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: Colors.purple.shade600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Title and date
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
                        const SizedBox(height: 4),
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
                  // Status badge
                  PremiumStatusBadge(
                    label: _getStatusLabel(booking.status),
                    statusKey: booking.status.name,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Divider
              Container(height: 1, color: Colors.grey[100]),
              const SizedBox(height: 16),
              // Footer row
              Row(
                children: [
                  // Time
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 18,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('HH:mm').format(booking.scheduledTime),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Price
                  Text(
                    'R\$ ${booking.totalPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Action button
                  _buildActionButton(context, ref),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (40 * index).ms).slideY(begin: 0.05);
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    switch (booking.status) {
      case ServiceBookingStatus.cancelled:
      case ServiceBookingStatus.noShow:
      case ServiceBookingStatus.rejected:
        return TextButton(
          onPressed: () => context.push('/services'),
          style: TextButton.styleFrom(
            foregroundColor: HistoryStatusColors.pendingForeground,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Reagendar'),
        );
      case ServiceBookingStatus.finished:
        return TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: HistoryStatusColors.completedForeground,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Detalhes'),
        );
      case ServiceBookingStatus.scheduled:
        return TextButton(
          onPressed: () => _cancelBooking(context, ref),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Cancelar'),
        );
      default:
        return Icon(
          Icons.chevron_right_rounded,
          color: theme.colorScheme.outline,
        );
    }
  }

  Future<void> _cancelBooking(BuildContext context, WidgetRef ref) async {
    // Use cancellation warning helper for consistent penalty warnings
    final confirmed = await CancellationWarningHelper.showCancellationDialog(
      context: context,
      scheduledTime: booking.scheduledTime,
    );

    if (confirmed) {
      try {
        await ref
            .read(independentServiceRepositoryProvider)
            .cancelBooking(booking.id);
        if (context.mounted) {
          final message = CancellationWarningHelper.getCancellationFeedback(
            booking.scheduledTime,
          );
          final isStrike = CancellationWarningHelper.shouldShowStrikeWarning(
            booking.scheduledTime,
          );
          if (isStrike) {
            AppToast.error(context, message: message);
          } else {
            AppToast.success(context, message: message);
          }
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
      case ServiceBookingStatus.pendingApproval:
        return 'Aguardando';
      case ServiceBookingStatus.scheduled:
        return 'Agendado';
      case ServiceBookingStatus.confirmed:
        return 'Confirmado';
      case ServiceBookingStatus.inProgress:
        return 'Em Andamento';
      case ServiceBookingStatus.finished:
        return 'Concluído';
      case ServiceBookingStatus.cancelled:
        return 'Cancelado';
      case ServiceBookingStatus.rejected:
        return 'Recusado';
      case ServiceBookingStatus.noShow:
        return 'Não Compareceu';
    }
  }
}

// ============================================================================
// SHARED WIDGETS
// ============================================================================

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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
