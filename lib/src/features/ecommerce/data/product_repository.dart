import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/product.dart';

part 'product_repository.g.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('products');

  /// Stream of all active products
  Stream<List<Product>> getActiveProducts() {
    return _collection
        .where('isActive', isEqualTo: true)
        .orderBy('isFeatured', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Product.fromJson({...doc.data(), 'id': doc.id});
          }).toList();
        });
  }

  /// Stream of featured products for dashboard
  Stream<List<Product>> getFeaturedProducts() {
    return _collection
        .where('isActive', isEqualTo: true)
        .where('isFeatured', isEqualTo: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Product.fromJson({...doc.data(), 'id': doc.id});
          }).toList();
        });
  }

  /// Stream of all products (for admin)
  Stream<List<Product>> getAllProducts() {
    return _collection.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return Product.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  /// Get a single product by ID
  Future<Product?> getProductById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists) return null;
      return Product.fromJson({...doc.data()!, 'id': id});
    } catch (e) {
      return null;
    }
  }

  /// Create a new product
  Future<String> createProduct(Product product) async {
    final data = product.toJson();
    data.remove('id');
    data['createdAt'] = FieldValue.serverTimestamp();
    final docRef = await _collection.add(data);
    return docRef.id;
  }

  /// Update an existing product
  Future<void> updateProduct(Product product) async {
    final data = product.toJson();
    data.remove('id');
    data.remove('createdAt'); // Don't overwrite creation date
    await _collection.doc(product.id).update(data);
  }

  /// Delete a product
  Future<void> deleteProduct(String id) async {
    await _collection.doc(id).delete();
  }

  /// Toggle product active status
  Future<void> toggleProductActive(String id, bool isActive) async {
    await _collection.doc(id).update({'isActive': isActive});
  }

  /// Toggle product featured status
  Future<void> toggleProductFeatured(String id, bool isFeatured) async {
    await _collection.doc(id).update({'isFeatured': isFeatured});
  }
}

@Riverpod(keepAlive: true)
ProductRepository productRepository(Ref ref) {
  return ProductRepository(ref.watch(firebaseFirestoreProvider));
}

@riverpod
Stream<List<Product>> activeProducts(Ref ref) {
  return ref.watch(productRepositoryProvider).getActiveProducts();
}

@riverpod
Stream<List<Product>> featuredProducts(Ref ref) {
  return ref.watch(productRepositoryProvider).getFeaturedProducts();
}

@riverpod
Stream<List<Product>> allProducts(Ref ref) {
  return ref.watch(productRepositoryProvider).getAllProducts();
}

@riverpod
Future<Product?> productById(Ref ref, String productId) {
  return ref.watch(productRepositoryProvider).getProductById(productId);
}
