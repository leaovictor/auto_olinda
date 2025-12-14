import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../common_widgets/atoms/primary_button.dart';
import '../../../booking/domain/booking.dart';
import '../../../booking/data/booking_repository.dart';
import '../../../profile/domain/vehicle.dart';
import '../../../subscription/data/subscription_repository.dart';
import '../../../../shared/utils/app_toast.dart';

/// Redesigned compact booking card for staff
/// Features: prominent plate, timer, premium badge, swipe-like action button
class StaffBookingCardCompact extends ConsumerStatefulWidget {
  final Booking booking;

  const StaffBookingCardCompact({super.key, required this.booking});

  @override
  ConsumerState<StaffBookingCardCompact> createState() =>
      _StaffBookingCardCompactState();
}

class _StaffBookingCardCompactState
    extends ConsumerState<StaffBookingCardCompact> {
  bool _isLoading = false;

  /// Validates if status transition is allowed based on photo requirements
  bool _canTransitionTo(BookingStatus newStatus) {
    final booking = widget.booking;

    // Require at least 1 "before" photo to start washing
    if (newStatus == BookingStatus.washing && booking.beforePhotos.isEmpty) {
      AppToast.warning(context, message: 'Adicione uma foto antes de iniciar');
      context.push('/staff/booking/${booking.id}');
      return false;
    }

    // Require at least 1 "after" photo to finalize
    if (newStatus == BookingStatus.finished && booking.afterPhotos.isEmpty) {
      AppToast.warning(context, message: 'Adicione uma foto do resultado');
      context.push('/staff/booking/${booking.id}');
      return false;
    }

    return true;
  }

  Future<void> _updateStatus(BookingStatus newStatus) async {
    if (!_canTransitionTo(newStatus)) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(bookingRepositoryProvider)
          .updateBookingStatus(widget.booking.id, newStatus);
      if (mounted) {
        AppToast.success(context, message: 'Status atualizado!');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao atualizar: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.scheduled:
      case BookingStatus.confirmed:
        return Colors.grey;
      case BookingStatus.checkIn:
        return Colors.blue;
      case BookingStatus.washing:
      case BookingStatus.vacuuming:
      case BookingStatus.drying:
      case BookingStatus.polishing:
        return Colors.orange;
      case BookingStatus.finished:
        return Colors.green;
      case BookingStatus.cancelled:
      case BookingStatus.noShow:
        return Colors.red;
    }
  }

  String _getStatusEmoji(BookingStatus status) {
    switch (status) {
      case BookingStatus.scheduled:
        return '📋';
      case BookingStatus.confirmed:
        return '✅';
      case BookingStatus.checkIn:
        return '🚗';
      case BookingStatus.washing:
        return '🚿';
      case BookingStatus.vacuuming:
        return '🧹';
      case BookingStatus.drying:
        return '💨';
      case BookingStatus.polishing:
        return '✨';
      case BookingStatus.finished:
        return '🏁';
      case BookingStatus.cancelled:
        return '❌';
      case BookingStatus.noShow:
        return '⏰';
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.scheduled:
        return 'Aguardando';
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
        return 'Pronto';
      case BookingStatus.cancelled:
        return 'Cancelado';
      case BookingStatus.noShow:
        return 'Ausente';
    }
  }

  BookingStatus? _getNextStatus(BookingStatus status) {
    switch (status) {
      case BookingStatus.scheduled:
      case BookingStatus.confirmed:
        return BookingStatus.checkIn;
      case BookingStatus.checkIn:
        return BookingStatus.washing;
      case BookingStatus.washing:
        return BookingStatus.vacuuming;
      case BookingStatus.vacuuming:
        return BookingStatus.drying;
      case BookingStatus.drying:
        return BookingStatus.polishing;
      case BookingStatus.polishing:
        return BookingStatus.finished;
      case BookingStatus.finished:
      case BookingStatus.cancelled:
      case BookingStatus.noShow:
        return null;
    }
  }

  String? _getNextActionText(BookingStatus status) {
    switch (status) {
      case BookingStatus.scheduled:
      case BookingStatus.confirmed:
        return 'Check-in';
      case BookingStatus.checkIn:
        return 'Iniciar';
      case BookingStatus.washing:
        return 'Aspirar';
      case BookingStatus.vacuuming:
        return 'Secar';
      case BookingStatus.drying:
        return 'Polir';
      case BookingStatus.polishing:
        return 'Finalizar';
      case BookingStatus.finished:
      case BookingStatus.cancelled:
      case BookingStatus.noShow:
        return null;
    }
  }

  /// Calculate time elapsed and severity
  ({String text, Color color}) _getTimeStatus(ThemeData theme) {
    final booking = widget.booking;
    final now = DateTime.now();
    final elapsed = now.difference(booking.scheduledTime);

    // Future booking
    if (elapsed.isNegative) {
      final minutes = elapsed.inMinutes.abs();
      if (minutes < 60) {
        return (text: 'em ${minutes}min', color: theme.colorScheme.primary);
      }
      return (
        text: 'em ${elapsed.inHours.abs()}h',
        color: theme.colorScheme.primary,
      );
    }

    // Past booking (active service)
    final minutes = elapsed.inMinutes;
    final hours = elapsed.inHours;

    // Severity thresholds
    Color color = theme.colorScheme.onSurfaceVariant;

    // If active status (washing/etc), show alerts
    if ([
      BookingStatus.washing,
      BookingStatus.vacuuming,
      BookingStatus.drying,
      BookingStatus.polishing,
    ].contains(booking.status)) {
      if (minutes > 45) {
        color = theme.colorScheme.error; // Red alert > 45min
      } else if (minutes > 30) {
        color = Colors.orange; // Amber alert > 30min
      } else {
        color = Colors.green; // Good pace
      }
    }

    if (minutes < 1) {
      return (text: 'agora', color: Colors.green);
    }

    if (minutes < 60) {
      return (text: 'há ${minutes}min', color: color);
    }

    return (text: 'há ${hours}h${minutes % 60}min', color: color);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final booking = widget.booking;
    final statusColor = _getStatusColor(booking.status);
    final nextStatus = _getNextStatus(booking.status);
    final nextActionText = _getNextActionText(booking.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/staff/booking/${booking.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Top Row: Status + Time
                Row(
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getStatusEmoji(booking.status),
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getStatusText(booking.status),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Time elapsed indicator
                    Builder(
                      builder: (context) {
                        final timeStatus = _getTimeStatus(theme);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: timeStatus.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: timeStatus.color.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: timeStatus.color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                timeStatus.text,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: timeStatus.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Main Row: Vehicle Info + Action
                Row(
                  children: [
                    // Vehicle Info
                    Expanded(
                      child: FutureBuilder<Vehicle?>(
                        future: ref
                            .read(bookingRepositoryProvider)
                            .getVehicle(booking.vehicleId),
                        builder: (context, snapshot) {
                          final vehicle = snapshot.data;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Plate - styled like license plate
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  vehicle?.plate ?? '...',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Vehicle model + Premium badge
                              Row(
                                children: [
                                  if (vehicle != null)
                                    Text(
                                      '${vehicle.brand} ${vehicle.model}',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  const SizedBox(width: 8),
                                  // Premium badge if subscriber
                                  _buildPremiumBadge(booking.userId),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Scheduled time
                              Text(
                                DateFormat(
                                  'HH:mm',
                                ).format(booking.scheduledTime),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    // Action Button
                    if (nextStatus != null && nextActionText != null)
                      SizedBox(
                        width: 100,
                        child: PrimaryButton(
                          text: nextActionText,
                          isLoading: _isLoading,
                          isFullWidth: true,
                          onPressed: () => _updateStatus(nextStatus),
                        ),
                      ),
                    if (booking.status == BookingStatus.finished)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 28,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumBadge(String userId) {
    return Consumer(
      builder: (context, ref, _) {
        final subscriptionAsync = ref.watch(
          subscriptionByUserIdProvider(userId),
        );

        return subscriptionAsync.when(
          data: (subscription) {
            if (subscription == null || subscription.status != 'active') {
              return const SizedBox.shrink();
            }
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade600, Colors.orange.shade400],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 10, color: Colors.white),
                  SizedBox(width: 2),
                  Text(
                    'PREMIUM',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }
}
