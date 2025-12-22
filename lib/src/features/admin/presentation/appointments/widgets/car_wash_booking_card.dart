import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../../../../features/booking/domain/booking.dart';
import '../../../domain/booking_with_details.dart';

/// Status color mapping for car wash bookings
Color getCarWashStatusColor(BookingStatus status) {
  switch (status) {
    case BookingStatus.scheduled:
      return Colors.orange;
    case BookingStatus.confirmed:
      return Colors.blue;
    case BookingStatus.checkIn:
      return Colors.purple;
    case BookingStatus.washing:
      return Colors.blueAccent;
    case BookingStatus.vacuuming:
      return Colors.teal;
    case BookingStatus.drying:
      return Colors.lightBlue;
    case BookingStatus.polishing:
      return Colors.indigo;
    case BookingStatus.finished:
      return Colors.green;
    case BookingStatus.cancelled:
      return Colors.red;
    case BookingStatus.noShow:
      return Colors.grey;
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Slidable(
        key: ValueKey(booking.id),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.5,
          children: [
            SlidableAction(
              onPressed: (_) => onManage(),
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              icon: Icons.edit_note_rounded,
              label: 'Gerenciar',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
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
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    icon: Icons.cancel_rounded,
                    label: 'Cancelar',
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
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
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
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
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat(
                                    'dd/MM/yyyy • HH:mm',
                                  ).format(booking.scheduledTime),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.grey[800],
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
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'R\$ ${booking.totalPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Client name (prominent)
                        Text(
                          user?.displayName ?? 'Cliente desconhecido',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
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
                              color: Colors.grey[600],
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
                                  color: Colors.blueGrey.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.blueGrey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  vehicle.plate,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Colors.blueGrey.shade700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${vehicle.brand} ${vehicle.model}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ] else
                              Text(
                                'Veículo desconhecido',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
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
                                color: statusColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(12),
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
    );
  }
}
