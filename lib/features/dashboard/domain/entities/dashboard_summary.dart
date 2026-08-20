import '../../../products/domain/entities/product.dart';

class TopProductSummary {
  final Product product;
  final int totalQuantitySold;
  final double totalRevenue;

  const TopProductSummary({
    required this.product,
    required this.totalQuantitySold,
    required this.totalRevenue,
  });
}

/// Pure Dart Dashboard Summary Entity (Domain Layer)
class DashboardSummary {
  final double totalSalesToday;
  final int totalTransactionsToday;
  final double averageOrderValue;
  final double totalSalesThisMonth;
  final int totalTransactionsThisMonth;
  final List<TopProductSummary> topProducts;
  final List<Product> lowStockProducts;

  const DashboardSummary({
    this.totalSalesToday = 0.0,
    this.totalTransactionsToday = 0,
    this.averageOrderValue = 0.0,
    this.totalSalesThisMonth = 0.0,
    this.totalTransactionsThisMonth = 0,
    this.topProducts = const [],
    this.lowStockProducts = const [],
  });
}
