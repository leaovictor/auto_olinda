import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../features/appointments/domain/booking.dart';
import '../../auth/data/auth_repository.dart';
import '../data/booking_repository.dart';
import '../../subscription_plans/data/subscription_repository.dart';
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
  // Filters: 'active', 'finished', 'cancelled'
  String _currentFilter = 'active';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateChangesProvider).value;
    final bookingsAsync = user != null
        ? ref.watch(userBookingsProvider(user.uid))
        : const AsyncValue.data(<Booking>[]);

    return Scaffold(
      backgroundColor: const Color(
        0xFF1E293B,
      ), // Slate 800 - Graphite/Dark Grey
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Modern Header
            _buildHeader(context, user?.displayName),

            const SizedBox(height: 24),

            // 2. Status Filters
            _buildFilterTabs(),

            const SizedBox(height: 16),

            // 3. Bookings List
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(
                    0xFFF1F5F9,
                  ), // Slate 100 - Light background for content
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
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
                      final filteredBookings = _filterBookings(bookings);

                      if (filteredBookings.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
                        itemCount: filteredBookings.length,
                        itemBuilder: (context, index) {
                          return _buildServiceCard(
                            context,
                            filteredBookings[index],
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: FullScreenLoader(
                        message: 'Carregando agendamentos...',
                      ),
                    ),
                    error: (err, stack) => Center(
                      child: Text(
                        'Erro ao carregar',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildHeader(BuildContext context, String? userName) {
    // Extract first name for a nicer greeting
    final firstName = userName?.split(' ').first ?? 'Cliente';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, $firstName',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Meus Agendamentos',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => context.pop(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'Ativos',
            value: 'active',
            count: 0, // In a real app we could count these
          ),
          const SizedBox(width: 12),
          _buildFilterChip(label: 'Concluídos', value: 'finished'),
          const SizedBox(width: 12),
          _buildFilterChip(label: 'Cancelados', value: 'cancelled'),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    int? count,
  }) {
    final isSelected = _currentFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _currentFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF38BDF8)
              : Colors.white.withValues(alpha: 0.05), // Sky 400 or transparent
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF38BDF8)
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, Booking booking) {
    final dateFormat = DateFormat("dd/MM · HH:mm", 'pt_BR');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF64748B,
            ).withValues(alpha: 0.08), // Slate 500 shadow
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _showBookingDetails(context, booking),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9), // Slate 100
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                        ), // Slate 200
                      ),
                      child: Icon(
                        booking.status == BookingStatus.finished
                            ? Icons.check_circle_outline_rounded
                            : Icons.local_car_wash_rounded,
                        color: const Color(0xFF475569), // Slate 600
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Main Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Lavagem Completa', // Placeholder for Service Name if not in Booking
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A), // Slate 900
                                ),
                              ),
                              _buildStatusBadge(booking.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.directions_car,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'ABC-1234', // Should be dynamic booking.vehiclePlate
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF64748B), // Slate 500
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.access_time_filled,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dateFormat.format(booking.scheduledTime),
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Optional Footer / Action
                if (booking.status == BookingStatus.scheduled) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Divider(color: Colors.grey[100], height: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            // Context menu or details would go here
                            _showBookingDetails(context, booking);
                          },
                          icon: const Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                          ),
                          label: Text(
                            'Detalhes',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF475569),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case BookingStatus.scheduled:
      case BookingStatus.confirmed:
        bg = const Color(0xFFE0F2FE); // Sky 100
        text = const Color(0xFF0284C7); // Sky 600
        label = 'Agendado';
        break;
      case BookingStatus.checkIn:
      case BookingStatus.washing:
      case BookingStatus.vacuuming:
      case BookingStatus.drying:
      case BookingStatus.polishing:
        bg = const Color(0xFFFEF3C7); // Amber 100
        text = const Color(0xFFD97706); // Amber 600
        label = 'Lava Rápido'; // Or status name
        // Let's use the actual status name for "In Progress"
        if (status == BookingStatus.washing) {
          label = 'Lavando';
        } else if (status == BookingStatus.drying) {
          label = 'Secando';
        } else {
          label = 'Em Progresso';
        }
        break;
      case BookingStatus.finished:
        bg = const Color(0xFFDCFCE7); // Emerald 100
        text = const Color(0xFF059669); // Emerald 600
        label = 'Concluído';
        break;
      case BookingStatus.cancelled:
      case BookingStatus.noShow:
        bg = const Color(0xFFFEE2E2); // Red 100
        text = const Color(0xFFDC2626); // Red 600
        label = 'Cancelado';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              size: 48,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum agendamento',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Você não tem agendamentos\nnessa categoria.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.push('/booking'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B), // Slate 800
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Agendar Agora',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---

  List<Booking> _filterBookings(List<Booking> bookings) {
    // 1. Sort by Date Newest
    bookings.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

    return bookings.where((b) {
      switch (_currentFilter) {
        case 'active':
          return b.status == BookingStatus.scheduled ||
              b.status == BookingStatus.confirmed ||
              _isInProgress(b.status);
        case 'finished':
          return b.status == BookingStatus.finished;
        case 'cancelled':
          return b.status == BookingStatus.cancelled ||
              b.status == BookingStatus.noShow;
        default:
          return true;
      }
    }).toList();
  }

  bool _isInProgress(BookingStatus status) {
    return status == BookingStatus.checkIn ||
        status == BookingStatus.washing ||
        status == BookingStatus.vacuuming ||
        status == BookingStatus.drying ||
        status == BookingStatus.polishing;
  }

  void _showBookingDetails(BuildContext context, Booking booking) {
    // Simple bottom sheet for quick details or navigation
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Detalhes do Agendamento',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Actions
            if (booking.status == BookingStatus.scheduled)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _cancelBooking(context, booking);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Cancelar Agendamento'),
                ),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelBooking(BuildContext context, Booking booking) async {
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
