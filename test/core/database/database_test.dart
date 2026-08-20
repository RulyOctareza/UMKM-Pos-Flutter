import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umkm_pos/core/database/app_database.dart';
import 'package:umkm_pos/features/products/data/repositories/category_repository_impl.dart';
import 'package:umkm_pos/features/products/data/repositories/product_repository_impl.dart';
import 'package:umkm_pos/features/products/domain/entities/category.dart';
import 'package:umkm_pos/features/products/domain/entities/product.dart';
import 'package:umkm_pos/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:umkm_pos/features/transactions/domain/entities/transaction_entity.dart';
import 'package:umkm_pos/features/transactions/domain/entities/transaction_item_entity.dart';

void main() {
  late AppDatabase db;
  late CategoryRepositoryImpl categoryRepo;
  late ProductRepositoryImpl productRepo;
  late TransactionRepositoryImpl transactionRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    categoryRepo = CategoryRepositoryImpl(db);
    productRepo = ProductRepositoryImpl(db);
    transactionRepo = TransactionRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Drift In-Memory Database Tests', () {
    test(
      'CRUD Category and Product with stock reduction upon transaction',
      () async {
        final now = DateTime(2026, 8, 20);

        // 1. Create Category
        final cat = Category(
          id: 'cat-1',
          name: 'Minuman',
          createdAt: now,
          updatedAt: now,
        );
        final catResult = await categoryRepo.createCategory(cat);
        expect(catResult.isSuccess, isTrue);

        // 2. Create Product with initial stock 10
        final prod = Product(
          id: 'prod-1',
          name: 'Kopi Susu Gula Aren',
          price: 18000,
          costPrice: 10000,
          categoryId: 'cat-1',
          stock: 10,
          minStockAlert: 3,
          unit: 'cup',
          createdAt: now,
          updatedAt: now,
        );
        final prodResult = await productRepo.createProduct(prod);
        expect(prodResult.isSuccess, isTrue);

        // Verify product query with joined category
        final fetchProducts = await productRepo.getProducts();
        expect(fetchProducts.isSuccess, isTrue);
        expect(fetchProducts.dataOrNull?.length, 1);
        expect(fetchProducts.dataOrNull?.first.categoryName, 'Minuman');

        // 3. Create Transaction purchasing 2 cups of Kopi Susu
        final tx = TransactionEntity(
          id: 'tx-1',
          invoiceNumber: 'INV/20260820/0001',
          totalAmount: 36000,
          paymentMethod: PaymentMethod.cash,
          cashReceived: 50000,
          changeAmount: 14000,
          items: const [
            TransactionItemEntity(
              id: 'item-1',
              transactionId: 'tx-1',
              productId: 'prod-1',
              productName: 'Kopi Susu Gula Aren',
              priceAtSale: 18000,
              quantity: 2,
              subtotal: 36000,
            ),
          ],
          createdAt: now,
          updatedAt: now,
        );

        final txResult = await transactionRepo.createTransaction(tx);
        expect(txResult.isSuccess, isTrue);

        // 4. Verify that product stock automatically decreased from 10 to 8
        final updatedProduct = await productRepo.getProductById('prod-1');
        expect(updatedProduct.isSuccess, isTrue);
        expect(updatedProduct.dataOrNull?.stock, 8);

        // 5. Verify transaction history contains the new transaction and items
        final txListResult = await transactionRepo.getTransactions();
        expect(txListResult.isSuccess, isTrue);
        expect(txListResult.dataOrNull?.length, 1);
        expect(txListResult.dataOrNull?.first.items.length, 1);
        expect(txListResult.dataOrNull?.first.changeAmount, 14000);
      },
    );
  });
}
