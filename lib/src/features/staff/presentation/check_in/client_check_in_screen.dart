import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../auth/data/auth_repository.dart';

class ClientCheckInScreen extends ConsumerStatefulWidget {
  final String serviceId;
  const ClientCheckInScreen({super.key, required this.serviceId});

  @override
  ConsumerState<ClientCheckInScreen> createState() =>
      _ClientCheckInScreenState();
}

class _ClientCheckInScreenState extends ConsumerState<ClientCheckInScreen> {
  Stream<DocumentSnapshot>? _serviceStream;

  @override
  void initState() {
    super.initState();
    if (widget.serviceId.isNotEmpty) {
      _serviceStream = FirebaseFirestore.instance
          .collection('servicos_ativos')
          .doc(widget.serviceId)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is logged in
    final user = ref.watch(authRepositoryProvider).currentUser;

    if (widget.serviceId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Link inválido (ID não encontrado)')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Status do Serviço'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => context.go('/home'),
            ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _serviceStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar o serviço.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Serviço não encontrado ou finalizado.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'unknown';
          final plate = data['plate'] ?? 'Placa';
          final model = data['vehicleModel'] ?? 'Veículo';
          final serviceType = data['serviceType'] ?? 'Serviço';

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatusCard(status),
                const SizedBox(height: 24),
                _buildDetailRow('Veículo', model),
                _buildDetailRow('Placa', plate),
                _buildDetailRow('Serviço', serviceType),
                const Spacer(),
                if (user == null) ...[
                  const Text(
                    'Quer acompanhar seu histórico e ganhar descontos?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.go(
                        '/sign-up?linkServiceId=${widget.serviceId}&plate=$plate',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'CRIAR CONTA E ACOMPANHAR',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'fila':
        color = Colors.orange;
        label = 'Na Fila';
        icon = Icons.schedule;
        break;
      case 'lavando':
        color = Colors.blue;
        label = 'Lavando';
        icon = Icons.cleaning_services;
        break;
      case 'pronto':
        color = Colors.green;
        label = 'Pronto';
        icon = Icons.check_circle;
        break;
      case 'entregue':
        color = Colors.grey;
        label = 'Entregue';
        icon = Icons.done_all;
        break;
      default:
        color = Colors.grey;
        label = status.toUpperCase();
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Status Atual', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
