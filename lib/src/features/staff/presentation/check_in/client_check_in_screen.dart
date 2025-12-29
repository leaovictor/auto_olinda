import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

/// Public screen for clients to track their service status.
/// This screen is accessible WITHOUT authentication via a shared link.
/// It uses direct Firestore access instead of providers to avoid auth dependencies.
class ClientCheckInScreen extends StatefulWidget {
  final String serviceId;
  const ClientCheckInScreen({super.key, required this.serviceId});

  @override
  State<ClientCheckInScreen> createState() => _ClientCheckInScreenState();
}

class _ClientCheckInScreenState extends State<ClientCheckInScreen> {
  Stream<DocumentSnapshot>? _serviceStream;
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _serviceData;

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  void _initializeStream() {
    if (widget.serviceId.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Link inválido (ID não encontrado)';
      });
      return;
    }

    // Direct Firestore access - no auth required for documents with isGuest: true
    _serviceStream = FirebaseFirestore.instance
        .collection('appointments')
        .doc(widget.serviceId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: _buildErrorView(_errorMessage!),
      );
    }

    if (widget.serviceId.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: _buildErrorView('Link inválido (ID não encontrado)'),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Acompanhe seu Serviço'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF0077B6),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _serviceStream,
        builder: (context, snapshot) {
          // Handle errors
          if (snapshot.hasError) {
            // Check if it's a permission error
            final error = snapshot.error.toString();
            if (error.contains('permission') ||
                error.contains('PERMISSION_DENIED')) {
              return _buildErrorView(
                'Acesso não autorizado.\nEste link pode ter expirado ou ser inválido.',
              );
            }
            return _buildErrorView('Erro ao carregar o serviço: $error');
          }

          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF0077B6)),
                  SizedBox(height: 16),
                  Text(
                    'Carregando informações...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Document not found
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildErrorView('Agendamento não encontrado');
          }

          // Parse data
          final data = snapshot.data!.data() as Map<String, dynamic>;
          return _buildServiceContent(data);
        },
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () {
                // Try to go home or back
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.home),
              label: const Text('Voltar ao Início'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceContent(Map<String, dynamic> data) {
    final status = data['status'] as String? ?? 'unknown';

    // Parse vehicle info from the special format: "GUEST:PLATE:MODEL"
    String plate = 'N/A';
    String model = 'Veículo';
    final vehicleId = data['vehicleId'] as String? ?? '';

    if (vehicleId.startsWith('GUEST:')) {
      final parts = vehicleId.split(':');
      if (parts.length >= 2) plate = parts[1];
      if (parts.length >= 3) model = parts[2];
    } else if (vehicleId.isNotEmpty) {
      plate = 'Registrado';
      model = 'Ver detalhes';
    }

    // Service type
    String serviceType = 'Serviço';
    final serviceIds = data['serviceIds'] as List<dynamic>?;
    if (serviceIds != null && serviceIds.isNotEmpty) {
      serviceType = serviceIds.first.toString();
    }

    // Get timestamp
    String dateInfo = '';
    final scheduledTime = data['scheduledTime'];
    if (scheduledTime != null) {
      DateTime date;
      if (scheduledTime is Timestamp) {
        date = scheduledTime.toDate();
      } else {
        date = DateTime.now();
      }
      dateInfo =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status Card
          _buildStatusCard(status),

          const SizedBox(height: 24),

          // Details Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detalhes do Serviço',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.directions_car, 'Veículo', model),
                const Divider(height: 24),
                _buildDetailRow(Icons.badge, 'Placa', plate),
                const Divider(height: 24),
                _buildDetailRow(
                  Icons.cleaning_services,
                  'Serviço',
                  serviceType,
                ),
                if (dateInfo.isNotEmpty) ...[
                  const Divider(height: 24),
                  _buildDetailRow(Icons.calendar_today, 'Data', dateInfo),
                ],
              ],
            ),
          ),

          const SizedBox(height: 32),

          // CTA - Create Account
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0077B6).withOpacity(0.1),
                  const Color(0xFF00B4D8).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF0077B6).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.card_giftcard,
                  size: 40,
                  color: Color(0xFF0077B6),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Quer acompanhar seu histórico e ganhar descontos?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Crie sua conta e tenha acesso a promoções exclusivas!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go(
                        '/signup?linkServiceId=${widget.serviceId}&plate=$plate',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF0077B6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'CRIAR CONTA GRÁTIS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Already have account
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text(
              'Já tenho uma conta',
              style: TextStyle(
                color: Color(0xFF0077B6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String status) {
    Color color;
    String label;
    IconData icon;
    String description;

    switch (status.toLowerCase()) {
      case 'scheduled':
      case 'agendado':
        color = Colors.blue;
        label = 'Agendado';
        icon = Icons.event;
        description = 'Seu serviço está agendado';
        break;
      case 'confirmed':
      case 'confirmado':
        color = Colors.teal;
        label = 'Confirmado';
        icon = Icons.check_circle_outline;
        description = 'Agendamento confirmado';
        break;
      case 'checkin':
      case 'check_in':
      case 'fila':
        color = Colors.orange;
        label = 'Na Fila';
        icon = Icons.schedule;
        description = 'Seu veículo está na fila de atendimento';
        break;
      case 'washing':
      case 'lavando':
        color = Colors.blue;
        label = 'Lavando';
        icon = Icons.water_drop;
        description = 'Seu veículo está sendo lavado';
        break;
      case 'vacuuming':
      case 'aspirando':
        color = Colors.indigo;
        label = 'Aspirando';
        icon = Icons.cleaning_services_outlined;
        description = 'Aspirando o interior do veículo';
        break;
      case 'drying':
      case 'secando':
        color = Colors.amber;
        label = 'Secando';
        icon = Icons.wb_sunny;
        description = 'Secando seu veículo';
        break;
      case 'polishing':
      case 'polindo':
        color = Colors.purple;
        label = 'Polindo';
        icon = Icons.auto_awesome;
        description = 'Finalizando com polimento';
        break;
      case 'finished':
      case 'pronto':
      case 'concluido':
        color = Colors.green;
        label = 'Pronto!';
        icon = Icons.check_circle;
        description = 'Seu veículo está pronto para retirada!';
        break;
      case 'entregue':
      case 'delivered':
        color = Colors.grey;
        label = 'Entregue';
        icon = Icons.done_all;
        description = 'Serviço concluído e veículo entregue';
        break;
      case 'cancelled':
      case 'cancelado':
        color = Colors.red;
        label = 'Cancelado';
        icon = Icons.cancel;
        description = 'Este serviço foi cancelado';
        break;
      default:
        color = Colors.grey;
        label = status.toUpperCase();
        icon = Icons.info;
        description = 'Status atual do serviço';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          // Animated icon container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: color),
          ),
          const SizedBox(height: 20),
          Text(
            label,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Atualizado em tempo real',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0077B6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF0077B6)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
