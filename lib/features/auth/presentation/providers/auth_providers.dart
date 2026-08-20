import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/store.dart';

final storeProfileStreamProvider = StreamProvider<Store?>((ref) {
  final useCase = ref.watch(getStoreProfileUseCaseProvider);
  return useCase.watch();
});

class StoreProfileNotifier extends StateNotifier<AsyncValue<Store?>> {
  final Ref _ref;

  StoreProfileNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadStoreProfile();
  }

  Future<void> loadStoreProfile() async {
    state = const AsyncValue.loading();
    final useCase = _ref.read(getStoreProfileUseCaseProvider);
    final result = await useCase.execute();
    result.when(
      onSuccess: (store) => state = AsyncValue.data(store),
      onError: (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
    );
  }

  Future<bool> saveStore(Store store) async {
    final useCase = _ref.read(saveStoreProfileUseCaseProvider);
    final result = await useCase.execute(store);
    return result.when(
      onSuccess: (saved) {
        state = AsyncValue.data(saved);
        return true;
      },
      onError: (_) => false,
    );
  }
}

final storeProfileNotifierProvider =
    StateNotifierProvider<StoreProfileNotifier, AsyncValue<Store?>>((ref) {
      return StoreProfileNotifier(ref);
    });

final isStoreConfiguredProvider = Provider<bool>((ref) {
  final storeAsync = ref.watch(storeProfileStreamProvider);
  return storeAsync.maybeWhen(
    data: (store) => store != null && store.name.isNotEmpty,
    orElse: () => false,
  );
});
