import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../features/auth/domain/app_user.dart';
import '../../../../features/auth/data/auth_repository.dart';
import '../../../../features/subscription/domain/subscription_plan.dart';
import '../../../../features/subscription/data/subscription_repository.dart';
import '../../data/admin_repository.dart';
import '../../../../shared/utils/app_toast.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_text_field.dart';

class NewSubscriberDialog extends ConsumerStatefulWidget {
  const NewSubscriberDialog({super.key});

  @override
  ConsumerState<NewSubscriberDialog> createState() =>
      _NewSubscriberDialogState();
}

class _NewSubscriberDialogState extends ConsumerState<NewSubscriberDialog> {
  int _currentStep = 0;
  AppUser? _selectedUser;
  SubscriptionPlan? _selectedPlan;
  CardFieldInputDetails? _cardDetails;
  bool _isLoading = false;

  // User Form Controllers
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cpfController = TextEditingController(); // New CPF Controller

  // Coupon removed (ecommerce not in SaaS scope)
  // Keeping _couponController for potential future promo code feature
  final _couponController = TextEditingController();
  final bool _isValidatingCoupon = false;
  String _couponError = '';

  bool _isCreatingUser = false; // Toggle for "New Client" form
  String _errorMessage = ''; // Local error message for form validation

  List<AppUser> _filterUsers(List<AppUser> users) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return users;
    return users.where((u) {
      final name = u.displayName?.toLowerCase() ?? '';
      final email = u.email.toLowerCase();
      final phone = u.phoneNumber ?? '';
      return name.contains(query) ||
          email.contains(query) ||
          phone.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AdminTheme.bgCard,
      title: const Text('Novo Assinante', style: AdminTheme.headingSmall),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Stepper Header
              Row(
                children: [
                  _buildStepHeader(0, 'Usuário'),
                  _buildStepDivider(),
                  _buildStepHeader(1, 'Plano'),
                  _buildStepDivider(),
                  _buildStepHeader(2, 'Pagamento'),
                ],
              ),
              const SizedBox(height: 24),
              // Step Content
              _buildStepContent(),
            ],
          ),
        ),
      ),
      actions: _buildActions(),
    );
  }

  Widget _buildStepHeader(int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AdminTheme.gradientPrimary[0]
                  : AdminTheme.bgCardLight,
              border: isCurrent
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                '${step + 1}',
                style: TextStyle(
                  color: isActive ? Colors.white : AdminTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive
                  ? AdminTheme.textPrimary
                  : AdminTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider() {
    return Container(
      width: 40,
      height: 2,
      color: AdminTheme.borderLight,
      margin: const EdgeInsets.only(bottom: 20),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildUserSelection();
      case 1:
        return _buildPlanSelection();
      case 2:
        return _buildPaymentDetails();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildUserSelection() {
    final usersAsync = ref.watch(adminUsersProvider);

    return usersAsync.when(
      data: (users) {
        final filteredUsers = _filterUsers(users);

        return Column(
          children: [
            if (!_isCreatingUser)
              AdminTextField(
                controller: _searchController,
                label: 'Buscar usuário...',
                hint: 'Buscar usuário...',
                icon: Icons.search,
                onChanged: (val) => setState(() {}),
              ),
            const SizedBox(height: 16),
            if (_isCreatingUser)
              _buildUserForm()
            else
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: AdminTheme.borderLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: filteredUsers.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhum usuário encontrado',
                          style: AdminTheme.bodyMedium.copyWith(
                            color: AdminTheme.textSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          final isSelected = _selectedUser?.uid == user.uid;

                          return ListTile(
                            selected: isSelected,
                            selectedTileColor: AdminTheme.gradientPrimary[0]
                                .withOpacity(0.1),
                            leading: CircleAvatar(
                              backgroundColor: AdminTheme.bgCardLight,
                              child: Text(
                                user.displayName
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    'U',
                                style: const TextStyle(
                                  color: AdminTheme.textPrimary,
                                ),
                              ),
                            ),
                            title: Text(
                              user.displayName ?? 'Sem Nome',
                              style: const TextStyle(
                                color: AdminTheme.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              user.email,
                              style: const TextStyle(
                                color: AdminTheme.textSecondary,
                              ),
                            ),
                            onTap: () {
                              setState(() => _selectedUser = user);
                            },
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: AdminTheme.gradientPrimary[0],
                                  )
                                : null,
                          );
                        },
                      ),
              ),
            if (!_isCreatingUser)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isCreatingUser = true;
                      _selectedUser = null;
                      _nameController.clear();
                      _emailController.clear();
                      _phoneController.clear();
                      _cpfController.clear();
                      _errorMessage = '';
                    });
                  },
                  icon: Icon(
                    Icons.person_add,
                    color: AdminTheme.gradientPrimary[0],
                  ), // Error: Invalid constant value
                  label: Text(
                    'Cadastrar Novo Cliente',
                    style: TextStyle(
                      color: AdminTheme.gradientPrimary[0],
                    ), // Error: Invalid constant value
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Erro ao carregar usuários: $e'),
    );
  }

  Widget _buildUserForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Novo Cliente', style: AdminTheme.headingSmall),
            IconButton(
              onPressed: () => setState(() => _isCreatingUser = false),
              icon: const Icon(Icons.close, color: AdminTheme.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildInput(_nameController, 'Nome Completo', icon: Icons.person),
        const SizedBox(height: 12),
        _buildInput(
          _emailController,
          'Email',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInput(
                _phoneController,
                'Telefone',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInput(
                _cpfController,
                'CPF',
                icon: Icons.badge,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
      ],
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label, {
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    return AdminTextField(
      controller: controller,
      label: label,
      icon: icon,
      keyboardType: keyboardType,
    );
  }

  Widget _buildPlanSelection() {
    final plansAsync = ref.watch(activePlansProvider);

    return plansAsync.when(
      data: (plans) {
        if (plans.isEmpty) {
          return const Center(child: Text('Nenhum plano ativo encontrado.'));
        }
        return Column(
          children: plans.map((plan) {
            final isSelected = _selectedPlan?.id == plan.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedPlan = plan),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AdminTheme.gradientPrimary[0].withOpacity(0.1)
                        : AdminTheme.bgCardLight,
                    border: Border.all(
                      color: isSelected
                          ? AdminTheme.gradientPrimary[0]
                          : AdminTheme.borderLight,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Radio<SubscriptionPlan>(
                        value: plan,
                        groupValue: _selectedPlan,
                        onChanged: (val) => setState(() => _selectedPlan = val),
                        activeColor: AdminTheme.gradientPrimary[0],
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name,
                              style: AdminTheme.headingSmall.copyWith(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${plan.washesPerMonth} lavagens/mês',
                              style: AdminTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'R\$ ${plan.price.toStringAsFixed(2)}',
                        style: AdminTheme.headingSmall.copyWith(
                          color: AdminTheme.gradientPrimary[0],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Erro ao carregar planos: $e'),
    );
  }

  Widget _buildPaymentDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dados do Cartão', style: AdminTheme.headingSmall),
        const SizedBox(height: 8),
        const Text(
          'Insira os dados do cartão para a cobrança recorrente.',
          style: AdminTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AdminTheme.borderLight),
          ),
          child: CardField(
            onCardChanged: (details) {
              setState(() => _cardDetails = details);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              labelText: 'Cartão de Crédito',
            ),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Inter',
            ),
          ),
        ),
        if (_selectedUser != null && _selectedPlan != null)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AdminTheme.bgCardLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    'Usuário',
                    _selectedUser!.displayName ?? _selectedUser!.email,
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Plano', _selectedPlan!.name),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Valor',
                    'R\$ ${_selectedPlan!.price.toStringAsFixed(2)}/mês',
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCouponInput() {
    // Coupon/promo code placeholder — ecommerce Coupon model removed.
    // Wire up a promo code field here when the feature is re-added.
    return const SizedBox.shrink();
  }

  Future<void> _validateCoupon() async {
    // Coupon validation removed with ecommerce module.
    // Placeholder for future promo code feature.
    setState(() => _couponError = 'Cupons não disponíveis nesta versão.');
  }

  double _calculateTotal() {
    return _selectedPlan?.price ?? 0.0;
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isDiscount = false,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AdminTheme.bodyMedium),
        Text(
          value,
          style: TextStyle(
            color: isDiscount ? Colors.green : AdminTheme.textPrimary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActions() {
    return [
      if (_currentStep > 0)
        TextButton(
          onPressed: _isLoading ? null : () => setState(() => _currentStep--),
          child: const Text(
            'Voltar',
            style: TextStyle(color: AdminTheme.textSecondary),
          ),
        ),
      FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AdminTheme.gradientPrimary[0],
        ),
        onPressed: _isLoading ? null : _handleNext,
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(_currentStep == 2 ? 'Finalizar' : 'Próximo'),
      ),
    ];
  }

  void _handleNext() async {
    if (_currentStep == 0) {
      // Step 0: User Selection or Creation
      if (_isCreatingUser) {
        // Validate and Create User
        if (_nameController.text.isEmpty ||
            _emailController.text.isEmpty ||
            _cpfController.text.isEmpty) {
          setState(
            () => _errorMessage =
                'Preencha todos os campos obrigatórios (Nome, Email, CPF).',
          );
          return;
        }
        await _createAndSelectUser();
      } else {
        if (_selectedUser == null) {
          AppToast.error(
            context,
            message: 'Selecione um usuário para continuar.',
          );
          return;
        }
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (_selectedPlan == null) {
        AppToast.error(context, message: 'Selecione um plano para continuar.');
        return;
      }
      setState(() => _currentStep++);
    } else {
      // Final Step: Submit
      if (_cardDetails?.complete != true) {
        AppToast.error(
          context,
          message: 'Preencha os dados do cartão corretamente.',
        );
        return;
      }

      await _submitSubscription();
    }
  }

  Future<void> _submitSubscription() async {
    setState(() => _isLoading = true);
    try {
      // 1. Create Payment Method via Stripe
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      // 2. Call Admin Repository to create subscription on backend
      await ref
          .read(subscriptionRepositoryProvider)
          .adminCreateSubscription(
            userId: _selectedUser!.uid,
            plan: _selectedPlan!,
            paymentMethodId: paymentMethod.id,
            couponId: null,
          );

      if (mounted) {
        Navigator.of(context).pop(true); // Return success
        AppToast.success(context, message: 'Assinatura criada com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao criar assinatura: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createAndSelectUser() async {
    setState(() => _isLoading = true);
    try {
      // Read current admin's tenantId so the new customer is scoped correctly.
      final adminTenantId =
          ref.read(currentUserProfileProvider).valueOrNull?.tenantId ?? '';

      final newUser = AppUser(
        uid: DateTime.now().millisecondsSinceEpoch.toString(),
        email: _emailController.text.trim(),
        displayName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        cpf: _cpfController.text.trim(),
        role: 'customer',
        status: 'active',
        tenantId: adminTenantId.isNotEmpty ? adminTenantId : null,
      );

      await ref.read(adminRepositoryProvider).createUser(newUser);

      setState(() {
        _selectedUser = newUser;
        _isCreatingUser = false;
        _currentStep++;
      });
    } catch (e) {
      setState(() => _errorMessage = 'Erro ao criar usuário: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
