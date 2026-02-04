import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/review_analytics_repository.dart';
import '../../data/review_export_service.dart';
import '../../../booking/data/review_tag_repository.dart';
import '../../../booking/data/booking_repository.dart';
import '../theme/admin_theme.dart';
import '../widgets/dashboard_stat_card.dart';

/// Dashboard de Analytics de Avaliações com foco em sentimento do cliente
class AdminReviewsAnalyticsScreen extends ConsumerStatefulWidget {
  const AdminReviewsAnalyticsScreen({super.key});

  @override
  ConsumerState<AdminReviewsAnalyticsScreen> createState() =>
      _AdminReviewsAnalyticsScreenState();
}

class _AdminReviewsAnalyticsScreenState
    extends ConsumerState<AdminReviewsAnalyticsScreen> {
  DateTimeRange? _selectedRange;
  int? _filterMinRating;
  List<String>? _filterTagIds;

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(
      reviewAnalyticsProvider((
        startDate: _selectedRange?.start,
        endDate: _selectedRange?.end,
      )),
    );

    final reviewsAsync = ref.watch(
      reviewsListProvider((
        startDate: _selectedRange?.start,
        endDate: _selectedRange?.end,
        minRating: _filterMinRating,
        tagIds: _filterTagIds,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics de Avaliações'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Gerenciar Tags',
            onPressed: () =>
                Navigator.pushNamed(context, '/admin/reviews/tags'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AdminTheme.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date range selector
              _buildDateRangeSelector(),
              const SizedBox(height: 24),

              // KPIs
              analyticsAsync.when(
                data: (analytics) => _buildKPISection(analytics),
                loading: () => _buildLoadingKPIs(),
                error: (e, s) => _buildErrorWidget('Erro ao carregar KPIs: $e'),
              ),
              const SizedBox(height: 32),

              // Charts
              analyticsAsync.when(
                data: (analytics) => _buildChartsSection(analytics),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 32),

              // Reviews list
              _buildReviewsSection(reviewsAsync),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExportDialog(analyticsAsync, reviewsAsync),
        icon: const Icon(Icons.download),
        label: const Text('Exportar'),
        backgroundColor: AdminTheme.gradientPrimary[0],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final rangeText = _selectedRange != null
        ? '${dateFormat.format(_selectedRange!.start)} - ${dateFormat.format(_selectedRange!.end)}'
        : 'Todos os períodos';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminTheme.bgCard,
        borderRadius: BorderRadius.circular(AdminTheme.radiusLG),
        border: Border.all(color: AdminTheme.borderLight),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: AdminTheme.gradientPrimary[0]),
          const SizedBox(width: 12),
          Expanded(child: Text(rangeText, style: AdminTheme.bodyLarge)),
          FilledButton.icon(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.tune, size: 18),
            label: const Text('Filtrar'),
            style: FilledButton.styleFrom(
              backgroundColor: AdminTheme.gradientPrimary[0],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: _selectedRange,
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      setState(() => _selectedRange = picked);
    }
  }

  Widget _buildKPISection(ReviewAnalytics analytics) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    final cards = [
      DashboardStatCard(
        title: '😊 Satisfação Geral',
        value: '${analytics.averageRating.toStringAsFixed(1)}/5.0',
        icon: Icons.sentiment_satisfied_alt,
        type: CardType.rating,
        animationDelay: 0,
      ),
      DashboardStatCard(
        title: '📊 Total de Avaliações',
        value: analytics.totalReviews.toString(),
        icon: Icons.rate_review,
        type: CardType.bookings,
        animationDelay: 100,
      ),
      DashboardStatCard(
        title: '🎯 NPS Score',
        value: analytics.npsScore.toStringAsFixed(0),
        icon: Icons.trending_up,
        type: analytics.npsScore >= 50 ? CardType.revenue : CardType.danger,
        animationDelay: 200,
      ),
      DashboardStatCard(
        title: '💬 Taxa de Resposta',
        value: '${analytics.responseRate.toStringAsFixed(0)}%',
        icon: Icons.question_answer,
        type: CardType.average,
        animationDelay: 300,
      ),
      DashboardStatCard(
        title: '⭐ Sentimento Positivo',
        value: '${analytics.positiveRate.toStringAsFixed(0)}%',
        icon: Icons.thumb_up,
        type: CardType.revenue,
        animationDelay: 400,
      ),
    ];

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 12),
              Expanded(child: cards[3]),
            ],
          ),
          const SizedBox(height: 12),
          cards[4],
        ],
      );
    } else {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: cards
            .map((card) => SizedBox(width: 200, child: card))
            .toList(),
      );
    }
  }

  Widget _buildLoadingKPIs() {
    return const Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }

  Widget _buildChartsSection(ReviewAnalytics analytics) {
    final monthlyTrendAsync = ref.watch(monthlyRatingsTrendProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Temporal Evolution Chart (NEW)
        monthlyTrendAsync.when(
          data: (monthlyData) {
            if (monthlyData.every((m) => m.reviewCount == 0)) {
              return const SizedBox.shrink(); // Hide if no data
            }
            return _buildChartCard(
              title: 'Evolução Temporal - Últimos 6 Meses',
              child: _buildTemporalChart(monthlyData),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 16),

        // Star distribution chart
        _buildChartCard(
          title: 'Distribuição por Estrelas',
          child: _buildStarDistributionChart(analytics.ratingDistribution),
        ),
        const SizedBox(height: 16),

        // Top tags
        if (analytics.topTags.isNotEmpty)
          _buildChartCard(
            title: 'Nuvem de Sentimento - Tags Mais Selecionadas',
            child: _buildTopTagsWidget(analytics.topTags),
          ),
      ],
    );
  }

  Widget _buildChartCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminTheme.bgCard,
        borderRadius: BorderRadius.circular(AdminTheme.radiusXL),
        border: Border.all(color: AdminTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AdminTheme.headingSmall),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildStarDistributionChart(Map<int, int> distribution) {
    final maxCount = distribution.values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxCount.toDouble() + 2,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}★', style: AdminTheme.bodySmall);
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(5, (index) {
            final stars = index + 1;
            final count = distribution[stars] ?? 0;
            return BarChartGroupData(
              x: stars,
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  color: _getStarColor(stars),
                  width: 40,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Color _getStarColor(int stars) {
    if (stars >= 4) return Colors.green;
    if (stars == 3) return Colors.orange;
    return Colors.red;
  }

  Widget _buildTemporalChart(List<MonthlyRating> monthlyData) {
    final monthNames = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < monthlyData.length) {
                    final month = monthlyData[value.toInt()].month;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        monthNames[month.month - 1],
                        style: AdminTheme.bodySmall,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: AdminTheme.bodySmall,
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: AdminTheme.borderLight),
          ),
          minY: 0,
          maxY: 5,
          lineBarsData: [
            LineChartBarData(
              spots: monthlyData.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.averageRating);
              }).toList(),
              isCurved: true,
              color: AdminTheme.gradientPrimary[0],
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AdminTheme.gradientPrimary[0],
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AdminTheme.gradientPrimary[0].withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTagsWidget(List<TagStat> tags) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AdminTheme.gradientSuccess[0].withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AdminTheme.gradientSuccess[0]),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tag.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                tag.label,
                style: AdminTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AdminTheme.gradientSuccess[0],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tag.count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewsSection(AsyncValue<List<ReviewItem>> reviewsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Avaliações Detalhadas', style: AdminTheme.headingMedium),
            const Spacer(),
            // Filter controls could go here
          ],
        ),
        const SizedBox(height: 16),
        reviewsAsync.when(
          data: (reviews) {
            if (reviews.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 64,
                        color: AdminTheme.textMuted,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma avaliação encontrada',
                        style: AdminTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                return _buildReviewCard(
                  reviews[index],
                ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.1);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => _buildErrorWidget('Erro ao carregar avaliações: $e'),
        ),
      ],
    );
  }

  Widget _buildReviewCard(ReviewItem review) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final allTagsAsync = ref.watch(allReviewTagsProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminTheme.bgCard,
        borderRadius: BorderRadius.circular(AdminTheme.radiusLG),
        border: Border.all(color: AdminTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Star rating
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < review.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
              ),
              const SizedBox(width: 12),
              Text(
                dateFormat.format(review.ratedAt),
                style: AdminTheme.bodySmall.copyWith(
                  color: AdminTheme.textMuted,
                ),
              ),
            ],
          ),

          // Comment
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(review.comment!, style: AdminTheme.bodyMedium),
          ],

          // Tags
          if (review.selectedTags.isNotEmpty) ...[
            const SizedBox(height: 12),
            allTagsAsync.when(
              data: (allTags) {
                final reviewTagsMap = {for (var tag in allTags) tag.id: tag};
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: review.selectedTags.map((tagId) {
                    final tag = reviewTagsMap[tagId];
                    if (tag == null) return const SizedBox.shrink();
                    return Chip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(tag.emoji),
                          const SizedBox(width: 6),
                          Text(tag.label, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      backgroundColor: AdminTheme.bgCanvas,
                      side: BorderSide(color: AdminTheme.borderLight),
                    );
                  }).toList(),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],

          // Admin Response Section
          if (review.adminResponse != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AdminTheme.gradientPrimary[0].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AdminTheme.gradientPrimary[0].withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        size: 16,
                        color: AdminTheme.gradientPrimary[0],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Resposta do Admin',
                        style: AdminTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AdminTheme.gradientPrimary[0],
                        ),
                      ),
                      if (review.adminResponseAt != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '• ${dateFormat.format(review.adminResponseAt!)}',
                          style: AdminTheme.bodySmall.copyWith(
                            color: AdminTheme.textMuted,
                          ),
                        ),
                      ],
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _showResponseDialog(
                          context,
                          review,
                          existingResponse: review.adminResponse,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(review.adminResponse!, style: AdminTheme.bodyMedium),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => _showResponseDialog(context, review),
                icon: const Icon(Icons.reply, size: 18),
                label: const Text('Responder'),
                style: FilledButton.styleFrom(
                  backgroundColor: AdminTheme.gradientPrimary[0],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminTheme.gradientDanger[0].withOpacity(0.1),
        borderRadius: BorderRadius.circular(AdminTheme.radiusLG),
        border: Border.all(color: AdminTheme.gradientDanger[0]),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: AdminTheme.gradientDanger[0]),
          const SizedBox(width: 16),
          Expanded(child: Text(message, style: AdminTheme.bodyMedium)),
        ],
      ),
    );
  }

  void _showResponseDialog(
    BuildContext context,
    ReviewItem review, {
    String? existingResponse,
  }) {
    final controller = TextEditingController(text: existingResponse);
    final isEditing = existingResponse != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Resposta' : 'Responder Avaliação'),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Sua resposta',
              hintText: 'Digite sua resposta para o cliente...',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final response = controller.text.trim();
              if (response.isEmpty) return;

              Navigator.pop(context);

              try {
                // TODO: Get actual admin user ID
                final adminId = 'admin-user-id';

                await ref
                    .read(bookingRepositoryProvider)
                    .updateAdminResponse(review.bookingId, response, adminId);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEditing
                            ? 'Resposta atualizada com sucesso'
                            : 'Resposta enviada com sucesso',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao salvar resposta: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(isEditing ? 'Salvar' : 'Enviar'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(
    AsyncValue<ReviewAnalytics> analyticsAsync,
    AsyncValue<List<ReviewItem>> reviewsAsync,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Relatório'),
        content: const Text('Escolha o formato de exportação:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _exportToCSV(analyticsAsync, reviewsAsync);
            },
            icon: const Icon(Icons.table_chart),
            label: const Text('CSV'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _exportToPDF(analyticsAsync, reviewsAsync);
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('PDF'),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToCSV(
    AsyncValue<ReviewAnalytics> analyticsAsync,
    AsyncValue<List<ReviewItem>> reviewsAsync,
  ) async {
    if (!analyticsAsync.hasValue || !reviewsAsync.hasValue) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aguarde o carregamento dos dados'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final analytics = analyticsAsync.value!;
    final reviews = reviewsAsync.value!;

    if (reviews.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhum dado para exportar'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      // Get tags map
      final allTagsAsync = await ref.read(allReviewTagsProvider.future);
      final tagsMap = {for (var tag in allTagsAsync) tag.id: tag};

      final exportService = ReviewExportService();
      await exportService.exportCSV(reviews, analytics, tagsMap);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV gerado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar CSV: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportToPDF(
    AsyncValue<ReviewAnalytics> analyticsAsync,
    AsyncValue<List<ReviewItem>> reviewsAsync,
  ) async {
    if (!analyticsAsync.hasValue || !reviewsAsync.hasValue) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aguarde o carregamento dos dados'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final analytics = analyticsAsync.value!;
    final reviews = reviewsAsync.value!;

    if (reviews.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhum dado para exportar'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      // Get tags map
      final allTagsAsync = await ref.read(allReviewTagsProvider.future);
      final tagsMap = {for (var tag in allTagsAsync) tag.id: tag};

      final exportService = ReviewExportService();
      await exportService.exportPDF(reviews, analytics, tagsMap);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF gerado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
