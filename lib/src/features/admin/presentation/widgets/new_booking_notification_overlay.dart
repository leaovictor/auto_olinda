import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/admin_repository.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../booking/domain/booking.dart';
import '../../../../shared/utils/app_toast.dart';
import '../../domain/new_booking_notification_data.dart';

/// Premium notification overlay widget that displays new booking information
/// with a stunning glassmorphic design, animations, and premium aesthetics
class NewBookingNotificationOverlay extends ConsumerStatefulWidget {
  final NewBookingNotificationData data;
  final VoidCallback onDismiss;
  final VoidCallback onViewDetails;

  const NewBookingNotificationOverlay({
    super.key,
    required this.data,
    required this.onDismiss,
    required this.onViewDetails,
  });

  @override
  ConsumerState<NewBookingNotificationOverlay> createState() =>
      _NewBookingNotificationOverlayState();
}

class _NewBookingNotificationOverlayState
    extends ConsumerState<NewBookingNotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    // Notification stays visible until user dismisses or clicks "Ver Detalhes"
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Semi-transparent backdrop (does not dismiss on tap)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),
          ).animate().fadeIn(duration: 300.ms),

          // Notification card
          Center(
            child:
                Container(
                      margin: const EdgeInsets.all(24),
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: _buildNotificationCard(),
                    )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      curve: Curves.elasticOut,
                      duration: 600.ms,
                    )
                    .slideY(begin: -0.3, end: 0, duration: 400.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1E1E2E).withOpacity(0.95),
                    const Color(0xFF2D2D44).withOpacity(0.9),
                  ],
                ),
                border: Border.all(width: 2, color: _getAnimatedBorderColor()),
                boxShadow: [
                  // Outer glow
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                  // Inner shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [_buildHeader(), _buildContent(), _buildActions()],
          ),
        ),
      ),
    );
  }

  Color _getAnimatedBorderColor() {
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFFEC4899), // Pink
      const Color(0xFF6366F1), // Back to Indigo
    ];

    final t = _shimmerController.value;
    final index = (t * (colors.length - 1)).floor();
    final localT = (t * (colors.length - 1)) - index;

    return Color.lerp(
      colors[index],
      colors[(index + 1) % colors.length],
      localT,
    )!;
  }

  Widget _buildHeader() {
    final isCarWash = widget.data.type == NewBookingType.carWash;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCarWash
              ? [
                  const Color(0xFF3B82F6).withOpacity(0.3),
                  const Color(0xFF06B6D4).withOpacity(0.2),
                ]
              : [
                  const Color(0xFF8B5CF6).withOpacity(0.3),
                  const Color(0xFFEC4899).withOpacity(0.2),
                ],
        ),
      ),
      child: Row(
        children: [
          // Animated icon
          Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isCarWash
                        ? [const Color(0xFF3B82F6), const Color(0xFF06B6D4)]
                        : [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isCarWash
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFF8B5CF6))
                              .withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  isCarWash
                      ? Icons.local_car_wash_rounded
                      : Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 1.seconds,
              ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFF59E0B),
                          Color(0xFFFBBF24),
                          Color(0xFFF59E0B),
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        '🔔 NOVO AGENDAMENTO!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(
                      duration: 2.seconds,
                      color: Colors.white.withOpacity(0.3),
                    ),
                const SizedBox(height: 4),
                Text(
                  isCarWash ? 'Lavagem de Veículo' : 'Serviço de Estética',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Close button
          IconButton(
            onPressed: widget.onDismiss,
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white70,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Client info row
          _buildClientRow(),
          const SizedBox(height: 16),

          // Vehicle info (if available)
          if (widget.data.vehiclePlate != null) ...[
            _buildInfoRow(
              icon: Icons.directions_car_rounded,
              iconColor: const Color(0xFF60A5FA),
              label: 'Veículo',
              value: _getVehicleText(),
              highlight: true,
            ),
            const SizedBox(height: 12),
          ],

          // Service info
          _buildInfoRow(
            icon: widget.data.type == NewBookingType.carWash
                ? Icons.local_car_wash_rounded
                : Icons.auto_fix_high_rounded,
            iconColor: const Color(0xFFA78BFA),
            label: 'Serviço',
            value: _getServiceText(),
          ),
          const SizedBox(height: 12),

          // Date/time info
          _buildInfoRow(
            icon: Icons.calendar_today_rounded,
            iconColor: const Color(0xFF34D399),
            label: 'Agendado para',
            value: _getDateTimeText(),
          ),
          const SizedBox(height: 12),

          // Price
          _buildPriceRow(),
        ],
      ),
    );
  }

  Widget _buildClientRow() {
    final initials = _getInitials(widget.data.clientName ?? 'C');

    return Row(
      children: [
        // Avatar with animated ring
        Stack(
          alignment: Alignment.center,
          children: [
            // Animated ring
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: widget.data.isPremiumSubscriber
                      ? [
                          const Color(0xFFFFD700),
                          const Color(0xFFFFA500),
                          const Color(0xFFFFD700),
                          const Color(0xFFFFA500),
                        ]
                      : [
                          const Color(0xFF6366F1),
                          const Color(0xFF8B5CF6),
                          const Color(0xFFEC4899),
                          const Color(0xFF6366F1),
                        ],
                  transform: GradientRotation(_shimmerController.value * 6.28),
                ),
              ),
            ).animate(onPlay: (c) => c.repeat()).rotate(duration: 3.seconds),
            // Avatar content
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E1E2E),
                image: widget.data.clientPhotoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(widget.data.clientPhotoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.data.clientPhotoUrl == null
                  ? Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
            // VIP badge for premium subscribers
            if (widget.data.isPremiumSubscriber)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1E1E2E),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      widget.data.clientName ?? 'Cliente',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Premium badge
                  if (widget.data.isPremiumSubscriber) ...[
                    const SizedBox(width: 8),
                    Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.workspace_premium,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.data.subscriptionPlanName ?? 'VIP',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.05, 1.05),
                          duration: 1.seconds,
                        ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              // Client badges row
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  // New client badge
                  if (widget.data.isNewClient)
                    _buildSmallBadge(
                      icon: Icons.celebration,
                      text: 'Novo Cliente!',
                      color: const Color(0xFF10B981),
                    ),
                  // Returning after long time badge
                  if (widget.data.isReturningAfterLongTime)
                    _buildSmallBadge(
                      icon: Icons.waving_hand,
                      text: 'Retornando!',
                      color: const Color(0xFFF59E0B),
                    ),
                  // Total bookings badge
                  if (widget.data.totalBookings > 0)
                    _buildSmallBadge(
                      icon: Icons.history,
                      text: '${widget.data.totalBookings} agendamentos',
                      color: const Color(0xFF60A5FA),
                    ),
                  // Total spent badge
                  if (widget.data.totalSpent > 0)
                    _buildSmallBadge(
                      icon: Icons.attach_money,
                      text:
                          'R\$ ${widget.data.totalSpent.toStringAsFixed(0)} gasto',
                      color: const Color(0xFF8B5CF6),
                    ),
                ],
              ),
              if (widget.data.clientPhone != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.phone_rounded,
                      color: Colors.white.withOpacity(0.6),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.data.clientPhone!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a small info badge for client status
  Widget _buildSmallBadge({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              highlight
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: iconColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    )
                  : Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withOpacity(0.2),
            const Color(0xFF059669).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Valor Total',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Text(
                'R\$ ${widget.data.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
                duration: 1.seconds,
              ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Cancel Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleCancel,
                  icon: const Icon(Icons.cancel_outlined, size: 20),
                  label: const Text('Cancelar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Confirm Button
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleConfirm,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline, size: 20),
                    label: Text(_isLoading ? 'Processando...' : 'Confirmar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Quick Actions Row
          Row(
            children: [
              // WhatsApp Button
              if (widget.data.clientPhone != null)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF25D366).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _openWhatsApp,
                      icon: const Icon(Icons.chat, size: 18),
                      label: const Text('WhatsApp'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              if (widget.data.clientPhone != null) const SizedBox(width: 8),
              // View Details Button
              Expanded(
                child: TextButton.icon(
                  onPressed: widget.onViewDetails,
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('Ver Detalhes'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isLoading = false;

  /// Opens WhatsApp with the client's phone number
  Future<void> _openWhatsApp() async {
    if (widget.data.clientPhone == null) return;

    // Clean phone number (remove non-digits)
    final cleanPhone = widget.data.clientPhone!.replaceAll(RegExp(r'\D'), '');

    // Create message with booking details
    final serviceName =
        widget.data.serviceName ??
        (widget.data.serviceNames.isNotEmpty
            ? widget.data.serviceNames.join(', ')
            : 'serviço');
    final dateFormatted = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(widget.data.scheduledTime);

    final message = Uri.encodeComponent(
      'Olá ${widget.data.clientName ?? ""}! 👋\n\n'
      'Recebemos seu agendamento:\n'
      '📅 *${dateFormatted}*\n'
      '🚗 *${serviceName}*\n'
      '💰 *R\$ ${widget.data.totalPrice.toStringAsFixed(2)}*\n\n'
      'Estamos confirmando seu horário. Qualquer dúvida, estamos à disposição! 😊',
    );

    final url = Uri.parse('https://wa.me/$cleanPhone?text=$message');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        AppToast.error(context, message: 'Não foi possível abrir o WhatsApp');
      }
    }
  }

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      await ref
          .read(adminRepositoryProvider)
          .updateBookingStatus(
            widget.data.bookingId,
            BookingStatus.confirmed,
            actorId: user.uid,
            message: 'Confirmado via Notificação Rápida',
          );

      if (mounted) {
        AppToast.success(
          context,
          message: 'Agendamento confirmado com sucesso!',
        );
        widget.onDismiss();
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao confirmar: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCancel() async {
    final justification = await _showJustificationDialog();
    if (justification == null || justification.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      await ref
          .read(adminRepositoryProvider)
          .updateBookingStatus(
            widget.data.bookingId,
            BookingStatus.cancelled,
            actorId: user.uid,
            message: justification,
          );

      if (mounted) {
        AppToast.success(
          context,
          message: 'Agendamento cancelado com sucesso!',
        );
        widget.onDismiss();
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao cancelar: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _showJustificationDialog() {
    String justification = '';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text(
          'Cancelar Agendamento',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Por favor, informe o motivo do cancelamento (visível para o cliente):',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => justification = value,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ex: Imprevisto técnico, horário indisponível...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Voltar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, justification),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Confirmar Cancelamento',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'C';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  String _getVehicleText() {
    final parts = <String>[];
    if (widget.data.vehiclePlate != null) {
      parts.add(widget.data.vehiclePlate!);
    }
    if (widget.data.vehicleBrand != null || widget.data.vehicleModel != null) {
      final vehicleDesc = [
        widget.data.vehicleBrand,
        widget.data.vehicleModel,
      ].where((e) => e != null).join(' ');
      if (vehicleDesc.isNotEmpty) {
        parts.add(vehicleDesc);
      }
    }
    return parts.join(' • ');
  }

  String _getServiceText() {
    if (widget.data.serviceName != null) {
      return widget.data.serviceName!;
    }
    if (widget.data.serviceNames.isNotEmpty) {
      return widget.data.serviceNames.join(', ');
    }
    return 'Serviço';
  }

  String _getDateTimeText() {
    final date = widget.data.scheduledTime;
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    return '${dateFormat.format(date)} às ${timeFormat.format(date)}';
  }
}
