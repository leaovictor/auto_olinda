import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/company_model.dart';

part 'company_repository.g.dart';

@Riverpod(keepAlive: true)
CompanyRepository companyRepository(CompanyRepositoryRef ref) {
  return CompanyRepository(FirebaseFirestore.instance);
}

class CompanyRepository {
  final FirebaseFirestore _firestore;

  CompanyRepository(this._firestore);

  Stream<List<Company>> watchCompanies() {
    return _firestore
        .collection('companies')
        .where('isActive', isEqualTo: true)
        // .orderBy('rating', descending: true) // Needs index
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Company.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  Future<Company?> getCompany(String id) async {
    final doc = await _firestore.collection('companies').doc(id).get();
    if (!doc.exists) return null;
    return Company.fromJson({...doc.data()!, 'id': doc.id});
  }

  Future<void> createCompany(Company company) async {
    // ID might be auto-generated or provided (e.g. from name slug or uuid)
    // Use set with merge true to be safe
    await _firestore
        .collection('companies')
        .doc(company.id)
        .set(company.toJson());
  }

  Future<void> updateCompany(Company company) async {
    await _firestore
        .collection('companies')
        .doc(company.id)
        .update(company.toJson());
  }
}

@riverpod
Stream<List<Company>> companies(CompaniesRef ref) {
  return ref.watch(companyRepositoryProvider).watchCompanies();
}
