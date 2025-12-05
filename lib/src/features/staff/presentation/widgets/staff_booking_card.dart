import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../common_widgets/atoms/app_card.dart';
import '../../../../common_widgets/atoms/primary_button.dart';
import '../../../../common_widgets/molecules/status_badge.dart';
import '../../../booking/domain/booking.dart';
import '../../../booking/data/booking_repository.dart';
import '../../../profile/domain/vehicle.dart';
import '../../../../shared/utils/app_toast.dart';

class StaffBookingCard extends ConsumerStatefulWidget {
  final Booking booking;

  const StaffBookingCard({super.key, required this.booking});

  @override
  ConsumerState<StaffBookingCard> createState() => _StaffBookingCardState();
}

class _StaffBookingCardState extends ConsumerState<StaffBookingCard> {
  bool _isLoading = false;

  Future<void> _updateStatus(BookingStatus newStatus) async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(bookingRepositoryProvider)
          .updateBookingStatus(widget.booking.id, newStatus);
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao atualizar status: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  StatusType _getStatusType(BookingStatus status) {
    switch (status) {
      case BookingStatus.scheduled:
        return StatusType.neutral;
      case BookingStatus.confirmed:
      case BookingStatus.checkIn:
        return StatusType.info;
      case BookingStatus.washing:
      case BookingStatus.vacuuming:
      case BookingStatus.drying:
      case BookingStatus.polishing:
        return StatusType.warning;
      case BookingStatus.finished:
        return StatusType.success;
      case BookingStatus.cancelled:
      case BookingStatus.noShow:
        return StatusType.error;
    }
  }

  String _getStatusText(BookingStatus status) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final booking = widget.booking;

    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.push('/staff/booking/${booking.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(
                    text: _getStatusText(booking.status),
                    type: _getStatusType(booking.status),
                  ),
                  Text(
                    DateFormat('HH:mm').format(booking.scheduledTime),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Vehicle Info (We might need to fetch vehicle details if not fully hydrated,
              // but for now assuming we might have vehicleId. Ideally Booking should have embedded vehicle data or we fetch it)
              // Since Booking only has vehicleId, we might need to fetch it or just show ID for now.
              // For better UX, let's assume we can fetch it or it's passed.
              // Actually, let's just show the ID or "Veículo" for now to keep it simple,
              // or fetch it if we want to be fancy. Let's stick to simple for this step.
              Row(
                children: [
                  Icon(
                    Icons.directions_car,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  FutureBuilder<Vehicle?>(
                    future: ref
                        .read(bookingRepositoryProvider)
                        .getVehicle(booking.vehicleId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                          'Carregando veículo...',
                          style: theme.textTheme.bodyLarge,
                        );
                      }
                      final vehicle = snapshot.data;
                      return Text(
                        vehicle != null
                            ? '${vehicle.brand} ${vehicle.model} (${vehicle.plate})'
                            : 'Veículo não encontrado',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildActionButtons(booking),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(Booking booking) {
    switch (booking.status) {
      case BookingStatus.scheduled:
      case BookingStatus.confirmed:
      case BookingStatus.checkIn:
        return PrimaryButton(
          text: 'Iniciar Lavagem',
          isLoading: _isLoading,
          onPressed: () => _updateStatus(BookingStatus.washing),
        );
      case BookingStatus.washing:
        return PrimaryButton(
          text: 'Iniciar Aspiração',
          isLoading: _isLoading,
          onPressed: () => _updateStatus(BookingStatus.vacuuming),
        );
      case BookingStatus.vacuuming:
        return PrimaryButton(
          text: 'Iniciar Secagem',
          isLoading: _isLoading,
          onPressed: () => _updateStatus(BookingStatus.drying),
        );
      case BookingStatus.drying:
        return PrimaryButton(
          text: 'Iniciar Polimento',
          isLoading: _isLoading,
          onPressed: () => _updateStatus(BookingStatus.polishing),
        );
      case BookingStatus.polishing:
        return PrimaryButton(
          text: 'Finalizar Serviço',
          isLoading: _isLoading,
          onPressed: () => _updateStatus(BookingStatus.finished),
        );
      case BookingStatus.finished:
        return const Center(
          child: Text(
            'Serviço Concluído',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        );
      case BookingStatus.cancelled:
        return const Center(
          child: Text(
            'Cancelado',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        );
      case BookingStatus.noShow:
        return const Center(
          child: Text(
            'Não Compareceu',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        );
    }
  }
}
