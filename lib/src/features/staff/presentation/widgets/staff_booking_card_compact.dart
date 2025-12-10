import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../common_widgets/atoms/primary_button.dart';
import '../../../booking/domain/booking.dart';
import '../../../booking/data/booking_repository.dart';
import '../../../profile/domain/vehicle.dart';
import '../../../../shared/utils/app_toast.dart';

/// Compact booking card optimized for staff quick actions
/// Shows plate prominently with single action button for status progression
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
      // Redirect to detail screen to add photos
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
    // Validate photo requirements
    if (!_canTransitionTo(newStatus)) {
      return;
    }

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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
            child: Row(
              children: [
                // Status Emoji + Vehicle Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Row
                      Row(
                        children: [
                          Text(
                            _getStatusEmoji(booking.status),
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getStatusText(booking.status),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('HH:mm').format(booking.scheduledTime),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Vehicle Plate (prominent)
                      FutureBuilder<Vehicle?>(
                        future: ref
                            .read(bookingRepositoryProvider)
                            .getVehicle(booking.vehicleId),
                        builder: (context, snapshot) {
                          final vehicle = snapshot.data;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vehicle?.plate ?? '...',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              if (vehicle != null)
                                Text(
                                  '${vehicle.brand} ${vehicle.model}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Action Button
                if (nextStatus != null && nextActionText != null)
                  SizedBox(
                    width: 90,
                    child: PrimaryButton(
                      text: nextActionText,
                      isLoading: _isLoading,
                      isFullWidth: true,
                      onPressed: () => _updateStatus(nextStatus),
                    ),
                  ),
                if (booking.status == BookingStatus.finished)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
