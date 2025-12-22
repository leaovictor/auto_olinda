import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../ecommerce/data/product_repository.dart';
import '../../../ecommerce/domain/cart_item.dart';
import '../cart/cart_controller.dart';

class ProductShopScreen extends ConsumerWidget {
  const ProductShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final productsAsync = ref.watch(activeProductsProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nossos Produtos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Badge(
              label: Consumer(
                builder: (context, ref, _) {
                  final cart = ref.watch(cartProvider);
                  return Text('${cart.length}');
                },
              ),
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: () => context.push('/cart'),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum produto disponível',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Volte mais tarde para conferir nossas novidades!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = products[index];
                    return Card(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              final item = CartItem(
                                serviceId: product.id,
                                name: product.name,
                                price: product.price,
                                imageUrl: product.imageUrl,
                              );
                              ref.read(cartProvider.notifier).addItem(item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product.name} adicionado ao carrinho!',
                                  ),
                                  action: SnackBarAction(
                                    label: 'Ver Carrinho',
                                    onPressed: () => context.push('/cart'),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Product image
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer
                                          .withValues(alpha: 0.3),
                                      image: product.imageUrl != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                product.imageUrl!,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: Stack(
                                      children: [
                                        if (product.imageUrl == null)
                                          Center(
                                            child: Icon(
                                              _getCategoryIcon(
                                                product.category,
                                              ),
                                              size: 50,
                                              color: theme.colorScheme.primary
                                                  .withValues(alpha: 0.5),
                                            ),
                                          ),
                                        if (product.isFeatured)
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.amber,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    size: 12,
                                                    color: Colors.black87,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Destaque',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        Positioned(
                                          bottom: 8,
                                          right: 8,
                                          child: FloatingActionButton.small(
                                            heroTag: 'add_${product.id}',
                                            onPressed: () {
                                              final item = CartItem(
                                                serviceId: product.id,
                                                name: product.name,
                                                price: product.price,
                                                imageUrl: product.imageUrl,
                                              );
                                              ref
                                                  .read(cartProvider.notifier)
                                                  .addItem(item);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '${product.name} adicionado!',
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  duration: const Duration(
                                                    seconds: 1,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Icon(
                                              Icons.add_shopping_cart,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Product info
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          product.description,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const Spacer(),
                                        Text(
                                          'R\$ ${product.price.toStringAsFixed(2)}',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: (50 * index).ms)
                        .scale(
                          begin: const Offset(0.95, 0.95),
                          duration: 200.ms,
                        );
                  }, childCount: products.length),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 200)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'cera':
        return Icons.auto_awesome;
      case 'perfume':
        return Icons.air;
      case 'acessorio':
        return Icons.build;
      case 'limpeza':
        return Icons.cleaning_services;
      default:
        return Icons.shopping_bag;
    }
  }
}
