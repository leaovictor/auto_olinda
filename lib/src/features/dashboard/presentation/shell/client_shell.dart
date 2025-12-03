import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class ClientShell extends ConsumerWidget {
  final Widget child;

  const ClientShell({super.key, required this.child});

  int _getCurrentIndex(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/shop')) return 1;
    if (location.startsWith('/my-bookings')) return 2;
    if (location.startsWith('/plans')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final theme = Theme.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withValues(alpha: 0.1),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
            child: GNav(
              rippleColor: theme.colorScheme.primaryContainer,
              hoverColor: theme.colorScheme.primaryContainer.withValues(
                alpha: 0.5,
              ),
              gap: 4,
              activeColor: theme.colorScheme.primary,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: theme.colorScheme.primaryContainer,
              color: theme.colorScheme.onSurfaceVariant,
              tabs: const [
                GButton(icon: Icons.home, text: 'Início'),
                GButton(icon: Icons.store, text: 'Loja'),
                GButton(icon: Icons.calendar_today, text: 'Agenda'),
                GButton(icon: Icons.card_membership, text: 'Planos'),
                GButton(icon: Icons.person, text: 'Perfil'),
              ],
              selectedIndex: _getCurrentIndex(location),
              onTabChange: (index) {
                switch (index) {
                  case 0:
                    context.go('/dashboard');
                    break;
                  case 1:
                    context.go('/shop');
                    break;
                  case 2:
                    context.go('/my-bookings');
                    break;
                  case 3:
                    context.go('/plans');
                    break;
                  case 4:
                    context.go('/profile');
                    break;
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
