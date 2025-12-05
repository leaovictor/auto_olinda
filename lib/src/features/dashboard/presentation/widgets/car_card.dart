import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/booking/data/booking_repository.dart';
import '../../../../features/profile/domain/vehicle.dart';

class CarCard extends ConsumerWidget {
  final Vehicle vehicle;
  final VoidCallback? onTap;

  const CarCard({super.key, required this.vehicle, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Using a specific dark gradient for the car card to make it pop, regardless of theme
    // but using theme tokens for consistency where possible.

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
            // Background Decoration
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.directions_car,
                size: 150,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                      Icon(
                        Icons.more_horiz,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                  const Spacer(),
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
                      ref
                          .watch(lastVehicleBookingProvider(vehicle.id))
                          .when(
                            data: (booking) {
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
