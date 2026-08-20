import '../../../../core/errors/result.dart';
import '../entities/store.dart';

abstract class StoreRepository {
  Future<Result<Store?>> getStoreProfile();
  Stream<Store?> watchStoreProfile();
  Future<Result<Store>> saveStoreProfile(Store store);
  Future<Result<bool>> verifyPin(String pin);
}
