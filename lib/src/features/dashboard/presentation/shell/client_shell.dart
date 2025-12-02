import 'dart:async';
import 'package:aquaclean_mobile/src/shared/providers/drawer_provider.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:go_router/go_router.dart';
import 'client_menu_screen.dart';

class ClientShell extends ConsumerStatefulWidget {
  final Widget child;

  const ClientShell({super.key, required this.child});

  @override
  ConsumerState<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends ConsumerState<ClientShell>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 2), // Start hidden below
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Show initially
    _showBottomBar();
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _showBottomBar() {
    if (_controller.status != AnimationStatus.completed) {
      _controller.forward();
    }
    _resetHideTimer();
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse(); // Hide
      }
    });
  }

  void _onUserInteraction() {
    _showBottomBar();
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/booking')) return 1;
    if (location.startsWith('/my-bookings')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    _showBottomBar(); // Ensure visible when tapping
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/booking');
        break;
      case 2:
        context.go('/my-bookings');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final drawerKey = ref.watch(clientDrawerKeyProvider);
    return SliderDrawer(
      key: drawerKey,
      appBar:
          const SizedBox.shrink(), // Hide default app bar as screens have their own
      slider: const ClientMenuScreen(),
      child: Listener(
        onPointerDown: (_) => _onUserInteraction(),
        onPointerMove: (_) => _onUserInteraction(),
        child: Scaffold(
          extendBody: true,
          body: widget.child,
          bottomNavigationBar: SlideTransition(
            position: _offsetAnimation,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CrystalNavigationBar(
                currentIndex: _calculateSelectedIndex(context),
                unselectedItemColor: Colors.white70,
                backgroundColor: Colors.black.withValues(alpha: 0.1),
                onTap: (index) => _onItemTapped(index, context),
                items: [
                  /// Home
                  CrystalNavigationBarItem(
                    icon: Icons.home_rounded,
                    unselectedIcon: Icons.home_outlined,
                    selectedColor: Colors.white,
                  ),

                  /// Booking
                  CrystalNavigationBarItem(
                    icon: Icons.add_circle_rounded,
                    unselectedIcon: Icons.add_circle_outline,
                    selectedColor: Colors.white,
                  ),

                  /// My Bookings
                  CrystalNavigationBarItem(
                    icon: Icons.calendar_month_rounded,
                    unselectedIcon: Icons.calendar_month_outlined,
                    selectedColor: Colors.white,
                  ),

                  /// Profile
                  CrystalNavigationBarItem(
                    icon: Icons.person_rounded,
                    unselectedIcon: Icons.person_outline,
                    selectedColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
