import 'package:flutter_test/flutter_test.dart';
import 'package:umkm_pos/features/cart/domain/entities/cart.dart';
import 'package:umkm_pos/features/cart/domain/entities/cart_item.dart';
import 'package:umkm_pos/features/products/domain/entities/product.dart';

void main() {
  group('Cart Aggregate Entity Tests', () {
    final now = DateTime(2026, 8, 20);
    final productA = Product(
      id: 'p1',
      name: 'Produk A',
      price: 10000,
      stock: 20,
      createdAt: now,
      updatedAt: now,
    );
    final productB = Product(
      id: 'p2',
      name: 'Produk B',
      price: 25000,
      stock: 10,
      createdAt: now,
      updatedAt: now,
    );

    test('Initial cart is empty with zero total', () {
      const cart = Cart();
      expect(cart.isEmpty, isTrue);
      expect(cart.totalQuantity, 0);
      expect(cart.totalAmount, 0.0);
    });

    test('addItem adds items and computes subtotal correctly', () {
      var cart = const Cart();
      cart = cart.addItem(CartItem(product: productA, quantity: 2));
      expect(cart.totalQuantity, 2);
      expect(cart.subtotal, 20000.0);

      // Add another product
      cart = cart.addItem(CartItem(product: productB, quantity: 1));
      expect(cart.totalQuantity, 3);
      expect(cart.subtotal, 45000.0);
      expect(cart.totalAmount, 45000.0);

      // Add same product increases quantity
      cart = cart.addItem(CartItem(product: productA, quantity: 1));
      expect(cart.totalQuantity, 4);
      expect(cart.items.firstWhere((i) => i.product.id == 'p1').quantity, 3);
      expect(cart.subtotal, 55000.0);
    });

    test('updateQuantity updates item quantity or removes if <= 0', () {
      var cart = const Cart();
      cart = cart.addItem(CartItem(product: productA, quantity: 2));
      cart = cart.updateQuantity('p1', 5);
      expect(cart.totalQuantity, 5);

      cart = cart.updateQuantity('p1', 0);
      expect(cart.isEmpty, isTrue);
    });

    test('discount correctly calculates final total amount', () {
      var cart = const Cart();
      cart = cart.addItem(CartItem(product: productA, quantity: 5)); // 50.000
      cart = cart.copyWith(discount: 10000);

      expect(cart.subtotal, 50000.0);
      expect(cart.totalAmount, 40000.0);
    });
  });
}
