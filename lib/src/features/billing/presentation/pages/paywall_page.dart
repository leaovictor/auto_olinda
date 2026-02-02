import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../features/billing/data/billing_functions.dart';
import '../features/billing/domain/subscription.dart';

class PaywallPage extends ConsumerWidget {
  final SubscriptionStatus status;

  const PaywallPage({super.key, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: Colors.amber),
              const SizedBox(height: 24),
              Text(
                _getTitle(status),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _getMessage(status),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _handleAction(context, ref),
                  child: const Text(
                    'Resolver Agora',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              if (status == SubscriptionStatus.pastDue) ...[
                const SizedBox(height: 16),
                const Text(
                  'Seus dados estão seguros, mas o acesso está temporariamente bloqueado.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.pastDue:
        return 'Pagamento Pendente';
      case SubscriptionStatus.canceled:
        return 'Assinatura Cancelada';
      case SubscriptionStatus.incomplete:
        return 'Configuração Pendente';
      default:
        return 'Acesso Restrito';
    }
  }

  String _getMessage(SubscriptionStatus status) {
    if (status == SubscriptionStatus.pastDue) {
      return 'Não conseguimos cobrar sua última fatura. Atualize seu método de pagamento para liberar o acesso.';
    }
    return 'Para continuar utilizando o JetClub, é necessário ativar uma assinatura válida.';
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final url = await ref
          .read(billingFunctionsServiceProvider)
          .createPortalSession(
            returnUrl: 'https://jetclub.app/', // Deep Link or App Scheme
          );

      Navigator.pop(context); // Dismiss loading

      if (url != null) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao criar sessão de pagamento.')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Dismiss loading on error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }
}
