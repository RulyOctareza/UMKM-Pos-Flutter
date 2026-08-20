import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../../features/auth/data/repositories/store_repository_impl.dart';
import '../../features/auth/domain/repositories/store_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/products/data/repositories/category_repository_impl.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/category_repository.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/product_usecases.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/domain/usecases/transaction_usecases.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/dashboard_usecases.dart';

/// Database Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Store & Auth Providers
final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return StoreRepositoryImpl(db);
});

final getStoreProfileUseCaseProvider = Provider<GetStoreProfileUseCase>((ref) {
  final repo = ref.watch(storeRepositoryProvider);
  return GetStoreProfileUseCase(repo);
});

final saveStoreProfileUseCaseProvider = Provider<SaveStoreProfileUseCase>((
  ref,
) {
  final repo = ref.watch(storeRepositoryProvider);
  return SaveStoreProfileUseCase(repo);
});

final verifyPinUseCaseProvider = Provider<VerifyPinUseCase>((ref) {
  final repo = ref.watch(storeRepositoryProvider);
  return VerifyPinUseCase(repo);
});

/// Product & Category Providers
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoryRepositoryImpl(db);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ProductRepositoryImpl(db);
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return GetCategoriesUseCase(repo);
});

final createCategoryUseCaseProvider = Provider<CreateCategoryUseCase>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return CreateCategoryUseCase(repo);
});

final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return GetProductsUseCase(repo);
});

final createProductUseCaseProvider = Provider<CreateProductUseCase>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return CreateProductUseCase(repo);
});

final updateProductUseCaseProvider = Provider<UpdateProductUseCase>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return UpdateProductUseCase(repo);
});

final deleteProductUseCaseProvider = Provider<DeleteProductUseCase>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return DeleteProductUseCase(repo);
});

/// Transaction & Cashier Providers
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TransactionRepositoryImpl(db);
});

final createTransactionUseCaseProvider = Provider<CreateTransactionUseCase>((
  ref,
) {
  final repo = ref.watch(transactionRepositoryProvider);
  return CreateTransactionUseCase(repo);
});

final getTransactionsUseCaseProvider = Provider<GetTransactionsUseCase>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return GetTransactionsUseCase(repo);
});

final calculateChangeUseCaseProvider = Provider<CalculateChangeUseCase>((ref) {
  return const CalculateChangeUseCase();
});

/// Dashboard Providers
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DashboardRepositoryImpl(db);
});

final getDashboardSummaryUseCaseProvider = Provider<GetDashboardSummaryUseCase>(
  (ref) {
    final repo = ref.watch(dashboardRepositoryProvider);
    return GetDashboardSummaryUseCase(repo);
  },
);
