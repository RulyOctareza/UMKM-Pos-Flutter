import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umkm_pos/core/widgets/product_card.dart';
import 'package:umkm_pos/features/products/domain/entities/product.dart';

void main() {
  group('ProductCard Widget Tests', () {
    final now = DateTime(2026, 8, 20);

    testWidgets('renders product name and formatted price correctly', (
      WidgetTester tester,
    ) async {
      final product = Product(
        id: 'p-1',
        name: 'Cappuccino Hangat',
        price: 22000,
        stock: 15,
        minStockAlert: 5,
        createdAt: now,
        updatedAt: now,
      );

      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 180,
              height: 220,
              child: ProductCard(
                product: product,
                onTap: () => wasTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Cappuccino Hangat'), findsOneWidget);
      expect(find.text('Rp 22.000'), findsOneWidget);

      // Tap card
      await tester.tap(find.byType(ProductCard));
      expect(wasTapped, isTrue);
    });

    testWidgets('displays Habis badge when stock is 0 and disables tap', (
      WidgetTester tester,
    ) async {
      final outOfStockProduct = Product(
        id: 'p-2',
        name: 'Donat Cokelat',
        price: 8000,
        stock: 0,
        minStockAlert: 5,
        createdAt: now,
        updatedAt: now,
      );

      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 180,
              height: 220,
              child: ProductCard(
                product: outOfStockProduct,
                onTap: () => wasTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Habis'), findsOneWidget);

      await tester.tap(find.byType(ProductCard));
      expect(wasTapped, isFalse);
    });

    testWidgets('renders quantity in cart badge and decrements on tap minus', (
      WidgetTester tester,
    ) async {
      final product = Product(
        id: 'p-3',
        name: 'Es Kopi Susu',
        price: 18000,
        stock: 10,
        minStockAlert: 3,
        createdAt: now,
        updatedAt: now,
      );

      bool wasDecremented = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 180,
              height: 220,
              child: ProductCard(
                product: product,
                quantityInCart: 3,
                onDecrement: () => wasDecremented = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      expect(wasDecremented, isTrue);
    });
  });
}
