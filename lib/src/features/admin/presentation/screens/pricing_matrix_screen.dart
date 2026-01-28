import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pricing/data/pricing_repository.dart';
import '../../../pricing/domain/pricing_matrix.dart';
import '../widgets/pricing_matrix_editor.dart';

class PricingMatrixScreen extends ConsumerStatefulWidget {
  const PricingMatrixScreen({super.key});

  @override
  ConsumerState<PricingMatrixScreen> createState() =>
      _PricingMatrixScreenState();
}

class _PricingMatrixScreenState extends ConsumerState<PricingMatrixScreen> {
  @override
  Widget build(BuildContext context) {
    final pricingMatrixAsync = ref.watch(pricingMatrixStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Matriz de Preços')),
      body: pricingMatrixAsync.when(
        data: (matrix) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gerencie os preços dos serviços avulsos por porte de veículo.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PricingMatrixEditor(
                        currentMatrix: matrix,
                        onSave: (newMatrix) => _saveMatrix(newMatrix),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
    );
  }

  Future<void> _saveMatrix(PricingMatrix newMatrix) async {
    try {
      // Show loading overlay or indicator
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Salvando alterações...')));

      await ref.read(pricingRepositoryProvider).updatePricingMatrix(newMatrix);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preços atualizados com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
