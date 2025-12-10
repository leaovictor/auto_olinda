import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../features/booking/domain/booking.dart';
import '../../booking/data/booking_repository.dart';
import '../../auth/data/auth_repository.dart';
import '../../../common_widgets/atoms/app_loader.dart';
import 'widgets/staff_booking_card_compact.dart';
import '../data/plate_lookup_service.dart';

class StaffDashboardScreen extends ConsumerStatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  ConsumerState<StaffDashboardScreen> createState() =>
      _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends ConsumerState<StaffDashboardScreen> {
  bool _showFinished = false;

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(bookingsForDateProvider(DateTime.now()));
    final statsAsync = ref.watch(todayStatsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header with stats and logout
            _buildHeader(context, theme, statsAsync),

            // Scan/Search Button - Prominent
            _buildScanCard(context, theme),

            // Booking List
            Expanded(
              child: bookingsAsync.when(
                data: (bookings) => _buildBookingList(context, bookings),
                loading: () => const Center(child: AppLoader()),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text('Erro ao carregar: $err'),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => ref.invalidate(
                          bookingsForDateProvider(DateTime.now()),
                        ),
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    AsyncValue<TodayStats> statsAsync,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
        children: [
          // Top Row: Title + Logout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pátio',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    DateFormat('EEEE, dd/MM', 'pt_BR').format(DateTime.now()),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Sair',
                onPressed: () {
                  ref.read(authRepositoryProvider).signOut();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats Row
          statsAsync.when(
            data: (stats) => Row(
              children: [
                _buildStatPill('Fila', stats.queue, Colors.orange),
                const SizedBox(width: 12),
                _buildStatPill('Andamento', stats.inProgress, Colors.blue),
                const SizedBox(width: 12),
                _buildStatPill('Prontos', stats.finished, Colors.green),
              ],
            ),
            loading: () => const SizedBox(height: 40),
            error: (_, __) => const SizedBox(height: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanCard(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Material(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => context.push('/staff/scan'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buscar Veículo',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        'Escanear placa ou QR code',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: theme.colorScheme.onPrimaryContainer.withValues(
                    alpha: 0.5,
                  ),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingList(BuildContext context, List<Booking> bookings) {
    final theme = Theme.of(context);

    // Sort bookings by priority: In Progress > Queue > Finished
    final inProgress = bookings.where((b) {
      return b.status == BookingStatus.washing ||
          b.status == BookingStatus.vacuuming ||
          b.status == BookingStatus.drying ||
          b.status == BookingStatus.polishing;
    }).toList();

    final queue = bookings.where((b) {
      return b.status == BookingStatus.scheduled ||
          b.status == BookingStatus.confirmed ||
          b.status == BookingStatus.checkIn;
    }).toList();

    final finished = bookings.where((b) {
      return b.status == BookingStatus.finished;
    }).toList();

    // Sort by scheduled time
    inProgress.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    queue.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    finished.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

    final displayList = [...inProgress, ...queue];
    final hasFinished = finished.isNotEmpty;

    if (displayList.isEmpty && !hasFinished) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Nenhum veículo no momento',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Use o botão acima para buscar por placa',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(bookingsForDateProvider(DateTime.now()));
        ref.invalidate(todayStatsProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          // In Progress Section
          if (inProgress.isNotEmpty) ...[
            _buildSectionHeader(
              theme,
              '🔧 Em Andamento',
              inProgress.length,
              Colors.orange,
            ),
            ...inProgress.map((b) => StaffBookingCardCompact(booking: b)),
            const SizedBox(height: 16),
          ],

          // Queue Section
          if (queue.isNotEmpty) ...[
            _buildSectionHeader(theme, '📋 Na Fila', queue.length, Colors.blue),
            ...queue.map((b) => StaffBookingCardCompact(booking: b)),
            const SizedBox(height: 16),
          ],

          // Finished Section (Collapsible)
          if (hasFinished) ...[
            InkWell(
              onTap: () => setState(() => _showFinished = !_showFinished),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      _showFinished ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '✅ Finalizados (${finished.length})',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_showFinished)
              ...finished.map((b) => StaffBookingCardCompact(booking: b)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    ThemeData theme,
    String title,
    int count,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
