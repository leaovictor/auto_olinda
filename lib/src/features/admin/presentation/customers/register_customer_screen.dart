import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../subscription/domain/subscription_plan.dart';
import '../../data/admin_repository.dart';
import '../../../../shared/utils/app_toast.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_text_field.dart';
import '../widgets/admin_dropdown_field.dart';

class RegisterCustomerScreen extends ConsumerStatefulWidget {
  const RegisterCustomerScreen({super.key});

  @override
  ConsumerState<RegisterCustomerScreen> createState() =>
      _RegisterCustomerScreenState();
}

class _RegisterCustomerScreenState
    extends ConsumerState<RegisterCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  // Customer Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Vehicle Controllers
  final _plateController = TextEditingController();
  final _modelController = TextEditingController();

  // Selections
  String? _selectedVehicleCategory;
  SubscriptionPlan? _selectedPlan;

  // Payment
  CardFieldInputDetails? _cardDetails;
  bool _isLoading = false;

  // Vehicle categories
  static const List<String> _vehicleCategories = [
    'hatch',
    'suv',
    'moto',
    'pickup',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _plateController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Cadastrar Novo Cliente', style: AdminTheme.headingMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AdminTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AdminTheme.backgroundGradient,
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 32),
            children: [
              // Customer Section
              Container(
                decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dados do Cliente', style: AdminTheme.headingSmall),
                    const SizedBox(height: 16),
                    AdminTextField(
                      controller: _nameController,
                      label: 'Nome Completo',
                      hint: 'Ex: João Silva',
                      icon: Icons.person,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Campo obrigatório';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AdminTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Ex: joao@email.com',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Campo obrigatório';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Email inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AdminTextField(
                      controller: _phoneController,
                      label: 'WhatsApp',
                      hint: 'Ex: 11999999999',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      helperText: 'DDD + número (apenas dígitos)',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Campo obrigatório';
                        }
                        if (value.replaceAll(RegExp(r'\D'), '').length < 10) {
                          return 'Telefone inválido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              // Vehicle Section
              Container(
                decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Veículo', style: AdminTheme.headingSmall),
                    const SizedBox(height: 16),
                    AdminTextField(
                      controller: _plateController,
                      label: 'Placa',
                      hint: 'Ex: ABC1234',
                      icon: Icons.numbers,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                        LengthLimitingTextInputFormatter(7),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          return newValue.copyWith(
                            text: newValue.text.toUpperCase(),
                          );
                        }),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Campo obrigatório';
                        }
                        if (value.trim().length < 7) {
                          return 'Placa deve ter 7 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AdminTextField(
                      controller: _modelController,
                      label: 'Modelo do Veículo',
                      hint: 'Ex: Corolla, Civic',
                      icon: Icons.directions_car,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Campo obrigatório';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AdminDropdownField<String>(
                      label: 'Categoria',
                      value: _selectedVehicleCategory,
                      hint: 'Selecione a categoria',
                      items: _vehicleCategories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(
                                  cat.substring(0, 1).toUpperCase() + cat.substring(1),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedVehicleCategory = value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione uma categoria';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              // Subscription Plan Section
              Container(
                decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Plano de Assinatura', style: AdminTheme.headingSmall),
                    const SizedBox(height: 16),
                    _buildPlanSelection(),
                  ],
                ),
              ),

              // Payment Section
              Container(
                decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dados de Pagamento', style: AdminTheme.headingSmall),
                    const SizedBox(height: 8),
                    const Text(
                      'Insira os dados do cartão para a cobrança.',
                      style: AdminTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AdminTheme.borderMedium),
                      ),
                      child: CardField(
                        onCardChanged: (details) {
                          setState(() => _cardDetails = details);
                        },
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Submit Button
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AdminTheme.gradientPrimary),
                  borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
                  boxShadow: AdminTheme.glowShadow(
                    AdminTheme.gradientPrimary[0],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Cadastrar Cliente',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanSelection() {
    final plansAsync = ref.watch(adminPlansProvider);

    return plansAsync.when(
      data: (plans) {
        if (plans.isEmpty) {
          return const Center(
            child: Text('Nenhum plano disponível.'),
          );
        }
        return AdminDropdownField<SubscriptionPlan>(
          label: 'Plano',
          value: _selectedPlan,
          hint: 'Selecione um plano',
          items: plans
              .map(
                (plan) => DropdownMenuItem(
                  value: plan,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'R\$ ${plan.price.toStringAsFixed(2)}/mês • ${plan.washesPerMonth} lavagens',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (plan) => setState(() => _selectedPlan = plan),
          validator: (value) {
            if (value == null) {
              return 'Selecione um plano';
            }
            return null;
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(
        child: Text('Erro ao carregar planos: $e'),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPlan == null) {
      AppToast.error(context, message: 'Selecione um plano');
      return;
    }

    if (_selectedVehicleCategory == null) {
      AppToast.error(context, message: 'Selecione a categoria do veículo');
      return;
    }

    if (_cardDetails?.complete != true) {
      AppToast.error(
        context,
        message: 'Preencha corretamente os dados do cartão',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create Payment Method
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      // Prepare data for cloud function
      final data = {
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim().replaceAll(RegExp(r'\D'), ''),
        'plate': _plateController.text.trim().toUpperCase(),
        'vehicleModel': _modelController.text.trim(),
        'vehicleCategory': _selectedVehicleCategory,
        'planId': _selectedPlan!.id,
        'paymentMethodId': paymentMethod.id,
      };

      // Call cloud function
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      await functions.httpsCallable('registerCustomerByAdmin').call(data);

      if (mounted) {
        AppToast.success(
          context,
          message: 'Cliente cadastrado com sucesso!',
        );
        context.pop();
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        AppToast.error(
          context,
          message: 'Erro: ${e.message ?? 'Falha ao cadastrar cliente'}',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(
          context,
          message: 'Erro inesperado: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
