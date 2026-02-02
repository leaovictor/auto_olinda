import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lavaflow_app/core/theme/app_colors.dart';
import '../../../common_widgets/atoms/app_text_field.dart';
import '../../../common_widgets/atoms/primary_button.dart';
import '../../../shared/utils/app_toast.dart';
import '../data/auth_repository.dart';
import '../../tenant/data/tenant_repository.dart';

class SaasSignupScreen extends ConsumerStatefulWidget {
  const SaasSignupScreen({super.key});

  @override
  ConsumerState<SaasSignupScreen> createState() => _SaasSignupScreenState();
}

class _SaasSignupScreenState extends ConsumerState<SaasSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController(); // Tenant Name
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // 1. Create User via AuthController (or Repository directly)
        // We use repository directly here to get the User object back easily
        // But for consistency let's use AuthController to sign up, then TenantRepo

        // Actually, we must create the user first.
        // Let's assume AuthController.signUp handles user creation.
        // But we need the UID to create the tenant.

        // STRATEGY: Create User -> Get UID -> Create Tenant -> Update User Profile

        final authRepo = ref.read(authRepositoryProvider);
        final user = await authRepo.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          displayName: _nameController.text.trim(),
        );

        // 2. Create Tenant
        await ref
            .read(tenantRepositoryProvider)
            .createTenant(
              name: _businessNameController.text.trim(),
              ownerId: user.uid,
              ownerEmail: user.email,
            );

        AppToast.success(context, message: 'Conta criada com sucesso!');

        // 3. Navigate to Admin Dashboard
        if (mounted) {
          // Force refresh of auth state/profile
          ref.invalidate(currentUserProfileProvider);
          context.go('/admin');
        }
      } catch (e) {
        AppToast.error(context, message: 'Erro ao criar conta: $e');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.primary, // Navy background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Registre sua Estética',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Comece seu teste grátis de 7 dias.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Business Info
                      Text(
                        'DA EMPRESA',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[500],
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _businessNameController,
                        label: 'Nome da Estética / Lavajato',
                        hint: 'Ex: Lava Jato Premium',
                        prefixIcon: const Icon(Icons.store_rounded),
                        validator: (v) =>
                            v?.isEmpty == true ? 'Obrigatório' : null,
                      ),
                      const SizedBox(height: 24),

                      // Owner Info
                      Text(
                        'SEUS DADOS',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[500],
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _nameController,
                        label: 'Seu Nome Completo',
                        hint: 'Ex: João Silva',
                        prefixIcon: const Icon(Icons.person),
                        validator: (v) =>
                            v?.isEmpty == true ? 'Obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _emailController,
                        label: 'E-mail Profissional',
                        hint: 'seu@email.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email),
                        validator: (v) =>
                            v?.isEmpty == true ? 'Obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _passwordController,
                        label: 'Senha',
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        validator: (v) =>
                            (v?.length ?? 0) < 6 ? 'Mínimo 6 caracteres' : null,
                      ),

                      const SizedBox(height: 32),
                      PrimaryButton(
                        text: 'CRIAR CONTA & COMEÇAR',
                        onPressed: _isLoading ? null : _submit,
                        isLoading: _isLoading,
                        backgroundColor: AppColors.secondary, // Gold
                      ),

                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text(
                          'Já tem conta? Fazer Login',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().slideY(begin: 0.1, duration: 400.ms).fadeIn(),
          ),
        ),
      ),
    );
  }
}
