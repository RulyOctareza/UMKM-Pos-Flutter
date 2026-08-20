import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final AppDatabase _db;

  DashboardRepositoryImpl(this._db);

  Future<DashboardSummary> _calculateSummary() async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final startOfMonth = DateTime(now.year, now.month, 1, 0, 0, 0);

    // 1. Transaksi Hari Ini
    final todayTxs =
        await (_db.select(_db.transactions)..where(
              (t) =>
                  t.createdAt.isBiggerOrEqualValue(startOfToday) &
                  t.createdAt.isSmallerOrEqualValue(endOfToday) &
                  t.status.equals('completed'),
            ))
            .get();

    final totalSalesToday = todayTxs.fold<double>(
      0.0,
      (sum, tx) => sum + tx.totalAmount,
    );
    final totalTransactionsToday = todayTxs.length;
    final aov = totalTransactionsToday > 0
        ? (totalSalesToday / totalTransactionsToday)
        : 0.0;

    // 2. Transaksi Bulan Ini
    final monthTxs =
        await (_db.select(_db.transactions)..where(
              (t) =>
                  t.createdAt.isBiggerOrEqualValue(startOfMonth) &
                  t.createdAt.isSmallerOrEqualValue(endOfToday) &
                  t.status.equals('completed'),
            ))
            .get();

    final totalSalesThisMonth = monthTxs.fold<double>(
      0.0,
      (sum, tx) => sum + tx.totalAmount,
    );
    final totalTransactionsThisMonth = monthTxs.length;

    // 3. Top Selling Products
    final topProductRows = await _db
        .customSelect(
          '''
      SELECT 
        ti.product_id,
        ti.product_name,
        SUM(ti.quantity) as total_qty,
        SUM(ti.subtotal) as total_revenue
      FROM transaction_items ti
      INNER JOIN transactions t ON t.id = ti.transaction_id
      WHERE t.status = 'completed'
      GROUP BY ti.product_id, ti.product_name
      ORDER BY total_qty DESC
      LIMIT 5
      ''',
          readsFrom: {_db.transactionItems, _db.transactions},
        )
        .get();

    final topProducts = <TopProductSummary>[];
    for (final row in topProductRows) {
      final productId = row.read<String>('product_id');
      final totalQty = row.read<int>('total_qty');
      final totalRev = row.read<double>('total_revenue');

      final productData = await (_db.select(
        _db.products,
      )..where((p) => p.id.equals(productId))).getSingleOrNull();
      final product = productData != null
          ? Product(
              id: productData.id,
              name: productData.name,
              price: productData.price,
              costPrice: productData.costPrice,
              stock: productData.stock,
              minStockAlert: productData.minStockAlert,
              imagePath: productData.imagePath,
              unit: productData.unit,
              createdAt: productData.createdAt,
              updatedAt: productData.updatedAt,
              isSynced: productData.isSynced,
            )
          : Product(
              id: productId,
              name: row.read<String>('product_name'),
              price: totalQty > 0 ? (totalRev / totalQty) : 0.0,
              createdAt: now,
              updatedAt: now,
            );

      topProducts.add(
        TopProductSummary(
          product: product,
          totalQuantitySold: totalQty,
          totalRevenue: totalRev,
        ),
      );
    }

    // 4. Produk Stok Menipis
    final lowStockData =
        await (_db.select(_db.products)
              ..where((p) => p.stock.isSmallerOrEqual(p.minStockAlert))
              ..orderBy([(p) => OrderingTerm.asc(p.stock)]))
            .get();

    final lowStockProducts = lowStockData
        .map(
          (p) => Product(
            id: p.id,
            name: p.name,
            price: p.price,
            costPrice: p.costPrice,
            stock: p.stock,
            minStockAlert: p.minStockAlert,
            imagePath: p.imagePath,
            unit: p.unit,
            createdAt: p.createdAt,
            updatedAt: p.updatedAt,
            isSynced: p.isSynced,
          ),
        )
        .toList();

    return DashboardSummary(
      totalSalesToday: totalSalesToday,
      totalTransactionsToday: totalTransactionsToday,
      averageOrderValue: aov,
      totalSalesThisMonth: totalSalesThisMonth,
      totalTransactionsThisMonth: totalTransactionsThisMonth,
      topProducts: topProducts,
      lowStockProducts: lowStockProducts,
    );
  }

  @override
  Future<Result<DashboardSummary>> getDashboardSummary() async {
    try {
      final summary = await _calculateSummary();
      return Result.success(summary);
    } catch (e) {
      return Result.error(
        DatabaseFailure('Gagal memuat ringkasan dashboard', cause: e),
      );
    }
  }

  @override
  Stream<DashboardSummary> watchDashboardSummary() {
    // Stream reaktif yang mendengarkan perubahan transaksi dan produk
    return _db
        .select(_db.transactions)
        .watch()
        .asyncMap((_) => _calculateSummary());
  }
}
