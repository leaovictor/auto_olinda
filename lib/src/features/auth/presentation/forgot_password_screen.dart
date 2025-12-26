import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../common_widgets/atoms/app_text_field.dart';
import '../../../common_widgets/atoms/primary_button.dart';
import '../../../shared/utils/app_toast.dart';
import '../../../core/theme/app_colors.dart';
import 'auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
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
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),

          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _buildBackButton(),
                      ),
                      const SizedBox(height: 24),

                      // Animated Logo
                      _buildAnimatedLogo()
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(
                            duration: 3.seconds,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                      const SizedBox(height: 40),

                      // Glassmorphic Card
                      _emailSent
                          ? _buildSuccessCard(theme)
                          : _buildFormCard(context, state, theme),

                      const SizedBox(height: 32),
                      // Brand tagline
                      Text(
                        'AquaClean • Gestão Inteligente',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ).animate().fadeIn(delay: 1.seconds),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.tertiary.withValues(alpha: 0.9),
            AppColors.secondary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Floating Bubbles
          ...List.generate(15, (index) {
            final random = DateTime.now().millisecondsSinceEpoch + index;
            final x = (random * 7) % 100 / 100;
            final y = (random * 13) % 100 / 100;
            final size = 20.0 + (random % 60);
            final duration = 3000 + (random % 4000);

            return Positioned(
              left: MediaQuery.of(context).size.width * x,
              top: MediaQuery.of(context).size.height * y,
              child:
                  Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .moveY(
                        begin: 0,
                        end: -100,
                        duration: duration.ms,
                        curve: Curves.easeInOut,
                      )
                      .fadeIn(duration: (duration / 2).ms)
                      .fadeOut(delay: (duration / 2).ms),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => context.go('/login'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'Voltar',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2);
  }

  Widget _buildAnimatedLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 70,
          height: 70,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_reset_rounded,
            size: 35,
            color: AppColors.primary,
          ),
        ),
      ),
    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut);
  }

  Widget _buildFormCard(
    BuildContext context,
    AsyncValue state,
    ThemeData theme,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Esqueceu sua senha?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ).animate().custom(
                  duration: 600.ms,
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Não se preocupe! Digite seu e-mail e enviaremos um link para redefinir sua senha.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 32),

                // Email field
                AppTextField(
                  controller: _emailController,
                  label: 'E-mail',
                  hint: 'seu@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Colors.white,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  labelStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  borderColor: Colors.white.withValues(alpha: 0.3),
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
                ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),
                const SizedBox(height: 28),

                // Submit button
                PrimaryButton(
                      text: 'Enviar Link',
                      icon: Icons.send_rounded,
                      isLoading: state.isLoading,
                      onPressed: _submit,
                      backgroundColor: Colors.white,
                      textColor: AppColors.primary,
                    )
                    .animate()
                    .scale(delay: 400.ms, begin: const Offset(0.9, 0.9))
                    .shimmer(delay: 1.5.seconds, duration: 1200.ms),

                const SizedBox(height: 20),

                // Back to login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lembrou a senha?',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text(
                        'Entrar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildSuccessCard(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.green.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.1),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              // Success icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 45,
                  color: Colors.white,
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),

              // Success title
              Text(
                'E-mail enviado!',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 12),

              // Success message
              Text(
                'Verifique sua caixa de entrada em\n${_emailController.text}\n\nSe não encontrar, verifique a pasta de spam.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 32),

              // Back to login button
              PrimaryButton(
                    text: 'Voltar ao Login',
                    icon: Icons.login_rounded,
                    onPressed: () => context.go('/login'),
                    backgroundColor: Colors.white,
                    textColor: Colors.green.shade700,
                  )
                  .animate()
                  .fadeIn(delay: 400.ms)
                  .scale(begin: const Offset(0.9, 0.9)),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.95, 0.95));
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
