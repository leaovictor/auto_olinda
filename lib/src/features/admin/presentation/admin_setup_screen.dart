import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../common_widgets/atoms/app_text_field.dart';
import '../../../common_widgets/atoms/primary_button.dart';
import '../../../shared/utils/app_toast.dart';
import '../../auth/data/auth_repository.dart';

class AdminSetupScreen extends ConsumerStatefulWidget {
  const AdminSetupScreen({super.key});

  @override
  ConsumerState<AdminSetupScreen> createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends ConsumerState<AdminSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _setupTenant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      // Call the Cloud Function to setup the new tenant
      // Note: We use southamerica-east1 as configured in our functions
      final result = await FirebaseFunctions.instanceFor(region: 'southamerica-east1')
          .httpsCallable('setupTenant')
          .call({
        'name': _nameController.text.trim(),
        'ownerUid': user.uid,
      });

      if (result.data['success'] == true) {
        AppToast.success(context, message: 'Lava-jato criado com sucesso!');
        
        // Invalidate profile to get the new tenantId
        ref.invalidate(currentUserProfileProvider);
        
        // Wait a bit for the profile to sync then go to admin
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) context.go('/admin');
        });
      }
    } catch (e) {
      AppToast.error(context, message: 'Erro ao criar lava-jato: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF38BDF8), size: 64),
                const SizedBox(height: 24),
                const Text(
                  'Bem-vindo ao CleanFlow!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Falta apenas um passo para começar. Qual o nome do seu lava-jato?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 16),
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _nameController,
                        label: 'Nome do Estabelecimento',
                        hint: 'Ex: Estética Automotiva Olinda',
                        prefixIcon: const Icon(Icons.storefront, color: Colors.white60),
                        validator: (val) => val == null || val.isEmpty ? 'Informe o nome' : null,
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        text: 'Criar Meu Lava-jato',
                        isLoading: _isLoading,
                        onPressed: _setupTenant,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => ref.read(authRepositoryProvider).signOut(),
                        child: const Text('Sair', style: TextStyle(color: Colors.white30)),
                      ),
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
}
