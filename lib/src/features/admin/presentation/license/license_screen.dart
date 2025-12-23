import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/admin_theme.dart';

class LicenseScreen extends StatelessWidget {
  const LicenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentYear = DateTime.now().year;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Licença de Software',
          style: AdminTheme.headingMedium,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AdminTheme.textPrimary),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AdminTheme.bgDark.withOpacity(0.9), Colors.transparent],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AdminTheme.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AdminTheme.gradientPrimary,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AdminTheme.gradientPrimary[0].withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.verified_user_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Auto Olinda',
                      style: AdminTheme.headingMedium.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sistema de Gestão de Lava-Jato',
                      style: AdminTheme.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.1),

              const SizedBox(height: 32),

              // Copyright Section
              _buildSection(
                icon: Icons.copyright_rounded,
                title: 'Direitos Autorais',
                content:
                    '© $currentYear Victor Leão\nTodos os direitos reservados.\n\nEste software é protegido pela Lei de Direitos Autorais (Lei 9.610/98) e convenções internacionais.',
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 16),

              // Developer Section
              _buildSection(
                icon: Icons.person_rounded,
                title: 'Desenvolvedor',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(theme, 'Nome', 'Victor Leão'),
                    _buildInfoRow(theme, 'Email', 'contato@victorleao.dev.br'),
                    const SizedBox(height: 12),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                            const ClipboardData(
                              text: 'contato@victorleao.dev.br',
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Email copiado!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Copiar Email'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AdminTheme.textPrimary,
                          side: const BorderSide(color: AdminTheme.borderLight),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 16),

              // License Terms Section
              _buildSection(
                icon: Icons.gavel_rounded,
                title: 'Termos de Licenciamento',
                content:
                    '''Este software é licenciado, não vendido. O uso é concedido mediante:

• Contrato de licenciamento por escrito
• Acordo de participação nos lucros (royalties)
• Pagamento de taxa de licenciamento

Proibições:
• Copiar, modificar ou distribuir o código
• Fazer engenharia reversa
• Sublicenciar a terceiros
• Remover avisos de copyright''',
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 16),

              // Jurisdiction Section
              _buildSection(
                icon: Icons.balance_rounded,
                title: 'Jurisdição',
                content:
                    'Este software é regido pelas leis da República Federativa do Brasil.\n\nForo: Comarca de Olinda/PE',
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 32),

              // Footer
              Center(
                child: Text(
                  'Para questões de licenciamento, entre em contato.',
                  style: AdminTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    String? content,
    Widget? child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AdminTheme.gradientPrimary[0].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AdminTheme.gradientPrimary[0],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(title, style: AdminTheme.headingSmall),
            ],
          ),
          const SizedBox(height: 16),
          if (content != null)
            Text(content, style: AdminTheme.bodyMedium.copyWith(height: 1.5)),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AdminTheme.bodyMedium.copyWith(
              color: AdminTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: AdminTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
