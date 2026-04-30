import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../auth/data/auth_repository.dart';
import '../../../weather/data/weather_repository.dart';
import '../../../weather/domain/weather_theme.dart';
import '../../../../common_widgets/molecules/dynamic_watermark.dart';
import '../../../../shared/services/screen_security_service.dart';

/// Provider for the drawer toggle callback
final drawerToggleProvider = StateProvider<VoidCallback?>((ref) => null);

class ClientShell extends ConsumerStatefulWidget {
  final Widget child;

  const ClientShell({super.key, required this.child});

  @override
  ConsumerState<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends ConsumerState<ClientShell> {
  final GlobalKey<SliderDrawerState> _sliderKey =
      GlobalKey<SliderDrawerState>();

  int _getCurrentIndex(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/my-bookings')) return 1;
    if (location.startsWith('/services')) return 2;
    if (location.startsWith('/plans')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onNavigate(int index) {
    HapticFeedback.selectionClick();
    _sliderKey.currentState?.closeSlider();

    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/my-bookings');
        break;
      case 2:
        context.go('/services');
        break;
      case 3:
        context.go('/plans');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    // Schedule the provider update after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(drawerToggleProvider.notifier).state = _toggleDrawer;
    });
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
    final user = ref.watch(authRepositoryProvider).currentUser;
    final userId = user?.uid ?? 'guest';

    // Base content
    Widget content = Scaffold(
      backgroundColor: theme.colorScheme.surface,
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

    // Apply watermark (sutil, funciona em todas as plataformas)
    content = DynamicWatermark(
      userId: userId,
      opacity: 0.03, // Muito sutil para não atrapalhar
      child: content,
    );

    // Apply secure mode only on Android (FLAG_SECURE)
    if (!kIsWeb && Platform.isAndroid) {
      content = SecureScreen(screenName: 'ClientApp', child: content);
    }

    return content;
  }

  Widget _buildDrawerContent(ThemeData theme, int currentIndex) {
    final userAsync = ref.watch(currentUserProfileProvider);
    final weatherAsync = ref.watch(currentWeatherProvider);

    // Get weather data for dynamic drawer colors
    final weather = weatherAsync.valueOrNull;
    final weatherCode = weather?.weatherCode ?? 1;
    final isDay = weather?.isDay ?? true;

    // Get weather theme (same as weather background)
    final weatherTheme = WeatherTheme.fromCode(weatherCode, isDay);

    return Container(
      decoration: BoxDecoration(gradient: weatherTheme.gradient),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: userAsync.when(
                data: (user) => _buildProfileHeader(theme, user),
                loading: () => _buildProfileHeaderLoading(theme),
                error: (_, __) => _buildProfileHeader(theme, null),
              ),
            ),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildNavItem(
                    theme: theme,
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_rounded,
                    label: 'Início',
                    index: 0,
                    currentIndex: currentIndex,
                  ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
                  _buildNavItem(
                    theme: theme,
                    icon: Icons.calendar_today_outlined,
                    selectedIcon: Icons.calendar_today_rounded,
                    label: 'Agendamentos',
                    index: 1,
                    currentIndex: currentIndex,
                  ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.2),
                  _buildNavItem(
                    theme: theme,
                    icon: Icons.local_car_wash_outlined,
                    selectedIcon: Icons.local_car_wash_rounded,
                    label: 'Serviços',
                    index: 2,
                    currentIndex: currentIndex,
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                  _buildNavItem(
                    theme: theme,
                    icon: Icons.card_membership_outlined,
                    selectedIcon: Icons.card_membership_rounded,
                    label: 'Planos',
                    index: 3,
                    currentIndex: currentIndex,
                  ).animate().fadeIn(delay: 250.ms).slideX(begin: -0.2),
                  _buildNavItem(
                    theme: theme,
                    icon: Icons.person_outline,
                    selectedIcon: Icons.person_rounded,
                    label: 'Perfil',
                    index: 4,
                    currentIndex: currentIndex,
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
                ],
              ),
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showLogoutDialog(context),
                  splashColor: Colors.white.withValues(alpha: 0.2),
                  highlightColor: Colors.white.withValues(alpha: 0.1),
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
            ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),

            // Footer with Logo
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'CleanFlow',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.bold,
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
    final name = user?.displayName ?? 'Visitante';
    final initials = name.isNotEmpty
        ? name
              .trim()
              .split(' ')
              .map((e) => e.isNotEmpty ? e[0] : '')
              .take(2)
              .join()
              .toUpperCase()
        : '?';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Photo
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 3,
            ),
            image: photoUrl != null
                ? DecorationImage(
                    image: NetworkImage(photoUrl),
                    fit: BoxFit.cover,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: photoUrl == null
              ? Center(
                  child: Text(
                    initials,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),

        const SizedBox(height: 16),

        // User Name
        Text(
          name,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),

        const SizedBox(height: 4),

        // Email or subtitle
        Text(
          user?.email ?? 'Bem-vindo!',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.1),
      ],
    );
  }

  Widget _buildProfileHeaderLoading(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 120,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 160,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
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
        splashColor: Colors.white.withValues(alpha: 0.1),
        highlightColor: Colors.white.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.15)
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
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
