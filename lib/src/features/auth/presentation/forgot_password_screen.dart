import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../common_widgets/atoms/app_card.dart';
import '../../../common_widgets/atoms/app_text_field.dart';
import '../../../common_widgets/atoms/primary_button.dart';
import '../../../shared/utils/app_toast.dart';
import 'auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _successScaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _successScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authControllerProvider.notifier)
          .resetPassword(_emailController.text.trim());
    }
  }

  void _playSuccessAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      if (state.hasError) {
        AppToast.error(context, message: _getErrorMessage(state.error));
      } else if (!state.isLoading &&
          !state.hasError &&
          _emailController.text.isNotEmpty) {
        setState(() => _emailSent = true);
        _playSuccessAnimation();
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => context.go('/login'),
                      icon: const Icon(Icons.arrow_back_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Animated card
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: AppCard(
                        padding: const EdgeInsets.all(32.0),
                        child: _emailSent
                            ? _buildSuccessContent(theme)
                            : _buildFormContent(theme, state),
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

  Widget _buildFormContent(ThemeData theme, AsyncValue state) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Animated icon
          ScaleTransition(
            scale: _iconScaleAnimation,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_reset_rounded,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Esqueceu sua senha?',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Não se preocupe! Digite seu e-mail e enviaremos um link para redefinir sua senha.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // Email field with animation
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
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
          const SizedBox(height: 24),

          // Submit button with animation
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
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
            child: PrimaryButton(
              text: 'Enviar Link',
              icon: Icons.send_rounded,
              isLoading: state.isLoading,
              onPressed: _submit,
            ),
          ),
          const SizedBox(height: 16),

          // Back to login link
          TextButton.icon(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Voltar ao login'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Success icon with animation
        ScaleTransition(
          scale: _successScaleAnimation,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              size: 60,
              color: Colors.green.shade600,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Success title
        FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            'E-mail enviado!',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Success message
        FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            'Verifique sua caixa de entrada em\n${_emailController.text}\n\nSe não encontrar, verifique a pasta de spam.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Back to login button
        FadeTransition(
          opacity: _fadeAnimation,
          child: PrimaryButton(
            text: 'Voltar ao Login',
            icon: Icons.login_rounded,
            onPressed: () => context.go('/login'),
          ),
        ),
      ],
    );
  }

  String _getErrorMessage(Object? error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('user-not-found')) {
      return 'Não encontramos uma conta com este e-mail';
    }
    if (errorString.contains('invalid-email')) {
      return 'E-mail inválido';
    }
    if (errorString.contains('network')) {
      return 'Erro de conexão. Verifique sua internet.';
    }
    return 'Ocorreu um erro. Tente novamente.';
  }
}
