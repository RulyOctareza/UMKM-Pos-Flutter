import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_item_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final AppDatabase _db;

  TransactionRepositoryImpl(this._db);

  TransactionEntity _toEntity(
    TransactionTableData data,
    List<TransactionItemTableData> itemsData,
  ) {
    final items = itemsData.map((item) {
      return TransactionItemEntity(
        id: item.id,
        transactionId: item.transactionId,
        productId: item.productId,
        productName: item.productName,
        priceAtSale: item.priceAtSale,
        quantity: item.quantity,
        subtotal: item.subtotal,
      );
    }).toList();

    return TransactionEntity(
      id: data.id,
      invoiceNumber: data.invoiceNumber,
      totalAmount: data.totalAmount,
      paymentMethod: PaymentMethod.fromString(data.paymentMethod),
      cashReceived: data.cashReceived,
      changeAmount: data.changeAmount,
      status: data.status,
      notes: data.notes,
      items: items,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      isSynced: data.isSynced,
    );
  }

  @override
  Future<Result<TransactionEntity>> createTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final now = DateTime.now();
      final item = transaction.copyWith(
        createdAt: now,
        updatedAt: now,
        isSynced: false,
      );

      await _db.transaction(() async {
        await _db
            .into(_db.transactions)
            .insert(
              TransactionsCompanion(
                id: Value(item.id),
                invoiceNumber: Value(item.invoiceNumber),
                totalAmount: Value(item.totalAmount),
                paymentMethod: Value(item.paymentMethod.value),
                cashReceived: Value(item.cashReceived),
                changeAmount: Value(item.changeAmount),
                status: Value(item.status),
                notes: Value(item.notes),
                createdAt: Value(item.createdAt),
                updatedAt: Value(item.updatedAt),
                isSynced: Value(item.isSynced),
              ),
            );

        for (final cartItem in item.items) {
          await _db
              .into(_db.transactionItems)
              .insert(
                TransactionItemsCompanion(
                  id: Value(cartItem.id),
                  transactionId: Value(item.id),
                  productId: Value(cartItem.productId),
                  productName: Value(cartItem.productName),
                  priceAtSale: Value(cartItem.priceAtSale),
                  quantity: Value(cartItem.quantity),
                  subtotal: Value(cartItem.subtotal),
                ),
              );

          await _db.customUpdate(
            'UPDATE products SET stock = stock - ?, updated_at = ?, is_synced = 0 WHERE id = ?',
            variables: [
              Variable.withInt(cartItem.quantity),
              Variable.withDateTime(now),
              Variable.withString(cartItem.productId),
            ],
            updates: {_db.products},
          );
        }
      });

      return Result.success(item);
    } catch (e) {
      return Result.error(
        DatabaseFailure('Gagal menyimpan transaksi kasir', cause: e),
      );
    }
  }

  @override
  Future<Result<List<TransactionEntity>>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) async {
    try {
      var query = _db.select(_db.transactions);

      if (startDate != null) {
        final start = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          0,
          0,
          0,
        );
        query = query..where((t) => t.createdAt.isBiggerOrEqualValue(start));
      }

      if (endDate != null) {
        final end = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
        );
        query = query..where((t) => t.createdAt.isSmallerOrEqualValue(end));
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final pattern = '%${searchQuery.trim()}%';
        query = query..where((t) => t.invoiceNumber.like(pattern));
      }

      query = query..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
      final txList = await query.get();

      final results = <TransactionEntity>[];
      for (final tx in txList) {
        final items = await (_db.select(
          _db.transactionItems,
        )..where((t) => t.transactionId.equals(tx.id))).get();
        results.add(_toEntity(tx, items));
      }

      return Result.success(results);
    } catch (e) {
      return Result.error(
        DatabaseFailure('Gagal memuat riwayat transaksi', cause: e),
      );
    }
  }

  @override
  Stream<List<TransactionEntity>> watchTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var query = _db.select(_db.transactions);

    if (startDate != null) {
      final start = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        0,
        0,
        0,
      );
      query = query..where((t) => t.createdAt.isBiggerOrEqualValue(start));
    }

    if (endDate != null) {
      final end = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
      );
      query = query..where((t) => t.createdAt.isSmallerOrEqualValue(end));
    }

    query = query..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

    return query.watch().asyncMap((txList) async {
      final results = <TransactionEntity>[];
      for (final tx in txList) {
        final items = await (_db.select(
          _db.transactionItems,
        )..where((t) => t.transactionId.equals(tx.id))).get();
        results.add(_toEntity(tx, items));
      }
      return results;
    });
  }

  @override
  Future<Result<TransactionEntity?>> getTransactionById(String id) async {
    try {
      final tx = await (_db.select(
        _db.transactions,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (tx == null) return const Result.success(null);

      final items = await (_db.select(
        _db.transactionItems,
      )..where((t) => t.transactionId.equals(tx.id))).get();
      return Result.success(_toEntity(tx, items));
    } catch (e) {
      return Result.error(
        DatabaseFailure('Gagal memuat detail transaksi', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> cancelTransaction(String id) async {
    try {
      final tx = await (_db.select(
        _db.transactions,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (tx == null) {
        return const Result.error(NotFoundFailure('Transaksi tidak ditemukan'));
      }

      await _db.transaction(() async {
        final items = await (_db.select(
          _db.transactionItems,
        )..where((t) => t.transactionId.equals(id))).get();
        for (final item in items) {
          await _db.customUpdate(
            'UPDATE products SET stock = stock + ?, updated_at = ?, is_synced = 0 WHERE id = ?',
            variables: [
              Variable.withInt(item.quantity),
              Variable.withDateTime(DateTime.now()),
              Variable.withString(item.productId),
            ],
            updates: {_db.products},
          );
        }

        await (_db.update(
          _db.transactions,
        )..where((t) => t.id.equals(id))).write(
          TransactionsCompanion(
            status: const Value('cancelled'),
            updatedAt: Value(DateTime.now()),
            isSynced: const Value(false),
          ),
        );
      });

      return const Result.success(null);
    } catch (e) {
      return Result.error(
        DatabaseFailure('Gagal membatalkan transaksi', cause: e),
      );
    }
  }
}
