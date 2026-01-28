import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../features/auth/data/auth_repository.dart';
import 'admin_sidebar.dart';
import '../../../../shared/widgets/app_version_display.dart';
import '../../../../common_widgets/molecules/dynamic_watermark.dart';
import '../../../../shared/services/screen_security_service.dart';
import '../../data/new_booking_notification_service.dart';
import '../../domain/new_booking_notification_data.dart';
import '../widgets/new_booking_notification_overlay.dart';

/// Provider for the admin drawer toggle callback
final adminDrawerToggleProvider = StateProvider<VoidCallback?>((ref) => null);

class AdminShell extends ConsumerStatefulWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  final GlobalKey<SliderDrawerState> _sliderKey =
      GlobalKey<SliderDrawerState>();

  // New booking notification state
  NewBookingNotificationData? _pendingNotification;

  int _getCurrentIndex(String location) {
    if (location == '/admin') return 0;
    if (location.startsWith('/admin/appointments')) return 1;
    if (location.startsWith('/admin/services')) return 2;
    if (location.startsWith('/admin/products')) return 2; // Same as services
    if (location.startsWith('/admin/independent-services')) return 3;
    if (location.startsWith('/admin/customers')) return 4;
    if (location.startsWith('/admin/calendar')) return 5;
    if (location.startsWith('/admin/reports')) return 6;
    if (location.startsWith('/admin/notifications')) return 7;
    if (location.startsWith('/admin/vehicles')) return 8;
    if (location.startsWith('/admin/subscriptions')) return 9;
    if (location.startsWith('/admin/staff')) return 10;
    if (location.startsWith('/admin/plans')) return 11;
    if (location.startsWith('/admin/settings')) return 12;
    if (location.startsWith('/admin/catalog')) return 13;
    if (location.startsWith('/admin/license')) return 14;
    if (location.startsWith('/admin/inbox')) return 15;
    if (location.startsWith('/admin/reviews')) return 16;
    if (location.startsWith('/admin/pricing')) return 17;
    return 0;
  }

  void _onNavigate(int index) {
    HapticFeedback.selectionClick();
    _sliderKey.currentState?.closeSlider();

    switch (index) {
      case 0:
        context.go('/admin');
        break;
      case 1:
        context.go('/admin/appointments');
        break;
      case 2:
        context.go('/admin/services');
        break;
      case 3:
        context.go('/admin/independent-services');
        break;
      case 4:
        context.go('/admin/customers');
        break;
      case 5:
        context.go('/admin/calendar');
        break;
      case 6:
        context.go('/admin/reports');
        break;
      case 7:
        context.go('/admin/notifications');
        break;
      case 8:
        context.go('/admin/vehicles');
        break;
      case 9:
        context.go('/admin/subscriptions');
        break;
      case 10:
        context.go('/admin/staff');
        break;
      case 11:
        context.go('/admin/plans');
        break;
      case 12:
        context.go('/admin/settings');
        break;
      case 13:
        context.go('/admin/catalog');
        break;
      case 14:
        context.go('/admin/license');
        break;
      case 15:
        context.go('/admin/inbox');
        break;
      case 16:
        context.go('/admin/reviews');
        break;
      case 17:
        context.go('/admin/pricing');
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminDrawerToggleProvider.notifier).state = _toggleDrawer;
      _initNotificationListener();
    });
  }

  void _initNotificationListener() {
    final notificationService = ref.read(
      newBookingNotificationServiceProvider.notifier,
    );

    notificationService.setOnNewBookingCallback((data) {
      if (mounted) {
        setState(() {
          _pendingNotification = data;
        });
      }
    });

    notificationService.startListening();
  }

  void _dismissNotification() {
    setState(() {
      _pendingNotification = null;
    });
  }

  void _viewNotificationDetails() {
    final notification = _pendingNotification;
    if (notification == null) return;

    _dismissNotification();

    // Navigate based on booking type
    if (notification.type == NewBookingType.carWash) {
      context.go('/admin/appointments');
    } else {
      context.go('/admin/appointments');
    }
  }

  void _toggleDrawer() {
    HapticFeedback.mediumImpact();
    _sliderKey.currentState?.toggle();
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final theme = Theme.of(context);
    final currentIndex = _getCurrentIndex(location);

    // Get admin user ID for watermark
    final adminUser = ref.watch(authRepositoryProvider).currentUser;
    final adminId = adminUser?.uid ?? 'admin';

    // Base layout content
    Widget layoutContent = LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // Desktop Layout with Sidebar
          return Scaffold(
            body: Row(
              children: [
                AdminSidebar(
                  currentIndex: currentIndex,
                  onNavigate: _onNavigate,
                  onLogout: () {
                    ref.read(authRepositoryProvider).signOut();
                  },
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF3F4F6),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          );
        } else {
          // Mobile Layout with SliderDrawer (same as client)
          return Scaffold(
            backgroundColor: const Color(0xFFF3F4F6),
            body: SliderDrawer(
              key: _sliderKey,
              appBar: const SizedBox.shrink(),
              sliderOpenSize: 280,
              animationDuration: 300,
              slideDirection: SlideDirection.rightToLeft,
              isDraggable: false,
              slider: _buildDrawerContent(theme, currentIndex),
              child: widget.child,
            ),
          );
        }
      },
    );

    // Apply watermark (subtle, works on all platforms)
    Widget content = DynamicWatermark(
      userId: adminId,
      opacity: 0.03,
      child: layoutContent,
    );

    // Apply secure mode only on Android
    if (!kIsWeb && Platform.isAndroid) {
      content = SecureScreen(screenName: 'AdminPanel', child: content);
    }

    // Wrap with Stack to show notification overlay
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        // Try to unlock audio on first interaction
        ref.read(newBookingNotificationServiceProvider.notifier).unlockAudio();
      },
      child: Stack(
        children: [
          content,
          // New booking notification overlay
          if (_pendingNotification != null)
            NewBookingNotificationOverlay(
              data: _pendingNotification!,
              onDismiss: _dismissNotification,
              onViewDetails: _viewNotificationDetails,
            ),
        ],
      ),
    );
  }

  Widget _buildDrawerContent(ThemeData theme, int currentIndex) {
    final userAsync = ref.watch(currentUserProfileProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16162A), Color(0xFF0F0F1A)],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: userAsync.when(
                data: (user) => _buildProfileHeader(theme, user),
                loading: () => _buildProfileHeaderLoading(theme),
                error: (_, __) => _buildProfileHeader(theme, null),
              ),
            ),

            Divider(color: Colors.white.withOpacity(0.2), height: 1),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildNavItem(
                    theme: theme,
                    icon: Icons.dashboard_outlined,
                    selectedIcon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    index: 0,
                    currentIndex: currentIndex,
                  ).animate().fadeIn(delay: 50.ms).slideX(begin: -0.2),
                  _buildNavItem(
                    theme: theme,
                    icon: Icons.calendar_today_outlined,
                    selectedIcon: Icons.calendar_today_rounded,
                    label: 'Agendamentos',
                    index: 1,
                    currentIndex: currentIndex,
                  ).animate().fadeIn(delay: 80.ms).slideX(begin: -0.2),
                  _buildNavItem(
                    theme: theme,
                    icon: Icons.local_car_wash_outlined,
                    selectedIcon: Icons.local_car_wash_rounded,
                    label: 'Lavagem e Produtos',
                    index: 2,
                    currentIndex: currentIndex,
                  ).animate().fadeIn(delay: 110.ms).slideX(begin: -0.2),
                  _buildNavItem(
                    theme: theme,
                    icon: Icons.auto_fix_high_outlined,
                    selectedIcon: Icons.auto_fix_high_rounded,
                    label: 'Serviços de Estética',
                    index: 3,
                    currentIndex: currentIndex,
                  ).animate().fadeIn(delay: 140.ms).slideX(begin: -0.2),
                  _buildNavItem(
                    theme: theme,
                    icon: Icons.people_outline,
                    selectedIcon: Icons.people_rounded,
                    label: 'Clientes',
                    index: 4,
                    currentIndex: currentIndex,
                  ).animate().fadeIn(delay: 170.ms).slideX(begin: -0.2),
                  _buildNavItem(
                    theme: theme,
                    icon: Icons.calendar_month_outlined,
                    selectedIcon: Icons.calendar_month_rounded,
                    label: 'Calendário',
                    index: 5,
                    currentIndex: currentIndex,
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                  _buildNavItem(
                    theme: theme,
                    icon: Icons.bar_chart_outlined,
                    selectedIcon: Icons.bar_chart_rounded,
                    label: 'Relatórios',
                    index: 6,
                    currentIndex: currentIndex,
                  ).animate().fadeIn(delay: 230.ms).slideX(begin: -0.2),
                  _buildNavItem(
                    theme: theme,
                    icon: Icons.send_outlined,
                    selectedIcon: Icons.send_rounded,
                    label: 'Enviar Push',
                    index: 7,
                    currentIndex: currentIndex,
                  ).animate().fadeIn(delay: 260.ms).slideX(begin: -0.2),
                  _buildNavItem(
                    theme: theme,
                    icon: Icons.directions_car_outlined,
                    selectedIcon: Icons.directions_car_rounded,
                    label: 'Veículos',
                    index: 8,
                    currentIndex: currentIndex,
                  ).animate().fadeIn(delay: 290.ms).slideX(begin: -0.2),
                  _buildNavItem(
                    theme: theme,
                    icon: Icons.card_membership_outlined,
                    selectedIcon: Icons.card_membership_rounded,
                    label: 'Assinaturas',
                    index: 9,
                    currentIndex: currentIndex,
                  ).animate().fadeIn(delay: 320.ms).slideX(begin: -0.2),
                  _buildNavItem(
                    theme: theme,
                    icon: Icons.badge_outlined,
                    selectedIcon: Icons.badge_rounded,
                    label: 'Funcionários',
                    index: 10,
                    currentIndex: currentIndex,
                  ).animate().fadeIn(delay: 350.ms).slideX(begin: -0.2),
                  _buildNavItem(
                    theme: theme,
                    icon: Icons.card_giftcard_outlined,
                    selectedIcon: Icons.card_giftcard_rounded,
                    label: 'Gerenciar Planos',
                    index: 11,
                    currentIndex: currentIndex,
                  ).animate().fadeIn(delay: 380.ms).slideX(begin: -0.2),
                  _buildNavItem(
                    theme: theme,
                    icon: Icons.price_change_outlined,
                    selectedIcon: Icons.price_change_rounded,
                    label: 'Matriz de Preços',
                    index: 17,
                    currentIndex: currentIndex,
                  ).animate().fadeIn(delay: 395.ms).slideX(begin: -0.2),
                  _buildNavItem(
                    theme: theme,
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings_rounded,
                    label: 'Configurações',
                    index: 12,
                    currentIndex: currentIndex,
                  ).animate().fadeIn(delay: 410.ms).slideX(begin: -0.2),
                  _buildNavItem(
                    theme: theme,
                    icon: Icons.local_offer_outlined,
                    selectedIcon: Icons.local_offer_rounded,
                    label: 'Cupons',
                    index: 13,
                    currentIndex: currentIndex,
                  ).animate().fadeIn(delay: 440.ms).slideX(begin: -0.2),
                  _buildNavItem(
                    theme: theme,
                    icon: Icons.article_outlined,
                    selectedIcon: Icons.article_rounded,
                    label: 'Licença',
                    index: 14,
                    currentIndex: currentIndex,
                  ).animate().fadeIn(delay: 470.ms).slideX(begin: -0.2),
                  _buildNavItem(
                    theme: theme,
                    icon: Icons.inbox_outlined,
                    selectedIcon: Icons.inbox_rounded,
                    label: 'Caixa de Entrada',
                    index: 15,
                    currentIndex: currentIndex,
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),
                  _buildNavItem(
                    theme: theme,
                    icon: Icons.rate_review_outlined,
                    selectedIcon: Icons.rate_review_rounded,
                    label: 'Avaliações',
                    index: 16,
                    currentIndex: currentIndex,
                  ).animate().fadeIn(delay: 530.ms).slideX(begin: -0.2),
                ],
              ),
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showLogoutDialog(context),
                  splashColor: Colors.white.withOpacity(0.2),
                  highlightColor: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Sair',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),

            // Footer with version
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppVersionDisplay(
                    color: Colors.white70,
                    showBuildNumber: true,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Painel Administrativo',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Você tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _sliderKey.currentState?.closeSlider();
              HapticFeedback.mediumImpact();
              ref.read(authRepositoryProvider).signOut();
              context.go('/login');
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, dynamic user) {
    final photoUrl = user?.photoUrl;
    final name = user?.displayName ?? 'Administrador';
    final initials = name.isNotEmpty
        ? name
              .trim()
              .split(' ')
              .map((e) => e.isNotEmpty ? e[0] : '')
              .take(2)
              .join()
              .toUpperCase()
        : 'AD';

    return Row(
      children: [
        // Profile Photo
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            image: photoUrl != null
                ? DecorationImage(
                    image: NetworkImage(photoUrl),
                    fit: BoxFit.cover,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: photoUrl == null
              ? Center(
                  child: Text(
                    initials,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),

        const SizedBox(width: 16),

        // User Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Admin',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeaderLoading(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 50,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required ThemeData theme,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required int currentIndex,
  }) {
    final isSelected = index == currentIndex;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onNavigate(index),
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.white.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.15)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
