import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../shared/widgets/app_version_display.dart';

/// Status filter options for staff dashboard (same as admin)
enum StaffFilter {
  all,
  scheduled,
  confirmed,
  checkIn,
  washing,
  vacuuming,
  drying,
  polishing,
  finished,
  noShow,
}

class StaffDashboardScreen extends ConsumerStatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  ConsumerState<StaffDashboardScreen> createState() =>
      _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends ConsumerState<StaffDashboardScreen> {
  StaffFilter _selectedFilter = StaffFilter.all;
  int _selectedNavIndex = 0;
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    // Use a stable date (only year/month/day) to prevent infinite rebuilds
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    print('🔵 [StaffDashboard] initState - using date: $_today');
  }

  @override
  Widget build(BuildContext context) {
    // Use stable _today instead of DateTime.now() to prevent infinite provider invalidation
    final bookingsAsync = ref.watch(bookingsForDateProvider(_today));
    final statsAsync = ref.watch(staffDayStatsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Premium Header with stats
            _buildPremiumHeader(context, theme, statsAsync, isDark),

            // Filter Chips
            _buildFilterChips(theme, statsAsync),

            // Booking List
            Expanded(
              child: bookingsAsync.when(
                data: (bookings) => _buildBookingList(context, theme, bookings),
                loading: () => const Center(child: AppLoader()),
                error: (err, stack) => _buildErrorState(theme, err),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context, theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNav(context, theme),
    );
  }

  Widget _buildPremiumHeader(
    BuildContext context,
    ThemeData theme,
    AsyncValue<StaffDayStats> statsAsync,
    bool isDark,
  ) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Bom dia'
        : now.hour < 18
        ? 'Boa tarde'
        : 'Boa noite';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  theme.colorScheme.primary.withValues(alpha: 0.3),
                  theme.colorScheme.surface,
                ]
              : [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.85),
                ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Greeting + Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting 👋',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDark
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                            : Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pátio Hoje',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? theme.colorScheme.onSurface
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeaderIconButton(
                    icon: Icons.refresh,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ref.invalidate(bookingsForDateProvider(DateTime.now()));
                      ref.invalidate(staffDayStatsProvider);
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildHeaderIconButton(
                    icon: Icons.logout_rounded,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ref.read(authRepositoryProvider).signOut();
                    },
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Date and version
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(now),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.7),
                ),
              ),
              AppVersionDisplay(
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.5),
                ),
                showBuildNumber: true,
                color: isDark
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats Cards Row
          statsAsync.when(
            data: (stats) => Row(
              children: [
                _buildFloatingStatCard(
                  icon: Icons.schedule_rounded,
                  value: stats.queue.toString(),
                  label: 'Fila',
                  color: Colors.orange,
                  theme: theme,
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _buildFloatingStatCard(
                  icon: Icons.local_car_wash_rounded,
                  value: stats.inProgress.toString(),
                  label: 'Lavando',
                  color: Colors.blue,
                  theme: theme,
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _buildFloatingStatCard(
                  icon: Icons.check_circle_rounded,
                  value: stats.finished.toString(),
                  label: 'Prontos',
                  color: Colors.green,
                  theme: theme,
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _buildFloatingStatCard(
                  icon: Icons.attach_money_rounded,
                  value: 'R\$${stats.revenue.toInt()}',
                  label: 'Receita',
                  color: Colors.purple,
                  theme: theme,
                  isDark: isDark,
                  isWide: true,
                ),
              ],
            ),
            loading: () => const SizedBox(height: 72),
            error: (_, __) => const SizedBox(height: 72),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: isDark ? Colors.white70 : Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required ThemeData theme,
    required bool isDark,
    bool isWide = false,
  }) {
    return Expanded(
      flex: isWide ? 2 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? theme.colorScheme.outline.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.15),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: isWide ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: isDark ? theme.colorScheme.onSurface : Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.85),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(
    ThemeData theme,
    AsyncValue<StaffDayStats> statsAsync,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(theme, 'Todos', StaffFilter.all),
            const SizedBox(width: 8),
            _buildFilterChip(theme, 'Pendentes', StaffFilter.scheduled),
            const SizedBox(width: 8),
            _buildFilterChip(theme, 'Confirmados', StaffFilter.confirmed),
            const SizedBox(width: 8),
            _buildFilterChip(theme, 'Check-in', StaffFilter.checkIn),
            const SizedBox(width: 8),
            _buildFilterChip(theme, 'Lavando', StaffFilter.washing),
            const SizedBox(width: 8),
            _buildFilterChip(theme, 'Aspirando', StaffFilter.vacuuming),
            const SizedBox(width: 8),
            _buildFilterChip(theme, 'Secando', StaffFilter.drying),
            const SizedBox(width: 8),
            _buildFilterChip(theme, 'Polindo', StaffFilter.polishing),
            const SizedBox(width: 8),
            _buildFilterChip(theme, 'Finalizados', StaffFilter.finished),
            const SizedBox(width: 8),
            _buildFilterChip(theme, 'Não Compareceu', StaffFilter.noShow),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildFilterChip(ThemeData theme, String label, StaffFilter filter) {
    final isSelected = _selectedFilter == filter;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilter = filter);
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: isSelected
          ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
          : BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
    );
  }

  Widget _buildBookingList(
    BuildContext context,
    ThemeData theme,
    List<Booking> bookings,
  ) {
    // Filter bookings based on selected filter
    final filteredBookings = _filterBookings(bookings);

    if (filteredBookings.isEmpty) {
      return _buildEmptyState(theme);
    }

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        ref.invalidate(bookingsForDateProvider(DateTime.now()));
        ref.invalidate(staffDayStatsProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: filteredBookings.length,
        itemBuilder: (context, index) {
          return StaffBookingCardCompact(
            booking: filteredBookings[index],
          ).animate().fadeIn(delay: (30 * index).ms).slideX(begin: 0.03);
        },
      ),
    );
  }

  List<Booking> _filterBookings(List<Booking> bookings) {
    switch (_selectedFilter) {
      case StaffFilter.all:
        return bookings
            .where((b) => b.status != BookingStatus.cancelled)
            .toList()
          ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

      case StaffFilter.scheduled:
        return bookings
            .where((b) => b.status == BookingStatus.scheduled)
            .toList()
          ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

      case StaffFilter.confirmed:
        return bookings
            .where((b) => b.status == BookingStatus.confirmed)
            .toList()
          ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

      case StaffFilter.checkIn:
        return bookings.where((b) => b.status == BookingStatus.checkIn).toList()
          ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

      case StaffFilter.washing:
        return bookings.where((b) => b.status == BookingStatus.washing).toList()
          ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

      case StaffFilter.vacuuming:
        return bookings
            .where((b) => b.status == BookingStatus.vacuuming)
            .toList()
          ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

      case StaffFilter.drying:
        return bookings.where((b) => b.status == BookingStatus.drying).toList()
          ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

      case StaffFilter.polishing:
        return bookings
            .where((b) => b.status == BookingStatus.polishing)
            .toList()
          ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

      case StaffFilter.finished:
        return bookings
            .where((b) => b.status == BookingStatus.finished)
            .toList()
          ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

      case StaffFilter.noShow:
        return bookings.where((b) => b.status == BookingStatus.noShow).toList()
          ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
    }
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_rounded,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Nenhum agendamento encontrado',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Puxe para baixo para atualizar',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Ops! Algo deu errado',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              err.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.tonalIcon(
              onPressed: () {
                ref.invalidate(bookingsForDateProvider(DateTime.now()));
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.push('/staff/scan');
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.search_rounded),
        label: const Text(
          'Buscar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ).animate().scale(delay: 300.ms, duration: 200.ms);
  }

  Widget _buildBottomNav(BuildContext context, ThemeData theme) {
    return NavigationBar(
      selectedIndex: _selectedNavIndex,
      onDestinationSelected: (index) {
        HapticFeedback.selectionClick();
        setState(() => _selectedNavIndex = index);

        switch (index) {
          case 0:
            // Already on dashboard - just reset filter
            setState(() => _selectedFilter = StaffFilter.all);
            break;
          case 1:
            // History
            context.push('/staff/history');
            break;
          case 2:
            // Orders (produtos pagos)
            context.push('/staff/orders');
            break;
          case 3:
            // Profile
            context.push('/staff/profile');
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: 'Pátio',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history_rounded),
          label: 'Histórico',
        ),
        NavigationDestination(
          icon: Icon(Icons.shopping_bag_outlined),
          selectedIcon: Icon(Icons.shopping_bag_rounded),
          label: 'Pedidos',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Perfil',
        ),
      ],
    );
  }
}
