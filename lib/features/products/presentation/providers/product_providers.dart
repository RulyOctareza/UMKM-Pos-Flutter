import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';

final selectedCategoryIdProvider = StateProvider<String?>((ref) => null);
final productSearchQueryProvider = StateProvider<String>((ref) => '');

/// Stream provider kategori produk
final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final useCase = ref.watch(getCategoriesUseCaseProvider);
  return useCase.watch();
});

/// Stream provider produk terfilter (reaktif terhadap kategori & pencarian)
final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final categoryId = ref.watch(selectedCategoryIdProvider);
  final query = ref.watch(productSearchQueryProvider);
  final repo = ref.watch(productRepositoryProvider);

  return repo.watchProducts(categoryId: categoryId, searchQuery: query);
});

/// Stream provider produk stok menipis
final lowStockProductsStreamProvider = StreamProvider<List<Product>>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.watchLowStockProducts();
});

/// Controller untuk form & aksi produk
class ProductController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  ProductController(this._ref) : super(const AsyncValue.data(null));

  Future<bool> createProduct(Product product) async {
    state = const AsyncValue.loading();
    final useCase = _ref.read(createProductUseCaseProvider);
    final result = await useCase.execute(product);
    return result.when(
      onSuccess: (_) {
        state = const AsyncValue.data(null);
        return true;
      },
      onError: (f) {
        state = AsyncValue.error(f.message, StackTrace.current);
        return false;
      },
    );
  }

  Future<bool> updateProduct(Product product) async {
    state = const AsyncValue.loading();
    final useCase = _ref.read(updateProductUseCaseProvider);
    final result = await useCase.execute(product);
    return result.when(
      onSuccess: (_) {
        state = const AsyncValue.data(null);
        return true;
      },
      onError: (f) {
        state = AsyncValue.error(f.message, StackTrace.current);
        return false;
      },
    );
  }

  Future<bool> deleteProduct(String id) async {
    state = const AsyncValue.loading();
    final useCase = _ref.read(deleteProductUseCaseProvider);
    final result = await useCase.execute(id);
    return result.when(
      onSuccess: (_) {
        state = const AsyncValue.data(null);
        return true;
      },
      onError: (f) {
        state = AsyncValue.error(f.message, StackTrace.current);
        return false;
      },
    );
  }

  Future<bool> createCategory(Category category) async {
    state = const AsyncValue.loading();
    final useCase = _ref.read(createCategoryUseCaseProvider);
    final result = await useCase.execute(category);
    return result.when(
      onSuccess: (_) {
        state = const AsyncValue.data(null);
        return true;
      },
      onError: (f) {
        state = AsyncValue.error(f.message, StackTrace.current);
        return false;
      },
    );
  }
}

final productControllerProvider =
    StateNotifierProvider<ProductController, AsyncValue<void>>((ref) {
      return ProductController(ref);
    });
