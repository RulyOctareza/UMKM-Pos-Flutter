import '../../../../core/errors/result.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  Future<Result<List<Product>>> getProducts({
    String? categoryId,
    String? searchQuery,
  });
  Stream<List<Product>> watchProducts({
    String? categoryId,
    String? searchQuery,
  });
  Future<Result<Product?>> getProductById(String id);
  Future<Result<Product>> createProduct(Product product);
  Future<Result<Product>> updateProduct(Product product);
  Future<Result<void>> deleteProduct(String id);
  Future<Result<List<Product>>> getLowStockProducts();
  Stream<List<Product>> watchLowStockProducts();
}
