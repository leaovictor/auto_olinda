import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../features/booking/domain/booking.dart';
import '../../booking/data/booking_repository.dart';
import '../../auth/data/auth_repository.dart';
import '../../../common_widgets/molecules/full_screen_loader.dart';
import '../../../common_widgets/molecules/dynamic_watermark.dart';
import '../../../shared/services/screen_security_service.dart';
import 'widgets/staff_booking_card_compact.dart';
import '../data/staff_stats_provider.dart';
import '../../../shared/widgets/app_version_display.dart';
import '../../staff/data/quick_entry_repository.dart';

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

extension StaffFilterExtension on StaffFilter {
  String get label {
    switch (this) {
      case StaffFilter.all:
        return 'Todos';
      case StaffFilter.scheduled:
        return 'Pendentes';
      case StaffFilter.confirmed:
        return 'Confirmados';
      case StaffFilter.checkIn:
        return 'Check-in';
      case StaffFilter.washing:
        return 'Lavando';
      case StaffFilter.vacuuming:
        return 'Aspirando';
      case StaffFilter.drying:
        return 'Secando';
      case StaffFilter.polishing:
        return 'Polindo';
      case StaffFilter.finished:
        return 'Prontos';
      case StaffFilter.noShow:
        return 'Ausente';
    }
  }

  IconData get icon {
    switch (this) {
      case StaffFilter.all:
        return Icons.dashboard_customize_rounded;
      case StaffFilter.scheduled:
        return Icons.schedule_rounded;
      case StaffFilter.confirmed:
        return Icons.check_circle_outline_rounded;
      case StaffFilter.checkIn:
        return Icons.assignment_turned_in_rounded;
      case StaffFilter.washing:
        return Icons.local_car_wash_rounded;
      case StaffFilter.vacuuming:
        return Icons.cleaning_services_rounded;
      case StaffFilter.drying:
        return Icons.air_rounded;
      case StaffFilter.polishing:
        return Icons.auto_awesome_rounded;
      case StaffFilter.finished:
        return Icons.check_circle_rounded;
      case StaffFilter.noShow:
        return Icons.event_busy_rounded;
    }
  }
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

