import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web/web.dart' as web;
import 'dart:js_interop';

import '../../../core/providers/system_settings_provider.dart';
import '../../../features/booking/domain/booking.dart';
import '../../../features/booking/domain/service_package.dart';
import '../../../features/profile/domain/vehicle.dart';
import '../../booking/data/booking_repository.dart';
import '../../../common_widgets/molecules/full_screen_loader.dart';
import '../../../shared/widgets/async_loader.dart';
import '../../auth/data/auth_repository.dart';
import '../../subscription/data/subscription_repository.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  ConsumerState<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  final GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final bookingAsync = ref.watch(bookingStreamProvider(widget.bookingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acompanhar Pedido'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () =>
                bookingAsync.whenData((booking) => _shareBooking(booking)),
          ),
        ],
      ),
      body: bookingAsync.when(
        data: (booking) => RepaintBoundary(
          key: _globalKey,
          child: Container(
            color: Theme.of(
              context,
            ).scaffoldBackgroundColor, // Ensure background is captured
            child: _buildContent(context, ref, booking),
          ),
        ),
        loading: () =>
            const FullScreenLoader(message: 'Carregando detalhes...'),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
    );
  }

  Future<void> _shareBooking(Booking booking) async {
    try {
      // Capture Image
      final boundary =
          _globalKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      // Use higher pixel ratio for better quality
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      if (kIsWeb) {
        // Web: Download Logic
        final blob = web.Blob(
          [pngBytes.toJS].toJS,
          web.BlobPropertyBag(type: 'image/png'),
        );
        final url = web.URL.createObjectURL(blob);
        final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
        anchor.href = url;
        anchor.download = 'status_agendamento_${booking.id}.png';
        anchor.click();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Imagem baixada com sucesso!')),
          );
        }
      } else {
        // Mobile: Share Plus Logic
        final tempDir = await getTemporaryDirectory();
        final file = await File(
          '${tempDir.path}/status_agendamento_${booking.id}.png',
        ).create();
        await file.writeAsBytes(pngBytes);

        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Acompanhe meu agendamento no Auto Olinda! 🚗✨');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao compartilhar: $e')));
      }
    }
  }

  // ... keeps existing _buildContent but make sure to update signature/usage since we changed to StatefulWidget ...
  Widget _buildContent(BuildContext context, WidgetRef ref, Booking booking) {
    // ... existing implementation ...

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

          // Service Duration Metrics (New)
          _buildServiceMetrics(context, booking),

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

                    // Check subscription status
                    final subscriptionState = ref.watch(
                      userSubscriptionProvider,
                    );
                    final isPremium =
                        subscriptionState.valueOrNull?.isActive ?? false;

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
                                isPremium
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: Colors.amber.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Incluso',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      )
                                    : Text(
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
                Consumer(
                  builder: (context, ref, child) {
                    final subscriptionState = ref.watch(
                      userSubscriptionProvider,
                    );
                    final isPremium =
                        subscriptionState.valueOrNull?.isActive ?? false;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        isPremium
                            ? Row(
                                children: [
                                  Text(
                                    'R\$ ${booking.totalPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Incluso na Assinatura',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber[700],
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'R\$ ${booking.totalPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                      ],
                    );
                  },
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
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
    // We use total Minutes for precision if needed, but rules are in hours
    final totalMinutes = difference.inMinutes;
    final hoursFloat = totalMinutes / 60.0;

    String title = 'Cancelar Agendamento?';
    String content = '';
    Color contentColor = Colors.grey[800]!;
    bool isStrikeRisk = false;

    // RULE 1: Safe (> 12h)
    if (hoursFloat >= 12) {
      content =
          'Faltam mais de 12 horas. Cancelamento seguro.\nSeu crédito será devolvido integralmente.';
    }
    // RULE 2: Warning (< 12h but > 4h)
    else if (hoursFloat >= 4) {
      title = 'Atenção: Cancelamento Tardio';
      content =
          'Faltam menos de 12 horas para o agendamento.\n\nSeu crédito de lavagem será CONSUMIDO mesmo com o cancelamento.\n\nDeseja continuar?';
      contentColor = Colors.orange[800]!;
    }
    // RULE 3: Critical (< 4h but > 2h)
    else if (hoursFloat >= 2) {
      title = 'Cancelamento Crítico!';
      content =
          'Faltam menos de 4 horas!\n\nSeu crédito será consumido e uma reincidência poderá gerar BLOQUEIO temporário da sua conta.\n\nDeseja realmente cancelar?';
      contentColor = Colors.red[700]!;
    }
    // RULE 4: Immediate / Strike (< 2h)
    else {
      title = 'RISCO DE STRIKE 🚫';
      content =
          'Faltam menos de 2 horas!\n\nSe você cancelar agora:\n1. Seu crédito será consumido.\n2. Sua conta receberá um STRIKE (bloqueio de 24h).\n\nRecomendamos manter o agendamento.';
      contentColor = Colors.red[900]!;
      isStrikeRisk = true;
    }

    // Check if it's already in the past (shouldn't happen for active bookings usually but safeguard)
    if (difference.isNegative) {
      title = 'Agendamento Vencido';
      content = 'Este agendamento já passou do horário.';
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(color: isStrikeRisk ? Colors.red : Colors.black),
        ),
        content: Text(
          content,
          style: TextStyle(color: contentColor, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Manter Agendamento'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: isStrikeRisk ? Colors.red[50] : null,
            ),
            child: Text(
              isStrikeRisk
                  ? 'Aceitar Strike e Cancelar'
                  : 'Confirmar Cancelamento',
            ),
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
            SnackBar(
              content: Text(
                isStrikeRisk
                    ? 'Cancelado. Bloqueio de 24h aplicado.'
                    : 'Agendamento cancelado com sucesso.',
              ),
              backgroundColor: isStrikeRisk ? Colors.red : null,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          // Parse error to show user friendly message
          String errorMsg = 'Erro ao cancelar: $e';
          if (e.toString().contains('failed-precondition')) {
            errorMsg = 'Erro: Regra de cancelamento não atendida.';
            if (e.toString().contains(': ')) {
              errorMsg = e.toString().split(': ').last;
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Widget _buildServiceMetrics(BuildContext context, Booking booking) {
    // Helper to convert to Brasilia Time (UTC-3)
    DateTime toBrasilia(DateTime date) {
      if (date.isUtc) {
        return date.subtract(const Duration(hours: 3));
      }
      return date; // Assuming local is already handled or we treat it as UTC if specified
    }

    // Find logs for Sort logs by timestamp just to be safe
    final sortedLogs = List<BookingLog>.from(booking.logs)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // START TIME: Find the first log that indicates service has started (washing or later)
    // We explicitly exclude scheduled, confirmed, and checkIn
    final startLog = sortedLogs.where((l) {
      return l.status == BookingStatus.washing ||
          l.status == BookingStatus.vacuuming ||
          l.status == BookingStatus.polishing ||
          l.status == BookingStatus.drying;
    }).firstOrNull;

    final endLog = sortedLogs
        .where((l) => l.status == BookingStatus.finished)
        .firstOrNull;

    final isFinished = booking.status == BookingStatus.finished;

    // Determine Start Time
    // Only set if we have an actual start log. Otherwise, it hasn't started.
    DateTime? startTime = startLog?.timestamp;

    // Determine End Time
    DateTime endTime = isFinished
        ? (endLog?.timestamp ?? DateTime.now())
        : DateTime.now();

    // Ensure valid duration
    final duration = startTime != null && endTime.isAfter(startTime)
        ? endTime.difference(startTime)
        : Duration.zero;

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final durationStr = hours > 0 ? '${hours}h ${minutes}min' : '${minutes}min';

    // Convert both to Brasilia for display
    // If startTime is null (not started), we can default to Scheduled Time for the "Início" label
    // BUT user specifically complained about "Tempo Decorrido" (Elapsed Time).
    // So for the timer logic (durationStr), we keep it 0.
    // For the UI column "Início", showing Scheduled Time is fine as "Estimate",
    // or we can show "--:--" if not started.
    // Let's show Estimated/Scheduled time in "Início" column if not started,
    // but the ELAPSED TIME (top right bubble) must be 0 if not started.

    final displayStartTime = startTime ?? booking.scheduledTime;
    final startBrasilia = toBrasilia(displayStartTime);
    final endBrasilia = toBrasilia(endTime);

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.timer_outlined, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                isFinished ? 'Tempo de Serviço' : 'Tempo Decorrido',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  durationStr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimeColumn(
                context,
                'Início',
                startBrasilia,
                Icons.play_circle_outline,
              ),
              Container(width: 1, height: 30, color: Colors.grey[300]),
              _buildTimeColumn(
                context,
                isFinished ? 'Término' : 'Agora',
                endBrasilia,
                isFinished ? Icons.check_circle_outline : Icons.access_time,
                isHighlight: !isFinished,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideX();
  }

  Widget _buildTimeColumn(
    BuildContext context,
    String label,
    DateTime time,
    IconData icon, {
    bool isHighlight = false,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isHighlight ? Colors.orange : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('HH:mm').format(time),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isHighlight ? Colors.orange : Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
