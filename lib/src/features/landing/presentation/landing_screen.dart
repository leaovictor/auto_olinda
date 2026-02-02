import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lavaflow_app/core/theme/app_colors.dart';
import 'package:lavaflow_app/src/common_widgets/atoms/primary_button.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.waves, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'LavaFlow',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Login'),
          ),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SizedBox(
              width: 140, // Reduced width for fitting
              child: PrimaryButton(
                text: 'Começar',
                onPressed: () => context.go('/register-business'),
                backgroundColor: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HERO SECTION
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      Text(
                        'A Revolução Digital para sua Estética Automotiva',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 24),
                      Text(
                        'Transforme seu lavajato em um negócio de assinatura recorrente. Venda planos, gerencie a agenda e fidelize clientes com nosso app White-Label.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          height: 1.4,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: 250,
                        height: 56,
                        child: PrimaryButton(
                          text: 'TESTAR GRATUITAMENTE',
                          icon: Icons.rocket_launch,
                          onPressed: () => context.go('/register-business'),
                          backgroundColor: AppColors.secondary, // Gold
                          textColor: Colors.white,
                        ),
                      ).animate().scale(delay: 500.ms),
                      const SizedBox(height: 16),
                      Text(
                        '7 dias grátis • Sem cartão de crédito •ancele quando quiser',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // FEATURES GRID
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 700;
                    return Wrap(
                      spacing: 32,
                      runSpacing: 32,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildFeatureCard(
                          icon: Icons.attach_money,
                          title: 'Receita Recorrente',
                          desc:
                              'Crie clubes de assinatura e garanta faturamento fixo todo mês.',
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildFeatureCard(
                          icon: Icons.calendar_month,
                          title: 'Agenda Inteligente',
                          desc:
                              'Controle agendamentos, evite conflitos e gerencie seu time.',
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildFeatureCard(
                          icon: Icons.phone_iphone,
                          title: 'App Próprio',
                          desc:
                              'Seus clientes baixam um app profissional com a sua marca.',
                          width: isMobile ? double.infinity : 300,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // PRICING
            Container(
              color: AppColors.primaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Planos Simples e Transparentes',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Wrap(
                    spacing: 32,
                    runSpacing: 32,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildPricingCard(
                        title: 'Start',
                        price: 'R\$ 197',
                        features: [
                          'Até 100 Clientes',
                          'Dashboard Básico',
                          'Agenda Online',
                        ],
                        isPopular: false,
                      ),
                      _buildPricingCard(
                        title: 'Pro',
                        price: 'R\$ 397',
                        features: [
                          'Clientes Ilimitados',
                          'Clube de Assinaturas',
                          'Gestão Financeira',
                          'Múltiplos Usuários',
                        ],
                        isPopular: true,
                        onPressed: () => context.go('/register-business'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // FOOTER
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.all(48),
              width: double.infinity,
              child: Column(
                children: [
                  const Icon(Icons.waves, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'LavaFlow',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2024 LavaFlow Tecnologia. Todos os direitos reservados.',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String desc,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(desc, style: TextStyle(color: Colors.grey[600], height: 1.5)),
        ],
      ),
    ).animate().moveY(begin: 30, duration: 600.ms, curve: Curves.easeOut);
  }

  Widget _buildPricingCard({
    required String title,
    required String price,
    required List<String> features,
    required bool isPopular,
    VoidCallback? onPressed,
  }) {
    return Stack(
      children: [
        Container(
          width: 320,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: isPopular
                ? Border.all(color: AppColors.secondary, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isPopular ? AppColors.secondary : Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Text('/mês', style: TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 32),
              ...features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: isPopular ? AppColors.secondary : Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(f),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'COMEÇAR AGORA',
                  onPressed: onPressed ?? () {},
                  backgroundColor: isPopular
                      ? AppColors.primary
                      : Colors.grey[200],
                  textColor: isPopular ? Colors.white : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        if (isPopular)
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'MAIS VENDIDO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
