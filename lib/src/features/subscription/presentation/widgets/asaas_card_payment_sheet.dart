import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brasil_fields/brasil_fields.dart';
import '../../../../shared/utils/app_toast.dart';
import '../../domain/subscription_plan.dart';
import '../../../../common_widgets/atoms/primary_button.dart';
import '../../../../common_widgets/atoms/app_loader.dart';
import '../../data/subscription_repository.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../payment/data/asaas_repository.dart';

class AsaasCardPaymentSheet extends ConsumerStatefulWidget {
  final SubscriptionPlan plan;
  final String userId;
  final String? couponId;
  final String? vehicleId;
  final String? vehiclePlate;
  final String? vehicleCategory;
  final VoidCallback onSuccess;
  final Function(String) onError;

  const AsaasCardPaymentSheet({
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
  ConsumerState<AsaasCardPaymentSheet> createState() => _AsaasCardPaymentSheetState();
}

class _AsaasCardPaymentSheetState extends ConsumerState<AsaasCardPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _cardNumberController = TextEditingController();
  final _holderNameController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _holderCpfController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill holder name from profile if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProfileProvider).valueOrNull;
      if (user != null) {
        _holderNameController.text = user.displayName ?? '';
        _holderCpfController.text = user.cpf ?? '';
      }
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _holderNameController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _holderCpfController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

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

      // 2. Prepare Card Data
      final expiry = _expiryDateController.text.split('/');
      final cardData = {
        'holderName': _holderNameController.text.trim(),
        'number': _cardNumberController.text.replaceAll(' ', ''),
        'expiryMonth': expiry[0],
        'expiryYear': '20' + expiry[1],
        'ccv': _cvvController.text,
      };

      final holderInfo = {
        'name': _holderNameController.text.trim(),
        'email': user.email,
        'cpfCnpj': _holderCpfController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        'postalCode': '53000000', // Default or fetch from user
        'addressNumber': '0',
        'phone': user.phoneNumber?.replaceAll(RegExp(r'[^0-9]'), '') ?? '81999999999',
      };

      // 3. Create Subscription
      final result = await asaasRepo.createSubscription(
        customerId: customerId,
        value: widget.plan.price,
        nextDueDate: DateTime.now().add(const Duration(days: 1)).toIso8601String().split('T')[0],
        creditCard: cardData,
        creditCardHolderInfo: holderInfo,
      );

      if (result['status'] == 'ACTIVE' || result['status'] == 'AWAITING_PAYMENT') {
        widget.onSuccess();
      } else {
        throw Exception('Status da assinatura: ${result['status']}');
      }
    } catch (e) {
      widget.onError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Dados do Cartão',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Card Number
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CardNumberInputFormatter(),
                ],
                decoration: const InputDecoration(
                  labelText: 'Número do Cartão',
                  prefixIcon: Icon(Icons.credit_card),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.length < 16) ? 'Número inválido' : null,
              ),
              const SizedBox(height: 16),

              // Holder Name
              TextFormField(
                controller: _holderNameController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Nome no Cartão',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  // Expiry
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _expiryDateController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ValidadeCartaoInputFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Validade (MM/AA)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.length < 5) ? 'Inválido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // CVV
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.length < 3) ? 'Inválido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Holder CPF
              TextFormField(
                controller: _holderCpfController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CpfInputFormatter(),
                ],
                decoration: const InputDecoration(
                  labelText: 'CPF do Titular',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || !CPFValidator.isValid(v)) ? 'CPF inválido' : null,
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                text: 'FINALIZAR ASSINATURA',
                isLoading: _isLoading,
                onPressed: _handlePayment,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
