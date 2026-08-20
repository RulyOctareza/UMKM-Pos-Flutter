import '../../../../core/errors/result.dart';
import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<Result<TransactionEntity>> createTransaction(
    TransactionEntity transaction,
  );
  Future<Result<List<TransactionEntity>>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  });
  Stream<List<TransactionEntity>> watchTransactions({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Result<TransactionEntity?>> getTransactionById(String id);
  Future<Result<void>> cancelTransaction(String id);
}
