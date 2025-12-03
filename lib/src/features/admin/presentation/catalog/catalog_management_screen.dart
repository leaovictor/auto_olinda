import 'package:aquaclean_mobile/src/features/admin/presentation/plans/plans_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'coupons/coupon_list_view.dart';

/// Admin screen for managing catalog (products, services, subscriptions, coupons)
class CatalogManagementScreen extends ConsumerStatefulWidget {
  const CatalogManagementScreen({super.key});

  @override
  ConsumerState<CatalogManagementScreen> createState() =>
      _CatalogManagementScreenState();
}

class _CatalogManagementScreenState
    extends ConsumerState<CatalogManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Cupons'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.workspace_premium), text: 'Assinaturas'),
            Tab(icon: Icon(Icons.local_offer), text: 'Cupons'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [PlansScreen(showAppBar: false), CouponListView()],
      ),
    );
  }
}
