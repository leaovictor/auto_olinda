// Photo upload support for web and mobile
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../common_widgets/atoms/app_card.dart';
import '../../../../common_widgets/atoms/primary_button.dart';
import '../../../../common_widgets/molecules/status_badge.dart';
import '../../../booking/domain/booking.dart';
import '../../../booking/data/booking_repository.dart';
import '../widgets/photo_upload_widget.dart';
import '../../../../shared/utils/app_toast.dart';
import '../../../subscription/data/subscription_repository.dart';

import '../../../../common_widgets/atoms/app_loader.dart';

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

  /// Validates if status transition is allowed based on photo requirements
  bool _canTransitionTo(Booking booking, BookingStatus newStatus) {
    // Require at least 1 "before" photo to start washing
    if (newStatus == BookingStatus.washing && booking.beforePhotos.isEmpty) {
      AppToast.warning(
        context,
        message: 'Adicione pelo menos 1 foto ANTES da lavagem',
      );
      return false;
    }

    // Require at least 1 "after" photo to finalize
    if (newStatus == BookingStatus.finished && booking.afterPhotos.isEmpty) {
      AppToast.warning(
        context,
        message: 'Adicione pelo menos 1 foto DEPOIS da lavagem',
      );
      return false;
    }

    return true;
  }

  Future<void> _updateStatus(Booking booking, BookingStatus newStatus) async {
    // Validate photo requirements
    if (!_canTransitionTo(booking, newStatus)) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(bookingRepositoryProvider)
          .updateBookingStatus(booking.id, newStatus);
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

  Future<void> _handlePhotoUpload(
    Uint8List bytes,
    String filename,
    Booking booking,
    bool isBefore,
  ) async {
    try {
      final repo = ref.read(bookingRepositoryProvider);
      final path =
          'bookings/${booking.id}/${isBefore ? "before" : "after"}/${DateTime.now().millisecondsSinceEpoch}_$filename';
      final url = await repo.uploadPhotoBytes(bytes.toList(), path);
      await repo.addBookingPhoto(booking.id, url, isBefore);
      if (mounted) {
        AppToast.success(context, message: 'Foto enviada!');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao enviar foto: $e');
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
        AppToast.error(context, message: 'Erro ao remover foto: $e');
      }
    }
  }

  /// Release vehicle with subscription validation
  Future<void> _releaseVehicle(Booking booking) async {
    setState(() => _isLoading = true);

    try {
      // Check if guest (Quick Entry)
      if (booking.userId == 'guest') {
        // Guest always needs to pay
        if (booking.paymentStatus == BookingPaymentStatus.pending) {
          setState(() => _isLoading = false);
          _showPaymentRequiredDialog(booking);
          return;
        }
      } else {
        // Check for active subscription
        final subscription = await ref.read(
          subscriptionByUserIdProvider(booking.userId).future,
        );

        if (subscription != null && subscription.isActive) {
          // Subscriber - mark as covered by subscription
          await ref
              .read(bookingRepositoryProvider)
              .updatePaymentStatus(
                booking.id,
                BookingPaymentStatus.subscription,
                paymentMethod: 'subscription',
              );
          if (mounted) {
            AppToast.success(context, message: 'Serviço coberto pelo plano! ⭐');
          }
        } else {
          // Not a subscriber - require payment
          if (booking.paymentStatus == BookingPaymentStatus.pending) {
            setState(() => _isLoading = false);
            _showPaymentRequiredDialog(booking);
            return;
          }
        }
      }

      // Vehicle released - show success
      if (mounted) {
        AppToast.success(context, message: 'Veículo liberado! ✅');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Show dialog requiring payment before release
  void _showPaymentRequiredDialog(Booking booking) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            const Text('Pagamento Pendente'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O cliente precisa pagar antes de retirar o veículo.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Total: ', style: theme.textTheme.titleMedium),
                  Text(
                    'R\$ ${booking.totalPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Selecione a forma de pagamento:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.money, size: 18),
            label: const Text('Dinheiro'),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(ctx);
              _markAsPaid(booking, BookingPaymentStatus.cash, 'cash');
              _releaseVehicle(booking);
            },
          ),
          FilledButton.icon(
            icon: const Icon(Icons.qr_code, size: 18),
            label: const Text('PIX'),
            style: FilledButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              Navigator.pop(ctx);
              _markAsPaid(booking, BookingPaymentStatus.pix, 'pix');
              _releaseVehicle(booking);
            },
          ),
          FilledButton.icon(
            icon: const Icon(Icons.credit_card, size: 18),
            label: const Text('Cartão'),
            style: FilledButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () {
              Navigator.pop(ctx);
              _markAsPaid(booking, BookingPaymentStatus.paid, 'card');
              _releaseVehicle(booking);
            },
          ),
        ],
      ),
    );
  }

  /// Build subscriber badge widget
  Widget _buildSubscriberBadge(String userId) {
    if (userId == 'guest') return const SizedBox.shrink();

    final subscriptionAsync = ref.watch(subscriptionByUserIdProvider(userId));

    return subscriptionAsync.when(
      data: (subscription) {
        if (subscription == null || !subscription.isActive) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade600, Colors.orange.shade400],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, size: 14, color: Colors.white),
              SizedBox(width: 4),
              Text(
                'ASSINANTE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
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
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  'Agendamento #${booking.id.substring(0, 5)}',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(width: 8),
                                _buildSubscriberBadge(booking.userId),
                              ],
                            ),
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
                          child: AppLoader(size: 20),
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
                        onPhotoAdded: (bytes, filename) =>
                            _handlePhotoUpload(bytes, filename, booking, true),
                        onPhotoRemoved: (url) =>
                            _handlePhotoRemove(url, booking, true),
                        isReadOnly: booking.status == BookingStatus.finished,
                      ),
                      const Divider(height: 32),
                      PhotoUploadWidget(
                        label: 'Depois da Lavagem',
                        photoUrls: booking.afterPhotos,
                        onPhotoAdded: (bytes, filename) =>
                            _handlePhotoUpload(bytes, filename, booking, false),
                        onPhotoRemoved: (url) =>
                            _handlePhotoRemove(url, booking, false),
                        isReadOnly: booking.status == BookingStatus.finished,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Payment Section
                _buildPaymentSection(theme, booking),
                const SizedBox(height: 24),

                // Quick Status Buttons
                if (booking.status != BookingStatus.finished &&
                    booking.status != BookingStatus.cancelled) ...[
                  Text(
                    'Progresso do Serviço',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatusProgressRow(theme, booking),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: _getNextActionLabel(booking.status),
                    isLoading: _isLoading,
                    onPressed: () =>
                        _updateStatus(booking, _getNextStatus(booking.status)),
                  ),
                ],
                if (booking.status == BookingStatus.finished) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Serviço Concluído! ✨',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Release Vehicle Button
                  FilledButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _releaseVehicle(booking),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.directions_car),
                    label: Text(
                      booking.paymentStatus == BookingPaymentStatus.pending
                          ? '💳 Cobrar e Liberar Veículo'
                          : '✅ Liberar Veículo',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          booking.paymentStatus == BookingPaymentStatus.pending
                          ? Colors.orange
                          : Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: AppLoader()),
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
        return 'Iniciar Secagem';
      case BookingStatus.drying:
        return 'Iniciar Polimento';
      case BookingStatus.polishing:
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
        return BookingStatus.drying;
      case BookingStatus.drying:
        return BookingStatus.polishing;
      case BookingStatus.polishing:
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

  Widget _buildStatusProgressRow(ThemeData theme, Booking booking) {
    final stages = [
      ('Check-in', BookingStatus.checkIn, '🚗'),
      ('Lavagem', BookingStatus.washing, '🚿'),
      ('Aspiração', BookingStatus.vacuuming, '🧹'),
      ('Secagem', BookingStatus.drying, '💨'),
      ('Polimento', BookingStatus.polishing, '✨'),
    ];

    int currentIndex = stages.indexWhere((s) => s.$2 == booking.status);
    if (currentIndex == -1) currentIndex = -1; // Before check-in

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < stages.length; i++) ...[
            _buildStageChip(
              theme,
              stages[i].$1,
              stages[i].$3,
              isActive: i == currentIndex,
              isCompleted: i < currentIndex,
              // Allow free selection of any stage (not the current one)
              onTap: i != currentIndex
                  ? () => _updateStatus(booking, stages[i].$2)
                  : null,
            ),
            if (i < stages.length - 1)
              Container(
                width: 20,
                height: 2,
                color: i < currentIndex
                    ? Colors.green
                    : theme.colorScheme.outlineVariant,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStageChip(
    ThemeData theme,
    String label,
    String emoji, {
    bool isActive = false,
    bool isCompleted = false,
    VoidCallback? onTap,
  }) {
    final color = isCompleted
        ? Colors.green
        : isActive
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primaryContainer
              : isCompleted
              ? Colors.green.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: isActive ? 2 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isCompleted
                    ? Colors.green
                    : isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (isCompleted) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check, size: 14, color: Colors.green),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds payment section with status and quick action buttons
  Widget _buildPaymentSection(ThemeData theme, Booking booking) {
    final isPending = booking.paymentStatus == BookingPaymentStatus.pending;
    final isSubscription =
        booking.paymentStatus == BookingPaymentStatus.subscription;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pagamento',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Payment status card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isPending
                ? Colors.red.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPending
                  ? Colors.red.withOpacity(0.3)
                  : Colors.green.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isPending ? Icons.pending : Icons.check_circle,
                color: isPending ? Colors.red : Colors.green,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPending
                          ? 'Pagamento Pendente'
                          : isSubscription
                          ? 'Coberto pelo Plano'
                          : 'Pagamento Confirmado',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isPending ? Colors.red : Colors.green,
                      ),
                    ),
                    if (isPending)
                      Text(
                        'R\$ ${booking.totalPrice.toStringAsFixed(2)}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    if (booking.paymentMethod != null)
                      Text(
                        'Via ${booking.paymentMethod!.toUpperCase()}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Quick payment actions
        if (isPending) ...[
          const SizedBox(height: 16),
          Text(
            'Marcar como pago:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPaymentButton(
                theme,
                'Dinheiro',
                Icons.money,
                Colors.green,
                () => _markAsPaid(booking, BookingPaymentStatus.cash, 'cash'),
              ),
              _buildPaymentButton(
                theme,
                'PIX',
                Icons.qr_code,
                Colors.teal,
                () => _markAsPaid(booking, BookingPaymentStatus.pix, 'pix'),
              ),
              _buildPaymentButton(
                theme,
                'Cartão',
                Icons.credit_card,
                Colors.blue,
                () => _markAsPaid(booking, BookingPaymentStatus.paid, 'card'),
              ),
              _buildPaymentButton(
                theme,
                'Assinante',
                Icons.star,
                Colors.amber,
                () => _markAsPaid(
                  booking,
                  BookingPaymentStatus.subscription,
                  'subscription',
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentButton(
    ThemeData theme,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _markAsPaid(
    Booking booking,
    BookingPaymentStatus status,
    String method,
  ) async {
    try {
      await ref
          .read(bookingRepositoryProvider)
          .updatePaymentStatus(booking.id, status, paymentMethod: method);
      if (mounted) {
        AppToast.success(context, message: 'Pagamento registrado!');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro: $e');
      }
    }
  }
}
