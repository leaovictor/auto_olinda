import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

/// Modal that prompts user to update the web app
class UpdateRequiredDialog extends StatelessWidget {
  const UpdateRequiredDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const UpdateRequiredDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(
          Icons.system_update,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        title: const Text(
          'Nova Versão Disponível',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Uma nova versão do aplicativo está disponível. '
              'Por favor, atualize para continuar usando.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Clique no botão abaixo para recarregar.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _reloadApp(context),
              icon: const Icon(Icons.refresh),
              label: const Text('Atualizar Agora'),
            ),
          ),
        ],
      ),
    );
  }

  void _reloadApp(BuildContext context) {
    if (kIsWeb) {
      // Use url_launcher to reload the current page
      // This works with both JS and WASM compilation
      launchUrl(Uri.parse(Uri.base.toString()), webOnlyWindowName: '_self');
    }
  }
}
