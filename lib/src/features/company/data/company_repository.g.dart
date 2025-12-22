// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$companyRepositoryHash() => r'9a206fb8c13e62e369f53814cfaaf16b5a67abd9';

/// See also [companyRepository].
@ProviderFor(companyRepository)
final companyRepositoryProvider = Provider<CompanyRepository>.internal(
  companyRepository,
  name: r'companyRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$companyRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CompanyRepositoryRef = ProviderRef<CompanyRepository>;
String _$companiesHash() => r'fec3d09ef54fa4f1ee514b19f7152e38af253f5a';

/// See also [companies].
@ProviderFor(companies)
final companiesProvider = AutoDisposeStreamProvider<List<Company>>.internal(
  companies,
  name: r'companiesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$companiesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CompaniesRef = AutoDisposeStreamProviderRef<List<Company>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
