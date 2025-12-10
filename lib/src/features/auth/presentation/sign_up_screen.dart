import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../common_widgets/atoms/app_card.dart';
import '../../../common_widgets/atoms/app_text_field.dart';
import '../../../common_widgets/atoms/primary_button.dart';
import '../../../shared/utils/app_toast.dart';
import 'auth_controller.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  double _passwordStrength = 0.0;

  late AnimationController _animationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _logoRotateAnimation = Tween<double>(begin: 0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _passwordController.addListener(_updatePasswordStrength);
    _animationController.forward();
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
    double strength = 0.0;

    if (password.length >= 6) strength += 0.25;
    if (password.length >= 8) strength += 0.15;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;

    setState(() => _passwordStrength = strength.clamp(0.0, 1.0));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authControllerProvider.notifier)
          .signUp(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _nameController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      if (state.hasError) {
        AppToast.error(context, message: _getErrorMessage(state.error));
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
              theme.colorScheme.surface,
              theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo
                  _buildAnimatedLogo(theme),
                  const SizedBox(height: 32),

                  // Sign Up Card
                  AppCard(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title
                          _AnimatedFormElement(
                            delay: 0,
                            child: Text(
                              'Crie sua conta',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _AnimatedFormElement(
                            delay: 1,
                            child: Text(
                              'Junte-se ao AquaClean Pro',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Name field
                          _AnimatedFormElement(
                            delay: 2,
                            child: AppTextField(
                              controller: _nameController,
                              label: 'Nome Completo',
                              hint: 'Seu Nome',
                              prefixIcon: const Icon(Icons.person_outline),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira seu nome';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Email field
                          _AnimatedFormElement(
                            delay: 3,
                            child: AppTextField(
                              controller: _emailController,
                              label: 'E-mail',
                              hint: 'seu@email.com',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email_outlined),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira seu e-mail';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Por favor, insira um e-mail válido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password field with visibility toggle
                          _AnimatedFormElement(
                            delay: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppTextField(
                                  controller: _passwordController,
                                  label: 'Senha',
                                  hint: '••••••••',
                                  obscureText: _obscurePassword,
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      transitionBuilder: (child, animation) {
                                        return RotationTransition(
                                          turns: Tween(
                                            begin: 0.5,
                                            end: 1.0,
                                          ).animate(animation),
                                          child: FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        key: ValueKey(_obscurePassword),
                                        size: 22,
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      );
                                    },
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, insira sua senha';
                                    }
                                    if (value.length < 6) {
                                      return 'A senha deve ter pelo menos 6 caracteres';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                // Password strength indicator
                                _buildPasswordStrengthIndicator(theme),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Confirm password field
                          _AnimatedFormElement(
                            delay: 5,
                            child: AppTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirmar Senha',
                              hint: '••••••••',
                              obscureText: _obscureConfirmPassword,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  transitionBuilder: (child, animation) {
                                    return RotationTransition(
                                      turns: Tween(
                                        begin: 0.5,
                                        end: 1.0,
                                      ).animate(animation),
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    key: ValueKey(_obscureConfirmPassword),
                                    size: 22,
                                  ),
                                ),
                                onPressed: () {
                                  setState(
                                    () => _obscureConfirmPassword =
                                        !_obscureConfirmPassword,
                                  );
                                },
                              ),
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return 'As senhas não coincidem';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Submit button
                          _AnimatedFormElement(
                            delay: 6,
                            child: PrimaryButton(
                              text: 'Cadastrar',
                              icon: Icons.person_add_rounded,
                              isLoading: state.isLoading,
                              onPressed: _submit,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Divider
                          _AnimatedFormElement(
                            delay: 7,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    'ou',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Login link
                          _AnimatedFormElement(
                            delay: 8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Já tem uma conta?',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context.go('/login'),
                                  child: Text(
                                    'Entrar',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo(ThemeData theme) {
    return ScaleTransition(
      scale: _logoScaleAnimation,
      child: RotationTransition(
        turns: _logoRotateAnimation,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [theme.colorScheme.secondary, theme.colorScheme.primary],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add_alt_1_rounded,
            size: 50,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator(ThemeData theme) {
    Color strengthColor;
    String strengthText;

    if (_passwordStrength < 0.3) {
      strengthColor = Colors.red.shade400;
      strengthText = 'Fraca';
    } else if (_passwordStrength < 0.6) {
      strengthColor = Colors.orange.shade400;
      strengthText = 'Média';
    } else if (_passwordStrength < 0.8) {
      strengthColor = Colors.yellow.shade700;
      strengthText = 'Boa';
    } else {
      strengthColor = Colors.green.shade500;
      strengthText = 'Forte';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0, end: _passwordStrength),
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: theme.colorScheme.outlineVariant.withValues(
                  alpha: 0.3,
                ),
                valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                minHeight: 4,
              );
            },
          ),
        ),
        if (_passwordController.text.isNotEmpty) ...[
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              'Força da senha: $strengthText',
              key: ValueKey(strengthText),
              style: TextStyle(
                fontSize: 12,
                color: strengthColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getErrorMessage(Object? error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('email-already-in-use')) {
      return 'Este e-mail já está em uso';
    }
    if (errorString.contains('invalid-email')) {
      return 'E-mail inválido';
    }
    if (errorString.contains('weak-password')) {
      return 'A senha é muito fraca';
    }
    if (errorString.contains('network')) {
      return 'Erro de conexão. Verifique sua internet.';
    }
    return 'Ocorreu um erro. Tente novamente.';
  }
}

/// Animated wrapper for form elements with staggered entrance
class _AnimatedFormElement extends StatelessWidget {
  final Widget child;
  final int delay;

  const _AnimatedFormElement({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (delay * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
