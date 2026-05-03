import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/independent_service_repository.dart';
import '../domain/service_booking.dart';
import '../../../common_widgets/atoms/app_loader.dart';
import '../../../shared/utils/app_toast.dart';
import '../../../shared/utils/cancellation_warning_helper.dart';
import '../../auth/data/auth_repository.dart';
import '../../owner_dashboard/presentation/shell/client_shell.dart';

/// Screen displaying user's service bookings
class MyServiceBookingsScreen extends ConsumerWidget {
  const MyServiceBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authRepositoryProvider).currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Meus Serviços')),
        body: const Center(
          child: Text('Faça login para ver seus agendamentos'),
        ),
      );
    }

    final bookingsAsync = ref.watch(userServiceBookingsProvider(user.uid));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Meus Serviços',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
        ),
        actions: [
          IconButton(
            onPressed: () {
              final toggle = ref.read(drawerToggleProvider);
              toggle?.call();
            },
            icon: Icon(Icons.menu, color: theme.colorScheme.onPrimary),
          ),
        ],
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum agendamento',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => context.push('/services'),
                    icon: const Icon(Icons.add),
                    label: const Text('Agendar serviço'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _BookingCard(booking: booking, index: index);
            },
          );
        },
        loading: () => const Center(child: AppLoader()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
    );
  }
}

class _BookingCard extends ConsumerWidget {
  final ServiceBooking booking;
  final int index;

  const _BookingCard({required this.booking, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final serviceAsync = ref.watch(
      independentServiceProvider(booking.serviceId),
    );

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    color: _getStatusColor(booking.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getStatusIcon(booking.status),
                    color: _getStatusColor(booking.status),
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
                          service?.title ?? 'Serviço',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        loading: () => Text(
                          'Serviço',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        error: (_, __) => const Text('Serviço'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'EEEE, dd/MM/yyyy',
                          'pt_BR',
                        ).format(booking.scheduledTime),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(theme, booking.status),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 12),
            // Show rejection reason if applicable
            if (booking.status == ServiceBookingStatus.rejected &&
                booking.rejectionReason != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.red.shade700,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Motivo da recusa:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.red.shade700,
                            ),
                          ),
                          Text(
                            booking.rejectionReason!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
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
                if (booking.status == ServiceBookingStatus.scheduled ||
                    booking.status == ServiceBookingStatus.pendingApproval)
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
    ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1);
  }

  Widget _buildStatusChip(ThemeData theme, ServiceBookingStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getStatusLabel(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Color _getStatusColor(ServiceBookingStatus status) {
    switch (status) {
      case ServiceBookingStatus.pendingApproval:
        return Colors.amber;
      case ServiceBookingStatus.scheduled:
        return Colors.orange;
      case ServiceBookingStatus.confirmed:
        return Colors.blue;
      case ServiceBookingStatus.inProgress:
        return Colors.purple;
      case ServiceBookingStatus.finished:
        return Colors.green;
      case ServiceBookingStatus.cancelled:
        return Colors.red;
      case ServiceBookingStatus.rejected:
        return Colors.red.shade900;
      case ServiceBookingStatus.noShow:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(ServiceBookingStatus status) {
    switch (status) {
      case ServiceBookingStatus.pendingApproval:
        return Icons.hourglass_empty;
      case ServiceBookingStatus.scheduled:
        return Icons.schedule;
      case ServiceBookingStatus.confirmed:
        return Icons.check_circle_outline;
      case ServiceBookingStatus.inProgress:
        return Icons.build;
      case ServiceBookingStatus.finished:
        return Icons.check_circle;
      case ServiceBookingStatus.cancelled:
        return Icons.cancel;
      case ServiceBookingStatus.rejected:
        return Icons.block;
      case ServiceBookingStatus.noShow:
        return Icons.person_off;
    }
  }

  String _getStatusLabel(ServiceBookingStatus status) {
    switch (status) {
      case ServiceBookingStatus.pendingApproval:
        return 'Aguardando Aprovação';
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
      case ServiceBookingStatus.rejected:
        return 'Recusado';
      case ServiceBookingStatus.noShow:
        return 'Não compareceu';
    }
  }

  void _cancelBooking(BuildContext context, WidgetRef ref) async {
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
}
