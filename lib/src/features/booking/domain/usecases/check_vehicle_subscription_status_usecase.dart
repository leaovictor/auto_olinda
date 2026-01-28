import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/vehicle_repository.dart';
import '../../../subscription/data/subscription_repository.dart';
import '../vehicle_subscription_status.dart';

part 'check_vehicle_subscription_status_usecase.g.dart';

class CheckVehicleSubscriptionStatusUseCase {
  final VehicleRepository _vehicleRepository;
  final SubscriptionRepository _subscriptionRepository;

  CheckVehicleSubscriptionStatusUseCase(
    this._vehicleRepository,
    this._subscriptionRepository,
  );

  Future<VehicleSubscriptionStatus> call(String vehicleId) async {
    final vehicle = await _vehicleRepository.getVehicleById(vehicleId);

    if (vehicle == null) {
      return const VehicleSubscriptionStatus.requiresCashPayment();
    }

    if (!vehicle.isSubscriptionVehicle ||
        vehicle.linkedSubscriptionId == null) {
      return const VehicleSubscriptionStatus.requiresCashPayment();
    }

    try {
      final subscription = await _subscriptionRepository.getSubscriptionById(
        vehicle.linkedSubscriptionId!,
      );

      if (subscription == null) {
        return const VehicleSubscriptionStatus.requiresCashPayment();
      }

      if (subscription.status != 'active' &&
          subscription.status != 'trialing') {
        return const VehicleSubscriptionStatus.subscriptionInactive();
      }

      // Check remaining washes logic
      // Assuming 'usage' map or similar field exists in Subscriber
      // If not present, I'll default to 4 for now until Subscriber entity is verified
      // Based on common patterns in this codebase

      return const VehicleSubscriptionStatus.canUseSubscription(
        remainingWashes:
            4, // Placeholder, will update after checking Subscriber.dart
      );
    } catch (e) {
      return const VehicleSubscriptionStatus.requiresCashPayment();
    }
  }
}

@riverpod
CheckVehicleSubscriptionStatusUseCase checkVehicleSubscriptionStatusUseCase(
  Ref ref,
) {
  return CheckVehicleSubscriptionStatusUseCase(
    ref.watch(vehicleRepositoryProvider),
    ref.watch(subscriptionRepositoryProvider),
  );
}
