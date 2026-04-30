import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -100,
            left: -100,
            child: _GlowBlob(color: const Color(0xFF38BDF8).withValues(alpha: 0.2), size: 500),
          ),
          Positioned(
            bottom: 200,
            right: -100,
            child: _GlowBlob(color: const Color(0xFF818CF8).withValues(alpha: 0.1), size: 400),
          ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildNavbar(context, isDesktop),
                SliverToBoxAdapter(child: _buildHero(context, isDesktop)),
                SliverToBoxAdapter(child: _buildTrustedBy(context)),
                SliverToBoxAdapter(child: _buildOwnerValueProp(context, isDesktop)),
                SliverToBoxAdapter(child: _buildClientValueProp(context, isDesktop)),
                SliverToBoxAdapter(child: _buildPricing(context, isDesktop)),
                SliverToBoxAdapter(child: _buildFinalCTA(context)),
                SliverToBoxAdapter(child: _buildFooter(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavbar(BuildContext context, bool isDesktop) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24, vertical: 24),
        child: Row(
          children: [
            const _Logo(),
            const Spacer(),
            if (isDesktop) ...[
              _NavLink(label: 'Recursos', onTap: () {}),
              _NavLink(label: 'Preços', onTap: () {}),
              _NavLink(label: 'Clientes', onTap: () {}),
              const SizedBox(width: 24),
            ],
            TextButton(
              onPressed: () => context.push('/login'),
              child: const Text('Entrar', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            _PrimaryButton(
              label: 'Teste Grátis',
              onPressed: () => context.push('/signup'),
              small: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24, vertical: 60),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, color: Color(0xFFFACC15), size: 16),
                const SizedBox(width: 8),
                Text(
                  'A plataforma #1 para Detailing Shops',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ).animate().fadeIn().scale(),
          const SizedBox(height: 32),
          Text(
            'Gerencie seu Lava-jato\ncom Precisão Cirúrgica.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop ? 72 : 42,
              fontWeight: FontWeight.bold,
              height: 1.1,
              letterSpacing: -2,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Text(
              'Aumente sua receita recorrente com assinaturas, automatize agendamentos e tenha o controle total da sua equipe em uma única plataforma SaaS premium.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: isDesktop ? 20 : 16, height: 1.6),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PrimaryButton(label: 'Criar Minha Loja', onPressed: () => context.push('/signup')),
              const SizedBox(width: 16),
              if (isDesktop) _SecondaryButton(label: 'Agendar Demo', onPressed: () {}),
            ],
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }

  Widget _buildTrustedBy(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Text(
            'CONFIADO POR MAIS DE 500 ESTABELECIMENTOS',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 32),
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LogoPlaceholder(name: 'AutoGlow'),
                _LogoPlaceholder(name: 'ShinePro'),
                _LogoPlaceholder(name: 'AquaClean'),
                _LogoPlaceholder(name: 'PremiumWash'),
                _LogoPlaceholder(name: 'EliteDetail'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerValueProp(BuildContext context, bool isDesktop) {
    return _ValuePropSection(
      title: 'Para o Dono do Negócio',
      subtitle: 'Controle total da operação e crescimento exponencial.',
      imageOnLeft: false,
      isDesktop: isDesktop,
      features: const [
        _Benefit(icon: Icons.analytics, title: 'Dashboard de Receita', description: 'Veja seus lucros e recorrência em tempo real.'),
        _Benefit(icon: Icons.people, title: 'Gestão de Staff', description: 'Controle de turnos, comissões e performance da equipe.'),
        _Benefit(icon: Icons.subscriptions, title: 'Planos de Assinatura', description: 'Transforme lavagens avulsas em receita mensal garantida.'),
      ],
    );
  }

  Widget _buildClientValueProp(BuildContext context, bool isDesktop) {
    return _ValuePropSection(
      title: 'Para o Seu Cliente',
      subtitle: 'Uma experiência de luxo desde o primeiro clique.',
      imageOnLeft: true,
      isDesktop: isDesktop,
      features: const [
        _Benefit(icon: Icons.touch_app, title: 'Booking em 3 Cliques', description: 'Sem filas, sem ligações. Rápido e prático.'),
        _Benefit(icon: Icons.notifications_active, title: 'Alertas de Status', description: 'WhatsApp automático quando o carro estiver pronto.'),
        _Benefit(icon: Icons.credit_card, title: 'Pagamento Invisível', description: 'Check-out rápido com cartões salvos via Stripe.'),
      ],
    );
  }

  Widget _buildPricing(BuildContext context, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24, vertical: 100),
      child: Column(
        children: [
          const Text('Preços Simples e Transparentes', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 48),
          if (isDesktop)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                _PricingCard(plan: 'Starter', price: 'R\$ 199', features: ['Até 2 Staff', 'Agendamentos Ilimitados', 'Dashboard Básico']),
                SizedBox(width: 24),
                _PricingCard(plan: 'Pro', price: 'R\$ 399', isPopular: true, features: ['Staff Ilimitado', 'Módulo de Assinaturas', 'Analytics Avançado', 'API do WhatsApp']),
                SizedBox(width: 24),
                _PricingCard(plan: 'Enterprise', price: 'Sob Consulta', features: ['Multi-unidades', 'Gerente de Conta', 'SLA Garantido']),
              ],
            )
          else
            Column(
              children: const [
                _PricingCard(plan: 'Starter', price: 'R\$ 199', features: ['Até 2 Staff', 'Agendamentos Ilimitados']),
                SizedBox(height: 24),
                _PricingCard(plan: 'Pro', price: 'R\$ 399', isPopular: true, features: ['Staff Ilimitado', 'Assinaturas', 'WhatsApp']),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFinalCTA(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 100),
      child: Center(
        child: Column(
          children: [
            const Text(
              'Pronto para liderar o mercado?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            _PrimaryButton(label: 'Começar Agora - 14 dias grátis', onPressed: () => context.push('/signup')),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: const Column(
        children: [
          Divider(color: Colors.white10),
          SizedBox(height: 40),
          _Logo(),
          SizedBox(height: 16),
          Text('O futuro da gestão de car wash.', style: TextStyle(color: Colors.white38)),
          SizedBox(height: 24),
          Text('© 2026 CleanFlow. Todos os direitos reservados.', style: TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF818CF8)]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.local_car_wash, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        const Text('CleanFlow', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
      ],
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavLink({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool small;
  const _PrimaryButton({required this.label, required this.onPressed, this.small = false});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF38BDF8),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: small ? 20 : 32, vertical: small ? 12 : 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _SecondaryButton({required this.label, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white24),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}

class _LogoPlaceholder extends StatelessWidget {
  final String name;
  const _LogoPlaceholder({required this.name});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(name, style: const TextStyle(color: Colors.white12, fontSize: 28, fontWeight: FontWeight.bold)),
    );
  }
}

class _ValuePropSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool imageOnLeft;
  final bool isDesktop;
  final List<_Benefit> features;

  const _ValuePropSection({
    required this.title,
    required this.subtitle,
    required this.imageOnLeft,
    required this.isDesktop,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        ...features,
      ],
    );

    final imageContent = Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Center(child: Icon(Icons.auto_awesome, color: Colors.white.withValues(alpha: 0.1), size: 100)),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24, vertical: 80),
      child: isDesktop
          ? Row(
              children: [
                if (imageOnLeft) ...[Expanded(child: imageContent), const SizedBox(width: 80)],
                Expanded(child: textContent),
                if (!imageOnLeft) ...[const SizedBox(width: 80), Expanded(child: imageContent)],
              ],
            )
          : Column(
              children: [
                textContent,
                const SizedBox(height: 48),
                imageContent,
              ],
            ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _Benefit({required this.icon, required this.title, required this.description});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF38BDF8).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF38BDF8), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: Colors.white60, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final String plan;
  final String price;
  final List<String> features;
  final bool isPopular;

  const _PricingCard({required this.plan, required this.price, required this.features, this.isPopular = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isPopular ? const Color(0xFF1E293B) : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isPopular ? const Color(0xFF38BDF8) : Colors.white10, width: isPopular ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: const Color(0xFF38BDF8), borderRadius: BorderRadius.circular(20)),
              child: const Text('MAIS POPULAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          Text(plan, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(price, style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
          const Text('/mês', style: TextStyle(color: Colors.white38, fontSize: 14)),
          const SizedBox(height: 32),
          const Divider(color: Colors.white10),
          const SizedBox(height: 32),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF2DD4BF), size: 18),
                    const SizedBox(width: 12),
                    Text(f, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              )),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular ? const Color(0xFF38BDF8) : Colors.white10,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Selecionar Plano', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .move(duration: 8.seconds, begin: const Offset(0,0), end: const Offset(40, 50))
     .scale(duration: 8.seconds, begin: const Offset(1,1), end: const Offset(1.2, 1.2));
  }
}
