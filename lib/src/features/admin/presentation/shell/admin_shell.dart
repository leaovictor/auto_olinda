import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../../../features/auth/data/auth_repository.dart';
import 'admin_sidebar.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  int _getCurrentIndex(String location) {
    if (location == '/admin') return 0;
    if (location.startsWith('/admin/appointments')) return 1;
    if (location.startsWith('/admin/services')) return 2;
    if (location.startsWith('/admin/customers')) return 3;
    if (location.startsWith('/admin/calendar')) return 4;
    if (location.startsWith('/admin/reports')) return 5;
    if (location.startsWith('/admin/inbox')) return 6;
    if (location.startsWith('/admin/vehicles')) return 7;
    if (location.startsWith('/admin/subscriptions')) return 8;
    if (location.startsWith('/admin/staff')) return 9;
    if (location.startsWith('/admin/settings')) return 10;
    return 0;
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Painel de Controle';
      case 1:
        return 'Agendamentos';
      case 2:
        return 'Serviços';
      case 3:
        return 'Clientes';
      case 4:
        return 'Calendário';
      case 5:
        return 'Relatórios';
      case 6:
        return 'Notificações';
      case 7:
        return 'Veículos';
      case 8:
        return 'Assinaturas';
      case 9:
        return 'Funcionários';
      case 10:
        return 'Configurações';
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
        context.go('/admin/customers');
        break;
      case 4:
        context.go('/admin/calendar');
        break;
      case 5:
        context.go('/admin/reports');
        break;
      case 6:
        context.go('/admin/inbox');
        break;
      case 7:
        context.go('/admin/vehicles');
        break;
      case 8:
        context.go('/admin/subscriptions');
        break;
      case 9:
        context.go('/admin/staff');
        break;
      case 10:
        context.go('/admin/settings');
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
          // Desktop Layout with New Sidebar
          return Scaffold(
            body: Row(
              children: [
                AdminSidebar(
                  currentIndex: currentIndex,
                  onNavigate: (index) => _onNavigate(context, index),
                  onLogout: () {
                    ref.read(authRepositoryProvider).signOut();
                  },
                ),
                Expanded(
                  child: Container(
                    color: const Color(
                      0xFFF3F4F6,
                    ), // Light grey background for dashboard area
                    child: child,
                  ),
                ),
              ],
            ),
          );
        } else {
          // Mobile Layout (Keep existing or update slightly if needed, keeping simple for now)
          return Scaffold(
            backgroundColor: const Color(0xFFF3F4F6),
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
                      GButton(icon: Icons.grid_view_rounded, text: 'Início'),
                      GButton(
                        icon: Icons.calendar_today_rounded,
                        text: 'Agenda',
                      ),
                      GButton(
                        icon: Icons.people_outline_rounded,
                        text: 'Clientes',
                      ),
                      GButton(
                        icon: Icons.cleaning_services_rounded,
                        text: 'Serviços',
                      ),
                      GButton(icon: Icons.menu, text: 'Mais'),
                    ],
                    selectedIndex: currentIndex >= 5
                        ? 4
                        : currentIndex, // Clamp for mobile nav limited space
                    onTabChange: (index) {
                      if (index == 4) {
                        // Simplify handling "More", maybe just go to reports for now or open drawer
                        // For now, let's map to Reports
                        _onNavigate(context, 5);
                      } else {
                        _onNavigate(context, index);
                      }
                    },
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
