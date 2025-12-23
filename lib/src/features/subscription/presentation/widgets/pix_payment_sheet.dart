import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../domain/subscription_plan.dart';
import '../../../../common_widgets/atoms/primary_button.dart';
import '../../../payment/data/abacate_pay_service.dart';

class PixPaymentSheet extends ConsumerStatefulWidget {
  final SubscriptionPlan plan;
  final String pixCopyPaste;
  final String pixQrUrl;
  final String billingId;
  final VoidCallback onSuccess;
  final Function(String) onError;

  const PixPaymentSheet({
    required this.plan,
    required this.pixCopyPaste,
    required this.pixQrUrl,
    required this.billingId,
    required this.onSuccess,
    required this.onError,
    super.key,
  });

  @override
  ConsumerState<PixPaymentSheet> createState() => _PixPaymentSheetState();
}

class _PixPaymentSheetState extends ConsumerState<PixPaymentSheet> {
  bool _isSuccess = false;
  bool _isPolling = true;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() async {
    // Poll for status every 5 seconds
    while (_isPolling && mounted) {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted || !_isPolling) return;

      try {
        // TODO: Implement getBillingStatus in AbacatePayService properly
        // For now we assume manual check or eventual consistency
      } catch (e) {
        debugPrint('Polling error: $e');
      }
    }
  }

  @override
  void dispose() {
    _isPolling = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    if (_isSuccess) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(
              'Pagamento Confirmado!',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(text: 'Continuar', onPressed: widget.onSuccess),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.pix, color: Color(0xFF32BCAD), size: 32),
                const SizedBox(width: 12),
                Text(
                  'Pagamento via PIX',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Amount
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Valor a pagar:', style: theme.textTheme.titleMedium),
                  Text(
                    'R\$ ${widget.plan.price.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // QR Code
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: QrImageView(
                  data: widget.pixCopyPaste,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Copy Paste
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.pixCopyPaste,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: widget.pixCopyPaste),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Código PIX copiado!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            PrimaryButton(
              text: 'Já fiz o pagamento',
              onPressed: () {
                // Manually confirm for now or trigger re-check
                widget.onSuccess();
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
