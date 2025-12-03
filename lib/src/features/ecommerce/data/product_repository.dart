import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/product.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final activeProductsProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).watchActiveProducts();
});

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Get all active products
  Stream<List<Product>> watchActiveProducts() {
    return _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Product.fromJson(data);
          }).toList();
        });
  }

  /// Get products by category
  Stream<List<Product>> watchProductsByCategory(ProductCategory category) {
    return _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .where('category', isEqualTo: category.name)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Product.fromJson(data);
          }).toList();
        });
  }

  /// Get product by ID
  Future<Product?> getProduct(String productId) async {
    final doc = await _firestore.collection('products').doc(productId).get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    data['id'] = doc.id;
    return Product.fromJson(data);
  }

  /// Create product (Admin only)
  Future<void> createProduct(Product product) async {
    final data = product.toJson();
    data.remove('id');

    final docRef = await _firestore.collection('products').add(data);

    // Sync with Stripe
    try {
      await _functions.httpsCallable('syncProductWithStripe').call({
        'productId': docRef.id,
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
      });
    } catch (e) {
      print('Error syncing product with Stripe: $e');
      // Don't throw - product is created in Firestore
    }
  }

  /// Update product (Admin only)
  Future<void> updateProduct(Product product) async {
    final data = product.toJson();
    data.remove('id');

    await _firestore.collection('products').doc(product.id).update(data);

    // Sync with Stripe
    try {
      await _functions.httpsCallable('syncProductWithStripe').call({
        'productId': product.id,
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
      });
    } catch (e) {
      print('Error syncing product with Stripe: $e');
    }
  }

  /// Delete product (Admin only)
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  /// Update stock
  Future<void> updateStock(String productId, int newStock) async {
    await _firestore.collection('products').doc(productId).update({
      'stock': newStock,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
