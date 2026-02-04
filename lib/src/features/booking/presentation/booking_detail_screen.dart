import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../features/booking/domain/booking.dart';
import '../../../features/booking/domain/service_package.dart';

import '../../../features/profile/domain/vehicle.dart';
import '../../booking/data/booking_repository.dart';
import '../../../common_widgets/molecules/full_screen_loader.dart';

import '../../auth/data/auth_repository.dart';
import '../../../core/providers/system_settings_provider.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  ConsumerState<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // Watch the specific booking stream
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
            onPressed: () => bookingAsync.whenData(
              (booking) => _generateAndSharePdf(context, ref, booking),
            ),
          ),
        ],
      ),
      body: bookingAsync.when(
        data: (booking) => _buildContent(context, ref, booking),
        loading: () =>
            const FullScreenLoader(message: 'Carregando detalhes...'),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
    );
  }

  Future<void> _generateAndSharePdf(
    BuildContext context,
    WidgetRef ref,
    Booking booking,
  ) async {
    try {
      // Show loading indicator
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      }

      // Fetch dependencies
      final vehicle = ref.read(vehicleProvider(booking.vehicleId)).valueOrNull;
      final allServices = ref.read(servicesProvider).valueOrNull ?? [];

      // Generate PDF
      final doc = pw.Document();

      // Load fonts if necessary or use default
      var font = await PdfGoogleFonts.interRegular();
      var boldFont = await PdfGoogleFonts.interBold();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: font, bold: boldFont),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Auto Olinda',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text(
                        'Agendamento #${booking.id.substring(0, 6).toUpperCase()}',
                        style: const pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Status & Date
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'DATA AGENDADA',
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
                            ),
                          ),
                          pw.Text(
                            DateFormat(
                              "dd/MM/yyyy 'às' HH:mm",
                              'pt_BR',
                            ).format(booking.scheduledTime),
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'STATUS',
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
                            ),
                          ),
                          pw.Text(
                            _statusToString(booking.status),
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: _statusToPdfColor(booking.status),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Vehicle Info
                if (vehicle != null) ...[
                  pw.Text(
                    'Veículo',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    '${vehicle.model} - ${vehicle.plate}',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.Divider(),
                ],

                pw.SizedBox(height: 10),

                // Services
                pw.Text(
                  'Serviços Realizados',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),

                // Build Service List
                ..._buildPdfServiceList(booking, allServices),

                pw.Divider(thickness: 2),

                pw.Divider(thickness: 2),

                // Review Section in PDF
                if (booking.isRated) ...[
                  pw.Text(
                    'Avaliação do Cliente',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    children: List.generate(
                      5,
                      (index) => pw.Text(
                        index < (booking.rating ?? 0) ? '★' : '☆',
                        style: const pw.TextStyle(
                          color: PdfColors.amber,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  if (booking.ratingComment != null) ...[
                    pw.SizedBox(height: 5),
                    pw.Text(
                      booking.ratingComment!,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ],
                  if (booking.adminResponse != null) ...[
                    pw.SizedBox(height: 10),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Resposta do Lava-jato:',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            booking.adminResponse!,
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                  pw.Divider(thickness: 1),
                ],

                // Totals
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      booking.paymentStatus == BookingPaymentStatus.subscription
                          ? 'Incluso na Assinatura'
                          : 'R\$ ${booking.totalPrice.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color:
                            booking.paymentStatus ==
                                BookingPaymentStatus.subscription
                            ? PdfColors.amber700
                            : PdfColors.black,
                      ),
                    ),
                  ],
                ),

                pw.Spacer(),

                // Footer
                pw.Center(
                  child: pw.Text(
                    'Auto Olinda - Cuidando do seu carro com excelência.',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey500,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Dismiss loading
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

      // Share
      await Printing.sharePdf(
        bytes: await doc.save(),
        filename: 'agendamento_${booking.id}.pdf',
      );
    } catch (e) {
      // Dismiss loading if active
      if (context.mounted &&
          Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao gerar PDF: $e')));
      }
    }
  }

  String _statusToString(BookingStatus status) {
    switch (status) {
      case BookingStatus.scheduled:
        return "AGENDADO";
      case BookingStatus.confirmed:
        return "CONFIRMADO";
      case BookingStatus.finished:
        return "CONCLUÍDO";
      case BookingStatus.cancelled:
        return "CANCELADO";
      default:
        return "EM ANDAMENTO";
    }
  }

  PdfColor _statusToPdfColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.scheduled:
        return PdfColors.blue700;
      case BookingStatus.finished:
        return PdfColors.green700;
      case BookingStatus.cancelled:
        return PdfColors.red700;
      default:
        return PdfColors.orange700;
    }
  }

  List<pw.Widget> _buildPdfServiceList(
    Booking booking,
    List<ServicePackage> allServices,
  ) {
    final bookedServices = <pw.Widget>[];

    // 1. Try to match IDs
    for (var id in booking.serviceIds) {
      final service = allServices.firstWhere(
        (s) => s.id == id || s.id == id.trim(), // Loose match
        orElse: () => ServicePackage(
          id: id,
          title: _mapServiceIdToName(id),
          description: "",
          price: 0,
          durationMinutes: 0,
          category: 'detailing',
        ),
      );

      bookedServices.add(
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(service.title),
              if (booking.paymentStatus != BookingPaymentStatus.subscription)
                pw.Text('R\$ ${service.price.toStringAsFixed(2)}'),
            ],
          ),
        ),
      );
    }

    if (bookedServices.isEmpty) {
      bookedServices.add(pw.Text('Nenhum serviço identificado.'));
    }

    return bookedServices;
  }

  String _mapServiceIdToName(String id) {
    if (id == 'subscription_wash') return 'Lavagem Premium';
    switch (id) {
      case 'lavagem_simples':
        return 'Lavagem Simples';
      case 'lavagem_completa':
        return 'Lavagem Completa';
      case 'polimento':
        return 'Polimento';
      case 'cristalizacao':
        return 'Cristalização';
      case 'higienizacao_interna':
        return 'Higienização Interna';
      case 'enceramento':
        return 'Enceramento';
      case 'limpeza_motor':
        return 'Limpeza de Motor';
      case 'ozonizacao':
        return 'Ozonização';
      case 'vitrificacao':
        return 'Vitrificação';
      default:
        // Capitalize first letter and replace underscores for unknown IDs
        return id
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) {
              if (word.isEmpty) return '';
              return word[0].toUpperCase() + word.substring(1);
            })
            .join(' ');
    }
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

          // Service Duration Metrics (New)
          _buildServiceMetrics(context, booking),

          // Review Section (New)
          if (booking.isRated) ...[
            const SizedBox(height: 32),
            _buildReviewSection(context, booking),
          ],

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
                    final bookedServices = <ServicePackage>[];

                    for (var id in booking.serviceIds) {
                      final found = allServices
                          .where((s) => s.id == id)
                          .firstOrNull;
                      if (found != null) {
                        bookedServices.add(found);
                      } else {
                        // Fallback for missing service
                        bookedServices.add(
                          ServicePackage(
                            id: id,
                            title: _mapServiceIdToName(id),
                            description: '',
                            price: 0,
                            durationMinutes: 0,
                            category: 'detailing',
                          ),
                        );
                      }
                    }

                    // Check if this booking is covered by subscription
                    final isIncludedInSubscription =
                        booking.paymentStatus ==
                        BookingPaymentStatus.subscription;

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
                                isIncludedInSubscription
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
                    booking.paymentStatus == BookingPaymentStatus.subscription
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
        'status': BookingStatus.drying,
        'icon': Icons.wb_sunny_outlined,
        'label': 'Secando',
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
    final confirmed = await showDialog<bool>(
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

    if (confirmed == true && context.mounted) {
      try {
        final user = ref.read(authRepositoryProvider).currentUser;
        if (user == null) return;

        await ref
            .read(bookingRepositoryProvider)
            .cancelBooking(booking.id, actorId: user.uid);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Agendamento cancelado com sucesso')),
          );
          Navigator.pop(context); // Go back
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro ao cancelar: $e')));
        }
      }
    }
  }
}

