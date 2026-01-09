import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/system_settings_provider.dart';
import '../../../features/booking/domain/booking.dart';
import '../../../features/booking/domain/service_package.dart';
import '../../../features/profile/domain/vehicle.dart';
import '../../booking/data/booking_repository.dart';

import '../../../common_widgets/molecules/full_screen_loader.dart';
import '../../../shared/widgets/async_loader.dart';
import '../../auth/data/auth_repository.dart';

class BookingDetailScreen extends ConsumerWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingStreamProvider(bookingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acompanhar Pedido'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: bookingAsync.when(
        data: (booking) => _buildContent(context, ref, booking),
        loading: () =>
            const FullScreenLoader(message: 'Carregando detalhes...'),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Booking booking) {
    final hasPhotos =
        booking.beforePhotos.isNotEmpty || booking.afterPhotos.isNotEmpty;

    // Watch services and vehicle for invoice
    final servicesAsync = ref.watch(servicesProvider);
    final vehicleAsync = ref.watch(vehicleProvider(booking.vehicleId));
    final supportPhone = ref.watch(supportPhoneNumberProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Info
          Center(
            child: Column(
              children: [
                Text(
                  'Agendamento #${booking.id.substring(0, 6).toUpperCase()}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat(
                    "d 'de' MMMM, HH:mm",
                    'pt_BR',
                  ).format(booking.scheduledTime.toLocal()),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Invoice Section
          _buildInvoiceSection(context, booking, servicesAsync, vehicleAsync),

          const SizedBox(height: 32),

          // Horizontal Timeline Stepper
          _buildHorizontalTimeline(context, booking.status),

          // Photo Gallery (if photos exist)
          if (hasPhotos) ...[
            const SizedBox(height: 32),
            _buildPhotoGallery(context, booking),
          ],

          const SizedBox(height: 32),

          // Panic Button / Actions
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchWhatsApp(context, supportPhone),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Falar com o Lavador'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 16),

          if (booking.status == BookingStatus.scheduled ||
              booking.status == BookingStatus.confirmed)
            Center(
              child: TextButton(
                onPressed: () =>
                    _showCancelDialog(context, ref, booking, supportPhone),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Cancelar Agendamento'),
              ),
            ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInvoiceSection(
    BuildContext context,
    Booking booking,
    AsyncValue<List<ServicePackage>> servicesAsync,
    AsyncValue<Vehicle?> vehicleAsync,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Invoice Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'Resumo do Serviço',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Info
                vehicleAsync.when(
                  data: (vehicle) => vehicle != null
                      ? _buildInvoiceRow(
                          icon: Icons.directions_car,
                          label: 'Veículo',
                          value: '${vehicle.model} - ${vehicle.plate}',
                        )
                      : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const Divider(height: 24),

                // Services List
                servicesAsync.when(
                  data: (allServices) {
                    final bookedServices = allServices
                        .where((s) => booking.serviceIds.contains(s.id))
                        .toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Serviços',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...bookedServices.map(
                          (service) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: Colors.green[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          service.title,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'R\$ ${service.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (_, __) => const Text('Erro ao carregar serviços'),
                ),

                const Divider(height: 24),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'R\$ ${booking.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildInvoiceRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHorizontalTimeline(
    BuildContext context,
    BookingStatus currentStatus,
  ) {
    final steps = [
      {
        'status': BookingStatus.scheduled,
        'icon': Icons.access_time,
        'label': 'Agendado',
      },
      {
        'status': BookingStatus.confirmed,
        'icon': Icons.check_circle_outline,
        'label': 'Confirmado',
      },
      {
        'status': BookingStatus.checkIn,
        'icon': Icons.login,
        'label': 'Check-in',
      },
      {
        'status': BookingStatus.washing,
        'icon': Icons.water_drop_outlined,
        'label': 'Lavando',
      },
      {
        'status': BookingStatus.vacuuming,
        'icon': Icons.cleaning_services,
        'label': 'Aspirando',
      },
      {
        'status': BookingStatus.polishing,
        'icon': Icons.auto_awesome,
        'label': 'Polindo',
      },
      {
        'status': BookingStatus.drying,
        'icon': Icons.wb_sunny_outlined,
        'label': 'Secando',
      },
      {
        'status': BookingStatus.finished,
        'icon': Icons.done_all,
        'label': 'Pronto',
      },
    ];

    int currentIndex = steps.indexWhere((s) => s['status'] == currentStatus);

    if (currentIndex == -1 && currentStatus == BookingStatus.cancelled) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: const Column(
            children: [
              Icon(Icons.cancel, color: Colors.red, size: 48),
              SizedBox(height: 8),
              Text(
                'Agendamento Cancelado',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acompanhamento',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              final isCompleted = index <= currentIndex;
              final isCurrent = index == currentIndex;
              final isLast = index == steps.length - 1;

              return Row(
                children: [
                  // Step Circle
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[200],
                              shape: BoxShape.circle,
                              boxShadow: isCurrent
                                  ? [
                                      BoxShadow(
                                        color: Theme.of(
                                          context,
                                        ).primaryColor.withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              step['icon'] as IconData,
                              color: isCompleted
                                  ? Colors.white
                                  : Colors.grey[400],
                              size: 22,
                            ),
                          )
                          .animate(target: isCurrent ? 1 : 0)
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.15, 1.15),
                          )
                          .shimmer(
                            duration: 1500.ms,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 60,
                        child: Text(
                          step['label'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isCompleted
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isCompleted
                                ? Colors.grey[800]
                                : Colors.grey[400],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // Connecting Line
                  if (!isLast)
                    Container(
                      width: 24,
                      height: 3,
                      margin: const EdgeInsets.only(bottom: 28),
                      decoration: BoxDecoration(
                        color: index < currentIndex
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ).animate().fadeIn(delay: (50 * index).ms);
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildPhotoGallery(BuildContext context, Booking booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fotos do Serviço',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Before Photos
        if (booking.beforePhotos.isNotEmpty) ...[
          Text(
            '📷 Antes da Lavagem',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: booking.beforePhotos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _buildPhotoItem(context, booking.beforePhotos[index]);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // After Photos
        if (booking.afterPhotos.isNotEmpty) ...[
          Text(
            '✨ Depois da Lavagem',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: booking.afterPhotos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _buildPhotoItem(context, booking.afterPhotos[index]);
              },
            ),
          ),
        ],
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildPhotoItem(BuildContext context, String url) {
    return GestureDetector(
      onTap: () => _showFullScreenPhoto(context, url),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          width: 160,
          height: 120,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 160,
              height: 120,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 160,
              height: 120,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }

  void _showFullScreenPhoto(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(child: InteractiveViewer(child: Image.network(url))),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchWhatsApp(
    BuildContext context,
    String? phoneNumber,
  ) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Número de suporte não configurado.')),
      );
      return;
    }

    // Remove non-digits just in case
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    final uri = Uri.parse(
      'https://wa.me/$cleanNumber?text=Olá, preciso de ajuda com meu pedido.',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
        );
      }
    }
  }

  Future<void> _showCancelDialog(
    BuildContext context,
    WidgetRef ref,
    Booking booking,
    String? supportPhone,
  ) async {
    final now = DateTime.now();
    final difference = booking.scheduledTime.difference(now);
    final hoursUntilBooking = difference.inHours;

    // Policy: 4 hours
    // Backend blocks < 4h for clients.
    final canCancel = hoursUntilBooking >= 4;

    if (!canCancel) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cancelamento Indisponível'),
          content: Text(
            'Faltam menos de 4 horas para o seu agendamento.\n\n'
            'Para cancelar agora, por favor entre em contato diretamente com o lavador via WhatsApp.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Voltar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _launchWhatsApp(context, supportPhone);
              },
              child: const Text('Contatar Suporte'),
            ),
          ],
        ),
      );
      return;
    }

    // Normal Cancellation Flow
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Agendamento?'),
        content: const Text(
          'Tem certeza que deseja cancelar? Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sim, Cancelar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final user = ref.read(authRepositoryProvider).currentUser;
        if (user != null) {
          // Wrap the cancellation future with the AsyncLoader dialog
          await AsyncLoader.show(
            context,
            future: ref
                .read(bookingRepositoryProvider)
                .cancelBooking(booking.id, actorId: user.uid),
            message: 'Cancelando agendamento...',
          );
        }

        // Show success
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Agendamento cancelado com sucesso.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao cancelar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
