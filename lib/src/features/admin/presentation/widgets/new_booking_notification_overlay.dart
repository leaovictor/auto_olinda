import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../domain/new_booking_notification_data.dart';

/// Premium notification overlay widget that displays new booking information
/// with a stunning glassmorphic design, animations, and premium aesthetics
class NewBookingNotificationOverlay extends StatefulWidget {
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
  State<NewBookingNotificationOverlay> createState() =>
      _NewBookingNotificationOverlayState();
}

class _NewBookingNotificationOverlayState
    extends State<NewBookingNotificationOverlay>
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
                  colors: [
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
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.data.clientName ?? 'Cliente',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.data.clientPhone != null) ...[
                const SizedBox(height: 4),
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
      child: Row(
        children: [
          // Dismiss button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: widget.onDismiss,
              icon: const Icon(Icons.close_rounded),
              label: const Text('Dispensar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // View details button
          Expanded(
            flex: 2,
            child:
                Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: widget.onViewDetails,
                        icon: const Icon(Icons.visibility_rounded),
                        label: const Text('Ver Detalhes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.02, 1.02),
                      duration: 1.5.seconds,
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
