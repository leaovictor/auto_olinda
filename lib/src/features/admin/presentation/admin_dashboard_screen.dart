import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/admin_repository.dart';
import '../data/admin_metrics_provider.dart';
import '../data/subscription_metrics_provider.dart';
import '../data/analytics_repository.dart';
import '../../../features/booking/domain/booking.dart';
import '../../../common_widgets/molecules/app_refresh_indicator.dart';
import 'widgets/dashboard_stat_card.dart';
import 'widgets/dashboard_charts.dart';
import 'widgets/dashboard_transaction_list.dart';
import 'widgets/subscriber_growth_chart.dart';
import 'widgets/fcm_efficiency_card.dart';
import '../domain/booking_with_details.dart'; // ignore: unused_import
import '../../weather/presentation/weather_card.dart';
import '../../weather/data/weather_repository.dart';
import '../../notifications/data/notification_repository.dart';
import '../../../core/services/version_service.dart';
import 'shell/admin_shell.dart';
import 'theme/admin_theme.dart';
import '../../auth/data/auth_repository.dart';
import 'widgets/quick_booking_dialog.dart';

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AdminTheme.gradientPrimary[0],
              surface: AdminTheme.bgCard,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _handleSearch(String query) {
    if (query.trim().isEmpty) return;
    final platePattern = RegExp(r'^[A-Za-z]{3}[0-9][A-Za-z0-9][0-9]{2}$');
    if (platePattern.hasMatch(query.toUpperCase().replaceAll('-', ''))) {
      context.go('/admin/appointments?search=${Uri.encodeComponent(query)}');
    } else {
      context.go('/admin/customers?search=${Uri.encodeComponent(query)}');
    }
    _searchController.clear();
    setState(() => _isSearchExpanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final recentBookingsAsync = ref.watch(
      adminRecentBookingsWithDetailsProvider,
    );
    final bookingsListAsync = ref.watch(adminBookingsProvider);
    final metricsAsync = ref.watch(
      adminDashboardMetricsProvider(
        startDate: _selectedDateRange?.start,
        endDate: _selectedDateRange?.end,
      ),
    );
    final userAsync = ref.watch(currentUserProfileProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Container(
      decoration: const BoxDecoration(gradient: AdminTheme.backgroundGradient),
      child: Scaffold(
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
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Header
                _buildPremiumHeader(context, userAsync, isMobile),
                SizedBox(height: isMobile ? 24 : 32),

                // KPI Cards
                _buildKPISection(metricsAsync, isMobile, isTablet),
                SizedBox(height: isMobile ? 24 : 32),

                // Subscription Metrics Section (NEW)
                _buildSubscriptionMetricsSection(isMobile),
                SizedBox(height: isMobile ? 24 : 32),

                // Quick Actions (Mobile only)
                if (isMobile) ...[
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                ],

                // Charts Section
                _buildChartsSection(
                  context,
                  metricsAsync,
                  bookingsListAsync,
                  isMobile,
                ),
                SizedBox(height: isMobile ? 24 : 32),

                // Weather Card
                const WeatherCard(useRoundedCorners: true)
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),
                SizedBox(height: isMobile ? 24 : 32),

                // Recent Transactions List
                _buildTransactionSection(recentBookingsAsync),

                const SizedBox(height: 24),

                // Version footer
                Center(
                  child: Text(
                    'v$currentAppVersion',
                    style: AdminTheme.labelSmall.copyWith(
                      color: AdminTheme.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(
    BuildContext context,
    AsyncValue userAsync,
    bool isMobile,
  ) {
    final now = DateTime.now();
    final greeting = now.greeting;
    final userName = userAsync.valueOrNull?.displayName ?? 'Admin';
    final firstName = userName.split(' ').first;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    now.greetingIcon,
                    color: AdminTheme.gradientWarning[0],
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text('$greeting,', style: AdminTheme.bodyMedium),
                ],
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: 4),
              Text(firstName, style: AdminTheme.headingLarge)
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.1, end: 0),
            ],
          ),
        ),
        Row(
          children: [
            // Search (Desktop only)
            if (!isMobile) _buildSearchBar(context),
            if (!isMobile) const SizedBox(width: 16),
            // Notification Bell
            _buildNotificationBell(context),
            const SizedBox(width: 8),
            // Menu button (Mobile)
            if (isMobile) _buildMenuButton(),
            // New button (Desktop)
            if (!isMobile) ...[const SizedBox(width: 16), _buildNewButton()],
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isSearchExpanded ? 300 : 200,
      height: 44,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: AdminTheme.standardBlur,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AdminTheme.bgCard.withOpacity(0.8),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _isSearchExpanded
                    ? AdminTheme.gradientPrimary[0].withOpacity(0.5)
                    : AdminTheme.borderLight,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: AdminTheme.bodyMedium.copyWith(
                      color: AdminTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      hintStyle: AdminTheme.bodyMedium,
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
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AdminTheme.gradientPrimary,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildNotificationBell(BuildContext context) {
    final unreadCountAsync = ref.watch(unreadNotificationCountProvider);
    final unreadCount = unreadCountAsync.valueOrNull ?? 0;

    return GestureDetector(
      onTap: () => context.go('/admin/inbox'),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AdminTheme.bgCard.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminTheme.borderLight),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.notifications_outlined,
              color: AdminTheme.textPrimary,
              size: 22,
            ),
            if (unreadCount > 0)
              Positioned(
                right: -6,
                top: -6,
                child:
                    Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: AdminTheme.gradientDanger,
                            ),
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.1, 1.1),
                          duration: 1.seconds,
                        ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildMenuButton() {
    return GestureDetector(
      onTap: () {
        final toggle = ref.read(adminDrawerToggleProvider);
        toggle?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AdminTheme.gradientPrimary),
          borderRadius: BorderRadius.circular(12),
          boxShadow: AdminTheme.glowShadow(
            AdminTheme.gradientPrimary[0],
            intensity: 0.3,
          ),
        ),
        child: const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildNewButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AdminTheme.gradientPrimary),
        borderRadius: BorderRadius.circular(12),
        boxShadow: AdminTheme.glowShadow(
          AdminTheme.gradientPrimary[0],
          intensity: 0.3,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showQuickBookingDialog(),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: const [
                Icon(Icons.add, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Novo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  void _showQuickBookingDialog() {
    showDialog(
      context: context,
      builder: (context) => const QuickBookingDialog(),
    ).then((result) {
      if (result == true) {
        // Refresh data after successful walk-in booking
        ref.invalidate(adminBookingsWithDetailsProvider);
        ref.invalidate(adminBookingsProvider);
      }
    });
  }

  Widget _buildKPISection(
    AsyncValue metricsAsync,
    bool isMobile,
    bool isTablet,
  ) {
    return metricsAsync.when(
      data: (metrics) {
        final cards = [
          DashboardStatCard(
            title: 'Faturamento Total',
            value: NumberFormat.currency(
              symbol: 'R\$',
              decimalDigits: 0,
              locale: 'pt_BR',
            ).format(metrics.totalRevenue),
            percentageChange: metrics.revenueChangePercent,
            icon: Icons.attach_money_rounded,
            type: CardType.revenue,
            animationDelay: 0,
          ),
          DashboardStatCard(
            title: 'Agendamentos',
            value: metrics.totalBookings.toString(),
            percentageChange: metrics.bookingsChangePercent,
            icon: Icons.calendar_today_rounded,
            type: CardType.bookings,
            animationDelay: 100,
          ),
          DashboardStatCard(
            title: 'Ticket Médio',
            value: NumberFormat.currency(
              symbol: 'R\$',
              decimalDigits: 0,
              locale: 'pt_BR',
            ).format(metrics.averageTicket),
            percentageChange: metrics.ticketChangePercent,
            icon: Icons.trending_up_rounded,
            type: CardType.average,
            animationDelay: 200,
          ),
          DashboardStatCard(
            title: 'Avaliação',
            value: '${metrics.averageRating.toStringAsFixed(1)}/5.0',
            percentageChange: metrics.ratingChangePercent,
            icon: Icons.star_rounded,
            type: CardType.rating,
            animationDelay: 300,
          ),
        ];

        // Responsive grid
        if (isMobile) {
          // 2 columns on mobile
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
            ],
          );
        } else if (isTablet) {
          // 2 columns on tablet
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 16),
                  Expanded(child: cards[1]),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: cards[2]),
                  const SizedBox(width: 16),
                  Expanded(child: cards[3]),
                ],
              ),
            ],
          );
        } else {
          // 4 columns on desktop
          return Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 16),
              Expanded(child: cards[1]),
              const SizedBox(width: 16),
              Expanded(child: cards[2]),
              const SizedBox(width: 16),
              Expanded(child: cards[3]),
            ],
          );
        }
      },
      loading: () => _buildKPILoadingState(isMobile),
      error: (e, s) =>
          Center(child: Text('Erro: $e', style: AdminTheme.bodyMedium)),
    );
  }

  Widget _buildKPILoadingState(bool isMobile) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildShimmerCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildShimmerCard()),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildShimmerCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildShimmerCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildShimmerCard() {
    return Container(
          height: 140,
          decoration: BoxDecoration(
            color: AdminTheme.bgCard.withOpacity(0.5),
            borderRadius: BorderRadius.circular(AdminTheme.radiusXL),
            border: Border.all(color: AdminTheme.borderLight),
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.1));
  }

  /// Subscription Metrics Section with KPI cards, growth chart, and FCM efficiency
  Widget _buildSubscriptionMetricsSection(bool isMobile) {
    final subscriptionMetricsAsync = ref.watch(subscriptionMetricsProvider);
    final washMetricsAsync = ref.watch(washFrequencyMetricsProvider);
    final fcmMetricsAsync = ref.watch(fcmEfficiencyMetricsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AdminTheme.gradientPrimary),
                borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
              ),
              child: const Icon(
                Icons.subscriptions_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: AdminTheme.paddingMD),
            Text('Métricas de Assinatura', style: AdminTheme.headingSmall),
          ],
        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
        const SizedBox(height: AdminTheme.paddingLG),

        // Subscription KPI Cards
        subscriptionMetricsAsync.when(
          data: (metrics) {
            final cards = [
              DashboardStatCard(
                title: 'Assinantes Ativos',
                value: metrics.activeSubscribers.toString(),
                percentageChange: metrics.mrrChangePercent,
                icon: Icons.people_alt_rounded,
                type: CardType.bookings,
                animationDelay: 0,
              ),
              DashboardStatCard(
                title: 'MRR (Receita Mensal)',
                value: NumberFormat.currency(
                  symbol: 'R\$',
                  decimalDigits: 0,
                  locale: 'pt_BR',
                ).format(metrics.mrr),
                percentageChange: metrics.mrrChangePercent,
                icon: Icons.trending_up_rounded,
                type: CardType.revenue,
                animationDelay: 100,
              ),
              washMetricsAsync.when(
                data: (washMetrics) => DashboardStatCard(
                  title: 'Lavagens Hoje',
                  value: washMetrics.totalWashesToday.toString(),
                  icon: Icons.local_car_wash_rounded,
                  type: CardType.average,
                  animationDelay: 200,
                ),
                loading: () => _buildShimmerCard(),
                error: (_, __) => DashboardStatCard(
                  title: 'Lavagens Hoje',
                  value: '—',
                  icon: Icons.local_car_wash_rounded,
                  type: CardType.average,
                  animationDelay: 200,
                ),
              ),
              DashboardStatCard(
                title: 'Inadimplentes',
                value: metrics.delinquent.toString(),
                icon: Icons.warning_amber_rounded,
                type: CardType.danger,
                animationDelay: 300,
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
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 16),
                  Expanded(child: cards[1]),
                  const SizedBox(width: 16),
                  Expanded(child: cards[2]),
                  const SizedBox(width: 16),
                  Expanded(child: cards[3]),
                ],
              );
            }
          },
          loading: () => _buildKPILoadingState(isMobile),
          error: (e, _) =>
              Center(child: Text('Erro: $e', style: AdminTheme.bodyMedium)),
        ),
        const SizedBox(height: AdminTheme.paddingLG),

        // Subscriber Growth Chart & FCM Efficiency
        if (isMobile)
          Column(
            children: [
              subscriptionMetricsAsync.when(
                data: (metrics) => SubscriberGrowthChart(
                  data: metrics.growthLast6Months,
                  animationDelay: 400,
                ),
                loading: () => _buildShimmerCard(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              fcmMetricsAsync.when(
                data: (metrics) =>
                    FcmEfficiencyCard(metrics: metrics, animationDelay: 500),
                loading: () => _buildShimmerCard(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: subscriptionMetricsAsync.when(
                  data: (metrics) => SubscriberGrowthChart(
                    data: metrics.growthLast6Months,
                    animationDelay: 400,
                  ),
                  loading: () => _buildShimmerCard(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: fcmMetricsAsync.when(
                  data: (metrics) =>
                      FcmEfficiencyCard(metrics: metrics, animationDelay: 500),
                  loading: () => _buildShimmerCard(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return ClipRRect(
          borderRadius: BorderRadius.circular(AdminTheme.radiusLG),
          child: BackdropFilter(
            filter: AdminTheme.standardBlur,
            child: Container(
              padding: const EdgeInsets.all(AdminTheme.paddingMD),
              decoration: BoxDecoration(
                color: AdminTheme.bgCard.withOpacity(0.8),
                borderRadius: BorderRadius.circular(AdminTheme.radiusLG),
                border: Border.all(color: AdminTheme.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickActionItem(
                    Icons.add_circle_rounded,
                    'Novo',
                    AdminTheme.gradientPrimary,
                    _showQuickBookingDialog,
                  ),
                  _buildQuickActionItem(
                    Icons.calendar_month_rounded,
                    'Agenda',
                    AdminTheme.gradientInfo,
                    () => context.go('/admin/appointments'),
                  ),
                  _buildQuickActionItem(
                    Icons.card_membership_rounded,
                    'Assinantes',
                    AdminTheme.gradientSuccess,
                    () => context.go('/admin/subscriptions'),
                  ),
                  _buildQuickActionItem(
                    Icons.people_rounded,
                    'Clientes',
                    AdminTheme.gradientWarning,
                    () => context.go('/admin/customers'),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: 400.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildQuickActionItem(
    IconData icon,
    String label,
    List<Color> gradient,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AdminTheme.labelSmall.copyWith(
              color: AdminTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(
    BuildContext context,
    AsyncValue metricsAsync,
    AsyncValue<List<Booking>> bookingsListAsync,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Visão Geral', style: AdminTheme.headingSmall),
            GestureDetector(
              onTap: _selectDateRange,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AdminTheme.bgCard.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AdminTheme.borderLight),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: AdminTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _dateRangeLabel,
                      style: AdminTheme.labelSmall.copyWith(
                        color: AdminTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
        const SizedBox(height: 16),

        // Charts
        if (isMobile)
          // Mobile: Stack charts vertically
          Column(
            children: [
              _buildRevenueChart(metricsAsync),
              const SizedBox(height: 16),
              _buildStatusChart(bookingsListAsync),
            ],
          )
        else
          // Desktop: Side by side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildRevenueChart(metricsAsync)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatusChart(bookingsListAsync)),
            ],
          ),
      ],
    );
  }

  Widget _buildRevenueChart(AsyncValue metricsAsync) {
    return ClipRRect(
          borderRadius: BorderRadius.circular(AdminTheme.radiusXL),
          child: BackdropFilter(
            filter: AdminTheme.standardBlur,
            child: Container(
              height: 320,
              padding: const EdgeInsets.all(AdminTheme.paddingLG),
              decoration: AdminTheme.glassmorphicDecoration(),
              child: metricsAsync.when(
                data: (metrics) {
                  final List<double> monthlyRevenue = <double>[];
                  for (int i = 0; i < metrics.monthlyRevenueData.length; i++) {
                    monthlyRevenue.add(metrics.monthlyRevenueData[i].revenue);
                  }
                  double maxRevenue = 1000.0;
                  for (int i = 0; i < monthlyRevenue.length; i++) {
                    if (monthlyRevenue[i] > maxRevenue) {
                      maxRevenue = monthlyRevenue[i];
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Receita Mensal',
                            style: AdminTheme.headingSmall,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AdminTheme.gradientSuccess[0].withOpacity(
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AdminTheme.gradientSuccess[0],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Faturamento',
                                  style: AdminTheme.labelSmall.copyWith(
                                    color: AdminTheme.gradientSuccess[0],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: DashboardRevenueChart(
                          monthlyRevenue: monthlyRevenue,
                          maxRevenue: maxRevenue > 0 ? maxRevenue : 1000,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                ),
                error: (e, _) => Center(
                  child: Text('Erro: $e', style: AdminTheme.bodyMedium),
                ),
              ),
            ),
          ),
        )
        .animate(delay: 500.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatusChart(AsyncValue<List<Booking>> bookingsListAsync) {
    return ClipRRect(
          borderRadius: BorderRadius.circular(AdminTheme.radiusXL),
          child: BackdropFilter(
            filter: AdminTheme.standardBlur,
            child: Container(
              height: 320,
              padding: const EdgeInsets.all(AdminTheme.paddingLG),
              decoration: AdminTheme.glassmorphicDecoration(),
              child: Column(
                children: [
                  Text('Status', style: AdminTheme.headingSmall),
                  const SizedBox(height: 16),
                  Expanded(
                    child: bookingsListAsync.when(
                      data: (bookings) {
                        final filtered = _selectedDateRange != null
                            ? bookings.where((b) {
                                return b.scheduledTime.isAfter(
                                      _selectedDateRange!.start,
                                    ) &&
                                    b.scheduledTime.isBefore(
                                      _selectedDateRange!.end.add(
                                        const Duration(days: 1),
                                      ),
                                    );
                              }).toList()
                            : bookings;

                        final completed = filtered
                            .where((b) => b.status == BookingStatus.finished)
                            .length;
                        final pending = filtered
                            .where(
                              (b) =>
                                  b.status == BookingStatus.washing ||
                                  b.status == BookingStatus.checkIn ||
                                  b.status == BookingStatus.confirmed ||
                                  b.status == BookingStatus.scheduled,
                            )
                            .length;
                        final cancelled = filtered
                            .where((b) => b.status == BookingStatus.cancelled)
                            .length;

                        return DashboardStatusPieChart(
                          completed: completed,
                          pending: pending,
                          cancelled: cancelled,
                          total: filtered.length,
                        );
                      },
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => context.go('/admin/appointments'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AdminTheme.borderMedium),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Ver Detalhes',
                          style: AdminTheme.bodyMedium.copyWith(
                            color: AdminTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: 600.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildTransactionSection(AsyncValue bookingsAsync) {
    return ClipRRect(
          borderRadius: BorderRadius.circular(AdminTheme.radiusXL),
          child: BackdropFilter(
            filter: AdminTheme.standardBlur,
            child: Container(
              padding: const EdgeInsets.all(AdminTheme.paddingLG),
              decoration: AdminTheme.glassmorphicDecoration(),
              child: bookingsAsync.when(
                data: (bookings) => DashboardTransactionList(
                  bookings: bookings,
                  onViewAll: () => context.go('/admin/appointments'),
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Center(
                  child: Text('Erro: $e', style: AdminTheme.bodyMedium),
                ),
              ),
            ),
          ),
        )
        .animate(delay: 700.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }
}
