import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../features/booking/domain/booking.dart';
import '../../booking/data/booking_repository.dart';
import '../../auth/data/auth_repository.dart';
import '../../../common_widgets/atoms/app_loader.dart';
import 'widgets/staff_booking_card_compact.dart';
import '../data/staff_stats_provider.dart';
import '../../../core/services/version_service.dart';

class StaffDashboardScreen extends ConsumerStatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  ConsumerState<StaffDashboardScreen> createState() =>
      _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends ConsumerState<StaffDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(bookingsForDateProvider(DateTime.now()));
    final statsAsync = ref.watch(staffDayStatsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header with greeting and stats
            _buildHeader(context, theme, statsAsync),

            // Quick Action Buttons
            _buildQuickActions(context, theme),

            // Tab Bar
            _buildTabBar(theme),

            // Booking Lists by Tab
            Expanded(
              child: bookingsAsync.when(
                data: (bookings) => _buildTabContent(context, bookings),
                loading: () => const Center(child: AppLoader()),
                error: (err, stack) => _buildErrorState(theme, err),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, theme),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    AsyncValue<StaffDayStats> statsAsync,
  ) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Bom dia'
        : now.hour < 18
        ? 'Boa tarde'
        : 'Boa noite';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Greeting + Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pátio Hoje',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Notifications icon (placeholder for future)
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    color: Colors.white,
                    onPressed: () {
                      // TODO: Show notifications
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    color: Colors.white,
                    tooltip: 'Sair',
                    onPressed: () {
                      ref.read(authRepositoryProvider).signOut();
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Date and version
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(now),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              Text(
                'v$currentAppVersion',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats Row - 4 metrics
          statsAsync.when(
            data: (stats) => Row(
              children: [
                _buildStatCard(
                  'Fila',
                  stats.queue,
                  Colors.orange,
                  Icons.schedule,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  'Lavando',
                  stats.inProgress,
                  Colors.blue,
                  Icons.local_car_wash,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  'Prontos',
                  stats.finished,
                  Colors.green,
                  Icons.check_circle,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  'Receita',
                  stats.revenue.toInt(),
                  Colors.purple,
                  Icons.attach_money,
                  isRevenue: true,
                ),
              ],
            ),
            loading: () => const SizedBox(height: 70),
            error: (_, __) => const SizedBox(height: 70),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildStatCard(
    String label,
    int value,
    Color color,
    IconData icon, {
    bool isRevenue = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              isRevenue ? 'R\$${value}' : value.toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Primary: Search/Scan
          Expanded(
            flex: 2,
            child: Material(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => context.push('/staff/scan'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Buscar Placa',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Secondary: Manual Add
          Expanded(
            child: Material(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {
                  // TODO: Open manual check-in dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Em breve: Check-in manual')),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Icon(
                    Icons.add,
                    color: theme.colorScheme.onSecondaryContainer,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        dividerHeight: 0,
        tabs: const [
          Tab(text: 'Fila'),
          Tab(text: 'Lavando'),
          Tab(text: 'Prontos'),
        ],
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, List<Booking> bookings) {
    // Categorize bookings
    final queue = bookings.where((b) {
      return b.status == BookingStatus.scheduled ||
          b.status == BookingStatus.confirmed ||
          b.status == BookingStatus.checkIn;
    }).toList()..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    final inProgress = bookings.where((b) {
      return b.status == BookingStatus.washing ||
          b.status == BookingStatus.vacuuming ||
          b.status == BookingStatus.drying ||
          b.status == BookingStatus.polishing;
    }).toList()..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    final finished = bookings.where((b) {
      return b.status == BookingStatus.finished;
    }).toList()..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

    return TabBarView(
      controller: _tabController,
      children: [
        _buildBookingListView(
          queue,
          'Nenhum veículo na fila',
          Icons.hourglass_empty,
        ),
        _buildBookingListView(
          inProgress,
          'Nenhum veículo sendo lavado',
          Icons.local_car_wash,
        ),
        _buildBookingListView(
          finished,
          'Nenhum veículo finalizado hoje',
          Icons.check_circle_outline,
        ),
      ],
    );
  }

  Widget _buildBookingListView(
    List<Booking> bookings,
    String emptyMessage,
    IconData emptyIcon,
  ) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(bookingsForDateProvider(DateTime.now()));
        ref.invalidate(staffDayStatsProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return StaffBookingCardCompact(
            booking: bookings[index],
          ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.05);
        },
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, Object err) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text('Erro ao carregar: $err'),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () =>
                ref.invalidate(bookingsForDateProvider(DateTime.now())),
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, ThemeData theme) {
    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            // Already on dashboard
            break;
          case 1:
            // History - TODO
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Em breve: Histórico')),
            );
            break;
          case 2:
            // Reports - TODO
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Em breve: Relatórios')),
            );
            break;
          case 3:
            // Profile/Settings
            ref.read(authRepositoryProvider).signOut();
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Pátio',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: 'Histórico',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: 'Relatórios',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}
