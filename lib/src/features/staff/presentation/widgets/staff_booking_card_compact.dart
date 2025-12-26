import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../booking/domain/booking.dart';
import '../../../booking/data/booking_repository.dart';
import '../../../profile/domain/vehicle.dart';
import '../../../subscription/data/subscription_repository.dart';
import '../../../../shared/utils/app_toast.dart';

/// Enhanced compact booking card for staff with real-time timer
/// Features: live timer, prominent plate, workflow actions, visual alerts
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
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateElapsed();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateElapsed() {
    final booking = widget.booking;
    final now = DateTime.now();

    // For active services, calculate time since service started
    if (_isActiveService(booking.status)) {
      _elapsed = now.difference(booking.scheduledTime);
    } else {
      _elapsed = Duration.zero;
    }
  }

  void _startTimer() {
    // Update every second for active services
    if (_isActiveService(widget.booking.status)) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {
            _elapsed = DateTime.now().difference(widget.booking.scheduledTime);
          });
        }
      });
    }
  }

  bool _isActiveService(BookingStatus status) {
    return [
      BookingStatus.checkIn,
      BookingStatus.washing,
      BookingStatus.vacuuming,
      BookingStatus.drying,
      BookingStatus.polishing,
    ].contains(status);
  }

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

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    try {
      await ref
          .read(bookingRepositoryProvider)
          .updateBookingStatus(widget.booking.id, newStatus);
      if (mounted) {
        AppToast.success(context, message: _getSuccessMessage(newStatus));
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

  String _getSuccessMessage(BookingStatus newStatus) {
    switch (newStatus) {
      case BookingStatus.checkIn:
        return 'Check-in realizado! 🚗';
      case BookingStatus.washing:
        return 'Lavagem iniciada! 🚿';
      case BookingStatus.vacuuming:
        return 'Aspiração iniciada! 🧹';
      case BookingStatus.drying:
        return 'Secagem iniciada! 💨';
      case BookingStatus.polishing:
        return 'Polimento iniciado! ✨';
      case BookingStatus.finished:
        return 'Serviço finalizado! 🏁';
      default:
        return 'Status atualizado!';
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
        return Colors.cyan;
      case BookingStatus.vacuuming:
        return Colors.teal;
      case BookingStatus.drying:
        return Colors.indigo;
      case BookingStatus.polishing:
        return Colors.purple;
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

  /// Get timer color based on elapsed time
  /// Green: < 30min, Yellow: 30-45min, Red: > 45min
  Color _getTimerColor() {
    if (!_isActiveService(widget.booking.status)) {
      return Colors.grey;
    }

    final minutes = _elapsed.inMinutes;
    if (minutes >= 45) {
      return Colors.red;
    } else if (minutes >= 30) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  /// Format elapsed time as mm:ss or hh:mm:ss
  String _formatElapsed() {
    final hours = _elapsed.inHours;
    final minutes = _elapsed.inMinutes % 60;
    final seconds = _elapsed.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get time until scheduled (for waiting bookings)
  String _getTimeUntil() {
    final now = DateTime.now();
    final diff = widget.booking.scheduledTime.difference(now);

    if (diff.isNegative) {
      final late = diff.abs();
      if (late.inMinutes < 1) return 'agora';
      if (late.inMinutes < 60) return '${late.inMinutes}min atrás';
      return '${late.inHours}h atrás';
    }

    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return 'em ${diff.inMinutes}min';
    return 'em ${diff.inHours}h';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final booking = widget.booking;
    final statusColor = _getStatusColor(booking.status);
    final nextStatus = _getNextStatus(booking.status);
    final nextActionText = _getNextActionText(booking.status);
    final isActive = _isActiveService(booking.status);
    final timerColor = _getTimerColor();
    final isLate = _elapsed.inMinutes >= 45;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: isLate
                ? Colors.red.withOpacity(0.2)
                : Colors.black.withOpacity(0.06),
            blurRadius: isLate ? 15 : 10,
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
                // Top Row: Status + Timer
                Row(
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
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
                    const SizedBox(width: 8),
                    // Payment status badge
                    _buildPaymentBadge(booking),
                    const Spacer(),
                    // Timer / Time indicator
                    if (isActive)
                      Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: timerColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: timerColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.timer, size: 16, color: timerColor),
                                const SizedBox(width: 6),
                                Text(
                                  _formatElapsed(),
                                  style: TextStyle(
                                    color: timerColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate(
                            onComplete: (controller) => isLate
                                ? controller.repeat(reverse: true)
                                : null,
                          )
                          .shimmer(
                            duration: isLate ? 1.seconds : Duration.zero,
                            color: isLate
                                ? Colors.red.withOpacity(0.3)
                                : Colors.transparent,
                          )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getTimeUntil(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Progress bar for active services
                if (isActive) ...[
                  _buildProgressBar(theme, booking.status),
                  const SizedBox(height: 14),
                ],

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
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: theme.colorScheme.outline
                                        .withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  vehicle?.plate ?? '...',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 3,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Vehicle model + Premium badge
                              Row(
                                children: [
                                  if (vehicle != null)
                                    Flexible(
                                      child: Text(
                                        '${vehicle.brand} ${vehicle.model}',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  _buildPremiumBadge(booking.userId),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Scheduled time
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
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
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Action Button
                    if (nextStatus != null && nextActionText != null)
                      SizedBox(
                        width: 110,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () => _updateStatus(nextStatus),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: statusColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  nextActionText,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ),
                    if (booking.status == BookingStatus.finished)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
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

  Widget _buildProgressBar(ThemeData theme, BookingStatus status) {
    const stages = [
      BookingStatus.checkIn,
      BookingStatus.washing,
      BookingStatus.vacuuming,
      BookingStatus.drying,
      BookingStatus.polishing,
    ];

    final currentIndex = stages.indexOf(status);
    final progress = (currentIndex + 1) / stages.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(_getStatusColor(status)),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 6),
        // Stage indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: stages.asMap().entries.map((entry) {
            final i = entry.key;
            final stage = entry.value;
            final isCompleted = i < currentIndex;
            final isCurrent = i == currentIndex;

            return Text(
              _getStatusEmoji(stage),
              style: TextStyle(
                fontSize: 12,
                color: isCompleted || isCurrent
                    ? null
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
              ),
            );
          }).toList(),
        ),
      ],
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
                    'VIP',
                    style: TextStyle(
                      fontSize: 9,
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

  /// Builds payment status badge - shows alert if payment is pending
  Widget _buildPaymentBadge(Booking booking) {
    // Don't show for scheduled bookings (not started yet)
    if (booking.status == BookingStatus.scheduled ||
        booking.status == BookingStatus.confirmed) {
      return const SizedBox.shrink();
    }

    // Check if payment is pending
    final isPending = booking.paymentStatus == BookingPaymentStatus.pending;
    final isSubscription =
        booking.paymentStatus == BookingPaymentStatus.subscription;

    if (isSubscription) {
      // Show "included in subscription" badge
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 10, color: Colors.green),
            SizedBox(width: 2),
            Text(
              'PLANO',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.green,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    if (isPending) {
      // Show payment pending alert
      return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.attach_money, size: 10, color: Colors.red),
                SizedBox(width: 2),
                Text(
                  'PENDENTE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          )
          .animate(onComplete: (c) => c.repeat(reverse: true))
          .shimmer(duration: 1500.ms, color: Colors.red.withOpacity(0.3));
    }

    // Payment confirmed - show green badge
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: 10, color: Colors.green),
          SizedBox(width: 2),
          Text(
            'PAGO',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.green,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
