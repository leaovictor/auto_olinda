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
    if (location.startsWith('/admin/notifications')) return 6;
    if (location.startsWith('/admin/vehicles')) return 7;
    if (location.startsWith('/admin/subscriptions')) return 8;
    if (location.startsWith('/admin/staff')) return 9;
    if (location.startsWith('/admin/plans')) return 10;
    if (location.startsWith('/admin/settings')) return 11;
    if (location.startsWith('/admin/catalog')) return 12;
    return 0;
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Painel de Controle';
      case 1:
        return 'Agendamentos';
      case 2:
        return 'Produtos e Serviços';
      case 3:
        return 'Clientes';
      case 4:
        return 'Calendário';
      case 5:
        return 'Relatórios';
      case 6:
        return 'Enviar Push';
      case 7:
        return 'Veículos';
      case 8:
        return 'Assinaturas';
      case 9:
        return 'Funcionários';
      case 10:
        return 'Gerenciar Planos';
      case 11:
        return 'Configurações';
      case 12:
        return 'Cupons de Desconto';
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
        context.go('/admin/notifications');
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
        context.go('/admin/plans');
        break;
      case 11:
        context.go('/admin/settings');
        break;
      case 12:
        context.go('/admin/catalog');
        break;
    }
  }

  void _showMoreMenu(BuildContext context, int currentIndex) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Menu Completo',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      4,
                      'Calendário',
                      Icons.calendar_month,
                      currentIndex,
                    ),
                    _buildMenuItem(
                      context,
                      5,
                      'Relatórios',
                      Icons.bar_chart,
                      currentIndex,
                    ),
                    _buildMenuItem(
                      context,
                      6,
                      'Enviar Push',
                      Icons.send,
                      currentIndex,
                    ),
                    _buildMenuItem(
                      context,
                      7,
                      'Veículos',
                      Icons.directions_car,
                      currentIndex,
                    ),
                    _buildMenuItem(
                      context,
                      8,
                      'Assinaturas',
                      Icons.card_membership,
                      currentIndex,
                    ),
                    _buildMenuItem(
                      context,
                      9,
                      'Funcionários',
                      Icons.badge,
                      currentIndex,
                    ),
                    _buildMenuItem(
                      context,
                      10,
                      'Gerenciar Planos',
                      Icons.card_giftcard,
                      currentIndex,
                    ),
                    _buildMenuItem(
                      context,
                      11,
                      'Configurações',
                      Icons.settings,
                      currentIndex,
                    ),
                    _buildMenuItem(
                      context,
                      12,
                      'Cupons',
                      Icons.local_offer,
                      currentIndex,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    int index,
    String label,
    IconData icon,
    int currentIndex,
  ) {
    final theme = Theme.of(context);
    final isSelected = currentIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      onTap: () {
        Navigator.pop(context);
        _onNavigate(context, index);
      },
    );
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
          // Mobile Layout with complete navigation
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
                        text: 'Produtos',
                      ),
                      GButton(icon: Icons.menu, text: 'Mais'),
                    ],
                    selectedIndex: currentIndex >= 4 ? 4 : currentIndex,
                    onTabChange: (index) {
                      if (index == 4) {
                        _showMoreMenu(context, currentIndex);
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
