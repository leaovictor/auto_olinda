import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../common_widgets/atoms/app_loader.dart';

import '../../../booking/data/booking_repository.dart';
import '../../../booking/domain/service_package.dart';
import '../../../ecommerce/data/product_repository.dart';
import '../../../ecommerce/domain/product.dart';
import '../../../../shared/utils/app_toast.dart';
import '../theme/admin_theme.dart';
import '../shell/admin_shell.dart';

/// Admin screen to manage services and products with tabs
class AdminServicesScreen extends ConsumerStatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  ConsumerState<AdminServicesScreen> createState() =>
      _AdminServicesScreenState();
}

class _AdminServicesScreenState extends ConsumerState<AdminServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 800;

    return Container(
      decoration: BoxDecoration(gradient: AdminTheme.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Produtos e Serviços', style: AdminTheme.headingMedium),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AdminTheme.textPrimary),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/admin');
              }
            },
          ),
          actions: isMobile
              ? [
                  IconButton(
                    onPressed: () {
                      final toggle = ref.read(adminDrawerToggleProvider);
                      toggle?.call();
                    },
                    icon: Icon(Icons.menu, color: AdminTheme.textPrimary),
                  ),
                ]
              : null,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AdminTheme.gradientPrimary[0],
            labelColor: AdminTheme.gradientPrimary[0],
            unselectedLabelColor: AdminTheme.textSecondary,
            dividerColor: AdminTheme.borderLight,
            tabs: const [
              Tab(icon: Icon(Icons.local_car_wash), text: 'Serviços'),
              Tab(icon: Icon(Icons.shopping_bag), text: 'Produtos'),
            ],
          ),
        ),
        floatingActionButton: AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            return FloatingActionButton.extended(
              onPressed: () {
                if (_tabController.index == 0) {
                  context.push('/admin/services/create');
                } else {
                  context.push('/admin/products/create');
                }
              },
              backgroundColor: AdminTheme.gradientPrimary[0],
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                _tabController.index == 0 ? 'Novo Serviço' : 'Novo Produto',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_ServicesTab(), _ProductsTab()],
        ),
      ),
    );
  }
}

/// Tab for managing wash services
class _ServicesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);

    return servicesAsync.when(
      data: (services) {
        if (services.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cleaning_services_outlined,
                  size: 64,
                  color: AdminTheme.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum serviço cadastrado.',
                  style: AdminTheme.bodyMedium.copyWith(
                    color: AdminTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: services.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final service = services[index];
            return _ServiceCard(service: service);
          },
        );
      },
      loading: () => const Center(child: AppLoader()),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AdminTheme.gradientDanger[0],
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar serviços: $err',
              style: TextStyle(color: AdminTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab for managing additional products
class _ProductsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(allProductsProvider);

    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 64,
                  color: AdminTheme.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum produto cadastrado.',
                  style: AdminTheme.bodyMedium.copyWith(
                    color: AdminTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Adicione produtos para venda durante agendamentos.',
                  style: AdminTheme.labelSmall.copyWith(
                    color: AdminTheme.textSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final product = products[index];
            return _ProductCard(product: product);
          },
        );
      },
      loading: () => const Center(child: AppLoader()),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AdminTheme.gradientDanger[0],
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar produtos: $err',
              style: TextStyle(color: AdminTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card widget for displaying a service
class _ServiceCard extends ConsumerWidget {
  final ServicePackage service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AdminTheme.radiusXL),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AdminTheme.gradientPrimary,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_car_wash,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                service.title,
                                style: AdminTheme.headingSmall,
                              ),
                            ),
                            if (service.isPopular)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AdminTheme.gradientWarning[0]
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AdminTheme.gradientWarning[0]
                                        .withOpacity(0.5),
                                  ),
                                ),
                                child: Text(
                                  'POPULAR',
                                  style: AdminTheme.labelSmall.copyWith(
                                    color: AdminTheme.gradientWarning[0],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service.description,
                          style: AdminTheme.bodyMedium.copyWith(
                            color: AdminTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: AdminTheme.gradientPrimary[0],
                    ),
                    onPressed: () {
                      context.push('/admin/services/edit', extra: service);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: AdminTheme.gradientDanger[0],
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AdminTheme.bgCard,
                          title: Text(
                            'Excluir Serviço',
                            style: AdminTheme.headingSmall,
                          ),
                          content: Text(
                            'Tem certeza que deseja excluir "${service.title}"?',
                            style: AdminTheme.bodyMedium,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: AdminTheme.textSecondary,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                'Excluir',
                                style: TextStyle(
                                  color: AdminTheme.gradientDanger[0],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ref
                            .read(bookingRepositoryProvider)
                            .deleteService(service.id);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: AdminTheme.borderLight),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 20,
                    color: AdminTheme.textPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'R\$ ${service.price.toStringAsFixed(2)}',
                    style: AdminTheme.headingSmall.copyWith(
                      color: AdminTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Icon(
                    Icons.access_time,
                    size: 20,
                    color: AdminTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${service.durationMinutes} min',
                    style: AdminTheme.bodyMedium.copyWith(
                      color: AdminTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              if (service.steps.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Passos da Lavagem (${service.steps.length})',
                  style: AdminTheme.labelSmall.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 8),
                ...service.steps.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AdminTheme.bgCardLight,
                            shape: BoxShape.circle,
                            border: Border.all(color: AdminTheme.borderLight),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AdminTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: AdminTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Card widget for displaying a product
class _ProductCard extends ConsumerWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: AdminTheme.headingSmall,
                        ),
                      ),
                      if (product.isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.5),
                            ),
                          ),
                          child: const Text(
                            '⭐',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
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
            ),
            PopupMenuButton<String>(
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
                              style: TextStyle(
                                color: AdminTheme.gradientDanger[0],
                              ),
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
          ],
        ),
      ),
    );
  }
}
