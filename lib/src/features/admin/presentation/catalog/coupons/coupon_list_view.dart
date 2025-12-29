import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../common_widgets/atoms/app_loader.dart';
import '../../../../ecommerce/domain/coupon.dart';
import '../../../../ecommerce/data/coupon_repository.dart';
import '../../theme/admin_theme.dart';
import 'coupon_form_dialog.dart';

final couponsProvider = StreamProvider<List<Coupon>>((ref) {
  return ref.watch(couponRepositoryProvider).watchActiveCoupons();
});

class CouponListView extends ConsumerWidget {
  const CouponListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couponsAsync = ref.watch(couponsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AdminTheme.backgroundGradient,
        ),
        child: couponsAsync.when(
          data: (coupons) {
            if (coupons.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_offer_outlined,
                      size: 100,
                      color: AdminTheme.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum cupom ativo',
                      style: AdminTheme.headingSmall.copyWith(
                        color: AdminTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Clique no + para criar uma promoção',
                      style: AdminTheme.bodyMedium.copyWith(
                        color: AdminTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: coupons.length,
              itemBuilder: (context, index) {
                final coupon = coupons[index];
                return _CouponCard(coupon: coupon);
              },
            );
          },
          loading: () => const Center(child: AppLoader()),
          error: (error, stack) => Center(
            child: Text(
              'Erro ao carregar cupons: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: AdminTheme.gradientPrimary),
          boxShadow: [
            BoxShadow(
              color: AdminTheme.gradientPrimary[0].withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showCouponDialog(context, ref, null),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showCouponDialog(BuildContext context, WidgetRef ref, Coupon? coupon) {
    showDialog(
      context: context,
      builder: (context) => CouponFormDialog(coupon: coupon),
    );
  }
}

class _CouponCard extends ConsumerWidget {
  final Coupon coupon;

  const _CouponCard({required this.coupon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Removed unused theme
    final isValid = coupon.isValid;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AdminTheme.bgCardLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AdminTheme.gradientPrimary[0].withOpacity(0.5),
                          style: BorderStyle.solid,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        coupon.code,
                        style: AdminTheme.headingSmall.copyWith(
                          color: AdminTheme.gradientPrimary[0],
                          letterSpacing: 1.2,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (!isValid)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Expirado/Inválido',
                          style: AdminTheme.bodySmall.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    // Active toggle
                    Switch(
                      value: coupon.isActive && isValid,
                      onChanged: (value) => _toggleActive(ref, value),
                      activeThumbColor: AdminTheme.gradientPrimary[0],
                      activeTrackColor: AdminTheme.gradientPrimary[0]
                          .withOpacity(0.3),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.bar_chart,
                        color: AdminTheme.textSecondary,
                      ),
                      onPressed: () => _showStats(context, ref),
                      tooltip: 'Estatísticas',
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () => _showEditDialog(context, ref),
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.redAccent,
                      onPressed: () => _confirmDelete(context, ref),
                      tooltip: 'Excluir',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(coupon.name, style: AdminTheme.headingSmall),
            if (coupon.description != null && coupon.description!.isNotEmpty)
              Text(coupon.description!, style: AdminTheme.bodySmall),
            const Divider(color: AdminTheme.borderLight, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Desconto', style: AdminTheme.bodySmall),
                    Text(
                      coupon.formattedDiscount,
                      style: AdminTheme.headingSmall.copyWith(
                        color: Colors.greenAccent,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Uso', style: AdminTheme.bodySmall),
                    Text(
                      '${coupon.usedCount}${coupon.maxUses != null ? '/${coupon.maxUses}' : ''}',
                      style: AdminTheme.bodyMedium,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Aplica-se a', style: AdminTheme.bodySmall),
                    Row(
                      children: coupon.applicableTo.map((type) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Tooltip(
                            message: type.displayName,
                            child: Text(
                              type.icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleActive(WidgetRef ref, bool value) async {
    final updatedCoupon = coupon.copyWith(isActive: value);
    await ref.read(couponRepositoryProvider).updateCoupon(updatedCoupon);
  }

  void _showStats(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<Map<String, dynamic>>(
        future: ref.read(couponRepositoryProvider).getCouponStats(coupon.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: SizedBox(height: 100, child: Center(child: AppLoader())),
            );
          }

          if (snapshot.hasError) {
            return AlertDialog(
              backgroundColor: AdminTheme.bgCard,
              title: const Text('Erro', style: AdminTheme.headingSmall),
              content: Text(
                'Erro ao carregar estatísticas: ${snapshot.error}',
                style: const TextStyle(color: AdminTheme.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'OK',
                    style: TextStyle(color: AdminTheme.textSecondary),
                  ),
                ),
              ],
            );
          }

          final stats = snapshot.data ?? {};
          final totalUses = stats['totalUses'] ?? coupon.usedCount;
          final totalDiscount = (stats['totalDiscount'] ?? 0.0).toDouble();

          return AlertDialog(
            backgroundColor: AdminTheme.bgCard,
            title: Row(
              children: [
                const Icon(Icons.bar_chart, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  'Estatísticas: ${coupon.code}',
                  style: AdminTheme.headingSmall,
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatRow('Total de Usos', totalUses.toString()),
                _buildStatRow(
                  'Limite',
                  coupon.maxUses?.toString() ?? 'Ilimitado',
                ),
                _buildStatRow(
                  'Desconto Total Concedido',
                  'R\$ ${totalDiscount.toStringAsFixed(2)}',
                ),
                _buildStatRow('Status', coupon.isActive ? 'Ativo' : 'Inativo'),
                _buildStatRow(
                  'Válido até',
                  coupon.validUntil != null
                      ? '${coupon.validUntil!.day}/${coupon.validUntil!.month}/${coupon.validUntil!.year}'
                      : 'Sem expiração',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Fechar',
                  style: TextStyle(color: AdminTheme.textSecondary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AdminTheme.bodySmall),
          Text(
            value,
            style: AdminTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => CouponFormDialog(coupon: coupon),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminTheme.bgCard,
        title: const Text('Excluir Cupom?', style: AdminTheme.headingSmall),
        content: const Text(
          'Tem certeza que deseja excluir este cupom? Esta ação não pode ser desfeita.',
          style: TextStyle(color: AdminTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AdminTheme.textSecondary),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(couponRepositoryProvider).deleteCoupon(coupon.id);
    }
  }
}
