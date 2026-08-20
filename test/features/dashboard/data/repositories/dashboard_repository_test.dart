import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umkm_pos/core/database/app_database.dart';
import 'package:umkm_pos/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:umkm_pos/features/products/data/repositories/product_repository_impl.dart';
import 'package:umkm_pos/features/products/domain/entities/product.dart';
import 'package:umkm_pos/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:umkm_pos/features/transactions/domain/entities/transaction_entity.dart';
import 'package:umkm_pos/features/transactions/domain/entities/transaction_item_entity.dart';

void main() {
  late AppDatabase db;
  late DashboardRepositoryImpl dashboardRepo;
  late ProductRepositoryImpl productRepo;
  late TransactionRepositoryImpl transactionRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dashboardRepo = DashboardRepositoryImpl(db);
    productRepo = ProductRepositoryImpl(db);
    transactionRepo = TransactionRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Dashboard Repository Aggregation Tests', () {
    test(
      'Calculates totalSalesToday, averageOrderValue, topProducts and lowStock correctly',
      () async {
        final now = DateTime.now();

        // 1. Create a product with low stock (2 units left, min alert 5)
        final prod1 = Product(
          id: 'p-1',
          name: 'Es Teh Manis',
          price: 5000,
          stock: 4,
          minStockAlert: 5,
          createdAt: now,
          updatedAt: now,
        );
        await productRepo.createProduct(prod1);

        // 2. Create a transaction of 2 units (Total: 10.000)
        final tx = TransactionEntity(
          id: 'tx-1',
          invoiceNumber: 'INV/DASH/001',
          totalAmount: 10000,
          paymentMethod: PaymentMethod.cash,
          cashReceived: 10000,
          changeAmount: 0,
          items: const [
            TransactionItemEntity(
              id: 'item-1',
              transactionId: 'tx-1',
              productId: 'p-1',
              productName: 'Es Teh Manis',
              priceAtSale: 5000,
              quantity: 2,
              subtotal: 10000,
            ),
          ],
          createdAt: now,
          updatedAt: now,
        );
        await transactionRepo.createTransaction(tx);

        // 3. Query Dashboard Summary
        final result = await dashboardRepo.getDashboardSummary();
        expect(result.isSuccess, isTrue);
        final summary = result.dataOrNull!;

        expect(summary.totalSalesToday, 10000.0);
        expect(summary.totalTransactionsToday, 1);
        expect(summary.averageOrderValue, 10000.0);
        expect(summary.topProducts.length, 1);
        expect(summary.topProducts.first.totalQuantitySold, 2);
        expect(summary.topProducts.first.totalRevenue, 10000.0);
        // Stock remaining is 2 (which is <= 5), so it should be in lowStockProducts
        expect(summary.lowStockProducts.length, 1);
        expect(summary.lowStockProducts.first.stock, 2);
      },
    );
  });
}
