import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ClientShell extends ConsumerWidget {
  final Widget child;

  const ClientShell({super.key, required this.child});

  int _getCurrentIndex(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/my-bookings')) return 1;
    if (location.startsWith('/plans')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onTabChange(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/my-bookings');
        break;
      case 2:
        context.go('/plans');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 70),
          child: child,
        ),
      ),
      bottomNavigationBar: CrystalNavigationBar(
        currentIndex: _getCurrentIndex(location),
        onTap: (index) => _onTabChange(context, index),
        indicatorColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurfaceVariant,
        selectedItemColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
        outlineBorderColor: theme.colorScheme.outline.withValues(alpha: 0.15),
        enableFloatingNavBar: false,
        enablePaddingAnimation: true,
        splashBorderRadius: 12,
        borderRadius: 0,
        marginR: EdgeInsets.zero,
        paddingR: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        items: [
          CrystalNavigationBarItem(
            icon: Icons.home_rounded,
            unselectedIcon: Icons.home_outlined,
            selectedColor: theme.colorScheme.primary,
          ),
          CrystalNavigationBarItem(
            icon: Icons.calendar_today_rounded,
            unselectedIcon: Icons.calendar_today_outlined,
            selectedColor: theme.colorScheme.primary,
          ),
          CrystalNavigationBarItem(
            icon: Icons.card_membership_rounded,
            unselectedIcon: Icons.card_membership_outlined,
            selectedColor: theme.colorScheme.primary,
          ),
          CrystalNavigationBarItem(
            icon: Icons.person_rounded,
            unselectedIcon: Icons.person_outline,
            selectedColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
