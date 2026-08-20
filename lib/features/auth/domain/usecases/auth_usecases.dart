import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/store.dart';
import '../repositories/store_repository.dart';

class GetStoreProfileUseCase {
  final StoreRepository _repository;
  const GetStoreProfileUseCase(this._repository);

  Future<Result<Store?>> execute() => _repository.getStoreProfile();
  Stream<Store?> watch() => _repository.watchStoreProfile();
}

class SaveStoreProfileUseCase {
  final StoreRepository _repository;
  const SaveStoreProfileUseCase(this._repository);

  Future<Result<Store>> execute(Store store) {
    if (store.name.trim().isEmpty) {
      return Future.value(
        const Result.error(ValidationFailure('Nama toko tidak boleh kosong')),
      );
    }
    return _repository.saveStoreProfile(store);
  }
}

class VerifyPinUseCase {
  final StoreRepository _repository;
  const VerifyPinUseCase(this._repository);

  Future<Result<bool>> execute(String pin) {
    if (pin.trim().isEmpty) {
      return Future.value(
        const Result.error(ValidationFailure('PIN tidak boleh kosong')),
      );
    }
    return _repository.verifyPin(pin);
  }
}
