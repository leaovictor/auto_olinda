import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../features/booking/domain/booking.dart';
import '../../booking/data/booking_repository.dart';
import '../../../common_widgets/molecules/full_screen_loader.dart';
import 'widgets/staff_booking_card_compact.dart';

/// Provider for bookings in a date range (for history)
final bookingsInRangeProvider =
    FutureProvider.family<List<Booking>, DateTimeRange>((ref, range) async {
      final repo = ref.read(bookingRepositoryProvider);
      return repo.getBookingsInRange(range.start, range.end);
    });

class StaffHistoryScreen extends ConsumerStatefulWidget {
  const StaffHistoryScreen({super.key});

  @override
  ConsumerState<StaffHistoryScreen> createState() => _StaffHistoryScreenState();
}

class _StaffHistoryScreenState extends ConsumerState<StaffHistoryScreen> {
  late DateTimeRange _selectedRange;

  @override
  void initState() {
    super.initState();
    // print('🔵 [StaffHistory] initState called');
    // Default to last 7 days
    final now = DateTime.now();
    _selectedRange = DateTimeRange(
      start: now.subtract(const Duration(days: 7)),
      end: now,
    );
    // print(
    //   '🔵 [StaffHistory] Date range: ${_selectedRange.start} to ${_selectedRange.end}',
    // );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _selectedRange,
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: Theme.of(context).colorScheme),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // print(
      //   '🔵 [StaffHistory] New date range selected: ${picked.start} to ${picked.end}',
      // );
      setState(() => _selectedRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    // print('🔵 [StaffHistory] build called');
    final theme = Theme.of(context);
    final bookingsAsync = ref.watch(bookingsInRangeProvider(_selectedRange));

    // Debug logging for bookings provider state
    bookingsAsync.when(
      data: (bookings) {
        // print('✅ [StaffHistory] Bookings loaded: ${bookings.length} items');
        // final finished = bookings
        //     .where((b) => b.status == BookingStatus.finished)
        //     .length;
        // print('   📋 Finished: $finished of ${bookings.length}');
      },
      loading: () {}, // print('⏳ [StaffHistory] Bookings loading...'),
      error: (err, stack) {
        // print('❌ [StaffHistory] Bookings ERROR: $err');
        // print('❌ [StaffHistory] Stack: $stack');
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () => _selectDateRange(context),
            tooltip: 'Selecionar período',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Range Header
          _buildDateRangeHeader(theme),

          // Bookings List
          Expanded(
            child: bookingsAsync.when(
              data: (bookings) => _buildBookingsList(context, theme, bookings),
              loading: () =>
                  const FullScreenLoader(message: 'Carregando histórico...'),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        err.toString(),
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeHeader(ThemeData theme) {
    final startStr = DateFormat("d MMM", 'pt_BR').format(_selectedRange.start);
    final endStr = DateFormat("d MMM", 'pt_BR').format(_selectedRange.end);
    final days = _selectedRange.duration.inDays + 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.date_range_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$startStr - $endStr',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$days dias',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => _selectDateRange(context),
            icon: const Icon(Icons.edit_calendar, size: 18),
            label: const Text('Alterar'),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildBookingsList(
    BuildContext context,
    ThemeData theme,
    List<Booking> bookings,
  ) {
    // Filter only finished bookings
    final finishedBookings =
        bookings.where((b) => b.status == BookingStatus.finished).toList()
          ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

    if (finishedBookings.isEmpty) {
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
                Icons.history_rounded,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nenhum serviço finalizado',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente selecionar outro período',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.6,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Calculate stats
    final totalRevenue = finishedBookings.fold<double>(
      0,
      (sum, b) => sum + b.totalPrice,
    );

    return Column(
      children: [
        // Stats summary
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.1),
                theme.colorScheme.secondary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                theme,
                Icons.check_circle_rounded,
                finishedBookings.length.toString(),
                'Serviços',
                Colors.green,
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
              _buildStatItem(
                theme,
                Icons.attach_money_rounded,
                'R\$${totalRevenue.toStringAsFixed(0)}',
                'Receita',
                Colors.purple,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

        // List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              HapticFeedback.mediumImpact();
              ref.invalidate(bookingsInRangeProvider(_selectedRange));
              await Future.delayed(const Duration(milliseconds: 300));
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: finishedBookings.length,
              itemBuilder: (context, index) {
                return StaffBookingCardCompact(
                  booking: finishedBookings[index],
                ).animate().fadeIn(delay: (30 * index).ms);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
