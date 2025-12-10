import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../cart/cart_controller.dart';
import '../../domain/cart_item.dart';

class ServiceCatalogScreen extends ConsumerWidget {
  const ServiceCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nossos Serviços'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              context.push('/cart');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('services')
            .where('isActive', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar serviços'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Nenhum serviço disponível no momento.'),
            );
          }

          final services = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index].data() as Map<String, dynamic>;
              final docId = services[index].id;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          color: Colors.grey[200],
                          image: service['imageUrl'] != null
                              ? DecorationImage(
                                  image: NetworkImage(service['imageUrl']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: service['imageUrl'] == null
                            ? const Icon(
                                Icons.cleaning_services,
                                size: 48,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service['name'] ?? 'Serviço',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            service['description'] ?? '',
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'R\$ ${(service['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  final item = CartItem(
                                    serviceId: docId,
                                    name: service['name'] ?? 'Serviço',
                                    price:
                                        (service['price'] as num?)
                                            ?.toDouble() ??
                                        0.0,
                                    imageUrl: service['imageUrl'],
                                  );
                                  ref.read(cartProvider.notifier).addItem(item);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${item.name} adicionado ao carrinho!',
                                      ),
                                      action: SnackBarAction(
                                        label: 'Ver Carrinho',
                                        onPressed: () => context.push('/cart'),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
