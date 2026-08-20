import 'transaction_item_entity.dart';

enum PaymentMethod {
  cash('cash', 'Tunai'),
  qris('qris', 'QRIS'),
  transfer('transfer', 'Transfer Bank');

  final String value;
  final String label;
  const PaymentMethod(this.value, this.label);

  static PaymentMethod fromString(String val) {
    return PaymentMethod.values.firstWhere(
      (e) => e.value == val,
      orElse: () => PaymentMethod.cash,
    );
  }
}

/// Pure Dart Transaction Aggregate Entity (Domain Layer)
class TransactionEntity {
  final String id;
  final String invoiceNumber;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final double cashReceived;
  final double changeAmount;
  final String status;
  final String? notes;
  final List<TransactionItemEntity> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  const TransactionEntity({
    required this.id,
    required this.invoiceNumber,
    required this.totalAmount,
    required this.paymentMethod,
    this.cashReceived = 0.0,
    this.changeAmount = 0.0,
    this.status = 'completed',
    this.notes,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  TransactionEntity copyWith({
    String? id,
    String? invoiceNumber,
    double? totalAmount,
    PaymentMethod? paymentMethod,
    double? cashReceived,
    double? changeAmount,
    String? status,
    String? notes,
    List<TransactionItemEntity>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cashReceived: cashReceived ?? this.cashReceived,
      changeAmount: changeAmount ?? this.changeAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is TransactionEntity && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
