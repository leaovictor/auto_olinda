import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../tenant/domain/tenant.dart';
import '../../../tenant/data/tenant_repository.dart';
import '../../../../core/theme/app_colors.dart';

/// SuperAdmin dashboard — accessible only to users with role=superAdmin.
///
/// Provides:
/// • List of all tenants (name, plan, status, Stripe Connect state)
/// • Provision new tenant via setupTenant Cloud Function
/// • Quick-suspend / quick-activate a tenant
class SuperAdminScreen extends ConsumerStatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  ConsumerState<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends ConsumerState<SuperAdminScreen> {
  @override
  Widget build(BuildContext context) {
    final tenantsAsync = ref.watch(allTenantsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D26),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'SUPER ADMIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Painel de Controle',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showProvisionDialog,
            icon: const Icon(Icons.add_business_rounded, color: Colors.white),
            tooltip: 'Provisionar novo tenant',
          ),
        ],
      ),
      body: tenantsAsync.when(
        data: (tenants) => Column(
          children: [
            _buildMetricsHeader(tenants),
            Expanded(child: _buildTenantList(tenants)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Erro: $e', style: const TextStyle(color: Colors.redAccent)),
        ),
      ),
    );
  }

  Widget _buildMetricsHeader(List<Tenant> tenants) {
    final activeTenants = tenants.where((t) => t.status == 'active').length;
    final onboardedTenants = tenants.where((t) => t.stripeConnectOnboarded).length;
    
    // Calculate SaaS MRR based on plans (example pricing)
    double mrr = 0;
    for (final t in tenants.where((t) => t.status == 'active')) {
      if (t.plan == 'starter') mrr += 99.0;
      if (t.plan == 'pro') mrr += 199.0;
      if (t.plan == 'enterprise') mrr += 299.0;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D26),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Métricas da Plataforma (SaaS)',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _kpiCard('Tenants Ativos', '$activeTenants / ${tenants.length}', Icons.business_outlined, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _kpiCard('MRR (Assinaturas)', 'R\$ ${mrr.toStringAsFixed(0)}', Icons.attach_money_rounded, Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _kpiCard('Stripe Connect', '$onboardedTenants', Icons.account_balance_outlined, Colors.purple)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildTenantList(List<Tenant> tenants) {
    if (tenants.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_outlined, size: 64, color: Colors.white24),
            SizedBox(height: 16),
            Text(
              'Nenhum tenant cadastrado',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Use o botão + para provisionar o primeiro.',
              style: TextStyle(color: Colors.white30, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tenants.length,
      itemBuilder: (_, index) => _TenantCard(tenant: tenants[index]),
    );
  }

  void _showProvisionDialog() {
    showDialog(context: context, builder: (_) => const _ProvisionTenantDialog());
  }
}

// ─── Tenant Card ─────────────────────────────────────────────────────────────

class _TenantCard extends ConsumerWidget {
  final Tenant tenant;
  const _TenantCard({required this.tenant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = tenant.status == 'active';
    final primaryColor = _parseColor(tenant.primaryColor);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Color indicator
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_car_wash_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tenant.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        tenant.id,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: tenant.status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.workspace_premium_rounded,
                  label: tenant.plan.toUpperCase(),
                  color: _planColor(tenant.plan),
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: tenant.stripeConnectOnboarded
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  label: tenant.stripeConnectOnboarded ? 'Stripe OK' : 'Stripe pendente',
                  color: tenant.stripeConnectOnboarded ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.percent_rounded,
                  label: '${tenant.platformFeePercent}% fee',
                  color: Colors.white38,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _toggleStatus(context, ref),
                  icon: Icon(
                    isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
                    size: 16,
                  ),
                  label: Text(isActive ? 'Suspender' : 'Ativar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isActive ? Colors.orange : Colors.green,
                    side: BorderSide(color: isActive ? Colors.orange : Colors.green),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleStatus(BuildContext context, WidgetRef ref) async {
    final newStatus = tenant.status == 'active' ? 'suspended' : 'active';
    try {
      await ref.read(tenantRepositoryProvider).updateTenant(tenant.id, {'status': newStatus});
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceFirst('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  Color _planColor(String plan) {
    switch (plan) {
      case 'enterprise':
        return const Color(0xFF6366F1);
      case 'pro':
        return const Color(0xFF0EA5E9);
      default:
        return Colors.white38;
    }
  }
}

// ─── Provision Tenant Dialog ──────────────────────────────────────────────────

class _ProvisionTenantDialog extends ConsumerStatefulWidget {
  const _ProvisionTenantDialog();

  @override
  ConsumerState<_ProvisionTenantDialog> createState() => _ProvisionTenantDialogState();
}

class _ProvisionTenantDialogState extends ConsumerState<_ProvisionTenantDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _ownerEmailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCtrl.dispose();
    _ownerEmailCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1D26),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Novo Tenant',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _darkField(_nameCtrl, 'Nome do lava-jato *', Icons.business_rounded),
                const SizedBox(height: 14),
                _darkField(
                  _idCtrl,
                  'ID único (slug) *',
                  Icons.key_rounded,
                  hint: 'ex: auto-olinda',
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Obrigatório';
                    if (!RegExp(r'^[a-z0-9-]+$').hasMatch(v)) {
                      return 'Apenas letras minúsculas, números e hífens';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _darkField(_ownerEmailCtrl, 'E-mail do proprietário *', Icons.person_outline,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _darkField(_phoneCtrl, 'Telefone', Icons.phone_outlined,
                        keyboardType: TextInputType.phone, required: false)),
                    const SizedBox(width: 12),
                    Expanded(child: _darkField(_cityCtrl, 'Cidade', Icons.location_city_outlined,
                        required: false)),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _provision,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _isLoading
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Provisionar'),
        ),
      ],
    );
  }

  Widget _darkField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    String? hint,
    TextInputType? keyboardType,
    bool required = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator ??
          (v) => required && (v == null || v.isEmpty) ? 'Obrigatório' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white54),
        hintStyle: const TextStyle(color: Colors.white24),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6366F1)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Future<void> _provision() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });

    try {
      final functions = FirebaseFunctions.instanceFor(region: 'southamerica-east1');
      await functions.httpsCallable('setupTenant').call({
        'id': _idCtrl.text.trim(),
        'name': _nameCtrl.text.trim(),
        'ownerEmail': _ownerEmailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅  Tenant "${_nameCtrl.text.trim()}" provisionado!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      setState(() => _error = e.message ?? e.code);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// ─── Small widgets ────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'active' => Colors.green,
      'suspended' => Colors.orange,
      'cancelled' => Colors.red,
      _ => Colors.white38,
    };
    final label = switch (status) {
      'active' => 'ATIVO',
      'suspended' => 'SUSPENSO',
      'cancelled' => 'CANCELADO',
      _ => status.toUpperCase(),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

/// Streams all tenants — readable only by superAdmin (enforced by Firestore rules).
final allTenantsProvider = StreamProvider<List<Tenant>>((ref) {
  return ref.watch(tenantRepositoryProvider).watchAllTenants();
});
