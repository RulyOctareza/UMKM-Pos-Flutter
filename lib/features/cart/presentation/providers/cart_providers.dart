import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';

class CartNotifier extends StateNotifier<Cart> {
  CartNotifier() : super(const Cart());

  void addProduct(Product product, [int quantity = 1]) {
    final existingIndex = state.items.indexWhere(
      (item) => item.product.id == product.id,
    );
    final currentQty = existingIndex >= 0
        ? state.items[existingIndex].quantity
        : 0;
    final targetQty = currentQty + quantity;

    if (targetQty > product.stock) {
      return;
    }

    state = state.addItem(CartItem(product: product, quantity: quantity));
  }

  void increment(String productId) {
    final item = state.items.firstWhere(
      (i) => i.product.id == productId,
      orElse: () => throw Exception('Item not found'),
    );
    if (item.quantity + 1 > item.product.stock) return;
    state = state.updateQuantity(productId, item.quantity + 1);
  }

  void decrement(String productId) {
    final item = state.items.firstWhere(
      (i) => i.product.id == productId,
      orElse: () => throw Exception('Item not found'),
    );
    state = state.updateQuantity(productId, item.quantity - 1);
  }

  void updateQuantity(String productId, int quantity) {
    state = state.updateQuantity(productId, quantity);
  }

  void removeItem(String productId) {
    state = state.removeItem(productId);
  }

  void setDiscount(double discount) {
    state = state.copyWith(discount: discount);
  }

  void setCustomerName(String? name) {
    state = state.copyWith(customerName: name);
  }

  void clear() {
    state = state.clear();
  }
}

final cartNotifierProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  return CartNotifier();
});

final cartTotalQuantityProvider = Provider<int>((ref) {
  return ref.watch(cartNotifierProvider).totalQuantity;
});

final cartTotalAmountProvider = Provider<double>((ref) {
  return ref.watch(cartNotifierProvider).totalAmount;
});

final isCartEmptyProvider = Provider<bool>((ref) {
  return ref.watch(cartNotifierProvider).isEmpty;
});
