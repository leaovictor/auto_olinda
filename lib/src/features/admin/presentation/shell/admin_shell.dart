import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../../../features/auth/data/auth_repository.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  int _getCurrentIndex(String location) {
    if (location == '/admin') return 0;
    if (location.startsWith('/admin/appointments')) return 1;
    if (location.startsWith('/admin/services')) return 2;
    if (location.startsWith('/admin/calendar')) return 3;
    if (location.startsWith('/admin/reports')) return 4;
    if (location.startsWith('/admin/notifications')) return 5;
    return 0;
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Agendamentos';
      case 2:
        return 'Serviços';
      case 3:
        return 'Calendário';
      case 4:
        return 'Relatórios';
      case 5:
        return 'Notificações';
      default:
        return 'Admin';
    }
  }

  void _onNavigate(BuildContext context, int index) {
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
        context.go('/admin/calendar');
        break;
      case 4:
        context.go('/admin/reports');
        break;
      case 5:
        context.go('/admin/notifications');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final theme = Theme.of(context);
    final currentIndex = _getCurrentIndex(location);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // Desktop Layout
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (index) => _onNavigate(context, index),
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Icon(
                      Icons.water_drop,
                      color: theme.colorScheme.primary,
                      size: 40,
                    ),
                  ),
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: IconButton(
                          icon: const Icon(Icons.logout),
                          onPressed: () {
                            ref.read(authRepositoryProvider).signOut();
                          },
                          tooltip: 'Sair',
                        ),
                      ),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.event_note_outlined),
                      selectedIcon: Icon(Icons.event_note),
                      label: Text('Agendamentos'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.local_car_wash_outlined),
                      selectedIcon: Icon(Icons.local_car_wash),
                      label: Text('Serviços'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month),
                      label: Text('Calendário'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.analytics_outlined),
                      selectedIcon: Icon(Icons.analytics),
                      label: Text('Relatórios'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.notifications_outlined),
                      selectedIcon: Icon(Icons.notifications),
                      label: Text('Notificações'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: child),
              ],
            ),
          );
        } else {
          // Mobile Layout
          return Scaffold(
            appBar: AppBar(
              title: Text(_getTitle(currentIndex)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    ref.read(authRepositoryProvider).signOut();
                  },
                  tooltip: 'Sair',
                ),
              ],
            ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 8,
                  ),
                  child: GNav(
                    rippleColor: theme.colorScheme.primaryContainer,
                    hoverColor: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.5,
                    ),
                    gap: 4,
                    activeColor: theme.colorScheme.primary,
                    iconSize: 24,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    duration: const Duration(milliseconds: 400),
                    tabBackgroundColor: theme.colorScheme.primaryContainer,
                    color: theme.colorScheme.onSurfaceVariant,
                    tabs: const [
                      GButton(icon: Icons.dashboard, text: 'Dashboard'),
                      GButton(icon: Icons.event_note, text: 'Agendamentos'),
                      GButton(icon: Icons.local_car_wash, text: 'Serviços'),
                      GButton(icon: Icons.calendar_month, text: 'Calendário'),
                      GButton(icon: Icons.analytics, text: 'Relatórios'),
                    ],
                    selectedIndex: currentIndex,
                    onTabChange: (index) => _onNavigate(context, index),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
