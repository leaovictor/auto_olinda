import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentSettingsScreen extends ConsumerStatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  ConsumerState<PaymentSettingsScreen> createState() =>
      _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends ConsumerState<PaymentSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _publishableKeyController = TextEditingController();
  final _secretKeyController = TextEditingController();
  final _webhookSecretController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('admin_settings')
          .doc('payments')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _publishableKeyController.text =
            data['stripe_publishable_key'] as String? ?? '';
        _secretKeyController.text = data['stripe_secret_key'] as String? ?? '';
        // We might not want to expose webhook secret here if it's set via params,
        // but if we want to make it dynamic too:
        // _webhookSecretController.text = data['stripe_webhook_secret'] as String? ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar configurações: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('admin_settings')
          .doc('payments')
          .set({
            'stripe_publishable_key': _publishableKeyController.text.trim(),
            'stripe_secret_key': _secretKeyController.text.trim(),
            'updated_at': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configurações salvas com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _publishableKeyController.dispose();
    _secretKeyController.dispose();
    _webhookSecretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações de Pagamento')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Stripe Keys',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Essas chaves serão usadas para processar pagamentos. '
                      'Mantenha a Secret Key segura e nunca a compartilhe.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _publishableKeyController,
                      decoration: const InputDecoration(
                        labelText: 'Publishable Key',
                        border: OutlineInputBorder(),
                        helperText: 'Começa com pk_test_ ou pk_live_',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }
                        if (!value.startsWith('pk_')) {
                          return 'Formato inválido (deve começar com pk_)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _secretKeyController,
                      decoration: const InputDecoration(
                        labelText: 'Secret Key',
                        border: OutlineInputBorder(),
                        helperText: 'Começa com sk_test_ ou sk_live_',
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }
                        if (!value.startsWith('sk_')) {
                          return 'Formato inválido (deve começar com sk_)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveSettings,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Salvar Alterações'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
