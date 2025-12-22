// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productRepositoryHash() => r'93a29e114c0f2197ebcbb1c29ac3b96cb0c786de';

/// See also [productRepository].
@ProviderFor(productRepository)
final productRepositoryProvider = Provider<ProductRepository>.internal(
  productRepository,
  name: r'productRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductRepositoryRef = ProviderRef<ProductRepository>;
String _$activeProductsHash() => r'814ddc01125e356acb348d96a873e07f370b2514';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [activeProducts].
@ProviderFor(activeProducts)
const activeProductsProvider = ActiveProductsFamily();

/// See also [activeProducts].
class ActiveProductsFamily extends Family<AsyncValue<List<Product>>> {
  /// See also [activeProducts].
  const ActiveProductsFamily();

  /// See also [activeProducts].
  ActiveProductsProvider call(String? companyId) {
    return ActiveProductsProvider(companyId);
  }

  @override
  ActiveProductsProvider getProviderOverride(
    covariant ActiveProductsProvider provider,
  ) {
    return call(provider.companyId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'activeProductsProvider';
}

/// See also [activeProducts].
class ActiveProductsProvider extends AutoDisposeStreamProvider<List<Product>> {
  /// See also [activeProducts].
  ActiveProductsProvider(String? companyId)
    : this._internal(
        (ref) => activeProducts(ref as ActiveProductsRef, companyId),
        from: activeProductsProvider,
        name: r'activeProductsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$activeProductsHash,
        dependencies: ActiveProductsFamily._dependencies,
        allTransitiveDependencies:
            ActiveProductsFamily._allTransitiveDependencies,
        companyId: companyId,
      );

  ActiveProductsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.companyId,
  }) : super.internal();

  final String? companyId;

  @override
  Override overrideWith(
    Stream<List<Product>> Function(ActiveProductsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ActiveProductsProvider._internal(
        (ref) => create(ref as ActiveProductsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        companyId: companyId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Product>> createElement() {
    return _ActiveProductsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveProductsProvider && other.companyId == companyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, companyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ActiveProductsRef on AutoDisposeStreamProviderRef<List<Product>> {
  /// The parameter `companyId` of this provider.
  String? get companyId;
}

class _ActiveProductsProviderElement
    extends AutoDisposeStreamProviderElement<List<Product>>
    with ActiveProductsRef {
  _ActiveProductsProviderElement(super.provider);

  @override
  String? get companyId => (origin as ActiveProductsProvider).companyId;
}

String _$featuredProductsHash() => r'a5f184a6106acf0e5cc383916bf8fb9a40bab023';

/// See also [featuredProducts].
@ProviderFor(featuredProducts)
const featuredProductsProvider = FeaturedProductsFamily();

/// See also [featuredProducts].
class FeaturedProductsFamily extends Family<AsyncValue<List<Product>>> {
  /// See also [featuredProducts].
  const FeaturedProductsFamily();

  /// See also [featuredProducts].
  FeaturedProductsProvider call(String? companyId) {
    return FeaturedProductsProvider(companyId);
  }

  @override
  FeaturedProductsProvider getProviderOverride(
    covariant FeaturedProductsProvider provider,
  ) {
    return call(provider.companyId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'featuredProductsProvider';
}

/// See also [featuredProducts].
class FeaturedProductsProvider
    extends AutoDisposeStreamProvider<List<Product>> {
  /// See also [featuredProducts].
  FeaturedProductsProvider(String? companyId)
    : this._internal(
        (ref) => featuredProducts(ref as FeaturedProductsRef, companyId),
        from: featuredProductsProvider,
        name: r'featuredProductsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$featuredProductsHash,
        dependencies: FeaturedProductsFamily._dependencies,
        allTransitiveDependencies:
            FeaturedProductsFamily._allTransitiveDependencies,
        companyId: companyId,
      );

  FeaturedProductsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.companyId,
  }) : super.internal();

  final String? companyId;

  @override
  Override overrideWith(
    Stream<List<Product>> Function(FeaturedProductsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FeaturedProductsProvider._internal(
        (ref) => create(ref as FeaturedProductsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        companyId: companyId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Product>> createElement() {
    return _FeaturedProductsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeaturedProductsProvider && other.companyId == companyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, companyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FeaturedProductsRef on AutoDisposeStreamProviderRef<List<Product>> {
  /// The parameter `companyId` of this provider.
  String? get companyId;
}

class _FeaturedProductsProviderElement
    extends AutoDisposeStreamProviderElement<List<Product>>
    with FeaturedProductsRef {
  _FeaturedProductsProviderElement(super.provider);

  @override
  String? get companyId => (origin as FeaturedProductsProvider).companyId;
}

String _$allProductsHash() => r'5b5e73ae0445565c00b538a71c6476cfdbc6a2e4';

/// See also [allProducts].
@ProviderFor(allProducts)
const allProductsProvider = AllProductsFamily();

/// See also [allProducts].
class AllProductsFamily extends Family<AsyncValue<List<Product>>> {
  /// See also [allProducts].
  const AllProductsFamily();

  /// See also [allProducts].
  AllProductsProvider call(String? companyId) {
    return AllProductsProvider(companyId);
  }

  @override
  AllProductsProvider getProviderOverride(
    covariant AllProductsProvider provider,
  ) {
    return call(provider.companyId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'allProductsProvider';
}

/// See also [allProducts].
class AllProductsProvider extends AutoDisposeStreamProvider<List<Product>> {
  /// See also [allProducts].
  AllProductsProvider(String? companyId)
    : this._internal(
        (ref) => allProducts(ref as AllProductsRef, companyId),
        from: allProductsProvider,
        name: r'allProductsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$allProductsHash,
        dependencies: AllProductsFamily._dependencies,
        allTransitiveDependencies: AllProductsFamily._allTransitiveDependencies,
        companyId: companyId,
      );

  AllProductsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.companyId,
  }) : super.internal();

  final String? companyId;

  @override
  Override overrideWith(
    Stream<List<Product>> Function(AllProductsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AllProductsProvider._internal(
        (ref) => create(ref as AllProductsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        companyId: companyId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Product>> createElement() {
    return _AllProductsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AllProductsProvider && other.companyId == companyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, companyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AllProductsRef on AutoDisposeStreamProviderRef<List<Product>> {
  /// The parameter `companyId` of this provider.
  String? get companyId;
}

class _AllProductsProviderElement
    extends AutoDisposeStreamProviderElement<List<Product>>
    with AllProductsRef {
  _AllProductsProviderElement(super.provider);

  @override
  String? get companyId => (origin as AllProductsProvider).companyId;
}

String _$productByIdHash() => r'25407e41efc82e895143b626dbbe413bd03e205e';

/// See also [productById].
@ProviderFor(productById)
const productByIdProvider = ProductByIdFamily();

/// See also [productById].
class ProductByIdFamily extends Family<AsyncValue<Product?>> {
  /// See also [productById].
  const ProductByIdFamily();

  /// See also [productById].
  ProductByIdProvider call(String productId) {
    return ProductByIdProvider(productId);
  }

  @override
  ProductByIdProvider getProviderOverride(
    covariant ProductByIdProvider provider,
  ) {
    return call(provider.productId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'productByIdProvider';
}

/// See also [productById].
class ProductByIdProvider extends AutoDisposeFutureProvider<Product?> {
  /// See also [productById].
  ProductByIdProvider(String productId)
    : this._internal(
        (ref) => productById(ref as ProductByIdRef, productId),
        from: productByIdProvider,
        name: r'productByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$productByIdHash,
        dependencies: ProductByIdFamily._dependencies,
        allTransitiveDependencies: ProductByIdFamily._allTransitiveDependencies,
        productId: productId,
      );

  ProductByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.productId,
  }) : super.internal();

  final String productId;

  @override
  Override overrideWith(
    FutureOr<Product?> Function(ProductByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductByIdProvider._internal(
        (ref) => create(ref as ProductByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        productId: productId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Product?> createElement() {
    return _ProductByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductByIdProvider && other.productId == productId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, productId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProductByIdRef on AutoDisposeFutureProviderRef<Product?> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _ProductByIdProviderElement
    extends AutoDisposeFutureProviderElement<Product?>
    with ProductByIdRef {
  _ProductByIdProviderElement(super.provider);

  @override
  String get productId => (origin as ProductByIdProvider).productId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
