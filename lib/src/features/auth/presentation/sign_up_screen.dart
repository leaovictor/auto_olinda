import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../common_widgets/atoms/app_text_field.dart';
import '../../../common_widgets/atoms/primary_button.dart';
import '../../../shared/utils/app_toast.dart';
import 'auth_controller.dart';
import 'widgets/auth_branding_panel.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authControllerProvider.notifier).signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            displayName: _nameController.text.trim(),
            role: 'tenantOwner', // Always Owner in this flow
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      if (state.hasError) {
        AppToast.error(context, message: state.error.toString());
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Row(
        children: [
          if (isDesktop) const Expanded(flex: 5, child: AuthBrandingPanel()),
          Expanded(
            flex: 4,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Comece seu Negócio',
                          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Crie sua conta administrativa e configure seu lava-jato em minutos.',
                          style: TextStyle(color: Colors.white60, fontSize: 16),
                        ),
                        const SizedBox(height: 40),
                        
                        AppTextField(
                          controller: _nameController,
                          label: 'Seu Nome',
                          hint: 'Ex: João Silva',
                          prefixIcon: const Icon(Icons.person_outline, color: Colors.white60),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _emailController,
                          label: 'E-mail Profissional',
                          hint: 'exemplo@empresa.com',
                          prefixIcon: const Icon(Icons.email_outlined, color: Colors.white60),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _passwordController,
                          label: 'Senha',
                          hint: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white60),
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirmar Senha',
                          hint: '••••••••',
                          prefixIcon: const Icon(Icons.lock_reset, color: Colors.white60),
                          obscureText: true,
                          validator: (val) => val != _passwordController.text ? 'As senhas não coincidem' : null,
                        ),
                        const SizedBox(height: 32),
                        PrimaryButton(
                          text: 'Criar Meu Painel',
                          isLoading: state.isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Já possui uma loja?', style: TextStyle(color: Colors.white60)),
                            TextButton(
                              onPressed: () => context.push('/login'),
                              child: const Text('Entrar no Painel', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
