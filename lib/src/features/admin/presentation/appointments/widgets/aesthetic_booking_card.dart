import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../../../../features/services/domain/service_booking.dart';
import '../../../../../features/services/domain/independent_service.dart';
import '../../theme/admin_theme.dart';

/// Status color mapping for aesthetic bookings
Color getAestheticStatusColor(ServiceBookingStatus status) {
  switch (status) {
    case ServiceBookingStatus.pendingApproval:
      return AdminTheme.gradientWarning[0];
    case ServiceBookingStatus.scheduled:
      return Colors.orangeAccent;
    case ServiceBookingStatus.confirmed:
      return AdminTheme.gradientInfo[1];
    case ServiceBookingStatus.inProgress:
      return Colors.purpleAccent;
    case ServiceBookingStatus.finished:
      return AdminTheme.gradientSuccess[0];
    case ServiceBookingStatus.cancelled:
      return AdminTheme.gradientDanger[0];
    case ServiceBookingStatus.rejected:
      return AdminTheme.gradientDanger[1];
    case ServiceBookingStatus.noShow:
      return AdminTheme.textMuted;
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
      return AdminTheme.gradientWarning[0];
    case PaymentStatus.paid:
      return AdminTheme.gradientSuccess[0];
    case PaymentStatus.partial:
      return Colors.amberAccent;
    case PaymentStatus.refunded:
      return AdminTheme.gradientInfo[0];
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: isPendingApproval
          ? AdminTheme.glassmorphicDecoration(
              opacity: 0.7,
              glowColor: Colors.amber,
            ).copyWith(
              border: Border.all(
                color: Colors.amber.withOpacity(0.5),
                width: 1.5,
              ),
            )
          : AdminTheme.glassmorphicDecoration(opacity: 0.6),
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
                            booking.userName ?? 'Cliente desconhecido',
                            style: AdminTheme.headingSmall.copyWith(
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
                                color: AdminTheme.gradientPrimary[1],
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  service?.title ?? 'Serviço desconhecido',
                                  style: AdminTheme.bodyMedium,
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
                                  color: AdminTheme.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                if (booking.vehiclePlate != null)
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
                                      booking.vehiclePlate!,
                                      style: AdminTheme.labelSmall.copyWith(
                                        color: AdminTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                if (booking.vehicleModel != null) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      booking.vehicleModel!,
                                      style: AdminTheme.bodyMedium,
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
                                  color: AdminTheme.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  booking.userPhone!,
                                  style: AdminTheme.bodyMedium,
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
                                  color: paymentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: paymentColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      getPaymentStatusIcon(
                                        booking.paymentStatus,
                                      ),
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
      ),
    );
  }
}
