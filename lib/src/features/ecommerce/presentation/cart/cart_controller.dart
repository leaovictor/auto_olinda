import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/cart_item.dart';

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(CartItem item) {
    // Check if item already exists
    if (state.any((i) => i.serviceId == item.serviceId)) {
      return;
    }
    state = [...state, item];
  }

  void removeItem(String serviceId) {
    state = state.where((i) => i.serviceId != serviceId).toList();
  }

  void clear() {
    state = [];
  }

  double get total => state.fold(0, (sum, item) => sum + item.price);
}
