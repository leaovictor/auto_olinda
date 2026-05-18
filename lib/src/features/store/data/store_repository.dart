import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/store.dart';

part 'store_repository.g.dart';

class StoreRepository {
  final FirebaseFirestore _firestore;

  StoreRepository(this._firestore);

  Future<Store?> getStore(String id) async {
    final doc = await _firestore.collection('stores').doc(id).get();
    if (!doc.exists) return null;
    return Store.fromJson({...doc.data()!, 'id': doc.id});
  }

  Future<Store?> getStoreBySlug(String slug) async {
    final query = await _firestore
        .collection('stores')
        .where('slug', isEqualTo: slug)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    return Store.fromJson({...doc.data(), 'id': doc.id});
  }

  Future<String> createStore(Store store) async {
    final data = store.toJson();
    data.remove('id');
    final docRef = await _firestore.collection('stores').add(data);
    return docRef.id;
  }

  Future<void> updateStore(Store store) async {
    final data = store.toJson();
    data.remove('id');
    await _firestore.collection('stores').doc(store.id).update(data);
  }

  Stream<List<Store>> watchAllStores() {
    return _firestore.collection('stores').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Store.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }
}

@Riverpod(keepAlive: true)
StoreRepository storeRepository(StoreRepositoryRef ref) {
  return StoreRepository(FirebaseFirestore.instance);
}
