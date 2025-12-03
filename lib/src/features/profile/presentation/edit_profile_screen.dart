import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/address.dart';
import '../../../common_widgets/atoms/primary_button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _cepController;
  late TextEditingController _streetController;
  late TextEditingController _numberController;
  late TextEditingController _complementController;
  late TextEditingController _neighborhoodController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;

  bool _isWhatsApp = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProfileProvider).value;
    _nameController = TextEditingController(text: user?.displayName);
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '+55');
    if (_phoneController.text.isEmpty) {
      _phoneController.text = '+55';
    }
    _cepController = TextEditingController(text: user?.address?.cep);
    _streetController = TextEditingController(text: user?.address?.street);
    _numberController = TextEditingController(text: user?.address?.number);
    _complementController = TextEditingController(
      text: user?.address?.complement,
    );
    _neighborhoodController = TextEditingController(
      text: user?.address?.neighborhood,
    );
    _cityController = TextEditingController(text: user?.address?.city);
    _stateController = TextEditingController(text: user?.address?.state);
    _isWhatsApp = user?.isWhatsApp ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cepController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _fetchAddressByCep(String cep) async {
    if (cep.length != 8) return;

    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cep/json/'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['erro'] != true) {
          setState(() {
            _streetController.text = data['logradouro'] ?? '';
            _neighborhoodController.text = data['bairro'] ?? '';
            _cityController.text = data['localidade'] ?? '';
            _stateController.text = data['uf'] ?? '';
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('CEP não encontrado.')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao buscar CEP: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = ref.read(currentUserProfileProvider).value;
      if (user == null) return;

      final updatedUser = user.copyWith(
        displayName: _nameController.text,
        phoneNumber: _phoneController.text.startsWith('+55')
            ? _phoneController.text
            : '+55${_phoneController.text}',
        isWhatsApp: _isWhatsApp,
        address: Address(
          cep: _cepController.text,
          street: _streetController.text,
          number: _numberController.text,
          complement: _complementController.text,
          neighborhood: _neighborhoodController.text,
          city: _cityController.text,
          state: _stateController.text,
        ),
      );

      await ref.read(authRepositoryProvider).updateUserProfile(updatedUser);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao atualizar perfil: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome Completo'),
                validator: (v) =>
                    v?.isEmpty == true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone (Mantenha o +55)',
                  hintText: '+5581999999999',
                ),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v?.isEmpty == true ? 'Campo obrigatório' : null,
              ),
              SwitchListTile(
                title: const Text('Este número é WhatsApp?'),
                value: _isWhatsApp,
                onChanged: (v) => setState(() => _isWhatsApp = v),
              ),
              const Divider(height: 32),
              TextFormField(
                controller: _cepController,
                decoration: InputDecoration(
                  labelText: 'CEP',
                  suffixIcon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () =>
                              _fetchAddressByCep(_cepController.text),
                        ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 8,
                onChanged: (v) {
                  if (v.length == 8) _fetchAddressByCep(v);
                },
                validator: (v) => v?.length != 8 ? 'CEP inválido' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _streetController,
                      decoration: const InputDecoration(labelText: 'Rua'),
                      validator: (v) =>
                          v?.isEmpty == true ? 'Campo obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _numberController,
                      decoration: const InputDecoration(labelText: 'Número'),
                      validator: (v) =>
                          v?.isEmpty == true ? 'Campo obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _complementController,
                decoration: const InputDecoration(
                  labelText: 'Complemento (Opcional)',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _neighborhoodController,
                decoration: const InputDecoration(labelText: 'Bairro'),
                validator: (v) =>
                    v?.isEmpty == true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'Cidade'),
                      validator: (v) =>
                          v?.isEmpty == true ? 'Campo obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(labelText: 'UF'),
                      validator: (v) =>
                          v?.isEmpty == true ? 'Campo obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'SALVAR ALTERAÇÕES',
                onPressed: _isLoading ? null : _saveProfile,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
