import 'package:flutter/material.dart';

class AdminSidebar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onNavigate;
  final VoidCallback onLogout;

  const AdminSidebar({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    // Dark sidebar theme colors based on image
    // Background: Dark Indigo/Navy (approx #1A1F36)
    // Selected Item: Indigo/Purple (approx #5C59E8)
    // Text: White/Light Grey

    const sidebarBgColor = Color(0xFF1E1E2D);
    const selectedItemColor = Color(0xFF5D5FEF);

    return Container(
      width: 250,
      color: sidebarBgColor,
      child: Column(
        children: [
          // Logo Area
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              children: [
                Icon(Icons.water_drop, color: selectedItemColor, size: 32),
                const SizedBox(width: 12),
                const Text(
                  "AquaClean",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16, bottom: 8),
                  child: Text(
                    "NAVEGAÇÃO",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildNavItem(
                  0,
                  "Início",
                  Icons.grid_view_rounded,
                  selectedItemColor,
                ),
                _buildNavItem(
                  1,
                  "Agendamentos",
                  Icons.calendar_today_rounded,
                  selectedItemColor,
                ),
                _buildNavItem(
                  2,
                  "Serviços",
                  Icons.cleaning_services_rounded,
                  selectedItemColor,
                ),
                _buildNavItem(
                  3,
                  "Clientes",
                  Icons.people_alt_rounded,
                  selectedItemColor,
                ),
                _buildNavItem(
                  4,
                  "Calendário",
                  Icons.calendar_month_outlined,
                  selectedItemColor,
                ),
                _buildNavItem(
                  5,
                  "Relatórios",
                  Icons.analytics_outlined,
                  selectedItemColor,
                ),
                _buildNavItem(
                  6,
                  "Notificações",
                  Icons.notifications_none_rounded,
                  selectedItemColor,
                ),

                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 24, bottom: 8),
                  child: Text(
                    "GERAL",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildNavItem(
                  7,
                  "Veículos",
                  Icons.directions_car_rounded,
                  selectedItemColor,
                ),
                _buildNavItem(
                  8,
                  "Assinaturas",
                  Icons.card_membership_rounded,
                  selectedItemColor,
                ),
                _buildNavItem(
                  9,
                  "Funcionários",
                  Icons.badge_rounded,
                  selectedItemColor,
                ),
                _buildNavItem(
                  10,
                  "Configurações",
                  Icons.settings_rounded,
                  selectedItemColor,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildNavItem(
              -1,
              "Sair",
              Icons.logout,
              Colors.red,
              onTapOverride: onLogout,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String label,
    IconData icon,
    Color activeColor, {
    VoidCallback? onTapOverride,
  }) {
    final isSelected = currentIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTapOverride ?? () => onNavigate(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: isSelected
                ? BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  )
                : null,
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontSize: 16,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
