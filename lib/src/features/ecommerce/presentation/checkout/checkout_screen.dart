import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../payment/data/abacate_pay_service.dart';
import '../../../subscription/presentation/widgets/pix_payment_sheet.dart';
import '../../../subscription/domain/subscription_plan.dart';
import '../cart/cart_controller.dart';
import '../../../../shared/utils/app_toast.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _isLoading = false;

  Future<void> _processCheckout() async {
    final cartItems = ref.read(cartProvider);
    if (cartItems.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref.read(currentUserProfileProvider).value;
      if (user == null) {
        throw Exception('Usuário não identificado.');
      }

      final total = ref.read(cartProvider.notifier).total;
      final description = cartItems
          .map((e) => '${e.name} (${e.quantity}x)')
          .join(', ');

      // Use AbacatePay Service
      final abacateService = ref.read(abacatePayServiceProvider);
      final billing = await abacateService.createBilling(
        amount: total,
        customerEmail: user.email,
        customerName: user.displayName ?? 'Cliente',
        description: 'Pedido: $description',
        customerCpf: null, // Add if available
      );

      if (!mounted) return;

      // Show PIX Sheet
      final billingDyn = billing as dynamic;
      final String copyPaste =
          billingDyn.pix?.copyPaste ?? billingDyn.url ?? '';
      final String qrUrl = billingDyn.pix?.qrCode ?? '';

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: false,
        enableDrag: false,
        builder: (sheetContext) => PixPaymentSheet(
          plan: SubscriptionPlan(
            id: 'cart_checkout',
            name: 'Pedido #${billingDyn.id.substring(0, 8)}',
            price: total,
            features: [],
          ),
          pixCopyPaste: copyPaste,
          pixQrUrl: qrUrl,
          billingId: billingDyn.id,
          onSuccess: () {
            Navigator.pop(sheetContext);
            // Clear cart and show success
            ref.read(cartProvider.notifier).clear();
            AppToast.success(
              context,
              message: 'Pagamento realizado com sucesso!',
            );
            Navigator.pop(context); // Go back to products or home
          },
          onError: (error) {
            Navigator.pop(sheetContext);
            AppToast.error(context, message: 'Erro: $error');
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final total = ref.read(cartProvider.notifier).total;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Resumo do Pedido',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return ListTile(
                          title: Text(item.name),
                          trailing: Text(
                            'R\$ ${item.price.toStringAsFixed(2)}',
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'R\$ ${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: cartItems.isEmpty ? null : _processCheckout,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Pagar com PIX (AbacatePay)'),
                  ),
                ],
              ),
            ),
    );
  }
}
