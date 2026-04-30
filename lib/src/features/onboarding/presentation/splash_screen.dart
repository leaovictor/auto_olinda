import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../auth/data/auth_repository.dart';
import '../data/onboarding_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigate();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigate() {
    if (!mounted) return;

    final user = ref.read(currentUserProfileProvider).value;
    final isOnboardingComplete = ref
        .read(onboardingRepositoryProvider)
        .isOnboardingComplete();

    if (user != null) {
      if (user.isSuperAdmin) {
        context.go('/super-admin'); // TODO: build super-admin screen (Day 3.5)
      } else if (user.isTenantAdmin) {
        context.go('/admin');
      } else if (user.isStaff) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0077B6),
      body: Center(
        child: Lottie.asset(
          'assets/animations/limpando.json',
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward();
          },
          fit: BoxFit.contain,
          width: MediaQuery.of(context).size.width * 0.6,
        ),
      ),
    );
  }
}
