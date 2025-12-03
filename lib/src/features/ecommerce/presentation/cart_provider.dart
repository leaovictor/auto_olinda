import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/cart.dart';
import '../domain/cart_item.dart';
import '../domain/product.dart';
import '../domain/service.dart';
import '../domain/coupon.dart';
import '../data/coupon_repository.dart';

part 'cart_provider.g.dart';

@Riverpod(keepAlive: true)
class CartNotifier extends _$CartNotifier {
  @override
  Cart build() {
    return const Cart();
  }

  void addProduct(Product product) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere(
      (item) => item.map(
        product: (p) => p.product.id == product.id,
        service: (_) => false,
      ),
    );

    if (index != -1) {
      // Increment quantity
      final existingItem = items[index];
      items[index] = existingItem.copyWith(quantity: existingItem.quantity + 1);
    } else {
      // Add new item
      items.add(CartItem.product(product: product));
    }

    state = state.copyWith(items: items);
    _recalculateDiscount();
  }

  void addService(Service service) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere(
      (item) => item.map(
        product: (_) => false,
        service: (s) => s.service.id == service.id,
      ),
    );

    if (index != -1) {
      // Increment quantity
      final existingItem = items[index];
      items[index] = existingItem.copyWith(quantity: existingItem.quantity + 1);
    } else {
      // Add new item
      items.add(CartItem.service(service: service));
    }

    state = state.copyWith(items: items);
    _recalculateDiscount();
  }

  void removeProduct(String productId) {
    final items = List<CartItem>.from(state.items);
    items.removeWhere(
      (item) => item.map(
        product: (p) => p.product.id == productId,
        service: (_) => false,
      ),
    );
    state = state.copyWith(items: items);
    _recalculateDiscount();
  }

  void removeService(String serviceId) {
    final items = List<CartItem>.from(state.items);
    items.removeWhere(
      (item) => item.map(
        product: (_) => false,
        service: (s) => s.service.id == serviceId,
      ),
    );
    state = state.copyWith(items: items);
    _recalculateDiscount();
  }

  void updateQuantity(CartItem item, int quantity) {
    if (quantity <= 0) {
      item.map(
        product: (p) => removeProduct(p.product.id),
        service: (s) => removeService(s.service.id),
      );
      return;
    }

    final items = List<CartItem>.from(state.items);
    final index = items.indexOf(item);

    if (index != -1) {
      items[index] = item.copyWith(quantity: quantity);
      state = state.copyWith(items: items);
      _recalculateDiscount();
    }
  }

  void clearCart() {
    state = const Cart();
  }

  Future<void> applyCoupon(String code) async {
    if (state.items.isEmpty) {
      throw Exception('O carrinho está vazio');
    }

    final repository = ref.read(couponRepositoryProvider);

    // 1. Get coupon
    final coupon = await repository.getCouponByCode(code);
    if (coupon == null) {
      throw Exception('Cupom não encontrado');
    }

    // 2. Validate locally first
    if (!coupon.isValid) {
      throw Exception('Cupom inválido ou expirado');
    }

    // 3. Check applicable types
    bool hasApplicableItems = false;
    if (coupon.canApplyTo(CouponApplicableTo.products) &&
        state.items.any(
          (i) => i.map(product: (_) => true, service: (_) => false),
        )) {
      hasApplicableItems = true;
    }
    if (coupon.canApplyTo(CouponApplicableTo.services) &&
        state.items.any(
          (i) => i.map(product: (_) => false, service: (_) => true),
        )) {
      hasApplicableItems = true;
    }

    if (!hasApplicableItems) {
      throw Exception('Este cupom não se aplica aos itens do carrinho');
    }

    // 4. Validate with backend (for strict checks like usage limits)
    final validation = await repository.validateCoupon(
      code: code,
      applicableTo: state.items.first.map(
        product: (_) => CouponApplicableTo.products,
        service: (_) => CouponApplicableTo.services,
      ), // Simplified: just checking against first item type for now
      amount: state.subtotal,
    );

    if (validation['valid'] != true) {
      throw Exception(validation['error'] ?? 'Erro ao validar cupom');
    }

    // 5. Apply
    state = state.copyWith(appliedCoupon: coupon);
    _recalculateDiscount();
  }

  void removeCoupon() {
    state = state.copyWith(appliedCoupon: null, discountAmount: 0);
  }

  Future<void> checkout() async {
    if (state.items.isEmpty) {
      throw Exception('O carrinho está vazio');
    }

    final functions = FirebaseFunctions.instance;

    // Prepare items for Cloud Function
    final items = state.items.map((item) {
      return item.map(
        product: (p) => {
          'type': 'product',
          'id': p.product.id,
          'quantity': p.quantity,
        },
        service: (s) => {
          'type': 'service',
          'id': s.service.id,
          'quantity': s.quantity,
        },
      );
    }).toList();

    try {
      final result = await functions
          .httpsCallable('createUnifiedCheckoutSession')
          .call({
            'items': items,
            'couponCode': state.appliedCoupon?.code,
            // TODO: Replace with actual deep links or web URLs
            'successUrl': 'https://aquaclean.app/success',
            'cancelUrl': 'https://aquaclean.app/cancel',
          });

      final url = result.data['url'];
      if (url != null) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Não foi possível abrir o link de pagamento');
        }
      }
    } catch (e) {
      print('Checkout error: $e');
      throw Exception('Erro ao iniciar checkout: $e');
    }
  }

  void _recalculateDiscount() {
    if (state.appliedCoupon == null) {
      state = state.copyWith(discountAmount: 0);
      return;
    }

    final coupon = state.appliedCoupon!;
    double eligibleAmount = 0;

    for (final item in state.items) {
      item.map(
        product: (p) {
          if (coupon.canApplyTo(CouponApplicableTo.products)) {
            eligibleAmount += p.total;
          }
        },
        service: (s) {
          if (coupon.canApplyTo(CouponApplicableTo.services)) {
            eligibleAmount += s.total;
          }
        },
      );
    }

    final discount = coupon.calculateDiscount(eligibleAmount);
    state = state.copyWith(discountAmount: discount);
  }
}