  Future<void> _refresh() async {
    HapticFeedback.mediumImpact();
    ref.invalidate(bookingsForDateProvider(DateTime.now()));
    ref.invalidate(staffDayStatsProvider);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    // Use stable _today instead of DateTime.now() to prevent infinite provider invalidation
    final bookingsAsync = ref.watch(bookingsForDateProvider(_today));
    final statsAsync = ref.watch(staffDayStatsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get staff user ID for watermark
    final staffUser = ref.watch(authRepositoryProvider).currentUser;
    final staffId = staffUser?.uid ?? 'staff';

    Widget content = Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            slivers: [
              // Premium Header (Collapsible)
              SliverToBoxAdapter(
                child: _buildPremiumHeader(context, theme, statsAsync, isDark),
              ),

              // Active Services (Quick Entry) & Bookings Combined
              // We removed the separate Quick Entry section to unify the list.

              // Next Arrivals Section (próximos 3 na fila)
              bookingsAsync.when(
                data: (bookings) {
                  final queue =
                      bookings
                          .where(
                            (b) =>
                                b.status == BookingStatus.scheduled ||
                                b.status == BookingStatus.confirmed,
                          )
                          .toList()
                        ..sort(
                          (a, b) => a.scheduledTime.compareTo(b.scheduledTime),
                        );
                  final nextArrivals = queue.take(3).toList();
                  if (nextArrivals.isEmpty) {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }
                  return SliverToBoxAdapter(
                    child: _buildNextArrivalsSection(theme, nextArrivals),
                  );
                },
                loading: () =>
                    const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (_, __) =>
                    const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),

              // Filter Chips
              SliverToBoxAdapter(child: _buildFilterChips(theme, statsAsync)),

              // Booking List (Merged)
              _buildMergedBookingList(context, theme, bookingsAsync, ref),

              // Bottom padding for FAB
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(context, theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNav(context, theme),
    );

    // Apply watermark (subtle, works on all platforms)
    content = DynamicWatermark(userId: staffId, opacity: 0.03, child: content);

    // Apply secure mode only on Android
    if (!kIsWeb && Platform.isAndroid) {
      content = SecureScreen(screenName: 'StaffDashboard', child: content);
    }

    return content;
  }

  // Helper to merge and build the list
  Widget _buildMergedBookingList(
    BuildContext context,
    ThemeData theme,
    AsyncValue<List<Booking>> bookingsAsync,
    WidgetRef ref,
  ) {
    return bookingsAsync.when(
      data: (bookings) {
        return _buildBookingSliver(context, theme, bookings);
      },
      loading: () => const SliverFillRemaining(
        child: FullScreenLoader(message: 'Carregando pátio...'),
      ),
      error: (err, stack) =>
          SliverFillRemaining(child: _buildErrorState(theme, err)),
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
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        color: sectionColor(isDark, theme),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                            : theme.colorScheme.primary.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pátio Hoje',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.primary,
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
                    icon: Icons.add_circle_outline_rounded,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      context.push('/staff/quick-entry'); // Verify route name
                    },
                    isDark: isDark,
                    theme: theme,
                  ),
                  const SizedBox(width: 8),
                  _buildHeaderIconButton(
                    icon: Icons.logout_rounded,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ref.read(authRepositoryProvider).signOut();
                    },
                    isDark: isDark,
                    theme: theme,
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
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              AppVersionDisplay(
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                showBuildNumber: true,
                color: isDark
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.4),
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

  Color sectionColor(bool isDark, ThemeData theme) {
    if (isDark) return theme.colorScheme.surfaceContainer;
    return Colors.white;
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required ThemeData theme,
  }) {
    return Material(
      color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : theme.colorScheme.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: isDark ? Colors.white70 : theme.colorScheme.primary,
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
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? theme.colorScheme.outline.withValues(alpha: 0.1)
                : color.withValues(alpha: 0.2),
          ),
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
                color: isDark ? theme.colorScheme.onSurface : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                    : Colors.black54,
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
          children: StaffFilter.values.map((filter) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildVisualFilterChip(theme, filter),
            );
          }).toList(),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildVisualFilterChip(ThemeData theme, StaffFilter filter) {
    final isSelected = _selectedFilter == filter;

    return FilterChip(
      avatar: Icon(
        filter.icon,
        size: 16,
        color: isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurfaceVariant,
      ),
      label: Text(filter.label),
      selected: isSelected,
      onSelected: (selected) {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilter = filter);
      },
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.5,
      ),
      selectedColor: theme.colorScheme.primary,
      checkmarkColor: theme.colorScheme.onPrimary,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
    );
  }

  Widget _buildBookingSliver(
    BuildContext context,
    ThemeData theme,
    List<Booking> bookings,
  ) {
    // Filter bookings based on selected filter
    final filteredBookings = _filterBookings(bookings);

    if (filteredBookings.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmptyState(theme),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return StaffBookingCardCompact(
            booking: filteredBookings[index],
          ).animate().fadeIn(delay: (30 * index).ms).slideX(begin: 0.03);
        }, childCount: filteredBookings.length),
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

  /// Builds a section showing the next arrivals waiting in queue
  Widget _buildNextArrivalsSection(
    ThemeData theme,
    List<Booking> nextArrivals,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.schedule, color: Colors.blue, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                'Próximas Chegadas',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Horizontal list of next arrivals
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: nextArrivals.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return _buildNextArrivalChip(
                  context,
                  theme,
                  nextArrivals[index],
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05);
  }

  Widget _buildNextArrivalChip(
    BuildContext context,
    ThemeData theme,
    Booking booking,
  ) {
    final timeUntil = booking.scheduledTime.difference(DateTime.now());
    final isLate = timeUntil.isNegative;

    return GestureDetector(
      onTap: () => context.push('/staff/booking/${booking.id}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLate
                ? Colors.orange.withOpacity(0.5)
                : theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Plate
            FutureBuilder(
              future: ref
                  .read(bookingRepositoryProvider)
                  .getVehicle(booking.vehicleId),
              builder: (context, snapshot) {
                return Text(
                  snapshot.data?.plate ?? '...',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            // Time
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLate ? Icons.warning_amber : Icons.schedule,
                  size: 12,
                  color: isLate ? Colors.orange : theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  isLate
                      ? '${timeUntil.inMinutes.abs()}min atrás'
                      : DateFormat('HH:mm').format(booking.scheduledTime),
                  style: TextStyle(
                    fontSize: 11,
                    color: isLate ? Colors.orange : theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
