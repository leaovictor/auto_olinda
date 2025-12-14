import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../ecommerce/data/product_repository.dart';
import '../../../ecommerce/domain/product.dart';
import '../../../../shared/utils/app_toast.dart';

class CreateProductScreen extends ConsumerStatefulWidget {
  final Product? productToEdit;

  const CreateProductScreen({super.key, this.productToEdit});

  @override
  ConsumerState<CreateProductScreen> createState() =>
      _CreateProductScreenState();
}

class _CreateProductScreenState extends ConsumerState<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  late TextEditingController _categoryController;
  late TextEditingController _stripePriceIdController;
  late bool _isActive;
  late bool _isFeatured;

  final List<String> _categories = [
    'cera',
    'perfume',
    'acessorio',
    'limpeza',
    'outro',
  ];

  @override
  void initState() {
    super.initState();
    final product = widget.productToEdit;
    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: product?.price.toStringAsFixed(2).replaceAll('.', ',') ?? '',
    );
    _imageUrlController = TextEditingController(text: product?.imageUrl ?? '');
    _categoryController = TextEditingController(text: product?.category ?? '');
    _stripePriceIdController = TextEditingController(
      text: product?.stripePriceId ?? '',
    );
    _isActive = product?.isActive ?? true;
    _isFeatured = product?.isFeatured ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    _stripePriceIdController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final price =
        double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;
    final imageUrl = _imageUrlController.text.trim().isEmpty
        ? null
        : _imageUrlController.text.trim();
    final category = _categoryController.text.trim().isEmpty
        ? null
        : _categoryController.text.trim();
    final stripePriceId = _stripePriceIdController.text.trim().isEmpty
        ? null
        : _stripePriceIdController.text.trim();

    final product = Product(
      id: widget.productToEdit?.id ?? '',
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      category: category,
      stripePriceId: stripePriceId,
      isActive: _isActive,
      isFeatured: _isFeatured,
      createdAt: widget.productToEdit?.createdAt,
    );

    try {
      final repo = ref.read(productRepositoryProvider);
      if (widget.productToEdit != null) {
        await repo.updateProduct(product);
        if (mounted) {
          AppToast.success(context, message: 'Produto atualizado!');
        }
      } else {
        await repo.createProduct(product);
        if (mounted) {
          AppToast.success(context, message: 'Produto criado!');
        }
      }
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao salvar: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Produto' : 'Novo Produto'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Product image preview
            if (_imageUrlController.text.isNotEmpty)
              Container(
                height: 150,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(_imageUrlController.text),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Produto',
                hintText: 'Ex: Cera Premium',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_bag),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira um nome';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Descreva o produto...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira uma descrição';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Preço',
                      hintText: '0,00',
                      border: OutlineInputBorder(),
                      prefixText: 'R\$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Insira o preço';
                      }
                      if (double.tryParse(value.replaceAll(',', '.')) == null) {
                        return 'Preço inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _categoryController.text.isEmpty
                        ? null
                        : _categoryController.text,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(_getCategoryLabel(cat)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _categoryController.text = value ?? '';
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'URL da Imagem (opcional)',
                hintText: 'https://...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
              ),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stripePriceIdController,
              decoration: const InputDecoration(
                labelText: 'Stripe Price ID (opcional)',
                hintText: 'price_...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payment),
                helperText: 'ID do preço no Stripe Dashboard',
              ),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Produto Ativo'),
              subtitle: const Text('Disponível para compra'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
            SwitchListTile(
              title: const Text('Produto em Destaque'),
              subtitle: const Text('Aparecer no topo da lista'),
              value: _isFeatured,
              onChanged: (value) => setState(() => _isFeatured = value),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saveProduct,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isEditing ? 'Salvar Alterações' : 'Criar Produto'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'cera':
        return '🧴 Cera';
      case 'perfume':
        return '🌸 Perfume';
      case 'acessorio':
        return '🔧 Acessório';
      case 'limpeza':
        return '🧹 Limpeza';
      default:
        return '📦 Outro';
    }
  }
}
