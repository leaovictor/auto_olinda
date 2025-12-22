import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/booking_with_details.dart';
import '../../../booking/domain/booking.dart';
import '../theme/admin_theme.dart';

/// Premium Transaction List for Dashboard
/// Displays recent bookings with glassmorphic cards and animations
class DashboardTransactionList extends StatelessWidget {
  final List<BookingWithDetails> bookings;
  final VoidCallback onViewAll;

  const DashboardTransactionList({
    super.key,
    required this.bookings,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Agendamentos Recentes', style: AdminTheme.headingSmall),
            GestureDetector(
              onTap: onViewAll,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AdminTheme.gradientPrimary),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Ver todos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Bookings list
        if (bookings.isEmpty)
          _buildEmptyState()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bookings.take(5).length,
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(height: 1, color: AdminTheme.borderLight),
            ),
            itemBuilder: (context, index) {
              final bookingDetails = bookings[index];
              return _buildTransactionItem(bookingDetails, index);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: AdminTheme.textMuted),
          const SizedBox(height: 12),
          Text(
            'Nenhum agendamento recente',
            style: AdminTheme.bodyMedium.copyWith(color: AdminTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BookingWithDetails details, int index) {
    final booking = details.booking;
    final vehicle = details.vehicle;
    final statusColor = _getStatusColor(booking.status);

    return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              // Icon with status color
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withOpacity(0.2),
                      statusColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Icon(
                  Icons.local_car_wash_rounded,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Vehicle and date info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle?.model ?? 'Veículo',
                      style: AdminTheme.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: AdminTheme.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat(
                            'dd/MM HH:mm',
                          ).format(booking.scheduledTime),
                          style: AdminTheme.labelSmall,
                        ),
                        if (vehicle?.plate != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AdminTheme.bgCardLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              vehicle!.plate,
                              style: AdminTheme.labelSmall.copyWith(
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Status badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      _getStatusText(booking.status),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(
                      symbol: 'R\$',
                      locale: 'pt_BR',
                      decimalDigits: 0,
                    ).format(booking.totalPrice),
                    style: AdminTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AdminTheme.gradientSuccess[0],
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: index * 100))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05, end: 0, duration: 300.ms);
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.finished:
        return AdminTheme.gradientSuccess[0];
      case BookingStatus.cancelled:
        return AdminTheme.gradientDanger[0];
      case BookingStatus.confirmed:
      case BookingStatus.washing:
        return AdminTheme.gradientInfo[0];
      case BookingStatus.checkIn:
        return AdminTheme.gradientPrimary[0];
      default:
        return AdminTheme.gradientWarning[0];
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.finished:
        return 'Concluído';
      case BookingStatus.cancelled:
        return 'Cancelado';
      case BookingStatus.confirmed:
        return 'Confirmado';
      case BookingStatus.washing:
        return 'Lavando';
      case BookingStatus.checkIn:
        return 'Check-in';
      default:
        return 'Pendente';
    }
  }
}
