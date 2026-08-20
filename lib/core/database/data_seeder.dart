import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../features/transactions/domain/entities/transaction_entity.dart';
import 'app_database.dart';

/// Utilitas Seeder untuk mengisi data dummy contoh UMKM (Coffee Shop & Bakery) dengan foto produk HD
class DataSeeder {
  DataSeeder._();

  static Future<void> seedDemoData(AppDatabase db) async {
    final now = DateTime.now();
    const uuid = Uuid();

    // 1. Profil Toko Demo
    await db.into(db.stores).insertOnConflictUpdate(
          StoresCompanion(
            id: const Value('demo-store-1'),
            name: const Value('Kopi & Roti Nusantara'),
            address: const Value('Jl. Malioboro No. 45, Yogyakarta'),
            phone: const Value('0812-3456-7890'),
            currency: const Value('IDR'),
            pin: const Value('1234'),
            logoPath: const Value(
              'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=500&auto=format&fit=crop&q=80',
            ),
            createdAt: Value(now),
            updatedAt: Value(now),
            isSynced: const Value(false),
          ),
        );

    // 2. Kategori Demo
    final categories = [
      CategoriesCompanion(
        id: const Value('cat-kopi'),
        name: const Value('Kopi Spesial'),
        iconName: const Value('coffee'),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
      ),
      CategoriesCompanion(
        id: const Value('cat-non-kopi'),
        name: const Value('Non-Kopi & Teh'),
        iconName: const Value('tea'),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
      ),
      CategoriesCompanion(
        id: const Value('cat-makanan'),
        name: const Value('Makanan & Snack'),
        iconName: const Value('food'),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
      ),
      CategoriesCompanion(
        id: const Value('cat-pastry'),
        name: const Value('Pastry & Roti'),
        iconName: const Value('bread'),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
      ),
    ];

    for (final cat in categories) {
      await db.into(db.categories).insertOnConflictUpdate(cat);
    }

    // 3. Produk Demo dengan Foto Internet HD (Unsplash CDN)
    final products = [
      ProductsCompanion(
        id: const Value('prod-1'),
        name: const Value('Kopi Susu Gula Aren'),
        price: const Value(18000.0),
        costPrice: const Value(9000.0),
        categoryId: const Value('cat-kopi'),
        stock: const Value(45),
        minStockAlert: const Value(5),
        unit: const Value('cup'),
        barcode: const Value('8991001'),
        imagePath: const Value(
          'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?w=500&auto=format&fit=crop&q=80',
        ),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
      ),
      ProductsCompanion(
        id: const Value('prod-2'),
        name: const Value('Americano Ice'),
        price: const Value(15000.0),
        costPrice: const Value(6000.0),
        categoryId: const Value('cat-kopi'),
        stock: const Value(30),
        minStockAlert: const Value(5),
        unit: const Value('cup'),
        barcode: const Value('8991002'),
        imagePath: const Value(
          'https://images.unsplash.com/photo-1551030173-122aabc4489c?w=500&auto=format&fit=crop&q=80',
        ),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
      ),
      ProductsCompanion(
        id: const Value('prod-3'),
        name: const Value('Caramel Macchiato'),
        price: const Value(24000.0),
        costPrice: const Value(12000.0),
        categoryId: const Value('cat-kopi'),
        stock: const Value(20),
        minStockAlert: const Value(5),
        unit: const Value('cup'),
        barcode: const Value('8991003'),
        imagePath: const Value(
          'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=500&auto=format&fit=crop&q=80',
        ),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
      ),
      ProductsCompanion(
        id: const Value('prod-4'),
        name: const Value('Matcha Latte Ice'),
        price: const Value(22000.0),
        costPrice: const Value(11000.0),
        categoryId: const Value('cat-non-kopi'),
        stock: const Value(25),
        minStockAlert: const Value(5),
        unit: const Value('cup'),
        barcode: const Value('8991004'),
        imagePath: const Value(
          'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=500&auto=format&fit=crop&q=80',
        ),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
      ),
      ProductsCompanion(
        id: const Value('prod-5'),
        name: const Value('Earl Grey Milk Tea'),
        price: const Value(20000.0),
        costPrice: const Value(9000.0),
        categoryId: const Value('cat-non-kopi'),
        stock: const Value(35),
        minStockAlert: const Value(5),
        unit: const Value('cup'),
        barcode: const Value('8991005'),
        imagePath: const Value(
          'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=500&auto=format&fit=crop&q=80',
        ),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
      ),
      ProductsCompanion(
        id: const Value('prod-6'),
        name: const Value('Roti Bakar Cokelat Keju'),
        price: const Value(16000.0),
        costPrice: const Value(8000.0),
        categoryId: const Value('cat-makanan'),
        stock: const Value(15),
        minStockAlert: const Value(3),
        unit: const Value('porsi'),
        barcode: const Value('8991006'),
        imagePath: const Value(
          'https://images.unsplash.com/photo-1584776296944-ab6fb57b0bdd?w=500&auto=format&fit=crop&q=80',
        ),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
      ),
      ProductsCompanion(
        id: const Value('prod-7'),
        name: const Value('Croissant Butter'),
        price: const Value(20000.0),
        costPrice: const Value(10000.0),
        categoryId: const Value('cat-pastry'),
        stock: const Value(3), // STOK MENIPIS (3 <= 5)
        minStockAlert: const Value(5),
        unit: const Value('pcs'),
        barcode: const Value('8991007'),
        imagePath: const Value(
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=500&auto=format&fit=crop&q=80',
        ),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
      ),
      ProductsCompanion(
        id: const Value('prod-8'),
        name: const Value('French Fries Sea Salt'),
        price: const Value(15000.0),
        costPrice: const Value(7000.0),
        categoryId: const Value('cat-makanan'),
        stock: const Value(0), // STOK HABIS
        minStockAlert: const Value(5),
        unit: const Value('porsi'),
        barcode: const Value('8991008'),
        imagePath: const Value(
          'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=500&auto=format&fit=crop&q=80',
        ),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
      ),
    ];

    for (final prod in products) {
      await db.into(db.products).insertOnConflictUpdate(prod);
    }

    // 4. Riwayat Transaksi Penjualan Contoh
    final tx1Id = uuid.v4();
    await db.into(db.transactions).insertOnConflictUpdate(
          TransactionsCompanion(
            id: Value(tx1Id),
            invoiceNumber: const Value('INV/20260820/0001'),
            totalAmount: const Value(54000.0),
            paymentMethod: Value(PaymentMethod.cash.value),
            cashReceived: const Value(100000.0),
            changeAmount: const Value(46000.0),
            status: const Value('completed'),
            notes: const Value('Dine-in meja 03'),
            createdAt: Value(now.subtract(const Duration(hours: 2))),
            updatedAt: Value(now.subtract(const Duration(hours: 2))),
            isSynced: const Value(false),
          ),
        );

    await db.into(db.transactionItems).insert(
          TransactionItemsCompanion(
            id: Value(uuid.v4()),
            transactionId: Value(tx1Id),
            productId: const Value('prod-1'),
            productName: const Value('Kopi Susu Gula Aren'),
            priceAtSale: const Value(18000.0),
            quantity: const Value(2),
            subtotal: const Value(36000.0),
          ),
        );

    await db.into(db.transactionItems).insert(
          TransactionItemsCompanion(
            id: Value(uuid.v4()),
            transactionId: Value(tx1Id),
            productId: const Value('prod-6'),
            productName: const Value('Roti Bakar Cokelat Keju'),
            priceAtSale: const Value(16000.0),
            quantity: const Value(1),
            subtotal: const Value(16000.0),
          ),
        );

    final tx2Id = uuid.v4();
    await db.into(db.transactions).insertOnConflictUpdate(
          TransactionsCompanion(
            id: Value(tx2Id),
            invoiceNumber: const Value('INV/20260820/0002'),
            totalAmount: const Value(44000.0),
            paymentMethod: Value(PaymentMethod.qris.value),
            cashReceived: const Value(44000.0),
            changeAmount: const Value(0.0),
            status: const Value('completed'),
            notes: const Value('Take-away'),
            createdAt: Value(now.subtract(const Duration(minutes: 45))),
            updatedAt: Value(now.subtract(const Duration(minutes: 45))),
            isSynced: const Value(false),
          ),
        );

    await db.into(db.transactionItems).insert(
          TransactionItemsCompanion(
            id: Value(uuid.v4()),
            transactionId: Value(tx2Id),
            productId: const Value('prod-3'),
            productName: const Value('Caramel Macchiato'),
            priceAtSale: const Value(24000.0),
            quantity: const Value(1),
            subtotal: const Value(24000.0),
          ),
        );

    await db.into(db.transactionItems).insert(
          TransactionItemsCompanion(
            id: Value(uuid.v4()),
            transactionId: Value(tx2Id),
            productId: const Value('prod-7'),
            productName: const Value('Croissant Butter'),
            priceAtSale: const Value(20000.0),
            quantity: const Value(1),
            subtotal: const Value(20000.0),
          ),
        );
  }

  /// Menghapus seluruh data untuk reset bersih
  static Future<void> clearAllData(AppDatabase db) async {
    await db.transaction(() async {
      await db.delete(db.transactionItems).go();
      await db.delete(db.transactions).go();
      await db.delete(db.products).go();
      await db.delete(db.categories).go();
      await db.delete(db.stores).go();
    });
  }
}
