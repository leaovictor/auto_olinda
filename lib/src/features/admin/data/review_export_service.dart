import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../booking/domain/review_tag.dart';
import 'review_analytics_repository.dart' show ReviewAnalytics, ReviewItem;

/// Service for exporting review analytics data to CSV and PDF formats
class ReviewExportService {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Generate CSV file with reviews data
  Future<String> generateCSV(
    List<ReviewItem> reviews,
    ReviewAnalytics analytics,
    Map<String, ReviewTag> tagsMap,
  ) async {
    // Headers
    final List<List<dynamic>> rows = [
      ['Data', 'Rating', 'Comentário', 'Tags', 'Resposta Admin'],
    ];

    // Data rows
    for (final review in reviews) {
      final tagLabels = review.selectedTags
          .map((tagId) => tagsMap[tagId]?.label ?? tagId)
          .join(', ');

      rows.add([
        _dateFormat.format(review.ratedAt),
        review.rating,
        review.comment ?? '',
        tagLabels,
        review.adminResponse ?? '',
      ]);
    }

    // Add analytics summary at the end
    rows.add([]);
    rows.add(['=== RESUMO ===']);
    rows.add(['Média Geral', analytics.averageRating.toStringAsFixed(2)]);
    rows.add(['Total de Avaliações', analytics.totalReviews]);
    rows.add(['NPS Score', analytics.npsScore.toStringAsFixed(0)]);
    rows.add([
      'Taxa de Resposta',
      '${analytics.responseRate.toStringAsFixed(0)}%',
    ]);
    rows.add([
      'Sentimento Positivo',
      '${analytics.positiveRate.toStringAsFixed(0)}%',
    ]);

    // Convert to CSV string
    final csvString = const ListToCsvConverter().convert(rows);

    // Save to file
    final directory = await getTemporaryDirectory();
    final fileName = 'avaliacoes_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csvString);

    return file.path;
  }

  /// Generate PDF file with reviews data
  Future<Uint8List> generatePDF(
    List<ReviewItem> reviews,
    ReviewAnalytics analytics,
    Map<String, ReviewTag> tagsMap,
  ) async {
    final pdf = pw.Document();

    // Try to load logo, fallback if not available
    pw.ImageProvider? logo;
    try {
      final logoBytes = await rootBundle.load('assets/autoolinda_logo.png');
      logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (e) {
      // Logo not available, continue without it
      logo = null;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header with logo
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Relatório de Avaliações',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Gerado em ${_dateFormat.format(DateTime.now())}',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey,
                    ),
                  ),
                ],
              ),
              if (logo != null) pw.Image(logo, width: 60, height: 60),
            ],
          ),
          pw.SizedBox(height: 24),

          // KPIs Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Resumo Geral',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildKPICard(
                      'Satisfação Geral',
                      '${analytics.averageRating.toStringAsFixed(1)}/5.0',
                    ),
                    _buildKPICard(
                      'Total de Avaliações',
                      analytics.totalReviews.toString(),
                    ),
                    _buildKPICard(
                      'NPS Score',
                      analytics.npsScore.toStringAsFixed(0),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildKPICard(
                      'Taxa de Resposta',
                      '${analytics.responseRate.toStringAsFixed(0)}%',
                    ),
                    _buildKPICard(
                      'Sentimento Positivo',
                      '${analytics.positiveRate.toStringAsFixed(0)}%',
                    ),
                    pw.SizedBox(width: 100), // Spacer
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Reviews list title
          pw.Text(
            'Avaliações Detalhadas',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),

          // Reviews table
          if (reviews.isEmpty)
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(32),
                child: pw.Text('Nenhuma avaliação encontrada'),
              ),
            )
          else
            ...reviews.map((review) => _buildReviewCard(review, tagsMap)),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildKPICard(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  pw.Widget _buildReviewCard(
    ReviewItem review,
    Map<String, ReviewTag> tagsMap,
  ) {
    final tagLabels = review.selectedTags
        .map(
          (tagId) =>
              '${tagsMap[tagId]?.emoji ?? ''} ${tagsMap[tagId]?.label ?? tagId}',
        )
        .join(', ');

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Rating and date
          pw.Row(
            children: [
              pw.Text(
                '★' * review.rating + '☆' * (5 - review.rating),
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.amber),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                _dateFormat.format(review.ratedAt),
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(review.comment!, style: const pw.TextStyle(fontSize: 10)),
          ],
          if (review.selectedTags.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Tags: $tagLabels',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
          if (review.adminResponse != null) ...[
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Resposta do Admin:',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    review.adminResponse!,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Share file using native share sheet
  Future<void> shareFile(String path, String mimeType) async {
    await Share.shareXFiles([
      XFile(path, mimeType: mimeType),
    ], text: 'Relatório de Avaliações - Auto Olinda');
  }

  /// Share PDF bytes directly
  Future<void> sharePDFBytes(Uint8List bytes) async {
    final directory = await getTemporaryDirectory();
    final fileName = 'avaliacoes_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);

    await shareFile(file.path, 'application/pdf');
  }
}
