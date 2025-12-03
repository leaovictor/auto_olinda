import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../ecommerce/domain/service.dart';
import '../../../../ecommerce/data/service_repository.dart';
import 'service_form_dialog.dart';

final servicesProvider = StreamProvider<List<Service>>((ref) {
  return ref.watch(serviceRepositoryProvider).watchActiveServices();
});

class ServiceListView extends ConsumerWidget {
  const ServiceListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      body: servicesAsync.when(
        data: (services) {
          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.build_outlined,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum serviço cadastrado',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Clique no + para adicionar',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return _ServiceCard(service: service);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Erro ao carregar serviços: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showServiceDialog(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Novo Serviço'),
      ),
    );
  }

  void _showServiceDialog(
    BuildContext context,
    WidgetRef ref,
    Service? service,
  ) {
    showDialog(
      context: context,
      builder: (context) => ServiceFormDialog(service: service),
    );
  }
}

class _ServiceCard extends ConsumerWidget {
  final Service service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: service.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  service.imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.build,
                        color: theme.colorScheme.secondary,
                      ),
                    );
                  },
                ),
              )
            : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.build, color: theme.colorScheme.secondary),
              ),
        title: Text(
          service.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '⏱️ ${service.estimatedDuration.inMinutes} min',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'R\$ ${service.price.toStringAsFixed(2)}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (service.features.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${service.features.length} recursos inclusos',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditDialog(context, ref),
              tooltip: 'Editar',
            ),
            IconButton(
              icon: Icon(
                service.isActive ? Icons.visibility : Icons.visibility_off,
                color: service.isActive ? Colors.green : Colors.grey,
              ),
              onPressed: () => _toggleActive(ref),
              tooltip: service.isActive ? 'Desativar' : 'Ativar',
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ServiceFormDialog(service: service),
    );
  }

  Future<void> _toggleActive(WidgetRef ref) async {
    final repository = ref.read(serviceRepositoryProvider);
    final updatedService = service.copyWith(
      isActive: !service.isActive,
      updatedAt: DateTime.now(),
    );
    await repository.updateService(updatedService);
  }
}
