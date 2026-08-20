/// Pure Dart Product Entity (Domain Layer)
class Product {
  final String id;
  final String name;
  final double price;
  final double costPrice;
  final String? categoryId;
  final String? categoryName; // Helper denormalized field untuk display cepat
  final int stock;
  final int minStockAlert;
  final String? imagePath;
  final String unit;
  final String? barcode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.costPrice = 0.0,
    this.categoryId,
    this.categoryName,
    this.stock = 0,
    this.minStockAlert = 5,
    this.imagePath,
    this.unit = 'pcs',
    this.barcode,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  bool get isLowStock => stock <= minStockAlert;
  bool get isOutOfStock => stock <= 0;

  Product copyWith({
    String? id,
    String? name,
    double? price,
    double? costPrice,
    String? categoryId,
    String? categoryName,
    int? stock,
    int? minStockAlert,
    String? imagePath,
    String? unit,
    String? barcode,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      stock: stock ?? this.stock,
      minStockAlert: minStockAlert ?? this.minStockAlert,
      imagePath: imagePath ?? this.imagePath,
      unit: unit ?? this.unit,
      barcode: barcode ?? this.barcode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Product && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
