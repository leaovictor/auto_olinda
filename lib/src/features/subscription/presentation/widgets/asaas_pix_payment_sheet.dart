import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/utils/app_toast.dart';
import '../../domain/subscription_plan.dart';
import '../../../../common_widgets/atoms/primary_button.dart';
import '../../../../common_widgets/atoms/app_loader.dart';
import '../../data/subscription_repository.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../payment/data/asaas_repository.dart';

class AsaasPixPaymentSheet extends ConsumerStatefulWidget {
  final SubscriptionPlan plan;
  final String userId;
  final String? couponId;
  final String? vehicleId;
  final String? vehiclePlate;
  final String? vehicleCategory;
  final VoidCallback onSuccess;
  final Function(String) onError;

  const AsaasPixPaymentSheet({
    required this.plan,
    required this.userId,
    required this.onSuccess,
    required this.onError,
    this.couponId,
    this.vehicleId,
    this.vehiclePlate,
    this.vehicleCategory,
    super.key,
  });

  @override
  ConsumerState<AsaasPixPaymentSheet> createState() => _AsaasPixPaymentSheetState();
}

class _AsaasPixPaymentSheetState extends ConsumerState<AsaasPixPaymentSheet> {
  bool _isLoading = true;
  bool _isSuccess = false;
  bool _isPolling = false;
  String? _error;
  String? _pixCode;
  String? _pixImage;
  String? _paymentId;
  double? _amount;

  @override
  void initState() {
    super.initState();
    _generatePix();
  }

  Future<void> _generatePix() async {
    try {
      final user = ref.read(currentUserProfileProvider).valueOrNull;
      if (user == null) throw Exception('Usuário não encontrado');

      final asaasRepo = ref.read(asaasRepositoryProvider);

      // 1. Ensure customer exists
      final customerId = await asaasRepo.createCustomer(
        name: user.displayName ?? 'Cliente',
        cpfCnpj: user.cpf ?? '',
        email: user.email ?? '',
        phone: user.phoneNumber ?? '',
      );

      // 2. Create Payment
      final paymentData = await asaasRepo.createPixPayment(
        customerId: customerId,
        value: widget.plan.price, // Should subtract discount if any
        description: 'Assinatura Laavei: ${widget.plan.name}',
        externalReference: widget.userId,
      );

      if (mounted) {
        setState(() {
          _paymentId = paymentData['paymentId'];
          _pixCode = paymentData['pixCode'];
          _pixImage = paymentData['pixImage'];
          _amount = widget.plan.price;
          _isLoading = false;
        });
        _startPolling();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _startPolling() {
    setState(() => _isPolling = true);
    _pollStatus();
  }

  Future<void> _pollStatus() async {
    // Poll for 10 minutes
    for (int i = 0; i < 120; i++) {
      if (!mounted || _isSuccess) return;
      await Future.delayed(const Duration(seconds: 5));

      try {
        final subRepo = ref.read(subscriptionRepositoryProvider);
        final sub = await subRepo.getAnyUserSubscription(widget.userId);

        if (sub != null && sub.isActive) {
          if (mounted) {
            setState(() {
              _isSuccess = true;
              _isPolling = false;
            });
            await Future.delayed(const Duration(seconds: 2));
            widget.onSuccess();
          }
          return;
        }
      } catch (e) {
        // Silent error
      }
    }
    
    if (mounted) {
      setState(() => _isPolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isSuccess) {
      return _buildFullWidthModal(
        theme,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(
              'Pagamento Confirmado!',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 8),
            const Text('Sua assinatura foi ativada com sucesso.'),
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    if (_isLoading) {
      return _buildFullWidthModal(
        theme,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLoader(),
            SizedBox(height: 16),
            Text('Gerando seu Pix...'),
            SizedBox(height: 24),
          ],
        ),
      );
    }

    if (_error != null) {
      return _buildFullWidthModal(
        theme,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 64),
            const SizedBox(height: 16),
            Text('Erro ao Gerar Pix', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.error)),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            PrimaryButton(text: 'Tentar Novamente', onPressed: _generatePix),
            const SizedBox(height: 12),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
          ],
        ),
      );
    }

    return _buildFullWidthModal(
      theme,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.pix, color: Color(0xFF32BCAD), size: 32),
              const SizedBox(width: 12),
              Text('Pagamento via Pix', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          if (_pixImage != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Image.memory(base64Decode(_pixImage!), width: 200, height: 200),
              ),
            ),
          const SizedBox(height: 24),
          if (_pixCode != null)
            PrimaryButton(
              text: 'COPIAR CÓDIGO PIX',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _pixCode!));
                AppToast.success(context, message: 'Código copiado!');
              },
            ),
          const SizedBox(height: 24),
          if (_isPolling)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 12),
                Text('Aguardando confirmação...', style: theme.textTheme.bodySmall?.copyWith(color: Colors.blue)),
              ],
            ),
          const SizedBox(height: 16),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ],
      ),
    );
  }

  Widget _buildFullWidthModal(ThemeData theme, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: child,
    );
  }
}
