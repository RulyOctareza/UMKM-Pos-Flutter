import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/store.dart';
import '../../domain/repositories/store_repository.dart';

class StoreRepositoryImpl implements StoreRepository {
  final AppDatabase _db;

  StoreRepositoryImpl(this._db);

  Store _toEntity(StoreTableData data) {
    return Store(
      id: data.id,
      name: data.name,
      address: data.address,
      phone: data.phone,
      logoPath: data.logoPath,
      currency: data.currency,
      pin: data.pin,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      isSynced: data.isSynced,
    );
  }

  StoresCompanion _toCompanion(Store store) {
    return StoresCompanion(
      id: Value(store.id),
      name: Value(store.name),
      address: Value(store.address),
      phone: Value(store.phone),
      logoPath: Value(store.logoPath),
      currency: Value(store.currency),
      pin: Value(store.pin),
      createdAt: Value(store.createdAt),
      updatedAt: Value(store.updatedAt),
      isSynced: Value(store.isSynced),
    );
  }

  @override
  Future<Result<Store?>> getStoreProfile() async {
    try {
      final store = await (_db.select(_db.stores)..limit(1)).getSingleOrNull();
      return Result.success(store != null ? _toEntity(store) : null);
    } catch (e) {
      return Result.error(DatabaseFailure('Gagal memuat data toko', cause: e));
    }
  }

  @override
  Stream<Store?> watchStoreProfile() {
    return (_db.select(_db.stores)..limit(1)).watchSingleOrNull().map(
      (data) => data != null ? _toEntity(data) : null,
    );
  }

  @override
  Future<Result<Store>> saveStoreProfile(Store store) async {
    try {
      final now = DateTime.now();
      final updatedStore = store.copyWith(updatedAt: now, isSynced: false);
      await _db
          .into(_db.stores)
          .insertOnConflictUpdate(_toCompanion(updatedStore));
      return Result.success(updatedStore);
    } catch (e) {
      return Result.error(
        DatabaseFailure('Gagal menyimpan profil toko', cause: e),
      );
    }
  }

  @override
  Future<Result<bool>> verifyPin(String pin) async {
    try {
      final store = await (_db.select(_db.stores)..limit(1)).getSingleOrNull();
      if (store == null || store.pin == null || store.pin!.isEmpty) {
        return const Result.success(true);
      }
      return Result.success(store.pin == pin);
    } catch (e) {
      return Result.error(DatabaseFailure('Gagal memverifikasi PIN', cause: e));
    }
  }
}
