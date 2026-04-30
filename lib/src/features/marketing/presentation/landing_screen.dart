import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(),
            _FeaturesBento(),
            _PricingSection(),
            _Footer(),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        children: [
          const Text(
            'CleanFlow SaaS',
            style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 18),
          ).animate().fadeIn().slideY(begin: 0.3),
          const SizedBox(height: 16),
          const Text(
            'Transforme seu Lava-jato em uma\nMáquina de Receita Recorrente',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold, height: 1.1),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
          const SizedBox(height: 24),
          const Text(
            'A plataforma completa de gestão, assinaturas e pagamentos\nfeita exclusivamente para donos de estética automotiva.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 20),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () => context.push('/signup'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Criar Meu Painel Agora', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ).animate().fadeIn(delay: 600.ms).scale(),
        ],
      ),
    );
  }
}

class _FeaturesBento extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Text('Tudo o que você precisa para escalar', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 48),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 1,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            children: [
              _FeatureCard(
                icon: Icons.repeat,
                title: 'Assinaturas Recorrentes',
                desc: 'Garanta previsibilidade de caixa com planos mensais automáticos para seus clientes.',
              ),
              _FeatureCard(
                icon: Icons.payments_outlined,
                title: 'Stripe Connect',
                desc: 'Receba pagamentos direto na sua conta com taxas competitivas e split automático.',
              ),
              _FeatureCard(
                icon: Icons.groups_outlined,
                title: 'Gestão de Equipe',
                desc: 'Controle o acesso de funcionários e monitore a produtividade em tempo real.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _FeatureCard({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF38BDF8), size: 40),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(desc, style: const TextStyle(color: Colors.white60, fontSize: 16)),
        ],
      ),
    );
  }
}

class _PricingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        children: [
          const Text('Preços simples para crescer', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Text('Plano Pro', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('R\$ 199/mês', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('+ 5% por transação', style: TextStyle(color: Colors.white60)),
                const SizedBox(height: 32),
                const _PriceItem('Lava-jato Ilimitado'),
                const _PriceItem('Até 5 Funcionários'),
                const _PriceItem('Suporte Prioritário'),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => context.push('/signup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    minimumSize: const Size(200, 60),
                  ),
                  child: const Text('Começar Agora', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceItem extends StatelessWidget {
  final String text;
  const _PriceItem(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, color: Color(0xFF10B981), size: 20),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: const Text('© 2026 CleanFlow SaaS • A solução definitiva para estética automotiva.', style: TextStyle(color: Colors.white30)),
    );
  }
}
