import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase _db;

  CategoryRepositoryImpl(this._db);

  Category _toEntity(CategoryTableData data) {
    return Category(
      id: data.id,
      name: data.name,
      iconName: data.iconName,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      isSynced: data.isSynced,
    );
  }

  CategoriesCompanion _toCompanion(Category category) {
    return CategoriesCompanion(
      id: Value(category.id),
      name: Value(category.name),
      iconName: Value(category.iconName),
      createdAt: Value(category.createdAt),
      updatedAt: Value(category.updatedAt),
      isSynced: Value(category.isSynced),
    );
  }

  @override
  Future<Result<List<Category>>> getCategories() async {
    try {
      final query = _db.select(_db.categories)
        ..orderBy([(t) => OrderingTerm.asc(t.name)]);
      final list = await query.get();
      return Result.success(list.map(_toEntity).toList());
    } catch (e) {
      return Result.error(DatabaseFailure('Gagal memuat kategori', cause: e));
    }
  }

  @override
  Stream<List<Category>> watchCategories() {
    final query = _db.select(_db.categories)
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    return query.watch().map((list) => list.map(_toEntity).toList());
  }

  @override
  Future<Result<Category>> createCategory(Category category) async {
    try {
      final now = DateTime.now();
      final item = category.copyWith(
        createdAt: now,
        updatedAt: now,
        isSynced: false,
      );
      await _db.into(_db.categories).insert(_toCompanion(item));
      return Result.success(item);
    } catch (e) {
      return Result.error(DatabaseFailure('Gagal membuat kategori', cause: e));
    }
  }

  @override
  Future<Result<Category>> updateCategory(Category category) async {
    try {
      final now = DateTime.now();
      final item = category.copyWith(updatedAt: now, isSynced: false);
      await _db.update(_db.categories).replace(_toCompanion(item));
      return Result.success(item);
    } catch (e) {
      return Result.error(
        DatabaseFailure('Gagal memperbarui kategori', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> deleteCategory(String id) async {
    try {
      await (_db.delete(_db.categories)..where((t) => t.id.equals(id))).go();
      return const Result.success(null);
    } catch (e) {
      return Result.error(
        DatabaseFailure('Gagal menghapus kategori', cause: e),
      );
    }
  }
}
