import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common_widgets/atoms/app_text_field.dart';
import '../../../common_widgets/atoms/primary_button.dart';
import '../../../shared/utils/app_toast.dart';
import '../../../core/theme/app_colors.dart';
import 'auth_controller.dart';
import 'multi_step_acceptance_screen.dart';
import '../domain/nda_content.dart';
import 'widgets/auth_branding_panel.dart';

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

  // NDA acceptance state
  bool _hasAcceptedNda = false;
  late DateTime _ndaAcceptanceDate;
  late String _ndaText;

  @override
  void initState() {
    super.initState();
    _ndaAcceptanceDate = DateTime.now();
    _ndaText = NdaContent.generateFullText(_ndaAcceptanceDate);
    _passwordController.addListener(_updatePasswordStrength);
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
            _ndaText,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= kAuthDesktopBreakpoint;

    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      if (state.hasError) {
        AppToast.error(context, message: _getErrorMessage(state.error));
      }
    });

    // Show multi-step acceptance screen first if not accepted
    if (!_hasAcceptedNda) {
      return MultiStepAcceptanceScreen(
        onAccept: () {
          setState(() => _hasAcceptedNda = true);
        },
        onDecline: () {
          context.go('/login');
        },
        acceptanceDate: _ndaAcceptanceDate,
      );
    }

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            // Left: Branding Panel
            const Expanded(flex: 5, child: AuthBrandingPanel()),
            // Right: Form
            Expanded(flex: 4, child: _buildFormSection(context, state, theme)),
          ],
        ),
      );
    }

    // Mobile Layout
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAnimatedLogo()
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(
                          duration: 3.seconds,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                    const SizedBox(height: 40),
                    _buildGlassCard(context, state, theme),
                    const SizedBox(height: 32),
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
        ],
      ),
    );
  }

  /// Desktop form section (right side)
  Widget _buildFormSection(
    BuildContext context,
    AsyncValue state,
    ThemeData theme,
  ) {
    return Container(
      color: Colors.grey[50],
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Crie sua conta',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ).animate().fadeIn().slideY(begin: -0.2),

                const SizedBox(height: 8),

                Text(
                  'Junte-se ao AquaClean Pro',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 40),

                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        controller: _nameController,
                        label: 'Nome Completo',
                        hint: 'Seu Nome',
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: AppColors.secondary,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu nome';
                          }
                          return null;
                        },
                      ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.1),

                      const SizedBox(height: 16),

                      AppTextField(
                        controller: _emailController,
                        label: 'E-mail',
                        hint: 'seu@email.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppColors.secondary,
                        ),
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
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),

                      const SizedBox(height: 16),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextField(
                            controller: _passwordController,
                            label: 'Senha',
                            hint: '••••••••',
                            obscureText: _obscurePassword,
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: AppColors.secondary,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
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
                          const SizedBox(height: 10),
                          _buildPasswordStrengthIndicator(forDesktop: true),
                        ],
                      ).animate().fadeIn(delay: 250.ms).slideX(begin: 0.1),

                      const SizedBox(height: 16),

                      AppTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirmar Senha',
                        hint: '••••••••',
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: AppColors.secondary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'As senhas não coincidem';
                          }
                          return null;
                        },
                      ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),

                      const SizedBox(height: 32),

                      PrimaryButton(
                            text: 'Criar Conta',
                            icon: Icons.person_add_rounded,
                            isLoading: state.isLoading,
                            onPressed: _submit,
                          )
                          .animate()
                          .fadeIn(delay: 350.ms)
                          .scale(begin: const Offset(0.95, 0.95)),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Já tem uma conta?',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: Text(
                              'Entrar',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 400.ms),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
            AppColors.secondary,
            AppColors.primary.withValues(alpha: 0.9),
            AppColors.tertiary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
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
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset('assets/aquaclean_logo.svg', fit: BoxFit.contain),
        ),
      ),
    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut);
  }

  Widget _buildGlassCard(
    BuildContext context,
    AsyncValue state,
    ThemeData theme,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(28.0),
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
                  'Crie sua conta',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 26,
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
                const SizedBox(height: 6),
                Text(
                  'Junte-se ao AquaClean Pro',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 28),

                _buildFieldWrapper(
                  delay: 250,
                  child: AppTextField(
                    controller: _nameController,
                    label: 'Nome Completo',
                    hint: 'Seu Nome',
                    prefixIcon: const Icon(
                      Icons.person_outline,
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
                        return 'Por favor, insira seu nome';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                _buildFieldWrapper(
                  delay: 300,
                  child: AppTextField(
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
                  ),
                ),
                const SizedBox(height: 16),

                _buildFieldWrapper(
                  delay: 350,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        controller: _passwordController,
                        label: 'Senha',
                        hint: '••••••••',
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
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
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
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
                      const SizedBox(height: 10),
                      _buildPasswordStrengthIndicator(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _buildFieldWrapper(
                  delay: 400,
                  child: AppTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirmar Senha',
                    hint: '••••••••',
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
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
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 28),

                PrimaryButton(
                      text: 'Criar Conta',
                      icon: Icons.person_add_rounded,
                      isLoading: state.isLoading,
                      onPressed: _submit,
                      backgroundColor: Colors.white,
                      textColor: AppColors.secondary,
                    )
                    .animate()
                    .scale(delay: 500.ms, begin: const Offset(0.9, 0.9))
                    .shimmer(delay: 1.5.seconds, duration: 1200.ms),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Já tem uma conta?',
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
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildFieldWrapper({required int delay, required Widget child}) {
    return child.animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildPasswordStrengthIndicator({bool forDesktop = false}) {
    Color strengthColor;
    String strengthText;

    if (_passwordStrength < 0.3) {
      strengthColor = forDesktop ? Colors.red : Colors.red.shade300;
      strengthText = 'Fraca';
    } else if (_passwordStrength < 0.6) {
      strengthColor = forDesktop ? Colors.orange : Colors.orange.shade300;
      strengthText = 'Média';
    } else if (_passwordStrength < 0.8) {
      strengthColor = forDesktop ? Colors.amber : Colors.yellow.shade300;
      strengthText = 'Boa';
    } else {
      strengthColor = forDesktop ? Colors.green : Colors.green.shade300;
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
                backgroundColor: forDesktop
                    ? Colors.grey.shade200
                    : Colors.white.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                minHeight: 4,
              );
            },
          ),
        ),
        if (_passwordController.text.isNotEmpty) ...[
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              'Força da senha: $strengthText',
              key: ValueKey(strengthText),
              style: TextStyle(
                fontSize: 12,
                color: strengthColor,
                fontWeight: FontWeight.w600,
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
