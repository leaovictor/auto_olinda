import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../common_widgets/atoms/primary_button.dart';
import '../../auth/domain/address.dart';
import '../data/store_repository.dart';
import '../data/current_store_provider.dart';
import '../../auth/data/auth_repository.dart';

class StoreSetupScreen extends ConsumerStatefulWidget {
  const StoreSetupScreen({super.key});

  @override
  ConsumerState<StoreSetupScreen> createState() => _StoreSetupScreenState();
}

class _StoreSetupScreenState extends ConsumerState<StoreSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final store = ref.read(currentStoreProvider).value;
    if (store != null) {
      _nameController.text = store.name;
      _phoneController.text = store.phoneNumber ?? '';
      if (store.address != null) {
        _streetController.text = store.address!.street;
        _numberController.text = store.address!.number;
        _neighborhoodController.text = store.address!.neighborhood;
        _cityController.text = store.address!.city;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final store = ref.read(currentStoreProvider).value;
      if (store == null) return;

      final updatedStore = store.copyWith(
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        address: Address(
          cep: '', // Added required cep field
          street: _streetController.text,
          number: _numberController.text,
          neighborhood: _neighborhoodController.text,
          city: _cityController.text,
          state: 'PE', // Default for now
        ),
      );

      await ref.read(storeRepositoryProvider).updateStore(updatedStore);
      
      if (mounted) {
        context.go('/admin');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar seu Lava-jato'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Bem-vindo ao Laavei!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Complete os dados do seu estabelecimento para começar.'),
              const SizedBox(height: 32),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Lava-jato',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone/WhatsApp',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),
              
              Text(
                'Endereço',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(labelText: 'Rua', border: OutlineInputBorder()),
                validator: (v) => v?.isEmpty ?? true ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _numberController,
                      decoration: const InputDecoration(labelText: 'Número', border: OutlineInputBorder()),
                      validator: (v) => v?.isEmpty ?? true ? 'Obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _neighborhoodController,
                      decoration: const InputDecoration(labelText: 'Bairro', border: OutlineInputBorder()),
                      validator: (v) => v?.isEmpty ?? true ? 'Obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Cidade', border: OutlineInputBorder()),
                validator: (v) => v?.isEmpty ?? true ? 'Obrigatório' : null,
              ),
              
              const SizedBox(height: 48),
              
              PrimaryButton(
                text: 'FINALIZAR CONFIGURAÇÃO',
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
