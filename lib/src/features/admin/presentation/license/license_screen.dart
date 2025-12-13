import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LicenseScreen extends StatelessWidget {
  const LicenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentYear = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Licença de Software'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Auto Olinda',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sistema de Gestão de Lava-Jato',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.1),

            const SizedBox(height: 32),

            // Copyright Section
            _buildSection(
              theme,
              icon: Icons.copyright_rounded,
              title: 'Direitos Autorais',
              content:
                  '© $currentYear Victor Leão\nTodos os direitos reservados.\n\nEste software é protegido pela Lei de Direitos Autorais (Lei 9.610/98) e convenções internacionais.',
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 16),

            // Developer Section
            _buildSection(
              theme,
              icon: Icons.person_rounded,
              title: 'Desenvolvedor',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(theme, 'Nome', 'Victor Leão'),
                  _buildInfoRow(theme, 'Email', 'contato@victorleao.dev.br'),
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
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            // License Terms Section
            _buildSection(
              theme,
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
              theme,
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
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme, {
    required IconData icon,
    required String title,
    String? content,
    Widget? child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (content != null)
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
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
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
