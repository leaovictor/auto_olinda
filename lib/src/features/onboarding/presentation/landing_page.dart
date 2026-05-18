import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../common_widgets/atoms/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../store/data/current_store_provider.dart';
import '../../store/data/store_repository.dart';

class LandingPage extends ConsumerStatefulWidget {
  final String? slug;
  const LandingPage({super.key, this.slug});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  @override
  void initState() {
    super.initState();
    if (widget.slug != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadStore();
      });
    }
  }

  Future<void> _loadStore() async {
    final store = await ref.read(storeRepositoryProvider).getStoreBySlug(widget.slug!);
    if (store != null) {
      ref.read(currentStoreProvider.notifier).setStore(store.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;
    final currentStore = ref.watch(currentStoreProvider).value;

    final storeName = currentStore?.name ?? 'Laavei';

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HERO SECTION
            _buildHeroSection(context, theme, size, isDesktop, storeName, currentStore?.logoUrl),

            // FEATURES SECTION
            _buildFeaturesSection(context, theme, size, isDesktop),

            // WHY CHOOSE US SECTION
            _buildBenefitSection(context, theme, size, isDesktop),

            // FINAL CTA
            _buildFinalCTA(context, theme, size, isDesktop, storeName),

            // FOOTER
            _buildFooter(context, theme, storeName),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, ThemeData theme, Size size, bool isDesktop, String storeName, String? logoUrl) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? size.width * 0.1 : 24,
        vertical: isDesktop ? 100 : 60,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
            AppColors.tertiary,
          ],
        ),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: logoUrl != null 
              ? Image.network(logoUrl, height: 80)
              : Image.asset('assets/laavei_logo.png', height: 80),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          
          const SizedBox(height: 32),
          
          Text(
            storeName,
            style: theme.textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

          const SizedBox(height: 16),

          Text(
            'A gestão inteligente que faz sua\nestética automotiva brilhar.',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w300,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

          const SizedBox(height: 48),

          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              SizedBox(
                width: isDesktop ? 200 : double.infinity,
                child: PrimaryButton(
                  text: 'COMEÇAR AGORA',
                  backgroundColor: Colors.white,
                  textColor: AppColors.primary,
                  onPressed: () => context.go('/signup?role=admin'),
                ),
              ).animate().fadeIn(delay: 600.ms).scale(),
              
              SizedBox(
                width: isDesktop ? 200 : double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/login'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('JÁ SOU CLIENTE', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ).animate().fadeIn(delay: 800.ms).scale(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, ThemeData theme, Size size, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? size.width * 0.1 : 24,
        vertical: 80,
      ),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'Tudo o que você precisa em um só lugar',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 60),
          
          isDesktop 
            ? Row(
                children: [
                  Expanded(child: _buildFeatureCard(Icons.calendar_month, 'Agendamento Online', 'Reduza faltas e organize sua agenda automaticamente.', theme)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildFeatureCard(Icons.people, 'Gestão de Clientes', 'Histórico completo de serviços e preferências de cada cliente.', theme)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildFeatureCard(Icons.bar_chart, 'Relatórios de Lucro', 'Saiba exatamente quanto você está ganhando por dia e por serviço.', theme)),
                ],
              )
            : Column(
                children: [
                  _buildFeatureCard(Icons.calendar_month, 'Agendamento Online', 'Reduza faltas e organize sua agenda automaticamente.', theme),
                  const SizedBox(height: 24),
                  _buildFeatureCard(Icons.people, 'Gestão de Clientes', 'Histórico completo de serviços e preferências de cada cliente.', theme),
                  const SizedBox(height: 24),
                  _buildFeatureCard(Icons.bar_chart, 'Relatórios de Lucro', 'Saiba exatamente quanto você está ganhando por dia e por serviço.', theme),
                ],
              ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryContainer),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.primary),
          const SizedBox(height: 20),
          Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(description, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildBenefitSection(BuildContext context, ThemeData theme, Size size, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? size.width * 0.1 : 24,
        vertical: 80,
      ),
      color: AppColors.surface,
      child: Column(
        children: [
          Text(
            'Por que escolher o nosso serviço?',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          
          _buildCheckItem('Aumente sua receita em até 30% com agendamentos automáticos.', theme),
          _buildCheckItem('Acabe com o papel e caneta. Tenha tudo no seu celular ou tablet.', theme),
          _buildCheckItem('Transmita mais profissionalismo e confiança para seus clientes.', theme),
          _buildCheckItem('Notificações via WhatsApp que lembram seus clientes da lavagem.', theme),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: AppColors.tertiary),
          const SizedBox(width: 12),
          Flexible(child: Text(text, style: theme.textTheme.titleMedium)),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildFinalCTA(BuildContext context, ThemeData theme, Size size, bool isDesktop, String storeName) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        children: [
          Text(
            'Pronto para transformar seu negócio?',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: isDesktop ? 300 : double.infinity,
            child: PrimaryButton(
              text: 'EXPERIMENTAR GRÁTIS',
              onPressed: () => context.go('/signup?role=admin'),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sem compromisso. Cancele quando quiser.',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme, String storeName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      color: Colors.grey[900],
      child: Column(
        children: [
          Text(
            '© 2026 $storeName • Gestão Automotiva Inteligente',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          Text(
            'Feito com ❤️ para estéticas automotivas brasileiras',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600], fontSize: 10),
          ),
        ],
      ),
    );
  }
}
