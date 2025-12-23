import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../ecommerce/data/product_repository.dart';
import '../../../ecommerce/domain/product.dart';
import '../../../../shared/utils/app_toast.dart';
import '../theme/admin_theme.dart';

class AdminProductsScreen extends ConsumerWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Gerenciar Produtos',
          style: AdminTheme.headingMedium,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AdminTheme.textPrimary),
            onPressed: () => context.push('/admin/products/create'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AdminTheme.backgroundGradient,
        ),
        child: productsAsync.when(
          data: (products) {
            if (products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 80,
                      color: AdminTheme.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum produto cadastrado',
                      style: AdminTheme.headingMedium.copyWith(
                        color: AdminTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Adicione produtos para venda avulsa',
                      style: AdminTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AdminTheme.gradientPrimary,
                        ),
                        borderRadius: BorderRadius.circular(
                          AdminTheme.radiusMD,
                        ),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/admin/products/create'),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Adicionar Produto',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
              itemCount: products.length + 1,
              itemBuilder: (context, index) {
                if (index == products.length) {
                  return const SizedBox(height: 80);
                }
                final product = products[index];
                return _ProductCard(product: product);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Text(
              'Erro: $err',
              style: TextStyle(color: AdminTheme.textPrimary),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/products/create'),
        backgroundColor: AdminTheme.gradientPrimary[0],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Novo Produto',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AdminTheme.bgCardLight,
            borderRadius: BorderRadius.circular(8),
            image: product.imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(product.imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: product.imageUrl == null
              ? Icon(Icons.shopping_bag, color: AdminTheme.textSecondary)
              : null,
        ),
        title: Row(
          children: [
            Expanded(child: Text(product.name, style: AdminTheme.headingSmall)),
            if (product.isFeatured)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: const Text('⭐', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              product.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AdminTheme.labelSmall.copyWith(
                color: AdminTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'R\$ ${product.price.toStringAsFixed(2)}',
                  style: AdminTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AdminTheme.gradientSuccess[1],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: product.isActive
                        ? AdminTheme.gradientSuccess[0].withOpacity(0.2)
                        : AdminTheme.gradientDanger[0].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: product.isActive
                          ? AdminTheme.gradientSuccess[0].withOpacity(0.5)
                          : AdminTheme.gradientDanger[0].withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    product.isActive ? 'Ativo' : 'Inativo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: product.isActive
                          ? AdminTheme.gradientSuccess[0]
                          : AdminTheme.gradientDanger[0],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AdminTheme.textSecondary),
          color: AdminTheme.bgCard,
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                context.push('/admin/products/edit', extra: product);
                break;
              case 'toggle_active':
                await ref
                    .read(productRepositoryProvider)
                    .toggleProductActive(product.id, !product.isActive);
                break;
              case 'toggle_featured':
                await ref
                    .read(productRepositoryProvider)
                    .toggleProductFeatured(product.id, !product.isFeatured);
                break;
              case 'delete':
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AdminTheme.bgCard,
                    title: Text(
                      'Excluir Produto',
                      style: AdminTheme.headingSmall,
                    ),
                    content: Text(
                      'Deseja excluir "${product.name}"?',
                      style: AdminTheme.bodyMedium,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(color: AdminTheme.textSecondary),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'Excluir',
                          style: TextStyle(color: AdminTheme.gradientDanger[0]),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref
                      .read(productRepositoryProvider)
                      .deleteProduct(product.id);
                  if (context.mounted) {
                    AppToast.success(context, message: 'Produto excluído!');
                  }
                }
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Text('Editar', style: AdminTheme.bodyMedium),
            ),
            PopupMenuItem(
              value: 'toggle_active',
              child: Text(
                product.isActive ? 'Desativar' : 'Ativar',
                style: AdminTheme.bodyMedium,
              ),
            ),
            PopupMenuItem(
              value: 'toggle_featured',
              child: Text(
                product.isFeatured ? 'Remover Destaque' : 'Destacar',
                style: AdminTheme.bodyMedium,
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text(
                'Excluir',
                style: AdminTheme.bodyMedium.copyWith(
                  color: AdminTheme.gradientDanger[0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
