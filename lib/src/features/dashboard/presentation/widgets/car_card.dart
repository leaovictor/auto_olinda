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
    final theme = Theme.of(context);
    final user = ref.watch(authStateChangesProvider).value;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.secondary, theme.colorScheme.tertiary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // ... (existing background)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status Badge (Premium vs Subscribe) - Replaces Plate? or next to it?
                      // Let's keep Plate.
                      // Maybe put Status Badge on the RIGHT, move Menu to...
                      // actually Menu is valuable.
                      // Let's put Status Badge BELOW Plate? Or separate row.
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          vehicle.plate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      _buildPopupMenu(context, ref),
                    ],
                  ),

                  // New Subscription Status Row
                  const SizedBox(height: 12),
                  if (subscription != null && subscription!.isActive)
                    _buildPremiumBadge()
                  else
                    _buildSubscribeButton(context),

                  const Spacer(),
                  // ... (existing brand/model)
                  Text(
                    vehicle.brand,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicle.model,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoBadge(Icons.palette_outlined, vehicle.color),
                      const SizedBox(width: 8),
                      // ... (existing wash status logic)
                      ref
                          .watch(
                            lastVehicleBookingProvider((
                              vehicle.id,
                              user?.uid ?? '',
                            )),
                          )
                          .when(
                            data: (booking) {
                              // ... (existing status text logic)
                              String statusText;
                              Color statusColor;
                              IconData statusIcon;

                              if (booking == null) {
                                statusText = 'Sujo';
                                statusColor = Colors.red;
                                statusIcon = Icons.warning_amber_rounded;
                              } else {
                                final daysSinceWash = DateTime.now()
                                    .difference(booking.scheduledTime)
                                    .inDays;

                                if (daysSinceWash <= 2) {
                                  statusText = 'Limpo';
                                  statusColor = Colors.green;
                                  statusIcon = Icons.check_circle_outline;
                                } else if (daysSinceWash <= 4) {
                                  statusText = 'Meio Sujo';
                                  statusColor = Colors.amber;
                                  statusIcon = Icons.access_time;
                                } else {
                                  statusText = 'Sujo';
                                  statusColor = Colors.red;
                                  statusIcon = Icons.warning_amber_rounded;
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
                              'Verificando...',
                            ),
                            error: (_, __) => _buildInfoBadge(
                              Icons.error_outline,
                              'Erro',
                              color: Colors.red,
                            ),
                          ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withValues(alpha: 0.2), // Gold
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 14),
          SizedBox(width: 4),
          Text(
            "PREMIUM",
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.push('/plans', extra: vehicle),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E3A8A), // Deep Blue
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Assinar',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 4),
            Icon(Icons.arrow_forward_ios, size: 12),
          ],
        ),
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
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                size: 20,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 12),
              Text(
                'Remover veículo',
                style: TextStyle(color: theme.colorScheme.error),
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
    final badgeColor = color ?? Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
