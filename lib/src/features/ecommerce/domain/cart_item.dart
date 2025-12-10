class CartItem {
  final String serviceId;
  final String name;
  final double price;
  final String? imageUrl;
  final int quantity;

  CartItem({
    required this.serviceId,
    required this.name,
    required this.price,
    this.imageUrl,
    this.quantity = 1,
  });

  CartItem copyWith({
    String? serviceId,
    String? name,
    double? price,
    String? imageUrl,
    int? quantity,
  }) {
    return CartItem(
      serviceId: serviceId ?? this.serviceId,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }
}
