import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../license/domain/store_license.dart';
import '../data/founder_repository.dart';
import '../../admin/presentation/theme/admin_theme.dart';
import 'founder_store_detail_screen.dart';

class FounderDashboardScreen extends ConsumerWidget {
  const FounderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(allStoresProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AdminTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: storesAsync.when(
                  data: (stores) => _buildBody(context, ref, stores),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (e, _) => Center(
                    child: Text('Erro: $e', style: AdminTheme.bodyMedium),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStoreDialog(context, ref),
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('Novo Lavajato'),
        backgroundColor: AdminTheme.gradientPrimary[0],
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          // Back button if nested
          if (context.canPop())
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '👑 Painel do Franqueador',
                  style: AdminTheme.headingMedium,
                ),
                Text(
                  'Gerencie todos os seus lavajatos',
                  style: AdminTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    List<StoreLicense> stores,
  ) {
    final activeCount = stores.where((s) => s.isActive && !s.isExpired).length;
    final expiredCount = stores.where((s) => s.isExpired).length;

    // Estimated monthly revenue (annual contracts ÷ 12)
    final estimatedMRR = stores
        .where((s) => s.isActive && !s.isExpired)
        .fold<double>(0, (sum, s) {
          if (s.modalidade == 'anual') return sum + s.contractValue / 12;
          return sum;
        });

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // ── Summary Cards ─────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'Ativos',
                value: '$activeCount',
                icon: Icons.check_circle_rounded,
                colors: AdminTheme.gradientSuccess,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                label: 'Expirados',
                value: '$expiredCount',
                icon: Icons.cancel_rounded,
                colors: AdminTheme.gradientDanger,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                label: 'MRR Est.',
                value:
                    'R\$${(estimatedMRR / 1000).toStringAsFixed(1)}k',
                icon: Icons.trending_up_rounded,
                colors: AdminTheme.gradientPrimary,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 32),

        Text(
          'Lavajatos (${stores.length})',
          style: AdminTheme.headingSmall,
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 16),

        if (stores.isEmpty)
          _buildEmptyState()
        else
          ...stores.asMap().entries.map((entry) {
            final index = entry.key;
            final store = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildStoreCard(context, store, index),
            );
          }),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required List<Color> colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors[0].withOpacity(0.2), colors[1].withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AdminTheme.radiusLG),
        border: Border.all(color: colors[0].withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors[0], size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: AdminTheme.statValue.copyWith(fontSize: 20),
          ),
          Text(label, style: AdminTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildStoreCard(
    BuildContext context,
    StoreLicense store,
    int index,
  ) {
    final isExpired = store.isExpired;
    final statusColor = isExpired
        ? AdminTheme.gradientDanger[0]
        : store.status == 'trial'
        ? AdminTheme.gradientWarning[0]
        : AdminTheme.gradientSuccess[0];

    final expiry = store.licenseExpiresAt ?? store.trialEndsAt;
    final daysLeft = store.daysUntilExpiry;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FounderStoreDetailScreen(license: store),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AdminTheme.glassmorphicDecoration(
          glowColor: isExpired ? AdminTheme.gradientDanger[0] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.local_car_wash_rounded,
                    color: statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store.storeName, style: AdminTheme.bodyLarge),
                      Text(store.ownerName, style: AdminTheme.bodySmall),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    store.statusLabel.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AdminTheme.borderLight, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMeta(
                    Icons.attach_money_rounded,
                    store.modalidadeLabel,
                  ),
                ),
                if (expiry != null)
                  Expanded(
                    child: _buildMeta(
                      Icons.calendar_today_rounded,
                      daysLeft != null && daysLeft < 0
                          ? 'Expirado'
                          : daysLeft != null
                          ? '$daysLeft dias restantes'
                          : DateFormat('dd/MM/yy').format(expiry),
                    ),
                  ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AdminTheme.textMuted,
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: (100 * index + 200).ms).slideX(begin: 0.05),
    );
  }

  Widget _buildMeta(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AdminTheme.textMuted),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: AdminTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 48),
          const Icon(
            Icons.store_mall_directory_outlined,
            size: 64,
            color: AdminTheme.textMuted,
          ),
          const SizedBox(height: 16),
          const Text('Nenhum lavajato cadastrado.', style: AdminTheme.bodyMedium),
          const SizedBox(height: 8),
          const Text(
            'Clique em + para adicionar o primeiro.',
            style: AdminTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _showAddStoreDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => const _AddStoreDialog(),
    );
  }
}

// ─── Add Store Dialog ─────────────────────────────────────────────────────────

class _AddStoreDialog extends ConsumerStatefulWidget {
  const _AddStoreDialog();

  @override
  ConsumerState<_AddStoreDialog> createState() => _AddStoreDialogState();
}

class _AddStoreDialogState extends ConsumerState<_AddStoreDialog> {
  final _formKey = GlobalKey<FormState>();
  final _storeIdCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _ownerCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _modalidade = 'anual';
  bool _loading = false;

  @override
  void dispose() {
    _storeIdCtrl.dispose();
    _nameCtrl.dispose();
    _ownerCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AdminTheme.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Novo Lavajato', style: AdminTheme.headingSmall),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(_storeIdCtrl, 'ID do Lavajato (ex: lava_rapido_centro)',
                    hint: 'lava_rapido_centro'),
                const SizedBox(height: 12),
                _field(_nameCtrl, 'Nome do Estabelecimento'),
                const SizedBox(height: 12),
                _field(_ownerCtrl, 'Nome do Dono'),
                const SizedBox(height: 12),
                _field(_emailCtrl, 'Email',
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _field(_phoneCtrl, 'WhatsApp',
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _modalidade,
                  dropdownColor: AdminTheme.bgCard,
                  decoration:
                      AdminTheme.inputDecoration(label: 'Modalidade de Licença'),
                  items: const [
                    DropdownMenuItem(
                        value: 'anual', child: Text('Licença Anual (R\$15k)')),
                    DropdownMenuItem(
                        value: 'royalties', child: Text('Royalties (15%)')),
                  ],
                  onChanged: (v) => setState(() => _modalidade = v!),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: TextStyle(color: AdminTheme.gradientDanger[0]),
          ),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminTheme.gradientPrimary[0],
            foregroundColor: Colors.white,
          ),
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Cadastrar'),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: AdminTheme.textPrimary),
      keyboardType: keyboardType,
      decoration: AdminTheme.inputDecoration(label: label).copyWith(
        hintText: hint,
        hintStyle: const TextStyle(color: AdminTheme.textMuted),
      ),
      validator: (v) =>
          (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(founderRepositoryProvider).createStore(
            storeId: _storeIdCtrl.text.trim().toLowerCase().replaceAll(' ', '_'),
            storeName: _nameCtrl.text.trim(),
            ownerName: _ownerCtrl.text.trim(),
            ownerEmail: _emailCtrl.text.trim(),
            ownerPhone: _phoneCtrl.text.trim(),
            modalidade: _modalidade,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: AdminTheme.gradientDanger[0],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
