import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:aquaclean_mobile/src/core/theme/app_colors.dart';

/// Shared branding panel for desktop auth screens (left side)
class AuthBrandingPanel extends StatelessWidget {
  const AuthBrandingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary.withValues(alpha: 0.9),
            AppColors.tertiary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Floating Bubbles
          ...List.generate(20, (index) {
            final random = DateTime.now().millisecondsSinceEpoch + index;
            final x = (random * 7) % 100 / 100;
            final y = (random * 13) % 100 / 100;
            final size = 20.0 + (random % 80);
            final duration = 4000 + (random % 5000);

            return Positioned(
              left: x * 500,
              top: y * 800,
              child:
                  Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .moveY(
                        begin: 0,
                        end: -150,
                        duration: duration.ms,
                        curve: Curves.easeInOut,
                      )
                      .fadeIn(duration: (duration / 2).ms)
                      .fadeOut(delay: (duration / 2).ms),
            );
          }),

          // Main Content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: const Icon(
                          Icons.local_car_wash,
                          color: Color(0xFF38BDF8),
                          size: 80,
                        ),
                      )
                      .animate()
                      .scale(duration: 800.ms, curve: Curves.elasticOut)
                      .then()
                      .shimmer(
                        duration: 3.seconds,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),

                  const SizedBox(height: 40),

                  // Brand Name
                  const Text(
                    'CleanFlow',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 16),

                  // Tagline
                  Text(
                    'Gestão Inteligente para\nsua Estética Automotiva',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 48),

                  // Features List
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildFeatures(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeatures() {
    final features = [
      {'icon': Icons.calendar_month_rounded, 'text': 'Agendamentos Online'},
      {'icon': Icons.people_rounded, 'text': 'Gestão de Clientes'},
      {'icon': Icons.bar_chart_rounded, 'text': 'Relatórios Detalhados'},
      {
        'icon': Icons.notifications_rounded,
        'text': 'Notificações em Tempo Real',
      },
    ];

    return features.asMap().entries.map((entry) {
      final index = entry.key;
      final feature = entry.value;

      return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  feature['text'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          )
          .animate()
          .fadeIn(delay: (700 + index * 150).ms)
          .slideX(begin: -0.2, end: 0);
    }).toList();
  }
}

/// Desktop breakpoint for auth screens
const double kAuthDesktopBreakpoint = 900;
