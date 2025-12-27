import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../../../../features/booking/domain/booking.dart';
import '../../../domain/booking_with_details.dart';
import '../../theme/admin_theme.dart';

/// Status color mapping for car wash bookings
Color getCarWashStatusColor(BookingStatus status) {
  switch (status) {
    case BookingStatus.scheduled:
      return AdminTheme.gradientWarning[0];
    case BookingStatus.confirmed:
      return AdminTheme.gradientInfo[1];
    case BookingStatus.checkIn:
      return Colors.purpleAccent;
    case BookingStatus.washing:
      return AdminTheme.gradientInfo[0];
    case BookingStatus.vacuuming:
      return Colors.tealAccent;
    case BookingStatus.drying:
      return Colors.orangeAccent;
    case BookingStatus.polishing:
      return Colors.deepPurpleAccent;
    case BookingStatus.finished:
      return AdminTheme.gradientSuccess[0];
    case BookingStatus.cancelled:
      return AdminTheme.gradientDanger[0];
    case BookingStatus.noShow:
      return AdminTheme.textMuted;
  }
}

/// Status icon mapping for car wash bookings
IconData getCarWashStatusIcon(BookingStatus status) {
  switch (status) {
    case BookingStatus.scheduled:
      return Icons.access_time;
    case BookingStatus.confirmed:
      return Icons.check_circle;
    case BookingStatus.checkIn:
      return Icons.login;
    case BookingStatus.washing:
      return Icons.water_drop;
    case BookingStatus.vacuuming:
      return Icons.cleaning_services;
    case BookingStatus.drying:
      return Icons.wb_sunny;
    case BookingStatus.polishing:
      return Icons.auto_awesome;
    case BookingStatus.finished:
      return Icons.done_all;
    case BookingStatus.cancelled:
      return Icons.cancel;
    case BookingStatus.noShow:
      return Icons.person_off;
  }
}

/// Status label mapping for car wash bookings
String getCarWashStatusLabel(BookingStatus status) {
  switch (status) {
    case BookingStatus.scheduled:
      return 'Pendente';
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
      return 'Não Compareceu';
  }
}

/// Modernized card for car wash bookings with enhanced visual design
/// Features: Status bar indicator, badge styling for plate, improved typography
class CarWashBookingCard extends ConsumerWidget {
  final BookingWithDetails bookingWithDetails;
  final VoidCallback onTap;
  final VoidCallback onManage;
  final VoidCallback onWhatsApp;
  final VoidCallback? onCancel;

  const CarWashBookingCard({
    super.key,
    required this.bookingWithDetails,
    required this.onTap,
    required this.onManage,
    required this.onWhatsApp,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = bookingWithDetails.booking;
    final user = bookingWithDetails.user;
    final vehicle = bookingWithDetails.vehicle;
    final statusColor = getCarWashStatusColor(booking.status);
    final canCancel =
        booking.status != BookingStatus.cancelled &&
        booking.status != BookingStatus.finished;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AdminTheme.glassmorphicDecoration(opacity: 0.95),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AdminTheme.radiusXL),
        child: Slidable(
          key: ValueKey(booking.id),
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.5,
            children: [
              SlidableAction(
                onPressed: (_) => onManage(),
                backgroundColor: AdminTheme.gradientInfo[0],
                foregroundColor: Colors.white,
                icon: Icons.edit_note_rounded,
                label: 'Gerenciar',
              ),
              CustomSlidableAction(
                onPressed: (_) => onWhatsApp(),
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/whatsapp.png',
                      width: 24,
                      height: 24,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'WhatsApp',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          endActionPane: canCancel
              ? ActionPane(
                  motion: const DrawerMotion(),
                  extentRatio: 0.25,
                  children: [
                    SlidableAction(
                      onPressed: (_) => onCancel?.call(),
                      backgroundColor: AdminTheme.gradientDanger[0],
                      foregroundColor: Colors.white,
                      icon: Icons.cancel_rounded,
                      label: 'Cancelar',
                    ),
                  ],
                )
              : null,
          child: InkWell(
            onTap: onTap,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Status indicator bar
                  Container(
                    width: 5,
                    decoration: BoxDecoration(color: statusColor),
                  ),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row: Date + Price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date/Time
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 16,
                                    color: AdminTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormat(
                                      'dd/MM/yyyy • HH:mm',
                                    ).format(booking.scheduledTime),
                                    style: AdminTheme.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AdminTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              // Price
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AdminTheme.gradientSuccess[0]
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AdminTheme.gradientSuccess[0]
                                        .withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  'R\$ ${booking.totalPrice.toStringAsFixed(2)}',
                                  style: AdminTheme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AdminTheme.gradientSuccess[0],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Client name (prominent)
                          Text(
                            user?.displayName ?? 'Cliente desconhecido',
                            style: AdminTheme.headingSmall.copyWith(
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Vehicle info with badge
                          Row(
                            children: [
                              Icon(
                                Icons.directions_car_rounded,
                                size: 16,
                                color: AdminTheme.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              if (vehicle != null) ...[
                                // Plate badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AdminTheme.bgCardLight,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AdminTheme.borderLight,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    vehicle.plate,
                                    style: AdminTheme.labelSmall.copyWith(
                                      color: AdminTheme.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${vehicle.brand} ${vehicle.model}',
                                    style: AdminTheme.bodyMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ] else
                                Text(
                                  'Veículo desconhecido',
                                  style: AdminTheme.bodyMedium,
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Status row with rating if available
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Status pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: statusColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      getCarWashStatusIcon(booking.status),
                                      size: 14,
                                      color: statusColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      getCarWashStatusLabel(booking.status),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Rating if available
                              if (booking.isRated && booking.rating != null)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < (booking.rating ?? 0)
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      size: 16,
                                      color: Colors.amber,
                                    );
                                  }),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
