import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../auth/data/auth_repository.dart';
import '../data/onboarding_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _logoController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _logoController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0077B6), // AquaClean primary blue
              Color(0xFF00B4D8), // Lighter aqua
              Color(0xFF90E0EF), // Light blue accent
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // AquaClean Logo with animation
                Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        'assets/aquaclean_logo.svg',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    )
                    .animate(controller: _logoController)
                    .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                      duration: 800.ms,
                      curve: Curves.elasticOut,
                    ),

                const SizedBox(height: 32),

                // Brand Name
                Text(
                      'AquaClean',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                    )
                    .animate(controller: _logoController)
                    .fadeIn(delay: 300.ms, duration: 500.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 8),

                // Tagline
                Text(
                      'Cuidando do seu carro com carinho',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    )
                    .animate(controller: _logoController)
                    .fadeIn(delay: 500.ms, duration: 500.ms)
                    .slideY(begin: 0.3, end: 0),

                const Spacer(flex: 2),

                // Loading Animation
                SizedBox(
                      width: 120,
                      height: 120,
                      child: Lottie.asset(
                        'assets/animations/limpando.json',
                        controller: _controller,
                        onLoaded: (composition) {
                          _controller
                            ..duration = composition.duration
                            ..forward().then((_) => _navigate(context, ref));
                        },
                        fit: BoxFit.contain,
                      ),
                    )
                    .animate(controller: _logoController)
                    .fadeIn(delay: 700.ms, duration: 500.ms),

                const SizedBox(height: 16),

                // Loading text
                Text(
                      'Carregando...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                    .animate(controller: _logoController)
                    .fadeIn(delay: 900.ms, duration: 500.ms),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, WidgetRef ref) {
    if (!mounted) return;

    final user = ref.read(currentUserProfileProvider).value;
    final isOnboardingComplete = ref
        .read(onboardingRepositoryProvider)
        .isOnboardingComplete();

    if (user != null) {
      if (user.role == 'admin') {
        context.go('/admin');
      } else if (user.role == 'staff') {
        context.go('/staff');
      } else {
        context.go('/dashboard');
      }
    } else {
      if (!isOnboardingComplete) {
        context.go('/onboarding');
      } else {
        context.go('/login');
      }
    }
  }
}
