import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:umkm_pos/core/errors/failure.dart';
import 'package:umkm_pos/core/errors/result.dart';
import 'package:umkm_pos/features/products/domain/entities/product.dart';
import 'package:umkm_pos/features/products/domain/repositories/category_repository.dart';
import 'package:umkm_pos/features/products/domain/repositories/product_repository.dart';
import 'package:umkm_pos/features/products/domain/usecases/product_usecases.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class FakeProduct extends Fake implements Product {}

void main() {
  late MockProductRepository mockProductRepo;
  late CreateProductUseCase createProductUseCase;
  late GetProductsUseCase getProductsUseCase;

  setUpAll(() {
    registerFallbackValue(FakeProduct());
  });

  setUp(() {
    mockProductRepo = MockProductRepository();
    createProductUseCase = CreateProductUseCase(mockProductRepo);
    getProductsUseCase = GetProductsUseCase(mockProductRepo);
  });

  group('Product UseCases Unit Tests', () {
    final now = DateTime(2026, 8, 20);
    final validProduct = Product(
      id: 'p-1',
      name: 'Roti Bakar Cokelat',
      price: 15000,
      stock: 10,
      createdAt: now,
      updatedAt: now,
    );

    test('CreateProductUseCase successfully creates valid product', () async {
      when(
        () => mockProductRepo.createProduct(any()),
      ).thenAnswer((_) async => Result.success(validProduct));

      final result = await createProductUseCase.execute(validProduct);
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.name, 'Roti Bakar Cokelat');
      verify(() => mockProductRepo.createProduct(validProduct)).called(1);
    });

    test('CreateProductUseCase fails when product name is empty', () async {
      final invalidProduct = validProduct.copyWith(name: '');
      final result = await createProductUseCase.execute(invalidProduct);

      expect(result.isError, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
      verifyZeroInteractions(mockProductRepo);
    });

    test('CreateProductUseCase fails when price is negative', () async {
      final invalidProduct = validProduct.copyWith(price: -5000);
      final result = await createProductUseCase.execute(invalidProduct);

      expect(result.isError, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
      verifyZeroInteractions(mockProductRepo);
    });

    test('GetProductsUseCase returns product list from repository', () async {
      when(
        () => mockProductRepo.getProducts(
          categoryId: any(named: 'categoryId'),
          searchQuery: any(named: 'searchQuery'),
        ),
      ).thenAnswer((_) async => Result.success([validProduct]));

      final result = await getProductsUseCase.execute();
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.length, 1);
    });
  });
}
