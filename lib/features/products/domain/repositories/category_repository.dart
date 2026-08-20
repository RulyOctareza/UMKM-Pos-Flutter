import '../../../../core/errors/result.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  Future<Result<List<Category>>> getCategories();
  Stream<List<Category>> watchCategories();
  Future<Result<Category>> createCategory(Category category);
  Future<Result<Category>> updateCategory(Category category);
  Future<Result<void>> deleteCategory(String id);
}