Widget _buildServiceMetrics(BuildContext context, Booking booking) {
  // 1. Find Check-in Time
  final checkInLog = booking.logs
      .where((log) => log.status == BookingStatus.checkIn)
      .firstOrNull;
  final checkInTime = checkInLog?.timestamp;

  // 2. Find Finished Time
  final finishedLog = booking.logs
      .where((log) => log.status == BookingStatus.finished)
      .firstOrNull;
  final finishedTime = finishedLog?.timestamp;

  // 3. Calculate Duration
  String? durationString;
  if (checkInTime != null && finishedTime != null) {
    final duration = finishedTime.difference(checkInTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      durationString = '${hours}h ${minutes}min';
    } else {
      durationString = '${minutes}min';
    }
  }

  // Only show if we have at least check-in info
  if (checkInTime == null) return const SizedBox.shrink();

  return Padding(
    padding: const EdgeInsets.only(top: 32),
    child: Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(Icons.timer_outlined, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              const Text(
                'Métricas do Serviço',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  context,
                  label: 'Horário Check-in',
                  value: DateFormat('HH:mm').format(checkInTime),
                  icon: Icons.login,
                ),
              ),
              if (durationString != null) ...[
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                Expanded(
                  child: _buildMetricItem(
                    context,
                    label: 'Tempo Total',
                    value: durationString,
                    icon: Icons.history,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
}

Widget _buildMetricItem(
  BuildContext context, {
  required String label,
  required String value,
  required IconData icon,
}) {
  return Column(
    children: [
      Icon(icon, color: Colors.grey[400], size: 24),
      const SizedBox(height: 8),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    ],
  );
}

Widget _buildReviewSection(BuildContext context, Booking booking) {
  return Container(
    padding: const EdgeInsets.all(20),
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
        Row(
          children: [
            Icon(Icons.star_outline, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            const Text(
              'Avaliação do Serviço',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // User Rating
        Row(
          children: List.generate(
            5,
            (index) => Icon(
              index < (booking.rating ?? 0) ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 24,
            ),
          ),
        ),
        if (booking.ratingComment != null &&
            booking.ratingComment!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            booking.ratingComment!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        // Admin Response
        if (booking.adminResponse != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.storefront,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Resposta do Lava-jato',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  booking.adminResponse!,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0);
}
