import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'contato@victorleao.dev.br',
      query: 'subject=Contato via App CleanFlow',
    );

    if (!await launchUrl(emailLaunchUri)) {
      debugPrint('Could not launch $emailLaunchUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Container(
      width: double.infinity,
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(color: theme.dividerColor.withOpacity(0.1)),
          const SizedBox(height: 12),

          // Developer Credits
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Feito com ❤️ por ',
                style: theme.textTheme.bodySmall?.copyWith(color: textColor),
              ),
              Text(
                'Victor Leão',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Contact Link
          InkWell(
            onTap: _launchEmail,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                'contato@victorleao.dev.br',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Copyright & Legal text
          Text(
            'Todos os direitos reservados.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor.withValues(alpha: 0.5),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
