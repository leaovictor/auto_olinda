import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../tenant/domain/tenant.dart';
import '../../../tenant/data/tenant_repository.dart';
import '../../../../shared/utils/app_toast.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_text_field.dart';

/// Tenant branding & Stripe Connect onboarding.
///
/// Available to tenantOwner/admin only (Firestore rules enforce this).
/// SuperAdmin can also access if they navigate directly to the admin shell
/// of a specific tenant.
class TenantBrandingScreen extends ConsumerStatefulWidget {
  const TenantBrandingScreen({super.key});

  @override
  ConsumerState<TenantBrandingScreen> createState() =>
      _TenantBrandingScreenState();
}

class _TenantBrandingScreenState
    extends ConsumerState<TenantBrandingScreen> {
  // Branding controllers
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  Color _pickedColor = const Color(0xFF1A73E8);

  bool _hasPopulatedForm = false;
  bool _isSaving = false;

  // Stripe Connect state
  bool _isStartingStripeConnect = false;
  bool _isCheckingStripeStatus = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    super.dispose();
  }

  void _populateForm(Tenant tenant) {
    if (_hasPopulatedForm) return;
    _hasPopulatedForm = true;
    _nameCtrl.text = tenant.name;
    _phoneCtrl.text = tenant.phone ?? '';
    _cityCtrl.text = tenant.city ?? '';
    _stateCtrl.text = tenant.state ?? '';
    try {
      final clean = tenant.primaryColor.replaceFirst('#', '');
      _pickedColor = Color(int.parse('FF$clean', radix: 16));
    } catch (_) {}
  }

  String get _hexColor =>
      '#${_pickedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  Future<void> _saveBranding(Tenant tenant) async {
    setState(() => _isSaving = true);
    try {
      await ref.read(tenantRepositoryProvider).updateTenant(tenant.id, {
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'primaryColor': _hexColor,
      });
      if (mounted) AppToast.success(context, message: 'Branding atualizado!');
    } catch (e) {
      if (mounted) AppToast.error(context, message: 'Erro ao salvar: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _startStripeConnect(Tenant tenant) async {
    setState(() => _isStartingStripeConnect = true);
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      final result = await functions
          .httpsCallable('createStripeConnectAccount')
          .call({'tenantId': tenant.id});

      final url = result.data['url'] as String?;
      if (url != null && url.isNotEmpty) {
        // Open Stripe Connect onboarding URL.
        // On mobile, launch via url_launcher; on web, open in new tab.
        // We write the URL to clipboard as a fallback (url_launcher may not be available in all builds).
        if (mounted) {
          _showStripeUrlDialog(url);
        }
      } else {
        if (mounted) {
          AppToast.error(
            context,
            message: 'Nenhuma URL retornada pelo servidor.',
          );
        }
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro Stripe: ${e.message ?? e.code}');
      }
    } catch (e) {
      if (mounted) AppToast.error(context, message: 'Erro: $e');
    } finally {
      if (mounted) setState(() => _isStartingStripeConnect = false);
    }
  }

  Future<void> _checkStripeStatus(Tenant tenant) async {
    setState(() => _isCheckingStripeStatus = true);
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      await functions
          .httpsCallable('checkStripeConnectStatus')
          .call({'tenantId': tenant.id});

      // Invalidate tenant stream so the UI reflects the updated stripeConnectOnboarded flag
      ref.invalidate(currentTenantProvider);

      if (mounted) {
        AppToast.success(context, message: 'Status do Stripe verificado!');
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        AppToast.error(
          context,
          message: 'Erro ao verificar: ${e.message ?? e.code}',
        );
      }
    } catch (e) {
      if (mounted) AppToast.error(context, message: 'Erro: $e');
    } finally {
      if (mounted) setState(() => _isCheckingStripeStatus = false);
    }
  }

  void _showStripeUrlDialog(String url) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AdminTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Conectar ao Stripe',
          style: AdminTheme.headingSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acesse o link abaixo para concluir o cadastro no Stripe Connect:',
              style: AdminTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AdminTheme.bgCardLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                url,
                style: TextStyle(
                  color: AdminTheme.gradientPrimary[0],
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Depois de concluir, use "Verificar status" para atualizar.',
              style: AdminTheme.bodyMedium,
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
      ),
    );
  }

  void _showColorPicker(StateSetter setDialogState) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AdminTheme.bgCard,
        title: const Text('Cor principal', style: AdminTheme.headingSmall),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _pickedColor,
            onColorChanged: (color) {
              setDialogState(() => _pickedColor = color);
              setState(() => _pickedColor = color);
            },
            enableAlpha: false,
            hexInputBar: true,
            labelTypes: const [],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: AdminTheme.gradientPrimary[0],
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tenantAsync = ref.watch(currentTenantProvider);

    return tenantAsync.when(
      data: (tenant) {
        if (tenant == null) {
          return const Center(
            child: Text(
              'Sem tenant associado a este usuário.',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }
        _populateForm(tenant);
        return _buildContent(tenant);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Erro: $e', style: const TextStyle(color: Colors.redAccent)),
      ),
    );
  }

  Widget _buildContent(Tenant tenant) {
    return Container(
      decoration: const BoxDecoration(gradient: AdminTheme.backgroundGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Text('Marca & Integração', style: AdminTheme.headingMedium),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AdminTheme.gradientPrimary[0].withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tenant.id,
                      style: TextStyle(
                        color: AdminTheme.gradientPrimary[0],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Personalize a identidade visual do seu lava-jato e gerencie sua conta de pagamentos.',
                style: AdminTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              // ── Branding Section ────────────────────────────────────────────
              _sectionCard(
                title: 'Identidade Visual',
                icon: Icons.palette_outlined,
                children: [
                  AdminTextField(
                    controller: _nameCtrl,
                    label: 'Nome do estabelecimento',
                    hint: 'Ex: CleanFlow Premium',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AdminTextField(
                          controller: _phoneCtrl,
                          label: 'Telefone',
                          hint: '(81) 9 9999-9999',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AdminTextField(
                          controller: _cityCtrl,
                          label: 'Cidade',
                          hint: 'Olinda',
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 80,
                        child: AdminTextField(
                          controller: _stateCtrl,
                          label: 'UF',
                          hint: 'PE',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Color picker row
                  StatefulBuilder(
                    builder: (context, setDialogState) {
                      return Row(
                        children: [
                          Text('Cor principal', style: AdminTheme.bodyLarge),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _showColorPicker(setDialogState),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: _pickedColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white24,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _hexColor,
                                  style: TextStyle(
                                    color: AdminTheme.gradientPrimary[0],
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.edit_outlined,
                                  size: 16,
                                  color: AdminTheme.gradientPrimary[0],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Live preview strip
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: _pickedColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        _nameCtrl.text.isEmpty ? 'Prévia da cor' : _nameCtrl.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _gradientButton(
                    label: _isSaving ? 'Salvando...' : 'Salvar Branding',
                    icon: Icons.save_outlined,
                    isLoading: _isSaving,
                    onPressed: () => _saveBranding(tenant),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Stripe Connect Section ───────────────────────────────────────
              _sectionCard(
                title: 'Pagamentos — Stripe Connect',
                icon: Icons.account_balance_outlined,
                children: [
                  // Status indicator
                  Row(
                    children: [
                      Icon(
                        tenant.stripeConnectOnboarded
                            ? Icons.verified_rounded
                            : Icons.warning_amber_rounded,
                        color: tenant.stripeConnectOnboarded
                            ? Colors.green
                            : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        tenant.stripeConnectOnboarded
                            ? 'Conta conectada e ativa'
                            : 'Conta ainda não conectada',
                        style: AdminTheme.bodyLarge.copyWith(
                          color: tenant.stripeConnectOnboarded
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Taxa da plataforma: ${tenant.platformFeePercent}%\n'
                    'Os pagamentos dos clientes são divididos automaticamente entre você e a plataforma.',
                    style: AdminTheme.bodyMedium,
                  ),
                  if (tenant.stripeConnectAccountId != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Account ID: ${tenant.stripeConnectAccountId}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: AdminTheme.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _gradientButton(
                          label: _isStartingStripeConnect
                              ? 'Aguarde...'
                              : (tenant.stripeConnectOnboarded
                                  ? 'Reconfigurar Stripe'
                                  : 'Conectar ao Stripe'),
                          icon: Icons.link_rounded,
                          isLoading: _isStartingStripeConnect,
                          onPressed: () => _startStripeConnect(tenant),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isCheckingStripeStatus
                              ? null
                              : () => _checkStripeStatus(tenant),
                          icon: _isCheckingStripeStatus
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white54,
                                  ),
                                )
                              : const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Verificar status'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AdminTheme.textSecondary,
                            side: const BorderSide(
                              color: AdminTheme.borderLight,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AdminTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Icon(icon, color: AdminTheme.gradientPrimary[0], size: 20),
                const SizedBox(width: 10),
                Text(title, style: AdminTheme.headingSmall),
              ],
            ),
          ),
          Divider(
            height: 24,
            color: AdminTheme.borderLight,
            indent: 20,
            endIndent: 20,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradientButton({
    required String label,
    required IconData icon,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AdminTheme.gradientPrimary),
        borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
        boxShadow: AdminTheme.glowShadow(AdminTheme.gradientPrimary[0]),
      ),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, color: Colors.white, size: 18),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }
}
