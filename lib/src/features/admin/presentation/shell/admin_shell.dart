import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:blurred_overlay/blurred_overlay.dart';
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
      case 13:
        context.go('/admin/products');
        break;
    }
  }

  void _showMoreMenu(BuildContext context, WidgetRef ref, int currentIndex) {
    final theme = Theme.of(context);

    showBlurredModalBottomSheet(
      context: context,
      showHandle: true,
      builder: (context) => Column(
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
            'Menu',
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
                  _buildMenuItem(
                    context,
                    13,
                    'Produtos',
                    Icons.shopping_bag,
                    currentIndex,
                  ),
                  const SizedBox(height: 8),
                  Divider(
                    color: theme.colorScheme.outlineVariant,
                    indent: 16,
                    endIndent: 16,
                  ),
                  const SizedBox(height: 8),
                  // Account section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.pop(context);
                          ref.read(authRepositoryProvider).signOut();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                color: Colors.red[700],
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Sair da conta',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
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
          // Mobile Layout with crystal navigation
          return Scaffold(
            backgroundColor: const Color(0xFFF3F4F6),
            extendBody: true,
            body: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 70),
                child: child,
              ),
            ),
            bottomNavigationBar: CrystalNavigationBar(
              currentIndex: currentIndex >= 5 ? 4 : currentIndex,
              onTap: (index) {
                if (index == 4) {
                  _showMoreMenu(context, ref, currentIndex);
                } else {
                  _onNavigate(context, index);
                }
              },
              indicatorColor: theme.colorScheme.primary,
              unselectedItemColor: theme.colorScheme.onSurfaceVariant,
              selectedItemColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
              outlineBorderColor: theme.colorScheme.outline.withValues(
                alpha: 0.15,
              ),
              enableFloatingNavBar: false,
              enablePaddingAnimation: true,
              splashBorderRadius: 12,
              borderRadius: 0,
              marginR: EdgeInsets.zero,
              paddingR: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              items: [
                CrystalNavigationBarItem(
                  icon: Icons.grid_view_rounded,
                  unselectedIcon: Icons.grid_view_outlined,
                  selectedColor: theme.colorScheme.primary,
                ),
                CrystalNavigationBarItem(
                  icon: Icons.calendar_today_rounded,
                  unselectedIcon: Icons.calendar_today_outlined,
                  selectedColor: theme.colorScheme.primary,
                ),
                CrystalNavigationBarItem(
                  icon: Icons.people_rounded,
                  unselectedIcon: Icons.people_outline_rounded,
                  selectedColor: theme.colorScheme.primary,
                ),
                CrystalNavigationBarItem(
                  icon: Icons.cleaning_services_rounded,
                  unselectedIcon: Icons.cleaning_services_outlined,
                  selectedColor: theme.colorScheme.primary,
                ),
                CrystalNavigationBarItem(
                  icon: Icons.more_horiz_rounded,
                  unselectedIcon: Icons.more_horiz_outlined,
                  selectedColor: theme.colorScheme.primary,
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
