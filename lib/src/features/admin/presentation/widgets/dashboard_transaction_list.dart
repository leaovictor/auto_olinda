import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/booking_with_details.dart';
import '../../../booking/domain/booking.dart';

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
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Agendamentos Recentes",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.more_horiz, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
        const SizedBox(height: 16),
        if (bookings.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Nenhum agendamento recente"),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bookings.take(5).length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final bookingDetails = bookings[index];
              final booking = bookingDetails.booking;
              final user = bookingDetails.user;
              final vehicle = bookingDetails.vehicle;

              return Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_car_wash,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle?.model ?? "Veículo Desconhecido",
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(booking.scheduledTime),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _getStatusText(booking.status),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _getStatusColor(booking.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        // Show Plate instead of ID
                        vehicle?.plate ?? booking.id.substring(0, 8),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    NumberFormat.currency(
                      symbol: 'R\$',
                      locale: 'pt_BR',
                      decimalDigits: 0,
                    ).format(booking.totalPrice),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.finished:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.confirmed:
      case BookingStatus.washing:
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.finished:
        return "Concluído";
      case BookingStatus.cancelled:
        return "Cancelado";
      case BookingStatus.confirmed:
        return "Confirmado";
      case BookingStatus.washing:
        return "Lavando";
      default:
        return "Pendente";
    }
  }
}
