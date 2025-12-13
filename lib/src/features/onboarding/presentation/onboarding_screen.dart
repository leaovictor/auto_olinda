import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../onboarding/data/onboarding_repository.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Agendamento Fácil',
      description:
          'Agende a lavagem do seu carro em poucos cliques, sem sair de casa.',
      animation: 'assets/animations/car polish.json',
    ),
    OnboardingPageData(
      title: 'Acompanhamento em Tempo Real',
      description:
          'Fique por dentro de cada etapa do serviço, desde o check-in até a finalização.',
      animation: 'assets/animations/Loading animation blue.json',
    ),
    OnboardingPageData(
      title: 'Qualidade Garantida',
      description:
          'Profissionais qualificados e produtos de alta qualidade para o seu veículo.',
      animation: 'assets/animations/Confetti.json',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingRepositoryProvider).setOnboardingComplete();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button at top
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 16),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Pular',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return _buildPage(context, _pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // Navigation Button
                  FloatingActionButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    child: Icon(
                      _currentPage < _pages.length - 1
                          ? Icons.arrow_forward
                          : Icons.check,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, OnboardingPageData data) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(flex: 3, child: Center(child: _buildAnimation(theme, data))),
          const SizedBox(height: 32),
          Text(
            data.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildAnimation(ThemeData theme, OnboardingPageData data) {
    // Use only the first animation (car polish) which works
    if (data.animation == 'assets/animations/car polish.json') {
      return Lottie.asset(
        data.animation,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackIcon(theme, data);
        },
      );
    }

    // For other animations, use icons to avoid Stack Overflow
    return _buildFallbackIcon(theme, data);
  }

  Widget _buildFallbackIcon(ThemeData theme, OnboardingPageData data) {
    IconData icon;

    if (data.animation.contains('Loading')) {
      icon = Icons.track_changes;
    } else if (data.animation.contains('Confetti')) {
      icon = Icons.verified;
    } else {
      icon = Icons.local_car_wash;
    }

    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 120, color: theme.colorScheme.primary),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String description;
  final String animation;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.animation,
  });
}
