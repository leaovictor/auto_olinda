import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../features/booking/domain/booking.dart';
import '../../booking/data/booking_repository.dart';

import '../../../common_widgets/atoms/app_loader.dart';
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
        loading: () => const Center(child: AppLoader()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Booking booking) {
    final hasPhotos =
        booking.beforePhotos.isNotEmpty || booking.afterPhotos.isNotEmpty;

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
                  ).format(booking.scheduledTime),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Timeline Stepper
          _buildTimeline(context, booking.status),

          // Photo Gallery (if photos exist)
          if (hasPhotos) ...[
            const SizedBox(height: 40),
            _buildPhotoGallery(context, booking),
          ],

          const SizedBox(height: 40),

          // Panic Button / Actions
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchWhatsApp(),
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
                onPressed: () => _showCancelDialog(context, ref, booking),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Cancelar Agendamento'),
              ),
            ),
        ],
      ),
    );
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

  Widget _buildTimeline(BuildContext context, BookingStatus currentStatus) {
    final steps = [
      {
        'status': BookingStatus.scheduled,
        'label': 'Aguardando Confirmação',
        'icon': Icons.access_time,
      },
      {
        'status': BookingStatus.confirmed,
        'label': 'Confirmado',
        'icon': Icons.check_circle_outline,
      },
      {
        'status': BookingStatus.checkIn,
        'label': 'Check-in Realizado',
        'icon': Icons.login,
      },
      {
        'status': BookingStatus.washing,
        'label': 'Lavando',
        'icon': Icons.water_drop_outlined,
      },
      {
        'status': BookingStatus.vacuuming,
        'label': 'Aspirando Interior',
        'icon': Icons.cleaning_services,
      },
      {
        'status': BookingStatus.polishing,
        'label': 'Polindo',
        'icon': Icons.auto_awesome,
      },
      {
        'status': BookingStatus.drying,
        'label': 'Secando',
        'icon': Icons.wb_sunny_outlined,
      },
      {
        'status': BookingStatus.finished,
        'label': 'Pronto para Retirada',
        'icon': Icons.done_all,
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
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon & Line
            Column(
              children: [
                Container(
                      width: 40,
                      height: 40,
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
                        color: isCompleted ? Colors.white : Colors.grey[400],
                        size: 20,
                      ),
                    )
                    .animate(target: isCurrent ? 1 : 0)
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.1, 1.1),
                    ),
                if (!isLast)
                  Container(
                        width: 2,
                        height: 40,
                        color: index < currentIndex
                            ? Theme.of(context).primaryColor
                            : Colors.grey[200],
                      )
                      .animate(target: index < currentIndex ? 1 : 0)
                      .tint(color: Theme.of(context).primaryColor),
              ],
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Container(
                height: 40, // Align with icon
                alignment: Alignment.centerLeft,
                child: Text(
                  step['label'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isCompleted
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isCompleted ? Colors.black87 : Colors.grey[400],
                  ),
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1, end: 0);
      }),
    );
  }

  Future<void> _launchWhatsApp() async {
    const phoneNumber = '5511999999999'; // Mock
    final uri = Uri.parse(
      'https://wa.me/$phoneNumber?text=Olá, preciso de ajuda com meu pedido.',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _showCancelDialog(
    BuildContext context,
    WidgetRef ref,
    Booking booking,
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
                _launchWhatsApp();
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
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: AppLoader()),
        );

        final user = ref.read(authRepositoryProvider).currentUser;
        if (user != null) {
          await ref
              .read(bookingRepositoryProvider)
              .cancelBooking(booking.id, actorId: user.uid);
        }

        // Dismiss loading
        if (context.mounted) Navigator.pop(context);

        // Show success
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Agendamento cancelado com sucesso.')),
          );
        }
      } catch (e) {
        if (context.mounted) Navigator.pop(context); // Dismiss loading
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
