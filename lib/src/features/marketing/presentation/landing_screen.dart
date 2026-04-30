import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient & Shapes
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          Positioned(
            top: -200,
            right: -100,
            child: _AnimatedBlob(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
              size: 600,
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: _AnimatedBlob(
              color: const Color(0xFF2DD4BF).withValues(alpha: 0.1),
              size: 500,
            ),
          ),

          // Main Content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildNavbar(context),
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? size.width * 0.1 : 24,
                    vertical: 40,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHeroSection(context, isDesktop),
                      const SizedBox(height: 80),
                      _buildFeaturesGrid(context, isDesktop),
                      const SizedBox(height: 80),
                      _buildCTASection(context),
                      const SizedBox(height: 80),
                      _buildFooter(context),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavbar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFF2DD4BF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_car_wash, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'CleanFlow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.push('/login'),
              child: const Text(
                'Entrar',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => context.push('/signup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Começar Agora'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.2)),
          ),
          child: const Text(
            '🚀 O Futuro do Detailing',
            style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ).animate().fadeIn().slideY(begin: 0.2),
        const SizedBox(height: 24),
        Text(
          'Escalone seu\nLava-jato com\nInteligência.',
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 56,
            height: 1.1,
            fontWeight: FontWeight.bold,
            letterSpacing: -1.5,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
        const SizedBox(height: 24),
        Text(
          'Simplifique agendamentos, automatize pagamentos e fidelize clientes com a plataforma SaaS mais completa do mercado.',
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 18,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
        const SizedBox(height: 40),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
          children: [
            _HeroButton(
              label: 'Teste Grátis 14 Dias',
              isPrimary: true,
              onPressed: () => context.push('/signup'),
            ),
            _HeroButton(
              label: 'Ver Demonstração',
              isPrimary: false,
              onPressed: () {},
            ),
          ],
        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildFeaturesGrid(BuildContext context, bool isDesktop) {
    return Column(
      children: [
        Text(
          'Recursos Premium',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Tudo o que você precisa em um só lugar',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 48),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isDesktop ? 3 : 1,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: isDesktop ? 1.2 : 1.5,
          children: const [
            _FeatureCard(
              icon: Icons.calendar_today,
              title: 'Agendamento em Tempo Real',
              description: 'Interface intuitiva para seus clientes reservarem em segundos.',
            ),
            _FeatureCard(
              icon: Icons.payments_outlined,
              title: 'Pagamentos Automáticos',
              description: 'Integração direta com Stripe para assinaturas e pagamentos avulsos.',
            ),
            _FeatureCard(
              icon: Icons.analytics_outlined,
              title: 'Analytics Avançado',
              description: 'Dashboard completo com métricas de crescimento e retenção.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF38BDF8), Color(0xFF2DD4BF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          const Text(
            'Pronto para transformar seu negócio?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Junte-se a centenas de detailing shops que já escalaram com CleanFlow.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => context.push('/signup'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F172A),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text(
              'Criar Minha Conta Agora',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Divider(color: Colors.white10),
          SizedBox(height: 40),
          Text(
            '© 2026 CleanFlow SaaS. Todos os direitos reservados.',
            style: TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _AnimatedBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .scale(duration: 5.seconds, begin: const Offset(1, 1), end: const Offset(1.2, 1.2))
     .move(duration: 5.seconds, begin: const Offset(0, 0), end: const Offset(20, 30));
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF38BDF8), size: 28),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().scale();
  }
}

class _HeroButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _HeroButton({
    required this.label,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF38BDF8) : Colors.transparent,
          foregroundColor: Colors.white,
          side: isPrimary ? null : BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          padding: const EdgeInsets.symmetric(horizontal: 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
