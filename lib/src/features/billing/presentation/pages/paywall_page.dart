import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/billing_functions.dart';
import '../../domain/subscription.dart';

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
              _buildIcon(status),
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
                    backgroundColor: _getActionColor(status),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _handleAction(context, ref),
                  child: Text(
                    _getButtonText(status),
                    style: const TextStyle(fontSize: 18),
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

  Widget _buildIcon(SubscriptionStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case SubscriptionStatus.pastDue:
        icon = Icons.credit_card_off;
        color = Colors.red;
        break;
      case SubscriptionStatus.canceled:
        icon = Icons.cancel_presentation;
        color = Colors.grey;
        break;
      case SubscriptionStatus.incomplete:
        icon = Icons.build_circle;
        color = Colors.orange;
        break;
      default:
        icon = Icons.lock_outline;
        color = Colors.amber;
    }

    return Icon(icon, size: 80, color: color);
  }

  String _getTitle(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.pastDue:
        return 'Pagamento Pendente';
      case SubscriptionStatus.canceled:
        return 'Assinatura Cancelada';
      case SubscriptionStatus.incomplete:
        return 'Configuração Incompleta';
      case SubscriptionStatus.trialing:
        return 'Período de Teste';
      default:
        return 'Acesso Restrito';
    }
  }

  String _getMessage(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.pastDue:
        return 'Não conseguimos processar o pagamento da sua última fatura. Atualize seu método de pagamento para restaurar o acesso imediato.';
      case SubscriptionStatus.canceled:
        return 'Sua assinatura foi cancelada. Reative sua assinatura para continuar aproveitando todos os recursos.';
      case SubscriptionStatus.incomplete:
        return 'Sua assinatura precisa ser finalizada. Complete o processo de pagamento para liberar o acesso.';
      default:
        return 'Para continuar utilizando o sistema, é necessário ter uma assinatura ativa.';
    }
  }

  String _getButtonText(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.pastDue:
        return 'Atualizar Pagamento';
      case SubscriptionStatus.canceled:
        return 'Reativar Assinatura';
      case SubscriptionStatus.incomplete:
        return 'Finalizar Configuração';
      default:
        return 'Gerenciar Assinatura';
    }
  }

  Color _getActionColor(SubscriptionStatus status) {
    if (status == SubscriptionStatus.pastDue) {
      return Colors.redAccent;
    }
    return Colors.blueAccent;
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

      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading
      }

      if (url != null) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao criar sessão de pagamento.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading on error
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }
}
