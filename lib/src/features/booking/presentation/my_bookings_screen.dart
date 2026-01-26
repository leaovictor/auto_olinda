import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../features/booking/domain/booking.dart';
import '../../auth/data/auth_repository.dart';
import '../../booking/data/booking_repository.dart';
import '../../subscription/data/subscription_repository.dart';
import '../../../common_widgets/molecules/full_screen_loader.dart';
import '../../../common_widgets/molecules/app_refresh_indicator.dart';
import '../../../shared/utils/app_toast.dart';
import '../../../shared/utils/cancellation_warning_helper.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  // Filters
  String _selectedCategory = 'Lavagem'; // 'Lavagem' or 'Estética'
  Set<BookingStatus>? _selectedStatuses; // null = "Todos"
  String _currentFilterLabel = 'Todos'; // To track the active chip visually

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateChangesProvider).value;
    final bookingsAsync = user != null
        ? ref.watch(userBookingsProvider(user.uid))
        : const AsyncValue.data(<Booking>[]);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      body: Column(
        children: [
          // 1. Custom Header & Filters
          _buildHeader(context),

          // 2. Category Tabs (Lavagem / Estética)
          _buildCategoryTabs(context),

          // 3. Bookings List
          Expanded(
            child: AppRefreshIndicator(
              onRefresh: () async {
                if (user != null) {
                  ref.invalidate(userBookingsProvider(user.uid));
                }
                ref.invalidate(userSubscriptionProvider);
                await Future.delayed(const Duration(seconds: 1));
              },
              child: bookingsAsync.when(
                data: (bookings) {
                  // Apply Category Filter
                  // Logic: 'Estética' if category matches or title implies aesthetic
                  // 'Lavagem' is default
                  var filteredBookings = bookings.where((b) {
                    // For now, since we might not have 'category' hydrated in all services yet,
                    // we might need to rely on future implementation or simplified check.
                    // We'll filter when we render the items or if we had access to service data here.
                    // Since we can't easily filter by Service Category here without async fetch,
                    // We will fetch service data inside the list builder and FILTER VISUALLY
                    // or ideally we update the repository to fetch with includes.
                    // For this UI implementation, we will pass all to list and let the list item decide
                    // OR (better) we assume all are Lavagem for now unless we can verify.
                    // *Temporary Strategy*: Show all in 'Lavagem' unless valid reason.
                    // Real implementation needs 'category' on Booking object or eager fetch.
                    return true;
                  }).toList();

                  // Apply Status Filter
                  if (_selectedStatuses != null) {
                    filteredBookings = filteredBookings
                        .where((b) => _selectedStatuses!.contains(b.status))
                        .toList();
                  }

                  // Sort Newest First by Default
                  filteredBookings.sort(
                    (a, b) => b.scheduledTime.compareTo(a.scheduledTime),
                  );

                  return _buildBookingList(context, filteredBookings);
                },
                loading: () => const FullScreenLoader(
                  message: 'Carregando agendamentos...',
                ),
                error: (err, stack) => Center(child: Text('Erro: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Dark Slate / Navy
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Back + Title + Menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    // Toggle drawer or menu
                  },
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // "Acompanhe seus serviços"
          const Text(
            'Acompanhe seus serviços',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Filters Row: [Todos] [Agendados] [Em Andamento]
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Todos',
                  icon: Icons.grid_view_rounded,
                  isActive: _currentFilterLabel == 'Todos',
                  activeColor: const Color(0xFFFFC107), // Amber/Yellow
                  activeTextColor: Colors.black,
                  onTap: () => setState(() {
                    _currentFilterLabel = 'Todos';
                    _selectedStatuses = null;
                  }),
                ),
                const SizedBox(width: 12),
                _buildFilterChip(
                  label: 'Agendados',
                  icon: Icons.access_time_filled_rounded,
                  isActive: _currentFilterLabel == 'Agendados',
                  activeColor: const Color(0xFF3B82F6), // Blue
                  onTap: () => setState(() {
                    _currentFilterLabel = 'Agendados';
                    _selectedStatuses = {
                      BookingStatus.scheduled,
                      BookingStatus.confirmed,
                    };
                  }),
                ),
                const SizedBox(width: 12),
                _buildFilterChip(
                  label: 'Em Andamento',
                  icon: Icons.sync_rounded,
                  isActive: _currentFilterLabel == 'Em Andamento',
                  activeColor: const Color(0xFF8B5CF6), // Purple
                  onTap: () => setState(() {
                    _currentFilterLabel = 'Em Andamento';
                    _selectedStatuses = {
                      BookingStatus.checkIn,
                      BookingStatus.washing,
                      BookingStatus.vacuuming,
                      BookingStatus.drying,
                      BookingStatus.polishing,
                    };
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    Color activeTextColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeColor : const Color(0xFF334155), // Slate 700
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? activeTextColor : Colors.grey[400],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeTextColor : Colors.grey[400],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(BuildContext context) {
    return Container(
      color: const Color(0xFF0F172A), // Match Header background
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC), // Body background
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Row(
          children: [
            Expanded(
              child: _buildCategoryTab(
                label: 'Lavagem',
                icon: Icons.local_car_wash,
                isSelected: _selectedCategory == 'Lavagem',
                onTap: () => setState(() => _selectedCategory = 'Lavagem'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCategoryTab(
                label: 'Estética',
                icon: Icons.auto_awesome,
                isSelected: _selectedCategory == 'Estética',
                onTap: () => setState(() => _selectedCategory = 'Estética'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFFFC107) : Colors.grey[400],
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFFC107) : Colors.grey[400],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookingList(BuildContext context, List<Booking> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Nenhum agendamento encontrado',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _BookingCard(booking: booking);
      },
    );
  }
}

class _BookingCard extends ConsumerWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat("EEEE, dd/MM/yyyy", 'pt_BR');
    final timeFormat = DateFormat("HH:mm");

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, // Card background
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top Row: Icon + Title/Date + Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Box
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE), // Light Blue
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_rounded,
                    color: Color(0xFF0284C7), // Blue
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Title and Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lavagem', // Fixed title or fetch dynamically
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(booking.scheduledTime),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Status Chip
                _buildStatusChip(booking.status),
              ],
            ),

            const SizedBox(height: 20),
            // Divider line
            Divider(color: Colors.grey[100], height: 1),
            const SizedBox(height: 16),

            // Bottom Row: Time, Price, Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Time
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeFormat.format(booking.scheduledTime),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),

                // Price
                Text(
                  'R\$ ${booking.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFFF59E0B), // Amber 500 (Golden)
                  ),
                ),

                // Action Button (Cancel/Reschedule)
                if (booking.status == BookingStatus.scheduled)
                  TextButton(
                    onPressed: () => _cancelBooking(context, ref, booking),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else if (booking.status == BookingStatus.cancelled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Cancelado',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(), // Or 'Reagendar' logic
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    String label;
    Color color;
    Color bgColor;

    switch (status) {
      case BookingStatus.scheduled:
        label = 'Agendado';
        color = const Color(0xFF0284C7); // Blue
        bgColor = const Color(0xFFE0F2FE);
        break;
      case BookingStatus.confirmed:
        label = 'Confirmado';
        color = const Color(0xFF059669); // Green
        bgColor = const Color(0xFFD1FAE5);
        break;
      case BookingStatus.cancelled:
        label = 'Cancelado';
        color = const Color(0xFFDC2626); // Red
        bgColor = const Color(0xFFFEE2E2);
        break;
      case BookingStatus.finished:
        label = 'Finalizado';
        color = const Color(0xFF059669);
        bgColor = const Color(0xFFD1FAE5);
        break;
      default:
        label = 'Em Progresso';
        color = const Color(0xFF7C3AED); // Purple
        bgColor = const Color(0xFFEDE9FE);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _cancelBooking(
    BuildContext context,
    WidgetRef ref,
    Booking booking,
  ) async {
    // Use existing cancel logic or simplified for this UI
    // Re-using helper if possible, or direct repository call
    final confirmed = await CancellationWarningHelper.showCancellationDialog(
      context: context,
      scheduledTime: booking.scheduledTime,
    );

    if (confirmed) {
      try {
        final user = ref.read(authRepositoryProvider).currentUser;
        if (user == null) return;
        await ref
            .read(bookingRepositoryProvider)
            .cancelBooking(booking.id, actorId: user.uid);
        if (context.mounted) {
          AppToast.success(
            context,
            message: 'Agendamento cancelado com sucesso.',
          );
        }
      } catch (e) {
        if (context.mounted) {
          AppToast.error(context, message: 'Erro ao cancelar: $e');
        }
      }
    }
  }
}
