import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../common_widgets/atoms/app_card.dart';
import '../../../../common_widgets/atoms/primary_button.dart';
import '../../../../common_widgets/molecules/status_badge.dart';
import '../../../booking/domain/booking.dart';
import '../../../booking/data/booking_repository.dart';
import '../widgets/photo_upload_widget.dart';

class StaffBookingDetailScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const StaffBookingDetailScreen({super.key, required this.bookingId});

  @override
  ConsumerState<StaffBookingDetailScreen> createState() =>
      _StaffBookingDetailScreenState();
}

class _StaffBookingDetailScreenState
    extends ConsumerState<StaffBookingDetailScreen> {
  bool _isLoading = false;

  Future<void> _updateStatus(Booking booking, BookingStatus newStatus) async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(bookingRepositoryProvider)
          .updateBookingStatus(booking.id, newStatus);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao atualizar status: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handlePhotoUpload(
    File file,
    Booking booking,
    bool isBefore,
  ) async {
    try {
      final repo = ref.read(bookingRepositoryProvider);
      final path =
          'bookings/${booking.id}/${isBefore ? "before" : "after"}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final url = await repo.uploadPhoto(file, path);
      await repo.addBookingPhoto(booking.id, url, isBefore);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao enviar foto: $e')));
      }
    }
  }

  Future<void> _handlePhotoRemove(
    String url,
    Booking booking,
    bool isBefore,
  ) async {
    try {
      await ref
          .read(bookingRepositoryProvider)
          .removeBookingPhoto(booking.id, url, isBefore);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao remover foto: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingAsync = ref.watch(bookingStreamProvider(widget.bookingId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Serviço')),
      body: bookingAsync.when(
        data: (booking) {
          final vehicleAsync = ref.watch(vehicleProvider(booking.vehicleId));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Info
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Agendamento #${booking.id.substring(0, 5)}',
                            style: theme.textTheme.titleMedium,
                          ),
                          StatusBadge(
                            text: booking.status.name.toUpperCase(),
                            type: _getStatusType(booking.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat(
                          "d 'de' MMMM, HH:mm",
                          'pt_BR',
                        ).format(booking.scheduledTime),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      vehicleAsync.when(
                        data: (vehicle) => Row(
                          children: [
                            Icon(
                              Icons.directions_car,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              vehicle != null
                                  ? '${vehicle.brand} ${vehicle.model} (${vehicle.plate})'
                                  : 'Veículo não encontrado',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        loading: () => const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, __) =>
                            const Text('Erro ao carregar veículo'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Photos Section
                Text(
                  'Fotos do Serviço',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      PhotoUploadWidget(
                        label: 'Antes da Lavagem',
                        photoUrls: booking.beforePhotos,
                        onPhotoAdded: (file) =>
                            _handlePhotoUpload(file, booking, true),
                        onPhotoRemoved: (url) =>
                            _handlePhotoRemove(url, booking, true),
                        isReadOnly: booking.status == BookingStatus.finished,
                      ),
                      const Divider(height: 32),
                      PhotoUploadWidget(
                        label: 'Depois da Lavagem',
                        photoUrls: booking.afterPhotos,
                        onPhotoAdded: (file) =>
                            _handlePhotoUpload(file, booking, false),
                        onPhotoRemoved: (url) =>
                            _handlePhotoRemove(url, booking, false),
                        isReadOnly: booking.status == BookingStatus.finished,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                if (booking.status != BookingStatus.finished &&
                    booking.status != BookingStatus.cancelled)
                  PrimaryButton(
                    text: _getNextActionLabel(booking.status),
                    isLoading: _isLoading,
                    onPressed: () =>
                        _updateStatus(booking, _getNextStatus(booking.status)),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
    );
  }

  String _getNextActionLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.scheduled:
      case BookingStatus.confirmed:
        return 'Realizar Check-in';
      case BookingStatus.checkIn:
        return 'Iniciar Lavagem';
      case BookingStatus.washing:
        return 'Iniciar Aspiração';
      case BookingStatus.vacuuming:
        return 'Iniciar Polimento';
      case BookingStatus.polishing:
        return 'Iniciar Secagem';
      case BookingStatus.drying:
        return 'Finalizar Serviço';
      default:
        return '';
    }
  }

  BookingStatus _getNextStatus(BookingStatus status) {
    switch (status) {
      case BookingStatus.scheduled:
      case BookingStatus.confirmed:
        return BookingStatus.checkIn;
      case BookingStatus.checkIn:
        return BookingStatus.washing;
      case BookingStatus.washing:
        return BookingStatus.vacuuming;
      case BookingStatus.vacuuming:
        return BookingStatus.polishing;
      case BookingStatus.polishing:
        return BookingStatus.drying;
      case BookingStatus.drying:
        return BookingStatus.finished;
      default:
        return status;
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
      case BookingStatus.polishing:
      case BookingStatus.drying:
        return StatusType.warning;
      case BookingStatus.finished:
        return StatusType.success;
      case BookingStatus.cancelled:
      case BookingStatus.noShow:
        return StatusType.error;
    }
  }
}
