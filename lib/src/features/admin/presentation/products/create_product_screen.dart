import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../ecommerce/data/product_repository.dart';
import '../../../ecommerce/domain/product.dart';
import '../../../../shared/utils/app_toast.dart';
import '../theme/admin_theme.dart';

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

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon, {
    String? hint,
    String? prefixText,
    String? helperText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helperText,
      prefixText: prefixText,
      labelStyle: TextStyle(color: AdminTheme.textSecondary),
      hintStyle: TextStyle(color: AdminTheme.textMuted),
      helperStyle: TextStyle(color: AdminTheme.textMuted),
      prefixIcon: Icon(icon, color: AdminTheme.gradientPrimary[0]),
      prefixStyle: TextStyle(color: AdminTheme.textPrimary),
      filled: true,
      fillColor: AdminTheme.bgCardLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
        borderSide: BorderSide(color: AdminTheme.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
        borderSide: BorderSide(color: AdminTheme.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
        borderSide: BorderSide(color: AdminTheme.gradientPrimary[0]),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
        borderSide: BorderSide(color: AdminTheme.gradientDanger[0]),
      ),
    );
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
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: AdminTheme.textPrimary),
                      decoration: _buildInputDecoration(
                        'Nome do Produto',
                        Icons.shopping_bag,
                        hint: 'Ex: Cera Premium',
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
                      style: const TextStyle(color: AdminTheme.textPrimary),
                      decoration: _buildInputDecoration(
                        'Descrição',
                        Icons.description,
                        hint: 'Descreva o produto...',
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
                            style: const TextStyle(
                              color: AdminTheme.textPrimary,
                            ),
                            decoration: _buildInputDecoration(
                              'Preço',
                              Icons.attach_money,
                              hint: '0,00',
                              prefixText: 'R\$ ',
                            ),
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
                          child: DropdownButtonFormField<String>(
                            dropdownColor: AdminTheme.bgCard,
                            style: const TextStyle(
                              color: AdminTheme.textPrimary,
                            ),
                            initialValue: _categoryController.text.isEmpty
                                ? null
                                : _categoryController.text,
                            decoration: _buildInputDecoration(
                              'Categoria',
                              Icons.category,
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
                      style: const TextStyle(color: AdminTheme.textPrimary),
                      decoration: _buildInputDecoration(
                        'URL da Imagem (opcional)',
                        Icons.image,
                        hint: 'https://...',
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stripePriceIdController,
                      style: const TextStyle(color: AdminTheme.textPrimary),
                      decoration: _buildInputDecoration(
                        'Stripe Price ID (opcional)',
                        Icons.payment,
                        hint: 'price_...',
                        helperText: 'ID do preço no Stripe Dashboard',
                      ),
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
