import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

class LeadsManagementScreen extends ConsumerStatefulWidget {
  const LeadsManagementScreen({super.key});

  @override
  ConsumerState<LeadsManagementScreen> createState() =>
      _LeadsManagementScreenState();
}

class _LeadsManagementScreenState extends ConsumerState<LeadsManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('leads_saas')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar leads.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final leads = snapshot.data!.docs;

        if (leads.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_rounded, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Nenhum contato B2B ainda.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 18),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: leads.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final leadDoc = leads[index];
            final data = leadDoc.data() as Map<String, dynamic>;
            final isNew = data['status'] == 'new';

            return Card(
              elevation: isNew ? 4 : 0,
              color: isNew ? Colors.white : Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: isNew ? BorderSide(color: AppColors.primary, width: 2) : BorderSide.none,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  data['businessName'] ?? 'Empresa Genérica',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                        children: [
                          const TextSpan(text: 'Dono: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: '${data['name'] ?? 'N/A'}\n'),
                          const TextSpan(text: 'E-mail: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: '${data['email'] ?? 'N/A'}\n'),
                          const TextSpan(text: 'Telefone: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: '${data['phone'] ?? 'N/A'}'),
                        ],
                      ),
                    ),
                  ],
                ),
                trailing: ElevatedButton.icon(
                  icon: const Icon(Icons.rocket_launch_rounded),
                  label: const Text('Provisionar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // TODO: Connect to Tenant Creation Form dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Integração com Cloud Function "createTenant" está sendo construída...'),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
