import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/order.dart' as domain;

class PaidOrdersScreen extends ConsumerWidget {
  const PaidOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos Pagos')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', isEqualTo: 'paid')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum pedido pago encontrado.'));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final data = doc.data() as Map<String, dynamic>;
              // Manually mapping ID since it's not in the data map usually
              data['id'] = doc.id;

              // Handle Timestamp conversion manually if generated code fails or just to be safe in UI
              // But utilize the model if possible.
              // Note: Order.fromJson expects Timestamp to be handled by converter?
              // The converter I wrote handles it.

              domain.Order order;
              try {
                order = domain.Order.fromJson(data);
              } catch (e) {
                return ListTile(title: Text('Erro ao ler pedido ${doc.id}'));
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.attach_money, color: Colors.green),
                  title: Text('Pedido #${order.id.substring(0, 8)}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Valor: ${order.currency.toUpperCase()} ${order.amount.toStringAsFixed(2)}',
                      ),
                      Text('Data: ${order.createdAt.toLocal()}'),
                      if (order.serviceId.isNotEmpty)
                        Text('Serviço ID: ${order.serviceId}'),
                    ],
                  ),
                  trailing: order.bookingId != null
                      ? const Chip(
                          label: Text('Agendado'),
                          backgroundColor: Colors.greenAccent,
                        )
                      : ElevatedButton(
                          onPressed: () {
                            // Logic to link to booking manually if needed?
                            // Or just "Process"
                          },
                          child: const Text('Processar'),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
