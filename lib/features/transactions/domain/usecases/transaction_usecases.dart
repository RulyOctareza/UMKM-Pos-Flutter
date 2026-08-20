import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class CreateTransactionUseCase {
  final TransactionRepository _repository;
  const CreateTransactionUseCase(this._repository);

  Future<Result<TransactionEntity>> execute(TransactionEntity transaction) {
    if (transaction.items.isEmpty) {
      return Future.value(
        const Result.error(ValidationFailure('Keranjang belanja kosong')),
      );
    }
    if (transaction.totalAmount <= 0) {
      return Future.value(
        const Result.error(ValidationFailure('Total transaksi tidak valid')),
      );
    }
    if (transaction.paymentMethod == PaymentMethod.cash) {
      if (transaction.cashReceived < transaction.totalAmount) {
        return Future.value(
          const Result.error(
            ValidationFailure('Uang tunai yang diterima kurang'),
          ),
        );
      }
    }
    return _repository.createTransaction(transaction);
  }
}

class GetTransactionsUseCase {
  final TransactionRepository _repository;
  const GetTransactionsUseCase(this._repository);

  Future<Result<List<TransactionEntity>>> execute({
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) => _repository.getTransactions(
    startDate: startDate,
    endDate: endDate,
    searchQuery: searchQuery,
  );

  Stream<List<TransactionEntity>> watch({
    DateTime? startDate,
    DateTime? endDate,
  }) => _repository.watchTransactions(startDate: startDate, endDate: endDate);
}

class CalculateChangeUseCase {
  const CalculateChangeUseCase();

  double execute({required double totalAmount, required double cashReceived}) {
    if (cashReceived < totalAmount) return 0.0;
    return cashReceived - totalAmount;
  }
}
