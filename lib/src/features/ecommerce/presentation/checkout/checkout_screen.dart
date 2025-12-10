import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../cart/cart_controller.dart';

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
      final List<Map<String, dynamic>> itemsPayload = [];

      // Fetch Stripe Price IDs for each item
      for (final item in cartItems) {
        final doc = await FirebaseFirestore.instance
            .collection('services')
            .doc(item.serviceId)
            .get();
        if (doc.exists) {
          final data = doc.data();
          final String? priceId = data?['stripePriceId'];

          if (priceId != null) {
            itemsPayload.add({'priceId': priceId, 'quantity': item.quantity});
          } else {
            // Handle case where service has no price ID (maybe skip or error?)
            // For now, log and maybe throw error
            throw Exception(
              'Serviço "${item.name}" não possui ID de preço configurado.',
            );
          }
        }
      }

      if (itemsPayload.isEmpty) {
        throw Exception('Nenhum item válido para checkout.');
      }

      // Call Cloud Function
      final result = await FirebaseFunctions.instance
          .httpsCallable('createCheckoutSession')
          .call({
            'mode': 'payment',
            'items': itemsPayload,
            'successUrl':
                'https://aquaclean.app/success', // Should be dynamic or deep link
            'cancelUrl': 'https://aquaclean.app/cancel',
          });

      final data = result.data as Map<String, dynamic>;
      final String? url = data['url'];

      if (url != null) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          // Optionally clear cart here or waiting for success webhook
          ref.read(cartProvider.notifier).clear();
        } else {
          throw Exception('Não foi possível abrir o link de pagamento.');
        }
      }
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
                    onPressed: cartItems.isEmpty
                        ? null
                        : _processCheckout, // Wired functionality
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Pagar com Stripe'),
                  ),
                ],
              ),
            ),
    );
  }
}
