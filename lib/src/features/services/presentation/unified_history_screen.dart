import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart'; // Added Google Fonts
import 'package:flutter_animate/flutter_animate.dart';

import '../../auth/data/auth_repository.dart';
import '../../booking/data/booking_repository.dart';
import '../../booking/domain/booking.dart';
import '../../booking/presentation/providers/booking_title_provider.dart';

import '../../dashboard/presentation/shell/client_shell.dart';
import '../data/independent_service_repository.dart';
import '../domain/service_booking.dart';
import './widgets/history_booking_card_skeleton.dart';
// import './widgets/premium_status_badge.dart'; // Replaced with internal badge
// import './constants/history_colors.dart'; // Replaced with internal colors
import '../../../shared/utils/app_toast.dart';
import '../../../shared/utils/cancellation_warning_helper.dart';

/// Unified screen showing all user's service history
/// Redesigned with Slate Theme and Material 3
class UnifiedHistoryScreen extends ConsumerStatefulWidget {
  const UnifiedHistoryScreen({super.key});

  @override
  ConsumerState<UnifiedHistoryScreen> createState() =>
      _UnifiedHistoryScreenState();
}

class _UnifiedHistoryScreenState extends ConsumerState<UnifiedHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _statusFilter = 'all'; // 'all', 'active', 'finished', 'cancelled'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final theme = Theme.of(context);
    final user = ref.watch(authStateChangesProvider).value;

    // We can count active bookings here if needed, but for now just UI

    return Scaffold(
      backgroundColor: const Color(0xFF1E293B), // Slate 800 - Graphite
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 240, // Increased for Greeting + Title
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1E293B),
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/dashboard');
                }
              },
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu, color: Colors.white),
                ),
                onPressed: () {
                  final toggle = ref.read(drawerToggleProvider);
                  toggle?.call();
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, ${user?.displayName?.split(' ').first ?? 'Cliente'}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Meus Agendamentos',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(130), // Filters + Tabs
              child: Container(
                color: const Color(0xFF1E293B),
                child: Column(
                  children: [
                    // Filter chips row
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildFilterChip('Ativos', 'active'),
                          const SizedBox(width: 12),
                          _buildFilterChip('Concluídos', 'finished'),
                          const SizedBox(width: 12),
                          _buildFilterChip('Cancelados', 'cancelled'),
                          const SizedBox(width: 12),
                          _buildFilterChip('Todos', 'all'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tab bar
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9), // Slate 100 for body start
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: const Color(0xFF0F172A),
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorWeight: 3,
                        labelColor: const Color(0xFF0F172A),
                        unselectedLabelColor: Colors.grey[500],
                        labelStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                        ),
                        tabs: const [
                          Tab(text: 'LAVAGEM'),
                          Tab(text: 'ESTÉTICA'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: Container(
          color: const Color(0xFFF1F5F9), // Slate 100
          child: TabBarView(
            controller: _tabController,
            children: [
              // Wash bookings tab
              _WashBookingsTab(userId: user?.uid, statusFilter: _statusFilter),
              // Aesthetic services tab
              _AestheticBookingsTab(
                userId: user?.uid,
                statusFilter: _statusFilter,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    // Special 'active' default behavior mapping
    // If 'active' is selected, show it

    return GestureDetector(
      onTap: () => setState(() => _statusFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
        alignment: Alignment.center,
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
}

// ============================================================================
// WASH BOOKINGS TAB
// ============================================================================

class _WashBookingsTab extends ConsumerWidget {
  final String? userId;
  final String statusFilter;

  const _WashBookingsTab({required this.userId, required this.statusFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId == null) {
      return const Center(child: Text('Faça login para ver seu histórico'));
    }

    final bookingsAsync = ref.watch(userBookingsProvider(userId!));

    return bookingsAsync.when(
      data: (bookings) {
        var filtered = _filterBookings(bookings);
        // Sort newest first
        filtered.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

        if (filtered.isEmpty) {
          return _EmptyState(
            icon: Icons.local_car_wash_rounded,
            message: 'Nenhum agendamento encontrado',
            actionLabel: 'Agendar Lavagem',
            onAction: () => context.push('/booking'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userBookingsProvider(userId!));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return _NewBookingCard(booking: filtered[index], index: index);
            },
          ),
        );
      },
      loading: () => const HistorySkeletonList(),
      error: (e, _) => Center(child: Text('Erro: $e')),
    );
  }

  List<Booking> _filterBookings(List<Booking> bookings) {
    return bookings.where((b) {
      switch (statusFilter) {
        case 'active':
          return b.status == BookingStatus.scheduled ||
              b.status == BookingStatus.confirmed ||
              b.status == BookingStatus.checkIn ||
              b.status == BookingStatus.washing ||
              b.status == BookingStatus.vacuuming ||
              b.status == BookingStatus.drying ||
              b.status == BookingStatus.polishing;
        case 'finished':
          return b.status == BookingStatus.finished;
        case 'cancelled':
          return b.status == BookingStatus.cancelled ||
              b.status == BookingStatus.noShow;
        case 'all':
        default:
          return true;
      }
    }).toList();
  }
}

// ============================================================================
// AESTHETIC BOOKINGS TAB
// ============================================================================

class _AestheticBookingsTab extends ConsumerWidget {
  final String? userId;
  final String statusFilter;

  const _AestheticBookingsTab({
    required this.userId,
    required this.statusFilter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId == null) {
      return const Center(child: Text('Faça login para ver seu histórico'));
    }

    final bookingsAsync = ref.watch(userServiceBookingsProvider(userId!));

    return bookingsAsync.when(
      data: (bookings) {
        var filtered = _filterBookings(bookings);
        filtered.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

        if (filtered.isEmpty) {
          return _EmptyState(
            icon: Icons.auto_awesome,
            message: 'Nenhum serviço de estética',
            actionLabel: 'Ver Serviços',
            onAction: () => context.push('/services'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userServiceBookingsProvider(userId!));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return _NewServiceBookingCard(
                booking: filtered[index],
                index: index,
              );
            },
          ),
        );
      },
      loading: () => const HistorySkeletonList(),
      error: (e, _) => Center(child: Text('Erro: $e')),
    );
  }

  List<ServiceBooking> _filterBookings(List<ServiceBooking> bookings) {
    return bookings.where((b) {
      switch (statusFilter) {
        case 'active':
          return b.status == ServiceBookingStatus.scheduled ||
              b.status == ServiceBookingStatus.confirmed ||
              b.status == ServiceBookingStatus.inProgress ||
              b.status == ServiceBookingStatus.pendingApproval;
        case 'finished':
          return b.status == ServiceBookingStatus.finished;
        case 'cancelled':
          return b.status == ServiceBookingStatus.cancelled ||
              b.status == ServiceBookingStatus.noShow ||
              b.status == ServiceBookingStatus.rejected;
        case 'all':
        default:
          return true;
      }
    }).toList();
  }
}

// ============================================================================
// NEW CARD DESIGNS
// ============================================================================

class _NewBookingCard extends ConsumerWidget {
  final Booking booking;
  final int index;

  const _NewBookingCard({required this.booking, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat("dd/MM · HH:mm", 'pt_BR');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.push('/booking/${booking.id}'),
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
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Icon(
                        booking.status == BookingStatus.finished
                            ? Icons.check_circle_outline_rounded
                            : Icons.local_car_wash_rounded,
                        color: const Color(0xFF475569),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ref
                                  .watch(bookingServiceTitleProvider(booking))
                                  .when(
                                    data: (title) => Text(
                                      title,
                                      style: GoogleFonts.inter(
                                        fontSize: 14, // Slightly smaller to fit
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0F172A),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    loading: () => const Text('Carregando...'),
                                    error: (_, __) => const Text('Lavagem'),
                                  ),
                              _buildStatusBadge(booking.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
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
                // Footer: Price and Action
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Divider(color: Colors.grey[100], height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'R\$ ${booking.totalPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      if (booking.status == BookingStatus.scheduled)
                        TextButton(
                          onPressed: () => _cancelBooking(context, ref),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text('Cancelar'),
                        )
                      else
                        TextButton(
                          onPressed: () =>
                              context.push('/booking/${booking.id}'),
                          child: const Text('Detalhes'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (40 * index).ms).slideY(begin: 0.1);
  }

  Widget _buildStatusBadge(BookingStatus status) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case BookingStatus.scheduled:
      case BookingStatus.confirmed:
        bg = const Color(0xFFE0F2FE);
        text = const Color(0xFF0284C7);
        label = 'Agendado';
        break;
      case BookingStatus.checkIn:
      case BookingStatus.washing:
      case BookingStatus.vacuuming:
      case BookingStatus.drying:
      case BookingStatus.polishing:
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFD97706);
        label = 'Em Progresso';
        break;
      case BookingStatus.finished:
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF059669);
        label = 'Concluído';
        break;
      case BookingStatus.cancelled:
      case BookingStatus.noShow:
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFDC2626);
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

  Future<void> _cancelBooking(BuildContext context, WidgetRef ref) async {
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
          AppToast.success(context, message: 'Cancelado com sucesso');
        }
      } catch (e) {
        if (context.mounted) AppToast.error(context, message: 'Erro: $e');
      }
    }
  }
}

class _NewServiceBookingCard extends ConsumerWidget {
  final ServiceBooking booking;
  final int index;

  const _NewServiceBookingCard({required this.booking, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat("dd/MM · HH:mm", 'pt_BR');
    final serviceAsync = ref.watch(
      independentServiceProvider(booking.serviceId),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {}, // Navigate to service detail if needed
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF), // Purple 100
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE9D5FF)),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: const Color(0xFF9333EA), // Purple 600
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              serviceAsync.when(
                                data: (s) => Text(
                                  s?.title ?? 'Estética',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                loading: () => const Text('Estética...'),
                                error: (_, __) => const Text('Estética'),
                              ),
                              _buildStatusBadge(booking.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dateFormat.format(booking.scheduledTime),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Footer
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Divider(color: Colors.grey[100], height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'R\$ ${booking.totalPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF9333EA),
                        ),
                      ),
                      if (booking.status == ServiceBookingStatus.scheduled)
                        TextButton(
                          onPressed: () => _cancelBooking(context, ref),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text('Cancelar'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (40 * index).ms).slideY(begin: 0.1);
  }

  Widget _buildStatusBadge(ServiceBookingStatus status) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case ServiceBookingStatus.pendingApproval:
        bg = const Color(0xFFFEF9C3);
        text = const Color(0xFFCA8A04);
        label = 'Aguardando';
        break;
      case ServiceBookingStatus.scheduled:
      case ServiceBookingStatus.confirmed:
        bg = const Color(0xFFE0F2FE);
        text = const Color(0xFF0284C7);
        label = 'Agendado';
        break;
      case ServiceBookingStatus.inProgress:
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFD97706);
        label = 'Em Andamento';
        break;
      case ServiceBookingStatus.finished:
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF059669);
        label = 'Concluído';
        break;
      case ServiceBookingStatus.cancelled:
      case ServiceBookingStatus.noShow:
      case ServiceBookingStatus.rejected:
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFDC2626);
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

  Future<void> _cancelBooking(BuildContext context, WidgetRef ref) async {
    final confirmed = await CancellationWarningHelper.showCancellationDialog(
      context: context,
      scheduledTime: booking.scheduledTime,
    );
    if (confirmed) {
      try {
        await ref
            .read(independentServiceRepositoryProvider)
            .cancelBooking(booking.id);
        if (context.mounted) {
          AppToast.success(context, message: 'Cancelado com sucesso');
        }
      } catch (e) {
        if (context.mounted) AppToast.error(context, message: 'Erro: $e');
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
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
            child: Icon(icon, size: 48, color: Colors.grey[300]),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              actionLabel,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
