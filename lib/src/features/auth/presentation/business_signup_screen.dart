import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../common_widgets/atoms/app_text_field.dart';
import '../../../common_widgets/atoms/primary_button.dart';
import '../../../shared/utils/app_toast.dart';
import '../../../core/theme/app_colors.dart';

class BusinessSignUpScreen extends StatefulWidget {
  const BusinessSignUpScreen({super.key});

  @override
  State<BusinessSignUpScreen> createState() => _BusinessSignUpScreenState();
}

class _BusinessSignUpScreenState extends State<BusinessSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _businessNameController = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create a Lead document in global scope
      await FirebaseFirestore.instance.collection('leads_saas').add({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'businessName': _businessNameController.text.trim(),
        'status': 'new',
        'source': 'app_landing',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isLoading = false;
        _isSubmitted = true;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppToast.error(context, message: 'Erro ao enviar dados. Tente novamente.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 32),
                  onPressed: () => context.go('/landing'),
                ).animate().fadeIn(),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: _isSubmitted ? _buildSuccessState(theme) : _buildFormState(theme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormState(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAnimatedLogo()
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(
              duration: 3.seconds,
              color: Colors.white.withValues(alpha: 0.3),
            ),
        const SizedBox(height: 32),
        _buildGlassCard(context, theme),
      ],
    );
  }

  Widget _buildSuccessState(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            color: Colors.white,
            size: 80,
          ),
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 32),
        Text(
          'Solicitação Enviada!',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(),
        const SizedBox(height: 16),
        Text(
          'Nossa equipe comercial entrará em contato com você em breve para configurar sua estética automotiva na plataforma Auto Olinda.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 48),
        PrimaryButton(
          text: 'Voltar ao Início',
          onPressed: () => context.go('/landing'),
          backgroundColor: Colors.white,
          textColor: AppColors.primary,
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }

  Widget _buildGlassCard(BuildContext context, ThemeData theme) {
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
                  'Seja um Parceiro',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 26,
                  ),
                ).animate().slideY(begin: -0.2),
                const SizedBox(height: 8),
                Text(
                  'Preencha os dados e entraremos em contato para configurar o seu painel de gestão.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 32),

                _buildFieldWrapper(
                  delay: 250,
                  child: AppTextField(
                    controller: _nameController,
                    label: 'Seu Nome',
                    hint: 'Nome Completo',
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.white),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    borderColor: Colors.white.withValues(alpha: 0.3),
                    validator: (v) => v!.isEmpty ? 'Insira seu nome' : null,
                  ),
                ),
                const SizedBox(height: 16),

                _buildFieldWrapper(
                  delay: 300,
                  child: AppTextField(
                    controller: _emailController,
                    label: 'E-mail Comercial',
                    hint: 'contato@empresa.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.white),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    borderColor: Colors.white.withValues(alpha: 0.3),
                    validator: (v) => v!.contains('@') ? null : 'E-mail inválido',
                  ),
                ),
                const SizedBox(height: 16),

                _buildFieldWrapper(
                  delay: 350,
                  child: AppTextField(
                    controller: _phoneController,
                    label: 'Telefone / WhatsApp',
                    hint: '(00) 00000-0000',
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined, color: Colors.white),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    borderColor: Colors.white.withValues(alpha: 0.3),
                    validator: (v) => v!.isEmpty ? 'Insira um telefone' : null,
                  ),
                ),
                const SizedBox(height: 16),

                _buildFieldWrapper(
                  delay: 400,
                  child: AppTextField(
                    controller: _businessNameController,
                    label: 'Nome da Estética / Lava Jato',
                    hint: 'Sua Empresa',
                    prefixIcon: const Icon(Icons.business_outlined, color: Colors.white),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    borderColor: Colors.white.withValues(alpha: 0.3),
                    validator: (v) => v!.isEmpty ? 'Insira o nome do seu negócio' : null,
                  ),
                ),
                const SizedBox(height: 32),

                PrimaryButton(
                      text: 'Solicitar Acesso',
                      icon: Icons.send_rounded,
                      isLoading: _isLoading,
                      onPressed: _submit,
                      backgroundColor: Colors.white,
                      textColor: AppColors.secondary,
                    )
                    .animate()
                    .scale(delay: 500.ms, begin: const Offset(0.9, 0.9)),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildFieldWrapper({required int delay, required Widget child}) {
    return child.animate().fadeIn(delay: delay.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primary,
            AppColors.secondary.withValues(alpha: 0.8),
            AppColors.tertiary,
          ],
        ),
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
          child: Image.asset('assets/autoolinda_logo.png', fit: BoxFit.contain),
        ),
      ),
    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut);
  }
}
