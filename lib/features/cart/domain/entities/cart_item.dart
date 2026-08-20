import '../../../products/domain/entities/product.dart';

/// Pure Dart CartItem Entity (Domain Layer)
class CartItem {
  final Product product;
  final int quantity;
  final String? customNote;

  const CartItem({required this.product, this.quantity = 1, this.customNote});

  double get subtotal => product.price * quantity;

  CartItem copyWith({Product? product, int? quantity, String? customNote}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      customNote: customNote ?? this.customNote,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CartItem &&
          other.product.id == product.id &&
          other.quantity == quantity);

  @override
  int get hashCode => product.id.hashCode ^ quantity.hashCode;
}
