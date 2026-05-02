import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      title: 'Agende no seu tempo',
      description:
          'Escolha o melhor horário para você. Nós vamos até onde seu carro estiver.',
      assetPath: 'assets/images/onboarding_schedule.png',
      color: const Color(0xFF6C63FF), // Purple accent
    ),
    OnboardingPageData(
      title: 'Tratamento Premium',
      description:
          'Produtos ecológicos e técnicas que protegem a pintura do seu veículo.',
      assetPath: 'assets/images/onboarding_wash.png',
      color: const Color(0xFF00B0FF), // Blue/Cyan accent
    ),
    OnboardingPageData(
      title: 'Acompanhe tudo',
      description:
          'Receba atualizações em tempo real e gerencie seus pagamentos com facilidade.',
      assetPath: 'assets/images/onboarding_track.png',
      color: const Color(0xFF00E676), // Green accent
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
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentPageData = _pages[_currentPage];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Background Gradient (Subtle)
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surface,
                    currentPageData.color.withOpacity(0.05),
                    currentPageData.color.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip Button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, right: 16),
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurface
                            .withOpacity(0.6),
                      ),
                      child: const Text(
                        'Pular',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),

                // Content Area
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

                // Bottom Controls
                Container(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      // Page Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentPage == index ? 32 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? _pages[index].color
                                  : theme.colorScheme.outlineVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Main Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: () {
                            if (_currentPage < _pages.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOutQuart,
                              );
                            } else {
                              _completeOnboarding();
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: currentPageData.color,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: currentPageData.color.withOpacity(0.5),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _currentPage < _pages.length - 1
                                ? const Text(
                                    'Próximo',
                                    key: ValueKey('Next'),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : const Text(
                                    'Começar Agora',
                                    key: ValueKey('Start'),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, OnboardingPageData data) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 3D Illustration
          Expanded(
            flex: 5,
            child: Center(
              child: Image.asset(data.assetPath, fit: BoxFit.contain)
                  .animate()
                  .fade(duration: 600.ms)
                  .scale(duration: 600.ms, curve: Curves.easeOutBack)
                  .moveY(
                    begin: 20,
                    end: 0,
                    duration: 600.ms,
                    curve: Curves.easeOut,
                  ),
            ),
          ),

          const Spacer(),

          // Text Content
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Text(
                  data.title,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fade(delay: 200.ms).moveY(begin: 20, end: 0),

                const SizedBox(height: 16),

                Text(
                  data.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fade(delay: 400.ms).moveY(begin: 20, end: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String description;
  final String assetPath;
  final Color color;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.assetPath,
    required this.color,
  });
}
