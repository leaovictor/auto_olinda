import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../ecommerce/data/product_repository.dart';
import '../../../ecommerce/domain/product.dart';
import '../../../../shared/utils/app_toast.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_text_field.dart';
import '../widgets/admin_dropdown_field.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Produto' : 'Novo Produto'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: AdminTheme.headingMedium,
        iconTheme: const IconThemeData(color: AdminTheme.textPrimary),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AdminTheme.bgDark.withOpacity(0.9), Colors.transparent],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AdminTheme.backgroundGradient,
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
            children: [
              // Product image preview
              if (_imageUrlController.text.isNotEmpty)
                Container(
                  height: 200,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration:
                      AdminTheme.glassmorphicDecoration(
                        opacity: 0.5,
                        borderRadius: AdminTheme.radiusXL,
                      ).copyWith(
                        image: DecorationImage(
                          image: NetworkImage(_imageUrlController.text),
                          fit: BoxFit.cover,
                        ),
                      ),
                ),

              Container(
                decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    AdminTextField(
                      controller: _nameController,
                      label: 'Nome do Produto',
                      hint: 'Ex: Cera Premium',
                      icon: Icons.shopping_bag,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira um nome';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AdminTextField(
                      controller: _descriptionController,
                      label: 'Descrição',
                      hint: 'Descreva o produto...',
                      icon: Icons.description,
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
                          child: AdminTextField(
                            controller: _priceController,
                            label: 'Preço',
                            hint: '0,00',
                            prefixText: 'R\$ ',
                            icon: Icons.attach_money,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Insira o preço';
                              }
                              if (double.tryParse(value.replaceAll(',', '.')) ==
                                  null) {
                                return 'Preço inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AdminDropdownField<String>(
                            label: 'Categoria',
                            value: _categoryController.text.isEmpty
                                ? null
                                : _categoryController.text,
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
                    AdminTextField(
                      controller: _imageUrlController,
                      label: 'URL da Imagem (opcional)',
                      hint: 'https://...',
                      icon: Icons.image,
                      onChanged: (value) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    AdminTextField(
                      controller: _stripePriceIdController,
                      label: 'Stripe Price ID (opcional)',
                      hint: 'price_...',
                      helperText: 'ID do preço no Stripe Dashboard',
                      icon: Icons.payment,
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile(
                      activeThumbColor: AdminTheme.gradientPrimary[0],
                      title: Text('Produto Ativo', style: AdminTheme.bodyLarge),
                      subtitle: Text(
                        'Disponível para compra',
                        style: AdminTheme.bodyMedium,
                      ),
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
                    ),
                    SwitchListTile(
                      activeThumbColor: AdminTheme.gradientPrimary[0],
                      title: Text(
                        'Produto em Destaque',
                        style: AdminTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        'Aparecer no topo da lista',
                        style: AdminTheme.bodyMedium,
                      ),
                      value: _isFeatured,
                      onChanged: (value) => setState(() => _isFeatured = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AdminTheme.gradientPrimary),
                  borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
                  boxShadow: AdminTheme.glowShadow(
                    AdminTheme.gradientPrimary[0],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Salvar Alterações' : 'Criar Produto',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
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
