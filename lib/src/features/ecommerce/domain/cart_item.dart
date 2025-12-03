import 'package:freezed_annotation/freezed_annotation.dart';
import 'product.dart';
import 'service.dart';

part 'cart_item.freezed.dart';
part 'cart_item.g.dart';

@freezed
abstract class CartItem with _$CartItem {
  const factory CartItem.product({
    required Product product,
    @Default(1) int quantity,
  }) = _CartItemProduct;

  const factory CartItem.service({
    required Service service,
    @Default(1) int quantity,
  }) = _CartItemService;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
}

extension CartItemExtension on CartItem {
  double get total {
    return map(
      product: (item) => item.product.price * item.quantity,
      service: (item) => item.service.price * item.quantity,
    );
  }

  String get name {
    return map(
      product: (item) => item.product.name,
      service: (item) => item.service.name,
    );
  }

  String? get imageUrl {
    return map(
      product: (item) => item.product.imageUrl,
      service: (item) => item.service.imageUrl,
    );
  }
}
