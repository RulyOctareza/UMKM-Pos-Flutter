import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:umkm_pos/core/errors/failure.dart';
import 'package:umkm_pos/core/errors/result.dart';
import 'package:umkm_pos/features/transactions/domain/entities/transaction_entity.dart';
import 'package:umkm_pos/features/transactions/domain/entities/transaction_item_entity.dart';
import 'package:umkm_pos/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:umkm_pos/features/transactions/domain/usecases/transaction_usecases.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockTransactionRepository mockRepo;
  late CreateTransactionUseCase createTransactionUseCase;
  late CalculateChangeUseCase calculateChangeUseCase;

  setUp(() {
    mockRepo = MockTransactionRepository();
    createTransactionUseCase = CreateTransactionUseCase(mockRepo);
    calculateChangeUseCase = const CalculateChangeUseCase();
  });

  group('Transaction UseCases Tests', () {
    final now = DateTime(2026, 8, 20);
    final validTx = TransactionEntity(
      id: 'tx-1',
      invoiceNumber: 'INV/20260820/0001',
      totalAmount: 50000,
      paymentMethod: PaymentMethod.cash,
      cashReceived: 100000,
      changeAmount: 50000,
      items: const [
        TransactionItemEntity(
          id: 'item-1',
          transactionId: 'tx-1',
          productId: 'prod-1',
          productName: 'Kopi',
          priceAtSale: 25000,
          quantity: 2,
          subtotal: 50000,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );

    test(
      'CreateTransactionUseCase succeeds with valid transaction and cash',
      () async {
        when(
          () => mockRepo.createTransaction(validTx),
        ).thenAnswer((_) async => Result.success(validTx));

        final result = await createTransactionUseCase.execute(validTx);
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.invoiceNumber, 'INV/20260820/0001');
      },
    );

    test('CreateTransactionUseCase fails when items is empty', () async {
      final invalidTx = validTx.copyWith(items: []);
      final result = await createTransactionUseCase.execute(invalidTx);

      expect(result.isError, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
    });

    test(
      'CreateTransactionUseCase fails when cash received is less than total',
      () async {
        final invalidTx = validTx.copyWith(cashReceived: 30000);
        final result = await createTransactionUseCase.execute(invalidTx);

        expect(result.isError, isTrue);
        expect(result.failureOrNull, isA<ValidationFailure>());
      },
    );

    test('CalculateChangeUseCase correctly computes change', () {
      expect(
        calculateChangeUseCase.execute(
          totalAmount: 50000,
          cashReceived: 100000,
        ),
        50000.0,
      );
      expect(
        calculateChangeUseCase.execute(totalAmount: 50000, cashReceived: 50000),
        0.0,
      );
      expect(
        calculateChangeUseCase.execute(totalAmount: 50000, cashReceived: 20000),
        0.0,
      );
    });
  });
}
