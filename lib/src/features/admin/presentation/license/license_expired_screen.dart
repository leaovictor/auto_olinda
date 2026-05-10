import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aquaclean_mobile/src/features/license/data/license_repository.dart';
import 'package:aquaclean_mobile/src/features/admin/presentation/theme/admin_theme.dart';

class LicenseExpiredScreen extends ConsumerWidget {
  const LicenseExpiredScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final licenseAsync = ref.watch(currentStoreLicenseProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AdminTheme.backgroundGradient),
        child: SafeArea(
          child: licenseAsync.when(
            data: (license) => _buildContent(context, license),
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (_, __) => _buildContent(context, null),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, dynamic license) {
    final expiryDate = license?.licenseExpiresAt ?? license?.trialEndsAt;
    final statusLabel = license?.statusLabel ?? 'Sem licença';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // ── Icon ──────────────────────────────────────────
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: AdminTheme.gradientDanger,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: AdminTheme.glowShadow(
                AdminTheme.gradientDanger[0],
                intensity: 0.4,
              ),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              size: 56,
              color: Colors.white,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

          const SizedBox(height: 32),

          // ── Title ─────────────────────────────────────────
          Text(
            'Licença Inativa',
            style: AdminTheme.headingLarge.copyWith(fontSize: 32),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 12),

          Text(
            'O acesso ao painel de gestão está\nbloqueado. Entre em contato com o\nsuporte para renovar sua licença.',
            style: AdminTheme.bodyMedium.copyWith(height: 1.6, fontSize: 16),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 40),

          // ── Status Card ───────────────────────────────────
          _buildStatusCard(statusLabel, expiryDate)
              .animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.2),

          const SizedBox(height: 32),

          // ── Contact Button ────────────────────────────────
          _buildContactButton()
              .animate()
              .fadeIn(delay: 500.ms)
              .slideY(begin: 0.2),

          const SizedBox(height: 16),

          // ── Copy Email ────────────────────────────────────
          _buildCopyEmailButton(context)
              .animate()
              .fadeIn(delay: 600.ms)
              .slideY(begin: 0.2),

          const SizedBox(height: 40),

          // ── Footer ────────────────────────────────────────
          Text(
            'Auto Olinda © ${DateTime.now().year}\nDesenvolvido por Victor Leão',
            style: AdminTheme.bodySmall.copyWith(height: 1.6),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 700.ms),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String statusLabel, DateTime? expiryDate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AdminTheme.glassmorphicDecoration(
        glowColor: AdminTheme.gradientDanger[0],
      ),
      child: Column(
        children: [
          _buildRow(
            Icons.info_outline_rounded,
            'Status',
            statusLabel,
            AdminTheme.gradientDanger[0],
          ),
          const SizedBox(height: 16),
          if (expiryDate != null) ...[
            _buildRow(
              Icons.calendar_today_rounded,
              'Vencimento',
              DateFormat('dd/MM/yyyy').format(expiryDate),
              AdminTheme.gradientWarning[0],
            ),
            const SizedBox(height: 16),
          ],
          _buildRow(
            Icons.store_rounded,
            'Sistema',
            'Auto Olinda - Gestão de Lava-Jato',
            AdminTheme.gradientPrimary[0],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AdminTheme.bodySmall.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(value, style: AdminTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          const phone = '5581999999999'; // Victor's WhatsApp — update as needed
          final url = Uri.parse(
            'https://wa.me/$phone?text=Olá Victor, preciso renovar a licença do Auto Olinda.',
          );
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
        icon: const Icon(Icons.message_rounded),
        label: const Text(
          'RENOVAR VIA WHATSAPP',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xFF25D366), // WhatsApp green
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildCopyEmailButton(BuildContext context) {
    const email = 'contato@victorleao.dev.br';
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Clipboard.setData(const ClipboardData(text: email));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email copiado!'),
              duration: Duration(seconds: 2),
              backgroundColor: Color(0xFF6366F1),
            ),
          );
        },
        icon: const Icon(Icons.email_outlined),
        label: const Text(email),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          foregroundColor: AdminTheme.textPrimary,
          side: const BorderSide(color: AdminTheme.borderMedium),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
