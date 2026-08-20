import 'cart_item.dart';

/// Pure Dart Cart Aggregate Entity (Domain Layer)
class Cart {
  final List<CartItem> items;
  final double discount;
  final String? customerName;

  const Cart({this.items = const [], this.discount = 0.0, this.customerName});

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get totalAmount {
    final finalAmount = subtotal - discount;
    return finalAmount > 0 ? finalAmount : 0.0;
  }

  Cart copyWith({
    List<CartItem>? items,
    double? discount,
    String? customerName,
  }) {
    return Cart(
      items: items ?? this.items,
      discount: discount ?? this.discount,
      customerName: customerName ?? this.customerName,
    );
  }

  Cart addItem(CartItem newItem) {
    final existingIndex = items.indexWhere(
      (item) => item.product.id == newItem.product.id,
    );
    if (existingIndex >= 0) {
      final updatedList = List<CartItem>.from(items);
      final current = updatedList[existingIndex];
      updatedList[existingIndex] = current.copyWith(
        quantity: current.quantity + newItem.quantity,
      );
      return copyWith(items: updatedList);
    } else {
      return copyWith(items: [...items, newItem]);
    }
  }

  Cart updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      return removeItem(productId);
    }
    final updatedList = items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();
    return copyWith(items: updatedList);
  }

  Cart removeItem(String productId) {
    final updatedList = items
        .where((item) => item.product.id != productId)
        .toList();
    return copyWith(items: updatedList);
  }

  Cart clear() {
    return const Cart();
  }
}
