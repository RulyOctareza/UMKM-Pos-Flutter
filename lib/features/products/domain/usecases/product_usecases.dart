import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/category.dart';
import '../entities/product.dart';
import '../repositories/category_repository.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository _repository;
  const GetProductsUseCase(this._repository);

  Future<Result<List<Product>>> execute({
    String? categoryId,
    String? searchQuery,
  }) =>
      _repository.getProducts(categoryId: categoryId, searchQuery: searchQuery);

  Stream<List<Product>> watch({String? categoryId, String? searchQuery}) =>
      _repository.watchProducts(
        categoryId: categoryId,
        searchQuery: searchQuery,
      );
}

class CreateProductUseCase {
  final ProductRepository _repository;
  const CreateProductUseCase(this._repository);

  Future<Result<Product>> execute(Product product) {
    if (product.name.trim().isEmpty) {
      return Future.value(
        const Result.error(ValidationFailure('Nama produk tidak boleh kosong')),
      );
    }
    if (product.price < 0) {
      return Future.value(
        const Result.error(
          ValidationFailure('Harga produk tidak boleh negatif'),
        ),
      );
    }
    if (product.stock < 0) {
      return Future.value(
        const Result.error(
          ValidationFailure('Stok produk tidak boleh negatif'),
        ),
      );
    }
    return _repository.createProduct(product);
  }
}

class UpdateProductUseCase {
  final ProductRepository _repository;
  const UpdateProductUseCase(this._repository);

  Future<Result<Product>> execute(Product product) {
    if (product.name.trim().isEmpty) {
      return Future.value(
        const Result.error(ValidationFailure('Nama produk tidak boleh kosong')),
      );
    }
    if (product.price < 0) {
      return Future.value(
        const Result.error(
          ValidationFailure('Harga produk tidak boleh negatif'),
        ),
      );
    }
    if (product.stock < 0) {
      return Future.value(
        const Result.error(
          ValidationFailure('Stok produk tidak boleh negatif'),
        ),
      );
    }
    return _repository.updateProduct(product);
  }
}

class DeleteProductUseCase {
  final ProductRepository _repository;
  const DeleteProductUseCase(this._repository);

  Future<Result<void>> execute(String id) => _repository.deleteProduct(id);
}

class GetCategoriesUseCase {
  final CategoryRepository _repository;
  const GetCategoriesUseCase(this._repository);

  Future<Result<List<Category>>> execute() => _repository.getCategories();
  Stream<List<Category>> watch() => _repository.watchCategories();
}

class CreateCategoryUseCase {
  final CategoryRepository _repository;
  const CreateCategoryUseCase(this._repository);

  Future<Result<Category>> execute(Category category) {
    if (category.name.trim().isEmpty) {
      return Future.value(
        const Result.error(
          ValidationFailure('Nama kategori tidak boleh kosong'),
        ),
      );
    }
    return _repository.createCategory(category);
  }
}
