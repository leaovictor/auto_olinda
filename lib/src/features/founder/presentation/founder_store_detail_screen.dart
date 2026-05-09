import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../license/domain/store_license.dart';
import '../data/founder_repository.dart';
import '../../admin/presentation/theme/admin_theme.dart';

class FounderStoreDetailScreen extends ConsumerStatefulWidget {
  final StoreLicense license;

  const FounderStoreDetailScreen({super.key, required this.license});

  @override
  ConsumerState<FounderStoreDetailScreen> createState() =>
      _FounderStoreDetailScreenState();
}

class _FounderStoreDetailScreenState
    extends ConsumerState<FounderStoreDetailScreen> {
  late StoreLicense _license;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _license = widget.license;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _license.isExpired
        ? AdminTheme.gradientDanger[0]
        : _license.status == 'trial'
        ? AdminTheme.gradientWarning[0]
        : AdminTheme.gradientSuccess[0];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AdminTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(statusColor),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 24),
                    _buildLicenseCard(),
                    const SizedBox(height: 24),
                    _buildActionsCard(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color statusColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 24, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.4)),
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
                Text(_license.storeName, style: AdminTheme.headingSmall),
                Text(_license.storeId, style: AdminTheme.bodySmall),
              ],
            ),
          ),
        ],
      ).animate().fadeIn().slideY(begin: -0.1),
    );
  }

  Widget _buildInfoCard() {
    return _sectionCard(
      title: 'Informações do Dono',
      icon: Icons.person_rounded,
      colors: AdminTheme.gradientInfo,
      children: [
        _row(Icons.person_outline, 'Nome', _license.ownerName),
        _row(Icons.email_outlined, 'Email', _license.ownerEmail),
        _row(Icons.phone_outlined, 'WhatsApp', _license.ownerPhone),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildLicenseCard() {
    final expiry = _license.licenseExpiresAt ?? _license.trialEndsAt;
    final fmt = DateFormat('dd/MM/yyyy');

    return _sectionCard(
      title: 'Licença',
      icon: Icons.verified_rounded,
      colors: _license.isExpired
          ? AdminTheme.gradientDanger
          : AdminTheme.gradientSuccess,
      children: [
        _row(
          Icons.assignment_outlined,
          'Status',
          _license.statusLabel,
          valueColor: _license.isExpired
              ? AdminTheme.gradientDanger[0]
              : AdminTheme.gradientSuccess[0],
        ),
        _row(Icons.receipt_long_rounded, 'Modalidade',
            _license.modalidadeLabel),
        if (expiry != null)
          _row(
            Icons.calendar_today_rounded,
            _license.status == 'trial' ? 'Trial até' : 'Válida até',
            fmt.format(expiry),
          ),
        if (_license.contractSignedAt != null)
          _row(
            Icons.handshake_rounded,
            'Contrato assinado',
            fmt.format(_license.contractSignedAt!),
          ),
        _row(
          Icons.attach_money_rounded,
          'Valor do contrato',
          'R\$ ${_license.contractValue.toStringAsFixed(2).replaceAll('.', ',')}',
        ),
        if (_license.notes.isNotEmpty)
          _row(Icons.notes_rounded, 'Notas', _license.notes),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildActionsCard(BuildContext context) {
    return _sectionCard(
      title: 'Ações',
      icon: Icons.settings_rounded,
      colors: AdminTheme.gradientPrimary,
      children: [
        // Activate for 1 year
        _actionButton(
          label: 'Ativar Licença Anual (1 ano)',
          icon: Icons.check_circle_rounded,
          colors: AdminTheme.gradientSuccess,
          onTap: () => _activateLicense(context, months: 12),
        ),
        const SizedBox(height: 8),
        // Activate for 6 months
        _actionButton(
          label: 'Ativar Licença (6 meses)',
          icon: Icons.calendar_today_rounded,
          colors: AdminTheme.gradientInfo,
          onTap: () => _activateLicense(context, months: 6),
        ),
        const SizedBox(height: 8),
        // Add 30-day trial
        _actionButton(
          label: 'Adicionar 30 dias de Trial',
          icon: Icons.hourglass_bottom_rounded,
          colors: AdminTheme.gradientWarning,
          onTap: () => _extendTrial(context, days: 30),
        ),
        const SizedBox(height: 8),
        // Suspend
        _actionButton(
          label: 'Suspender Acesso',
          icon: Icons.block_rounded,
          colors: AdminTheme.gradientDanger,
          onTap: () => _suspend(context),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Color> colors,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AdminTheme.glassmorphicDecoration(glowColor: colors[0]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors[0].withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: colors[0], size: 18),
              ),
              const SizedBox(width: 12),
              Text(title, style: AdminTheme.headingSmall),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AdminTheme.borderLight, height: 1),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _row(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AdminTheme.textMuted),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: AdminTheme.bodySmall.copyWith(fontSize: 13),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: AdminTheme.bodyLarge.copyWith(
                fontSize: 14,
                color: valueColor ?? AdminTheme.textPrimary,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _loading ? null : onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          backgroundColor: colors[0].withOpacity(0.15),
          foregroundColor: colors[0],
          elevation: 0,
          side: BorderSide(color: colors[0].withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> _activateLicense(BuildContext context, {required int months}) async {
    final confirmed = await _confirm(
      context,
      'Ativar Licença por $months meses?',
      'Isso vai liberar o painel admin para ${_license.storeName}.',
    );
    if (!confirmed) return;

    setState(() => _loading = true);
    try {
      final expiresAt = DateTime.now().add(Duration(days: months * 30));
      await ref.read(founderRepositoryProvider).activateLicense(
            storeId: _license.storeId,
            expiresAt: expiresAt,
            modalidade: _license.modalidade,
            contractValue: _license.contractValue,
          );
      if (mounted) {
        _showSnack('✅ Licença ativada com sucesso!', isError: false);
      }
    } catch (e) {
      if (mounted) _showSnack('Erro: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _extendTrial(BuildContext context, {required int days}) async {
    final confirmed = await _confirm(
      context,
      'Adicionar $days dias de trial?',
      'O período trial de ${_license.storeName} será estendido.',
    );
    if (!confirmed) return;

    setState(() => _loading = true);
    try {
      final currentExpiry = _license.trialEndsAt ?? DateTime.now();
      final newExpiry = currentExpiry.add(Duration(days: days));
      await ref.read(founderRepositoryProvider).saveLicense(
            _license.copyWith(
              status: 'trial',
              trialEndsAt: newExpiry,
            ),
          );
      if (mounted) {
        _showSnack('✅ Trial estendido!', isError: false);
      }
    } catch (e) {
      if (mounted) _showSnack('Erro: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _suspend(BuildContext context) async {
    final confirmed = await _confirm(
      context,
      '⚠️ Suspender Acesso?',
      'O painel admin de ${_license.storeName} será bloqueado imediatamente.',
      dangerous: true,
    );
    if (!confirmed) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(founderRepositoryProvider)
          .suspendLicense(_license.storeId);
      if (mounted) {
        _showSnack('Acesso suspenso.', isError: false);
      }
    } catch (e) {
      if (mounted) _showSnack('Erro: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool> _confirm(
    BuildContext context,
    String title,
    String body, {
    bool dangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: AdminTheme.headingSmall),
        content: Text(body, style: AdminTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AdminTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: dangerous
                  ? AdminTheme.gradientDanger[0]
                  : AdminTheme.gradientSuccess[0],
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSnack(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? AdminTheme.gradientDanger[0]
            : AdminTheme.gradientSuccess[0],
      ),
    );
  }
}
