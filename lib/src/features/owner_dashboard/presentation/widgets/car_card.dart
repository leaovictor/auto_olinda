import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/auth/data/auth_repository.dart';
import '../../../../features/booking/data/booking_repository.dart';
import '../../../../features/booking/data/vehicle_repository.dart';
import '../../../../features/profile/domain/vehicle.dart';
import '../../../../shared/utils/app_toast.dart';
import '../../../../shared/widgets/async_loader.dart';
import '../../../../features/subscription/domain/subscriber.dart';
import 'edit_vehicle_bottom_sheet.dart';
import '../../../../shared/extensions/vehicle_category_extension.dart';

enum _CarMenuAction { edit, schedule, history, delete }

class CarCard extends ConsumerWidget {
  final Vehicle vehicle;
  final Subscriber? subscription; // Added
  final VoidCallback? onTap;

  const CarCard({
    super.key,
    required this.vehicle,
    this.subscription,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).value;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        height: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          // Deep dark blue-black background
          gradient: const LinearGradient(
            colors: [Color(0xFF0A1628), Color(0xFF1A2332), Color(0xFF0F1922)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: const Color(0xFF1E3A5F).withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Frosted glass overlay (glassmorphism)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.02),
                        Colors.blue.shade900.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
              ),

              // Premium gold border for premium users
              if (subscription != null && subscription!.isActive)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        width: 1,
                        color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),

              // Vehicle Image
              Positioned(
                right: -10,
                bottom: 10,
                child: Opacity(
                  opacity: 0.9,
                  child: Image.asset(
                    vehicle.category.assetPath,
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Metal plate + Menu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Metal-look plate badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF4A5568),
                                const Color(0xFF2D3748),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF718096),
                              width: 0.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            vehicle.plate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              letterSpacing: 1.5,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        _buildPopupMenu(context, ref),
                      ],
                    ),

                    const Spacer(),

                    // Car info section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand
                        Text(
                          vehicle.brand.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Model - Large and bold
                        Text(
                          vehicle.model,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Bottom row: Info badges + Premium seal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Info badges
                        Flexible(
                          child: Row(
                            children: [
                              _buildInfoBadge(
                                Icons.palette_outlined,
                                vehicle.color,
                              ),
                              const SizedBox(width: 6),

                              // Wash status
                              Flexible(
                                child: ref
                                    .watch(
                                      lastVehicleBookingProvider((
                                        vehicle.id,
                                        user?.uid ?? '',
                                      )),
                                    )
                                    .when(
                                      data: (booking) {
                                        String statusText;
                                        Color statusColor;
                                        IconData statusIcon;

                                        if (booking == null) {
                                          statusText = 'Sujo';
                                          statusColor = const Color(0xFFFF6B6B);
                                          statusIcon = Icons.water_drop;
                                        } else {
                                          final daysSinceWash = DateTime.now()
                                              .difference(booking.scheduledTime)
                                              .inDays;

                                          if (daysSinceWash <= 2) {
                                            statusText = 'Limpo';
                                            statusColor = const Color(
                                              0xFF51CF66,
                                            );
                                            statusIcon = Icons.check_circle;
                                          } else if (daysSinceWash <= 4) {
                                            statusText = 'Ok';
                                            statusColor = const Color(
                                              0xFFFFD93D,
                                            );
                                            statusIcon = Icons.schedule;
                                          } else {
                                            statusText = 'Sujo';
                                            statusColor = const Color(
                                              0xFFFF6B6B,
                                            );
                                            statusIcon = Icons.water_drop;
                                          }
                                        }

                                        return _buildInfoBadge(
                                          statusIcon,
                                          statusText,
                                          color: statusColor,
                                        );
                                      },
                                      loading: () => _buildInfoBadge(
                                        Icons.hourglass_empty,
                                        '...',
                                      ),
                                      error: (_, __) => const SizedBox.shrink(),
                                    ),
                              ),
                            ],
                          ),
                        ),

                        // Premium gold seal (bottom right)
                        if (subscription != null && subscription!.isActive)
                          _buildPremiumSeal(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumSeal() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFC107)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.verified, color: Color(0xFF1A1A1A), size: 14),
          SizedBox(width: 4),
          Text(
            'PREMIUM',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w900,
              fontSize: 9,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return PopupMenuButton<_CarMenuAction>(
      icon: Icon(Icons.more_horiz, color: Colors.white.withValues(alpha: 0.9)),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.surfaceContainer,
      elevation: 8,
      onSelected: (action) => _handleMenuAction(context, ref, action),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _CarMenuAction.schedule,
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              const Text('Agendar lavagem'),
            ],
          ),
        ),
        PopupMenuItem(
          value: _CarMenuAction.history,
          child: Row(
            children: [
              Icon(
                Icons.history,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              const Text('Histórico de lavagens'),
            ],
          ),
        ),
        PopupMenuItem(
          value: _CarMenuAction.edit,
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              const Text('Editar veículo'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: _CarMenuAction.delete,
          enabled: !vehicle.isSubscriptionVehicle,
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                size: 20,
                color: vehicle.isSubscriptionVehicle
                    ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)
                    : theme.colorScheme.error,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remover veículo',
                      style: TextStyle(
                        color: vehicle.isSubscriptionVehicle
                            ? theme.colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.3,
                              )
                            : theme.colorScheme.error,
                      ),
                    ),
                    if (vehicle.isSubscriptionVehicle)
                      Text(
                        'Veículo vinculado à assinatura',
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    _CarMenuAction action,
  ) {
    switch (action) {
      case _CarMenuAction.schedule:
        // Navigate to booking with this vehicle pre-selected
        context.push('/booking', extra: {'vehicleId': vehicle.id});
        break;

      case _CarMenuAction.history:
        context.push('/vehicle-history', extra: vehicle);
        break;

      case _CarMenuAction.edit:
        EditVehicleBottomSheet.show(context, vehicle);
        break;

      case _CarMenuAction.delete:
        _showDeleteConfirmation(context, ref);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Extra safety check - should never be called for subscription vehicles
    if (vehicle.isSubscriptionVehicle) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              const Text('Veículo Premium'),
            ],
          ),
          content: const Text(
            'Este veículo está vinculado à sua assinatura premium e não pode ser removido.\n\n'
            'Para remover este veículo, primeiro cancele sua assinatura ou vincule outro veículo.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendi'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
            const SizedBox(width: 12),
            const Text('Remover veículo'),
          ],
        ),
        content: Text(
          'Tem certeza que deseja remover o ${vehicle.brand} ${vehicle.model} (${vehicle.plate})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context); // Close confirmation dialog
              try {
                // Wrap deletion with AsyncLoader
                await AsyncLoader.show(
                  context,
                  future: ref
                      .read(vehicleRepositoryProvider)
                      .deleteVehicle(vehicle.id),
                  message: 'Removendo veículo...',
                );

                if (context.mounted) {
                  AppToast.success(
                    context,
                    message: 'Veículo removido com sucesso!',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  AppToast.error(
                    context,
                    message: 'Erro ao remover veículo: $e',
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String label, {Color? color}) {
    final badgeColor = color ?? Colors.white.withValues(alpha: 0.9);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
