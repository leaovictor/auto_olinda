import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../company/domain/company_model.dart';

part 'company_context.g.dart';

@Riverpod(keepAlive: true)
class CurrentCompany extends _$CurrentCompany {
  @override
  Company? build() {
    return null;
  }

  void setCompany(Company company) {
    state = company;
  }
}
