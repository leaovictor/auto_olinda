import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isDesktop ? 1000 : 500),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAnimatedLogo()
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(
                            duration: 3.seconds,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                      const SizedBox(height: 32),
                      Text(
                        'Bem-vindo ao',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                      const SizedBox(height: 8),
                      Text(
                        'Auto Olinda',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                      const SizedBox(height: 16),
                      Text(
                        'Como você deseja acessar a plataforma?',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ).animate().fadeIn(delay: 500.ms),
                      const SizedBox(height: 56),

                      // Reseta o layout baseado em tela (lado a lado no desktop, coluna no mobile)
                      isDesktop 
                          ? Row(
                              children: [
                                Expanded(child: _buildChoiceCard(
                                  context: context,
                                  title: 'Sou Cliente',
                                  subtitle: 'Agende serviços, acompanhe seu veículo e gerencie suas assinaturas.',
                                  icon: Icons.directions_car_rounded,
                                  isPrimary: true,
                                  onTap: () => context.go('/login?role=client'),
                                  delay: 600,
                                )),
                                const SizedBox(width: 32),
                                Expanded(child: _buildChoiceCard(
                                  context: context,
                                  title: 'Sou Dono de Lavajato',
                                  subtitle: 'Gerencie sua estética automotiva, seus clientes e serviços.',
                                  icon: Icons.business_center_rounded,
                                  isPrimary: false,
                                  onTap: () => context.go('/business-signup'),
                                  delay: 700,
                                )),
                              ],
                            )
                          : Column(
                              children: [
                                _buildChoiceCard(
                                  context: context,
                                  title: 'Sou Cliente',
                                  subtitle: 'Agende serviços, acompanhe seu veículo e gerencie suas assinaturas.',
                                  icon: Icons.directions_car_rounded,
                                  isPrimary: true,
                                  onTap: () => context.go('/login?role=client'),
                                  delay: 600,
                                ),
                                const SizedBox(height: 24),
                                _buildChoiceCard(
                                  context: context,
                                  title: 'Sou Dono de Lavajato',
                                  subtitle: 'Gerencie sua estética automotiva, seus clientes e serviços.',
                                  icon: Icons.business_center_rounded,
                                  isPrimary: false,
                                  onTap: () => context.go('/login?role=business'),
                                  delay: 700,
                                ),
                              ],
                            ),
                            
                      const SizedBox(height: 48),
                      Text(
                        'A plataforma premium para estética automotiva',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w600,
                        ),
                      ).animate().fadeIn(delay: 1.seconds),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
    required int delay,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: (isPrimary ? Colors.white : AppColors.primary).withValues(alpha: 0.2),
        highlightColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: isPrimary 
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isPrimary 
                      ? Colors.white.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.2),
                  width: isPrimary ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 36,
                      color: isPrimary ? AppColors.primary : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        'Acessar',
                        style: TextStyle(
                          color: isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.9),
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.1, duration: 600.ms, curve: Curves.easeOut);
  }

  Widget _buildAnimatedBackground() {
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
          ...List.generate(15, (index) {
            final random = DateTime.now().millisecondsSinceEpoch + index;
            final x = (random * 7) % 100 / 100;
            final y = (random * 13) % 100 / 100;
            final size = 30.0 + (random % 80);
            final duration = 4000 + (random % 5000);

            return Positioned(
              left: MediaQuery.of(context).size.width * x,
              top: MediaQuery.of(context).size.height * y,
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
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 90,
          height: 90,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(12),
          child: Image.asset('assets/autoolinda_logo.png', fit: BoxFit.contain),
        ),
      ),
    ).animate().scale(duration: 800.ms, curve: Curves.elasticOut);
  }
}
