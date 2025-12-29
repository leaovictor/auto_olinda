import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blurred_overlay/blurred_overlay.dart';
import 'package:intl/intl.dart';
import '../../domain/booking_with_details.dart';
import '../../../booking/domain/booking.dart';
import '../../data/admin_repository.dart';
import '../../../../shared/utils/app_toast.dart';
import '../theme/admin_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingDetailsDialog extends ConsumerWidget {
  final BookingWithDetails bookingData;

  const BookingDetailsDialog({super.key, required this.bookingData});

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final url = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
        AppToast.error(context, message: 'Erro ao abrir discador');
      }
    }
  }

  Future<void> _openWhatsApp(BuildContext context, String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final url = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        AppToast.error(context, message: 'Erro ao abrir WhatsApp');
      }
    }
  }

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    BookingStatus newStatus,
  ) async {
    final confirm = await showBlurredDialog<bool>(
      context: context,
      builder: (context) => _PremiumConfirmDialog(
        title: 'Confirmar Alteração',
        message: 'Mudar status para ${_getStatusLabel(newStatus)}?',
        confirmLabel: 'Confirmar',
        cancelLabel: 'Cancelar',
        confirmColor: _getStatusColor(newStatus),
      ),
    );

    if (confirm == true) {
      try {
        await ref
            .read(adminRepositoryProvider)
            .updateBookingStatus(
              bookingData.booking.id,
              newStatus,
              actorId: 'admin',
            );
        if (context.mounted) {
          Navigator.pop(context);
          AppToast.success(context, message: 'Status atualizado!');
        }
      } catch (e) {
        if (context.mounted) AppToast.error(context, message: 'Erro: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = bookingData.booking;
    final user = bookingData.user;
    final vehicle = bookingData.vehicle;
    final services = bookingData.services;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AdminTheme.radiusXXL),
        child: BackdropFilter(
          filter: AdminTheme.heavyBlur,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
            decoration: BoxDecoration(
              color: AdminTheme.bgCard.withOpacity(0.95),
              borderRadius: BorderRadius.circular(AdminTheme.radiusXXL),
              border: Border.all(color: AdminTheme.borderLight),
              boxShadow: AdminTheme.glowShadow(
                AdminTheme.gradientPrimary[0],
                intensity: 0.15,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(context, booking),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AdminTheme.paddingLG),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Client Card
                        _buildClientCard(context, user),
                        const SizedBox(height: AdminTheme.paddingMD),

                        // Vehicle Card
                        if (vehicle != null) ...[
                          _buildVehicleCard(vehicle),
                          const SizedBox(height: AdminTheme.paddingMD),
                        ],

                        // Services Card
                        if (services.isNotEmpty) ...[
                          _buildServicesCard(services, booking),
                          const SizedBox(height: AdminTheme.paddingMD),
                        ],

                        // Status Card
                        _buildStatusCard(booking),

                        // Photo Gallery
                        if (booking.beforePhotos.isNotEmpty ||
                            booking.afterPhotos.isNotEmpty) ...[
                          const SizedBox(height: AdminTheme.paddingMD),
                          _buildPhotoGallery(context, booking),
                        ],
                      ],
                    ),
                  ),
                ),

                // Actions
                _buildActions(context, ref, booking),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Booking booking) {
    return Container(
      padding: const EdgeInsets.all(AdminTheme.paddingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AdminTheme.gradientPrimary[0].withOpacity(0.2),
            AdminTheme.gradientPrimary[1].withOpacity(0.1),
          ],
        ),
        border: Border(bottom: BorderSide(color: AdminTheme.borderLight)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AdminTheme.gradientPrimary),
              borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
              boxShadow: AdminTheme.glowShadow(
                AdminTheme.gradientPrimary[0],
                intensity: 0.3,
              ),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AdminTheme.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Detalhes do Agendamento', style: AdminTheme.headingSmall),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(booking.scheduledTime),
                  style: AdminTheme.bodySmall.copyWith(
                    color: AdminTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AdminTheme.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientCard(BuildContext context, dynamic user) {
    final displayName = user?.displayName ?? 'Cliente Desconhecido';
    final phoneNumber = user?.phoneNumber;
    final initials = _getInitials(displayName);

    return Container(
      padding: const EdgeInsets.all(AdminTheme.paddingMD),
      decoration: AdminTheme.glassmorphicDecoration(
        glowColor: const Color(0xFF60A5FA),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
              ),
              shape: BoxShape.circle,
              boxShadow: AdminTheme.glowShadow(
                const Color(0xFF6366F1),
                intensity: 0.3,
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AdminTheme.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      color: const Color(0xFF60A5FA),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Cliente',
                      style: AdminTheme.labelSmall.copyWith(
                        color: const Color(0xFF60A5FA),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  displayName,
                  style: AdminTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                if (phoneNumber != null) ...[
                  const SizedBox(height: 4),
                  Text(phoneNumber, style: AdminTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (phoneNumber != null) ...[
            _buildActionButton(
              icon: Icons.chat_rounded,
              color: const Color(0xFF25D366),
              onTap: () => _openWhatsApp(context, phoneNumber),
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.phone_rounded,
              color: const Color(0xFF3B82F6),
              onTap: () => _makePhoneCall(context, phoneNumber),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildVehicleCard(dynamic vehicle) {
    return Container(
      padding: const EdgeInsets.all(AdminTheme.paddingMD),
      decoration: AdminTheme.glassmorphicDecoration(
        glowColor: const Color(0xFFA78BFA),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFA78BFA).withOpacity(0.15),
              borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
            ),
            child: const Icon(
              Icons.directions_car_rounded,
              color: Color(0xFFA78BFA),
              size: 24,
            ),
          ),
          const SizedBox(width: AdminTheme.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_car_wash_rounded,
                      color: const Color(0xFFA78BFA),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Veículo',
                      style: AdminTheme.labelSmall.copyWith(
                        color: const Color(0xFFA78BFA),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${vehicle.brand} ${vehicle.model}',
                  style: AdminTheme.bodyLarge,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFA78BFA).withOpacity(0.2),
              borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
              border: Border.all(
                color: const Color(0xFFA78BFA).withOpacity(0.5),
              ),
            ),
            child: Text(
              vehicle.plate.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFA78BFA),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesCard(List<dynamic> services, Booking booking) {
    return Container(
      padding: const EdgeInsets.all(AdminTheme.paddingMD),
      decoration: AdminTheme.glassmorphicDecoration(
        glowColor: const Color(0xFF10B981),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
                ),
                child: const Icon(
                  Icons.auto_fix_high_rounded,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Serviços',
                      style: AdminTheme.labelSmall.copyWith(
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${services.length} ${services.length == 1 ? 'serviço' : 'serviços'}',
                      style: AdminTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AdminTheme.gradientSuccess),
                  borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
                  boxShadow: AdminTheme.glowShadow(
                    AdminTheme.gradientSuccess[0],
                    intensity: 0.3,
                  ),
                ),
                child: Text(
                  'R\$ ${booking.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...services.map(
            (s) => Padding(
              padding: const EdgeInsets.only(left: 48, bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      s.title,
                      style: AdminTheme.bodyMedium.copyWith(
                        color: AdminTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(Booking booking) {
    final statusColor = _getStatusColor(booking.status);
    final statusLabel = _getStatusLabel(booking.status);

    return Container(
      padding: const EdgeInsets.all(AdminTheme.paddingMD),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AdminTheme.radiusLG),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(booking.status),
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Atual',
                  style: AdminTheme.labelSmall.copyWith(
                    color: statusColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGallery(BuildContext context, Booking booking) {
    return Container(
      padding: const EdgeInsets.all(AdminTheme.paddingMD),
      decoration: AdminTheme.glassmorphicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
                ),
                child: const Icon(
                  Icons.photo_library_rounded,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Fotos do Serviço',
                style: AdminTheme.bodyLarge.copyWith(
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),

          if (booking.beforePhotos.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '📷 Antes (${booking.beforePhotos.length})',
              style: AdminTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: booking.beforePhotos
                  .map((url) => _buildPhotoThumbnail(context, url))
                  .toList(),
            ),
          ],

          if (booking.afterPhotos.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '✨ Depois (${booking.afterPhotos.length})',
              style: AdminTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: booking.afterPhotos
                  .map((url) => _buildPhotoThumbnail(context, url))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, Booking booking) {
    return Container(
      padding: const EdgeInsets.all(AdminTheme.paddingLG),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border(top: BorderSide(color: AdminTheme.borderLight)),
      ),
      child: Row(
        children: [
          // Close button
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AdminTheme.textSecondary,
                side: BorderSide(color: AdminTheme.borderMedium),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
                ),
              ),
              child: const Text('Fechar'),
            ),
          ),
          const SizedBox(width: 12),
          // Action button based on status
          if (_getNextAction(booking.status) != null)
            Expanded(
              flex: 2,
              child: _buildGradientButton(context, ref, booking),
            ),
        ],
      ),
    );
  }

  Widget _buildGradientButton(
    BuildContext context,
    WidgetRef ref,
    Booking booking,
  ) {
    final nextStatus = _getNextAction(booking.status);
    if (nextStatus == null) return const SizedBox.shrink();

    final gradient = _getActionGradient(nextStatus);
    final label = _getActionLabel(nextStatus);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
        boxShadow: AdminTheme.glowShadow(gradient[0], intensity: 0.3),
      ),
      child: ElevatedButton.icon(
        onPressed: () => _updateStatus(context, ref, nextStatus),
        icon: Icon(_getActionIcon(nextStatus), size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
          ),
        ),
      ),
    );
  }

  BookingStatus? _getNextAction(BookingStatus status) {
    switch (status) {
      case BookingStatus.scheduled:
        return BookingStatus.confirmed;
      case BookingStatus.confirmed:
        return BookingStatus.washing;
      case BookingStatus.washing:
        return BookingStatus.finished;
      default:
        return null;
    }
  }

  List<Color> _getActionGradient(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return AdminTheme.gradientInfo;
      case BookingStatus.washing:
        return AdminTheme.gradientPrimary;
      case BookingStatus.finished:
        return AdminTheme.gradientSuccess;
      default:
        return AdminTheme.gradientPrimary;
    }
  }

  String _getActionLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 'Confirmar';
      case BookingStatus.washing:
        return 'Iniciar Lavagem';
      case BookingStatus.finished:
        return 'Finalizar';
      default:
        return 'Avançar';
    }
  }

  IconData _getActionIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case BookingStatus.washing:
        return Icons.local_car_wash_rounded;
      case BookingStatus.finished:
        return Icons.done_all_rounded;
      default:
        return Icons.arrow_forward_rounded;
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.scheduled:
        return const Color(0xFFF59E0B);
      case BookingStatus.confirmed:
        return const Color(0xFF3B82F6);
      case BookingStatus.checkIn:
        return const Color(0xFF8B5CF6);
      case BookingStatus.washing:
        return const Color(0xFF06B6D4);
      case BookingStatus.vacuuming:
        return const Color(0xFF14B8A6);
      case BookingStatus.drying:
        return const Color(0xFF22D3EE);
      case BookingStatus.polishing:
        return const Color(0xFFFBBF24);
      case BookingStatus.finished:
        return const Color(0xFF10B981);
      case BookingStatus.cancelled:
        return const Color(0xFFEF4444);
      case BookingStatus.noShow:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.scheduled:
        return 'Agendado';
      case BookingStatus.confirmed:
        return 'Confirmado';
      case BookingStatus.checkIn:
        return 'Check-in';
      case BookingStatus.washing:
        return 'Lavando';
      case BookingStatus.vacuuming:
        return 'Aspirando';
      case BookingStatus.drying:
        return 'Secando';
      case BookingStatus.polishing:
        return 'Polindo';
      case BookingStatus.finished:
        return 'Concluído';
      case BookingStatus.cancelled:
        return 'Cancelado';
      case BookingStatus.noShow:
        return 'Não Compareceu';
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.scheduled:
        return Icons.schedule_rounded;
      case BookingStatus.confirmed:
        return Icons.check_circle_rounded;
      case BookingStatus.checkIn:
        return Icons.login_rounded;
      case BookingStatus.washing:
        return Icons.local_car_wash_rounded;
      case BookingStatus.vacuuming:
        return Icons.cleaning_services_rounded;
      case BookingStatus.drying:
        return Icons.air_rounded;
      case BookingStatus.polishing:
        return Icons.auto_awesome_rounded;
      case BookingStatus.finished:
        return Icons.done_all_rounded;
      case BookingStatus.cancelled:
        return Icons.cancel_rounded;
      case BookingStatus.noShow:
        return Icons.person_off_rounded;
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'C';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  String _formatDateTime(DateTime dateTime) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    return '${dateFormat.format(dateTime)} às ${timeFormat.format(dateTime)}';
  }

  Widget _buildPhotoThumbnail(BuildContext context, String url) {
    return GestureDetector(
      onTap: () => _showFullScreenPhoto(context, url),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
          border: Border.all(color: AdminTheme.borderLight),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
          child: Image.network(
            url,
            width: 80,
            height: 60,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 80,
                height: 60,
                color: AdminTheme.bgCardLight,
                child: const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AdminTheme.textSecondary,
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 80,
                height: 60,
                color: AdminTheme.bgCardLight,
                child: const Icon(
                  Icons.broken_image_rounded,
                  color: AdminTheme.textMuted,
                  size: 20,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showFullScreenPhoto(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            // Blurred background
            Positioned.fill(
              child: BackdropFilter(
                filter: AdminTheme.heavyBlur,
                child: Container(color: Colors.black.withOpacity(0.8)),
              ),
            ),
            // Image
            Center(
              child: InteractiveViewer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AdminTheme.radiusLG),
                  child: Image.network(url),
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 50,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Premium styled confirmation dialog
class _PremiumConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final Color confirmColor;

  const _PremiumConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AdminTheme.radiusXL),
        child: BackdropFilter(
          filter: AdminTheme.heavyBlur,
          child: Container(
            padding: const EdgeInsets.all(AdminTheme.paddingLG),
            decoration: BoxDecoration(
              color: AdminTheme.bgCard.withOpacity(0.95),
              borderRadius: BorderRadius.circular(AdminTheme.radiusXL),
              border: Border.all(color: AdminTheme.borderLight),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AdminTheme.headingSmall),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: AdminTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AdminTheme.textSecondary,
                          side: BorderSide(color: AdminTheme.borderMedium),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AdminTheme.radiusMD,
                            ),
                          ),
                        ),
                        child: Text(cancelLabel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: confirmColor,
                          borderRadius: BorderRadius.circular(
                            AdminTheme.radiusMD,
                          ),
                          boxShadow: AdminTheme.glowShadow(
                            confirmColor,
                            intensity: 0.3,
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AdminTheme.radiusMD,
                              ),
                            ),
                          ),
                          child: Text(confirmLabel),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
