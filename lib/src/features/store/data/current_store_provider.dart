import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/store.dart';
import 'store_repository.dart';

part 'current_store_provider.g.dart';

@riverpod
class CurrentStore extends _$CurrentStore {
  @override
  FutureOr<Store?> build() async {
    final userProfile = await ref.watch(currentUserProfileProvider.future);
    
    if (userProfile != null) {
      final storeId = userProfile.currentStoreId ?? userProfile.ownedStoreId;
      if (storeId != null) {
        return ref.read(storeRepositoryProvider).getStore(storeId);
      }
    }
    return null;
  }

  Future<void> setStore(String storeId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final store = await ref.read(storeRepositoryProvider).getStore(storeId);
      return store;
    });
  }

  void clearStore() {
    state = const AsyncValue.data(null);
  }
}
