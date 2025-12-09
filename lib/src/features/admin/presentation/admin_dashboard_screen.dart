import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/admin_repository.dart';
import '../data/admin_metrics_provider.dart';
import '../../../features/booking/domain/booking.dart';
import '../../../common_widgets/molecules/app_refresh_indicator.dart';
import 'widgets/dashboard_stat_card.dart';
import 'widgets/dashboard_charts.dart';
import 'widgets/dashboard_transaction_list.dart';
import '../domain/booking_with_details.dart'; // ignore: unused_import
import '../../weather/presentation/weather_card.dart';
import '../../weather/data/weather_repository.dart';
import '../../notifications/data/notification_repository.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  DateTimeRange? _selectedDateRange;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _dateRangeLabel {
    if (_selectedDateRange == null) {
      final now = DateTime.now();
      return '${DateFormat('MMM yyyy', 'pt_BR').format(DateTime(now.year, 1))} - ${DateFormat('MMM yyyy', 'pt_BR').format(now)}';
    }
    return '${DateFormat('dd/MM/yy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yy').format(_selectedDateRange!.end)}';
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange:
          _selectedDateRange ??
          DateTimeRange(start: DateTime(now.year, now.month, 1), end: now),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _handleSearch(String query) {
    if (query.trim().isEmpty) return;

    // Check if query looks like a plate (letters + numbers pattern)
    final platePattern = RegExp(r'^[A-Za-z]{3}[0-9][A-Za-z0-9][0-9]{2}$');
    if (platePattern.hasMatch(query.toUpperCase().replaceAll('-', ''))) {
      // Navigate to appointments with plate filter
      context.go('/admin/appointments?search=${Uri.encodeComponent(query)}');
    } else {
      // Navigate to customers with search filter
      context.go('/admin/customers?search=${Uri.encodeComponent(query)}');
    }
    _searchController.clear();
    setState(() => _isSearchExpanded = false);
  }

  void _showNewMenu() {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 80, 20, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        const PopupMenuItem(
          value: 'appointment',
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 20),
              SizedBox(width: 12),
              Text('Novo Agendamento'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'service',
          child: Row(
            children: [
              Icon(Icons.cleaning_services, size: 20),
              SizedBox(width: 12),
              Text('Novo Serviço'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'notification',
          child: Row(
            children: [
              Icon(Icons.notifications, size: 20),
              SizedBox(width: 12),
              Text('Enviar Notificação'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == null) return;
      switch (value) {
        case 'appointment':
          context.go('/admin/appointments');
          break;
        case 'service':
          context.go('/admin/services/create');
          break;
        case 'notification':
          context.go('/admin/notifications');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookingsAsync = ref.watch(adminBookingsWithDetailsProvider);
    final bookingsListAsync = ref.watch(adminBookingsProvider);

    // Get real metrics using the new provider
    final metricsAsync = ref.watch(
      adminDashboardMetricsProvider(
        startDate: _selectedDateRange?.start,
        endDate: _selectedDateRange?.end,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppRefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminBookingsWithDetailsProvider);
          ref.invalidate(adminBookingsProvider);
          ref.invalidate(subscribersProvider);
          ref.invalidate(adminVehiclesProvider);
          ref.invalidate(adminDashboardMetricsProvider);
          ref.invalidate(currentWeatherProvider);
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar (Search, Profile, etc)
              _buildTopBar(context),
              const SizedBox(height: 32),

              // Dashboard Title & Date Filter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Painel de Controle",
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Visão geral e métricas do seu negócio.",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(_dateRangeLabel),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Weather Card for quick weather check
              const WeatherCard(),
              const SizedBox(height: 24),

              // KPI Cards with real metrics
              metricsAsync.when(
                data: (metrics) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        children: [
                          Expanded(
                            child: DashboardStatCard(
                              title: "Faturamento Total",
                              value: NumberFormat.currency(
                                symbol: 'R\$',
                                decimalDigits: 2,
                                locale: 'pt_BR',
                              ).format(metrics.totalRevenue),
                              percentageChange: metrics.revenueChangePercent,
                              icon: Icons.attach_money,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DashboardStatCard(
                              title: "Agendamentos Totais",
                              value: metrics.totalBookings.toString(),
                              percentageChange: metrics.bookingsChangePercent,
                              icon: Icons.calendar_today,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DashboardStatCard(
                              title: "Ticket Médio",
                              value: NumberFormat.currency(
                                symbol: 'R\$',
                                decimalDigits: 2,
                                locale: 'pt_BR',
                              ).format(metrics.averageTicket),
                              percentageChange: metrics.ticketChangePercent,
                              icon: Icons.trending_up,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Erro: $e'),
              ),

              const SizedBox(height: 32),

              // Charts Area with real data
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 400,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: metricsAsync.when(
                                  data: (metrics) {
                                    final monthlyRevenue = metrics
                                        .monthlyRevenueData
                                        .map((m) => m.revenue)
                                        .toList();
                                    final maxRevenue = monthlyRevenue.isNotEmpty
                                        ? monthlyRevenue.reduce(
                                            (a, b) => a > b ? a : b,
                                          )
                                        : 1000.0;
                                    final totalYearRevenue = monthlyRevenue
                                        .fold(0.0, (sum, r) => sum + r);

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Receita Mensal",
                                              style: theme.textTheme.titleLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            Row(
                                              children: [
                                                _buildLegendDot(
                                                  Colors.blue,
                                                  "Faturamento",
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          NumberFormat.currency(
                                            symbol: 'R\$',
                                            locale: 'pt_BR',
                                            decimalDigits: 0,
                                          ).format(totalYearRevenue),
                                          style: theme.textTheme.headlineMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Expanded(
                                          child: DashboardRevenueChart(
                                            monthlyRevenue: monthlyRevenue,
                                            maxRevenue: maxRevenue > 0
                                                ? maxRevenue
                                                : 1000,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                  loading: () => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  error: (e, _) => Text('Erro: $e'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 400,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "Status dos Agendamentos",
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 24),
                                    bookingsListAsync.when(
                                      data: (bookings) {
                                        // Filter by date range if selected
                                        final filtered =
                                            _selectedDateRange != null
                                            ? bookings.where((b) {
                                                return b.scheduledTime.isAfter(
                                                      _selectedDateRange!.start,
                                                    ) &&
                                                    b.scheduledTime.isBefore(
                                                      _selectedDateRange!.end
                                                          .add(
                                                            const Duration(
                                                              days: 1,
                                                            ),
                                                          ),
                                                    );
                                              }).toList()
                                            : bookings;

                                        final completed = filtered
                                            .where(
                                              (b) =>
                                                  b.status ==
                                                  BookingStatus.finished,
                                            )
                                            .length;
                                        final pending = filtered
                                            .where(
                                              (b) =>
                                                  b.status ==
                                                      BookingStatus.washing ||
                                                  b.status ==
                                                      BookingStatus.confirmed ||
                                                  b.status ==
                                                      BookingStatus.scheduled,
                                            )
                                            .length;
                                        final cancelled = filtered
                                            .where(
                                              (b) =>
                                                  b.status ==
                                                  BookingStatus.cancelled,
                                            )
                                            .length;
                                        return SizedBox(
                                          height: 200,
                                          child: DashboardStatusPieChart(
                                            completed: completed,
                                            pending: pending,
                                            cancelled: cancelled,
                                            total: filtered.length,
                                          ),
                                        );
                                      },
                                      loading: () => const SizedBox(),
                                      error: (_, __) => const SizedBox(),
                                    ),
                                    const Spacer(),
                                    OutlinedButton(
                                      onPressed: () {
                                        context.go('/admin/appointments');
                                      },
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(
                                          double.infinity,
                                          44,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: const Text("Ver Detalhes"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Container(
                              height: 400,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: metricsAsync.when(
                                data: (metrics) {
                                  final monthlyRevenue = metrics
                                      .monthlyRevenueData
                                      .map((m) => m.revenue)
                                      .toList();
                                  final maxRevenue = monthlyRevenue.isNotEmpty
                                      ? monthlyRevenue.reduce(
                                          (a, b) => a > b ? a : b,
                                        )
                                      : 1000.0;
                                  return DashboardRevenueChart(
                                    monthlyRevenue: monthlyRevenue,
                                    maxRevenue: maxRevenue > 0
                                        ? maxRevenue
                                        : 1000,
                                  );
                                },
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                error: (e, _) => Text('Erro: $e'),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Mobile pie chart
                            Container(
                              height: 300,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Status dos Agendamentos",
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: bookingsListAsync.when(
                                      data: (bookings) {
                                        final completed = bookings
                                            .where(
                                              (b) =>
                                                  b.status ==
                                                  BookingStatus.finished,
                                            )
                                            .length;
                                        final pending = bookings
                                            .where(
                                              (b) =>
                                                  b.status ==
                                                      BookingStatus.washing ||
                                                  b.status ==
                                                      BookingStatus.confirmed ||
                                                  b.status ==
                                                      BookingStatus.scheduled,
                                            )
                                            .length;
                                        final cancelled = bookings
                                            .where(
                                              (b) =>
                                                  b.status ==
                                                  BookingStatus.cancelled,
                                            )
                                            .length;
                                        return DashboardStatusPieChart(
                                          completed: completed,
                                          pending: pending,
                                          cancelled: cancelled,
                                          total: bookings.length,
                                        );
                                      },
                                      loading: () => const SizedBox(),
                                      error: (_, __) => const SizedBox(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                },
              ),

              const SizedBox(height: 32),

              // Transaction List
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: bookingsAsync.when(
                  data: (bookings) => DashboardTransactionList(
                    bookings: bookings,
                    onViewAll: () => context.go('/admin/appointments'),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text("Erro ao carregar agendamentos: $e"),
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Admin",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
        Row(
          children: [
            // Functional Search Bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isSearchExpanded ? 350 : 300,
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _isSearchExpanded
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[300]!,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Buscar cliente ou placa...",
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onTap: () => setState(() => _isSearchExpanded = true),
                      onSubmitted: _handleSearch,
                      onTapOutside: (_) {
                        if (_searchController.text.isEmpty) {
                          setState(() => _isSearchExpanded = false);
                        }
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _handleSearch(_searchController.text),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () => context.go('/admin/notifications'),
              icon: const Icon(Icons.mail_outline),
              tooltip: 'Mensagens',
            ),
            _buildNotificationBell(context),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: _showNewMenu,
              icon: const Icon(Icons.add),
              label: const Text("Novo"),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildNotificationBell(BuildContext context) {
    final unreadCountAsync = ref.watch(unreadNotificationCountProvider);
    final unreadCount = unreadCountAsync.valueOrNull ?? 0;

    return Stack(
      children: [
        IconButton(
          onPressed: () => context.go('/admin/notifications'),
          icon: const Icon(Icons.notifications_none),
          tooltip: 'Notificações',
        ),
        if (unreadCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
