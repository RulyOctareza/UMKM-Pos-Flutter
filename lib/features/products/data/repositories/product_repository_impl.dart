import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final AppDatabase _db;

  ProductRepositoryImpl(this._db);

  Product _rowToEntity(TypedResult row) {
    final productData = row.readTable(_db.products);
    final categoryData = row.readTableOrNull(_db.categories);

    return Product(
      id: productData.id,
      name: productData.name,
      price: productData.price,
      costPrice: productData.costPrice,
      categoryId: productData.categoryId,
      categoryName: categoryData?.name,
      stock: productData.stock,
      minStockAlert: productData.minStockAlert,
      imagePath: productData.imagePath,
      unit: productData.unit,
      barcode: productData.barcode,
      createdAt: productData.createdAt,
      updatedAt: productData.updatedAt,
      isSynced: productData.isSynced,
    );
  }

  ProductsCompanion _toCompanion(Product product) {
    return ProductsCompanion(
      id: Value(product.id),
      name: Value(product.name),
      price: Value(product.price),
      costPrice: Value(product.costPrice),
      categoryId: Value(product.categoryId),
      stock: Value(product.stock),
      minStockAlert: Value(product.minStockAlert),
      imagePath: Value(product.imagePath),
      unit: Value(product.unit),
      barcode: Value(product.barcode),
      createdAt: Value(product.createdAt),
      updatedAt: Value(product.updatedAt),
      isSynced: Value(product.isSynced),
    );
  }

  JoinedSelectStatement<HasResultSet, dynamic> _buildJoinedQuery({
    String? categoryId,
    String? searchQuery,
    bool? lowStockOnly,
  }) {
    var query = _db.select(_db.products).join([
      leftOuterJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.products.categoryId),
      ),
    ]);

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query..where(_db.products.categoryId.equals(categoryId));
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final pattern = '%${searchQuery.trim().toLowerCase()}%';
      query = query..where(_db.products.name.lower().like(pattern));
    }

    if (lowStockOnly == true) {
      query = query
        ..where(
          _db.products.stock.isSmallerOrEqual(_db.products.minStockAlert),
        );
    }

    query = query..orderBy([OrderingTerm.asc(_db.products.name)]);

    return query;
  }

  @override
  Future<Result<List<Product>>> getProducts({
    String? categoryId,
    String? searchQuery,
  }) async {
    try {
      final rows = await _buildJoinedQuery(
        categoryId: categoryId,
        searchQuery: searchQuery,
      ).get();
      return Result.success(rows.map(_rowToEntity).toList());
    } catch (e) {
      return Result.error(
        DatabaseFailure('Gagal memuat daftar produk', cause: e),
      );
    }
  }

  @override
  Stream<List<Product>> watchProducts({
    String? categoryId,
    String? searchQuery,
  }) {
    return _buildJoinedQuery(
      categoryId: categoryId,
      searchQuery: searchQuery,
    ).watch().map((rows) => rows.map(_rowToEntity).toList());
  }

  @override
  Future<Result<Product?>> getProductById(String id) async {
    try {
      final query = _db.select(_db.products).join([
        leftOuterJoin(
          _db.categories,
          _db.categories.id.equalsExp(_db.products.categoryId),
        ),
      ])..where(_db.products.id.equals(id));

      final row = await query.getSingleOrNull();
      return Result.success(row != null ? _rowToEntity(row) : null);
    } catch (e) {
      return Result.error(
        DatabaseFailure('Gagal memuat data produk', cause: e),
      );
    }
  }

  @override
  Future<Result<Product>> createProduct(Product product) async {
    try {
      final now = DateTime.now();
      final item = product.copyWith(
        createdAt: now,
        updatedAt: now,
        isSynced: false,
      );
      await _db.into(_db.products).insert(_toCompanion(item));
      return Result.success(item);
    } catch (e) {
      return Result.error(
        DatabaseFailure('Gagal menambahkan produk baru', cause: e),
      );
    }
  }

  @override
  Future<Result<Product>> updateProduct(Product product) async {
    try {
      final now = DateTime.now();
      final item = product.copyWith(updatedAt: now, isSynced: false);
      await _db.update(_db.products).replace(_toCompanion(item));
      return Result.success(item);
    } catch (e) {
      return Result.error(
        DatabaseFailure('Gagal memperbarui data produk', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> deleteProduct(String id) async {
    try {
      await (_db.delete(_db.products)..where((t) => t.id.equals(id))).go();
      return const Result.success(null);
    } catch (e) {
      return Result.error(DatabaseFailure('Gagal menghapus produk', cause: e));
    }
  }

  @override
  Future<Result<List<Product>>> getLowStockProducts() async {
    try {
      final rows = await _buildJoinedQuery(lowStockOnly: true).get();
      return Result.success(rows.map(_rowToEntity).toList());
    } catch (e) {
      return Result.error(
        DatabaseFailure('Gagal memuat produk stok menipis', cause: e),
      );
    }
  }

  @override
  Stream<List<Product>> watchLowStockProducts() {
    return _buildJoinedQuery(
      lowStockOnly: true,
    ).watch().map((rows) => rows.map(_rowToEntity).toList());
  }
}
