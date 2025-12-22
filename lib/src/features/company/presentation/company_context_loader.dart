import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/company_repository.dart';
import 'company_context.dart';

class CompanyContextLoader extends ConsumerStatefulWidget {
  final String companyId;
  final Widget child;

  const CompanyContextLoader({
    super.key,
    required this.companyId,
    required this.child,
  });

  @override
  ConsumerState<CompanyContextLoader> createState() =>
      _CompanyContextLoaderState();
}

class _CompanyContextLoaderState extends ConsumerState<CompanyContextLoader> {
  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  @override
  void didUpdateWidget(covariant CompanyContextLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.companyId != widget.companyId) {
      _loadCompany();
    }
  }

  Future<void> _loadCompany() async {
    // Delay slightly to avoid build phase conflicts if immediate
    await Future.microtask(() async {
      final current = ref.read(currentCompanyProvider);
      if (current?.id != widget.companyId) {
        // Fetch company
        final company = await ref
            .read(companyRepositoryProvider)
            .getCompany(widget.companyId);

        if (company != null && mounted) {
          ref.read(currentCompanyProvider.notifier).setCompany(company);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentCompany = ref.watch(currentCompanyProvider);

    // If company not loaded yet or mismatch, show loading
    if (currentCompany == null || currentCompany.id != widget.companyId) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return widget.child;
  }
}
