/// Pure Dart TransactionItem Entity (Domain Layer)
class TransactionItemEntity {
  final String id;
  final String transactionId;
  final String productId;
  final String productName;
  final double priceAtSale;
  final int quantity;
  final double subtotal;

  const TransactionItemEntity({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.priceAtSale,
    required this.quantity,
    required this.subtotal,
  });

  TransactionItemEntity copyWith({
    String? id,
    String? transactionId,
    String? productId,
    String? productName,
    double? priceAtSale,
    int? quantity,
    double? subtotal,
  }) {
    return TransactionItemEntity(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      priceAtSale: priceAtSale ?? this.priceAtSale,
      quantity: quantity ?? this.quantity,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionItemEntity && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
