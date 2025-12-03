import 'package:freezed_annotation/freezed_annotation.dart';
import 'cart_item.dart';
import 'coupon.dart';

part 'cart.freezed.dart';
part 'cart.g.dart';

@freezed
abstract class Cart with _$Cart {
  const factory Cart({
    @Default([]) List<CartItem> items,
    Coupon? appliedCoupon,
    @Default(0) double discountAmount,
  }) = _Cart;

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);
}

extension CartExtension on Cart {
  double get subtotal {
    return items.fold(0, (sum, item) => sum + item.total);
  }

  double get total {
    return subtotal - discountAmount;
  }

  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  bool get isEmpty => items.isEmpty;
}
