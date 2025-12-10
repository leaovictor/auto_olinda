import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'coupons/coupon_list_view.dart';

/// Admin screen for managing catalog (products, services, subscriptions, coupons)
class CatalogManagementScreen extends ConsumerWidget {
  const CatalogManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Cupons')),
      body: const CouponListView(),
    );
  }
}
