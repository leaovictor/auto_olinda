import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../../../../features/services/domain/service_booking.dart';
import '../../../../../features/services/domain/independent_service.dart';

/// Status color mapping for aesthetic bookings
Color getAestheticStatusColor(ServiceBookingStatus status) {
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

/// Status icon mapping for aesthetic bookings
IconData getAestheticStatusIcon(ServiceBookingStatus status) {
  switch (status) {
    case ServiceBookingStatus.pendingApproval:
      return Icons.hourglass_empty;
    case ServiceBookingStatus.scheduled:
      return Icons.access_time;
    case ServiceBookingStatus.confirmed:
      return Icons.check_circle;
    case ServiceBookingStatus.inProgress:
      return Icons.build;
    case ServiceBookingStatus.finished:
      return Icons.done_all;
    case ServiceBookingStatus.cancelled:
      return Icons.cancel;
    case ServiceBookingStatus.rejected:
      return Icons.block;
    case ServiceBookingStatus.noShow:
      return Icons.person_off;
  }
}

/// Status label mapping for aesthetic bookings
String getAestheticStatusLabel(ServiceBookingStatus status) {
  switch (status) {
    case ServiceBookingStatus.pendingApproval:
      return 'Aguardando Aprovação';
    case ServiceBookingStatus.scheduled:
      return 'Agendado';
    case ServiceBookingStatus.confirmed:
      return 'Confirmado';
    case ServiceBookingStatus.inProgress:
      return 'Em Andamento';
    case ServiceBookingStatus.finished:
      return 'Finalizado';
    case ServiceBookingStatus.cancelled:
      return 'Cancelado';
    case ServiceBookingStatus.rejected:
      return 'Recusado';
    case ServiceBookingStatus.noShow:
      return 'Não Compareceu';
  }
}

/// Payment status helpers
Color getPaymentStatusColor(PaymentStatus status) {
  switch (status) {
    case PaymentStatus.pending:
      return Colors.orange;
    case PaymentStatus.paid:
      return Colors.green;
    case PaymentStatus.partial:
      return Colors.amber;
    case PaymentStatus.refunded:
      return Colors.blue;
  }
}

IconData getPaymentStatusIcon(PaymentStatus status) {
  switch (status) {
    case PaymentStatus.pending:
      return Icons.pending;
    case PaymentStatus.paid:
      return Icons.check_circle;
    case PaymentStatus.partial:
      return Icons.pie_chart;
    case PaymentStatus.refunded:
      return Icons.replay;
  }
}

String getPaymentStatusLabel(PaymentStatus status) {
  switch (status) {
    case PaymentStatus.pending:
      return 'Pendente';
    case PaymentStatus.paid:
      return 'Pago';
    case PaymentStatus.partial:
      return 'Parcial';
    case PaymentStatus.refunded:
      return 'Reembolsado';
  }
}

/// Modernized card for aesthetic service bookings with enhanced visual design
/// Features: Status bar indicator, badge styling, payment info, improved typography
class AestheticBookingCard extends ConsumerWidget {
  final ServiceBooking booking;
  final IndependentService? service;
  final VoidCallback onTap;
  final VoidCallback onManage;
  final VoidCallback onWhatsApp;
  final VoidCallback? onCancel;

  const AestheticBookingCard({
    super.key,
    required this.booking,
    this.service,
    required this.onTap,
    required this.onManage,
    required this.onWhatsApp,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = getAestheticStatusColor(booking.status);
    final paymentColor = getPaymentStatusColor(booking.paymentStatus);
    final canCancel =
        booking.status != ServiceBookingStatus.cancelled &&
        booking.status != ServiceBookingStatus.finished;
    final isPendingApproval =
        booking.status == ServiceBookingStatus.pendingApproval;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      elevation: isPendingApproval ? 4 : 2,
      shadowColor: isPendingApproval
          ? Colors.amber.withAlpha(100)
          : Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPendingApproval
            ? BorderSide(color: Colors.amber.shade400, width: 2)
            : BorderSide.none,
      ),
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
                          booking.userName ?? 'Cliente desconhecido',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        // Service name
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 16,
                              color: Colors.purple.shade400,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                service?.title ?? 'Serviço desconhecido',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        // Vehicle info (if present)
                        if (booking.vehiclePlate != null ||
                            booking.vehicleModel != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.directions_car_rounded,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              if (booking.vehiclePlate != null)
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
                                    booking.vehiclePlate!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: Colors.blueGrey.shade700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              if (booking.vehicleModel != null) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    booking.vehicleModel!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                        // Phone
                        if (booking.userPhone != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.phone_rounded,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                booking.userPhone!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 10),
                        // Status row with payment info
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
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
                                    getAestheticStatusIcon(booking.status),
                                    size: 14,
                                    color: statusColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    getAestheticStatusLabel(booking.status),
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Payment status pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: paymentColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    getPaymentStatusIcon(booking.paymentStatus),
                                    size: 14,
                                    color: paymentColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    getPaymentStatusLabel(
                                      booking.paymentStatus,
                                    ),
                                    style: TextStyle(
                                      color: paymentColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (booking.paymentStatus ==
                                      PaymentStatus.partial)
                                    Text(
                                      ' (R\$ ${booking.paidAmount.toStringAsFixed(2)})',
                                      style: TextStyle(
                                        color: paymentColor,
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
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
