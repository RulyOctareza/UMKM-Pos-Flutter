import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_item_entity.dart';

final transactionStartDateProvider = StateProvider<DateTime?>((ref) => null);
final transactionEndDateProvider = StateProvider<DateTime?>((ref) => null);
final transactionSearchProvider = StateProvider<String>((ref) => '');

final transactionsStreamProvider = StreamProvider<List<TransactionEntity>>((
  ref,
) {
  final start = ref.watch(transactionStartDateProvider);
  final end = ref.watch(transactionEndDateProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchTransactions(startDate: start, endDate: end);
});

class CheckoutController extends StateNotifier<AsyncValue<TransactionEntity?>> {
  final Ref _ref;
  CheckoutController(this._ref) : super(const AsyncValue.data(null));

  Future<Result<TransactionEntity>> processCheckout({
    required PaymentMethod paymentMethod,
    required double cashReceived,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    final cart = _ref.read(cartNotifierProvider);
    final useCase = _ref.read(createTransactionUseCaseProvider);

    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final invoiceNumber = 'INV/$dateStr/$timeStr';
    final transactionId = const Uuid().v4();

    final items = cart.items.map((item) {
      return TransactionItemEntity(
        id: const Uuid().v4(),
        transactionId: transactionId,
        productId: item.product.id,
        productName: item.product.name,
        priceAtSale: item.product.price,
        quantity: item.quantity,
        subtotal: item.subtotal,
      );
    }).toList();

    final changeAmount = paymentMethod == PaymentMethod.cash
        ? (cashReceived - cart.totalAmount)
        : 0.0;

    final transaction = TransactionEntity(
      id: transactionId,
      invoiceNumber: invoiceNumber,
      totalAmount: cart.totalAmount,
      paymentMethod: paymentMethod,
      cashReceived: paymentMethod == PaymentMethod.cash
          ? cashReceived
          : cart.totalAmount,
      changeAmount: changeAmount > 0 ? changeAmount : 0.0,
      status: 'completed',
      notes: notes,
      items: items,
      createdAt: now,
      updatedAt: now,
    );

    final result = await useCase.execute(transaction);
    result.when(
      onSuccess: (savedTx) {
        state = AsyncValue.data(savedTx);
        _ref.read(cartNotifierProvider.notifier).clear();
      },
      onError: (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
    );

    return result;
  }
}

final checkoutControllerProvider =
    StateNotifierProvider<CheckoutController, AsyncValue<TransactionEntity?>>((
      ref,
    ) {
      return CheckoutController(ref);
    });
