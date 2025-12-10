import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../common_widgets/atoms/app_card.dart';
import '../../../common_widgets/atoms/app_text_field.dart';
import '../../../common_widgets/atoms/primary_button.dart';
import '../../../shared/utils/app_toast.dart';
import '../../../core/services/version_service.dart';
import 'auth_controller.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

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

    _logoRotateAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              theme.colorScheme.surface,
              theme.colorScheme.secondaryContainer.withValues(alpha: 0.2),
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

                  // Login Card
                  AppCard(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Welcome text with staggered animation
                          _AnimatedFormElement(
                            delay: 0,
                            child: Text(
                              'Bem-vindo de volta!',
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
                              'Faça login para continuar',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Email field
                          _AnimatedFormElement(
                            delay: 2,
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
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password field with visibility toggle
                          _AnimatedFormElement(
                            delay: 3,
                            child: AppTextField(
                              controller: _passwordController,
                              label: 'Senha',
                              hint: '••••••••',
                              obscureText: _obscurePassword,
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
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    key: ValueKey(_obscurePassword),
                                    size: 22,
                                  ),
                                ),
                                onPressed: () {
                                  setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  );
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira sua senha';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Forgot password link
                          _AnimatedFormElement(
                            delay: 4,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => context.go('/forgot-password'),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                ),
                                child: Text(
                                  'Esqueceu sua senha?',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Submit button
                          _AnimatedFormElement(
                            delay: 5,
                            child: PrimaryButton(
                              text: 'Entrar',
                              icon: Icons.login_rounded,
                              isLoading: state.isLoading,
                              onPressed: _submit,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Divider
                          _AnimatedFormElement(
                            delay: 6,
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

                          // Sign up link
                          _AnimatedFormElement(
                            delay: 7,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Não tem uma conta?',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context.go('/signup'),
                                  child: Text(
                                    'Cadastre-se',
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
                  // Version footer
                  const SizedBox(height: 24),
                  Text(
                    'v$currentAppVersion',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.water_drop_rounded,
            size: 50,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getErrorMessage(Object? error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('user-not-found') ||
        errorString.contains('wrong-password') ||
        errorString.contains('invalid-credential')) {
      return 'E-mail ou senha incorretos';
    }
    if (errorString.contains('invalid-email')) {
      return 'E-mail inválido';
    }
    if (errorString.contains('user-disabled')) {
      return 'Esta conta foi desativada';
    }
    if (errorString.contains('too-many-requests')) {
      return 'Muitas tentativas. Tente novamente mais tarde.';
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
