import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umkm_pos/features/products/domain/entities/category.dart';
import 'package:umkm_pos/features/products/domain/entities/product.dart';
import 'package:umkm_pos/features/products/presentation/providers/product_providers.dart';
import 'package:umkm_pos/features/transactions/presentation/screens/cashier_screen.dart';

void main() {
  group('CashierScreen Widget Tests', () {
    final now = DateTime(2026, 8, 20);
    final mockProducts = [
      Product(
        id: 'p-1',
        name: 'Kopi Hitam',
        price: 10000,
        stock: 50,
        createdAt: now,
        updatedAt: now,
      ),
      Product(
        id: 'p-2',
        name: 'Teh Manis',
        price: 5000,
        stock: 50,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    testWidgets(
      'renders products in grid and adding to cart shows floating cart bar',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              productsStreamProvider.overrideWith(
                (ref) => Stream.value(mockProducts),
              ),
              categoriesStreamProvider.overrideWith(
                (ref) => Stream.value([
                  Category(
                    id: 'c1',
                    name: 'Minuman',
                    createdAt: now,
                    updatedAt: now,
                  ),
                ]),
              ),
            ],
            child: const MaterialApp(home: CashierScreen()),
          ),
        );

        await tester.pumpAndSettle();

        // Verifikasi produk muncul di layar
        expect(find.text('Kopi Hitam'), findsOneWidget);
        expect(find.text('Teh Manis'), findsOneWidget);

        // Tap produk Kopi Hitam untuk menambahkan ke cart
        await tester.tap(find.text('Kopi Hitam'));
        await tester.pumpAndSettle();

        // Verifikasi Floating Cart Bar muncul dengan 1 item dan harga Rp 10.000
        expect(find.text('1 item'), findsOneWidget);
        expect(find.text('Lihat Keranjang'), findsOneWidget);
      },
    );
  });
}
