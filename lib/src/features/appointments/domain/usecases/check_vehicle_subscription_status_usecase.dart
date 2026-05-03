import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/vehicle_repository.dart';
import '../../../subscription_plans/data/subscription_repository.dart';
import '../../../subscription_plans/domain/subscriber.dart';
import '../vehicle_subscription_status.dart';

part 'check_vehicle_subscription_status_usecase.g.dart';

class CheckVehicleSubscriptionStatusUseCase {
  final VehicleRepository _vehicleRepository;
  final SubscriptionRepository _subscriptionRepository;

  CheckVehicleSubscriptionStatusUseCase(
    this._vehicleRepository,
    this._subscriptionRepository,
  );

  Future<VehicleSubscriptionStatus> call(
    String vehicleId, {
    String? userId,
  }) async {
    final vehicle = await _vehicleRepository.getVehicleById(vehicleId);

    if (vehicle == null) {
      return const VehicleSubscriptionStatus.requiresCashPayment();
    }

    try {
      Subscriber? subscription;

      if (vehicle.linkedSubscriptionId != null) {
        // Primary lookup: via the stored subscription ID
        subscription = await _subscriptionRepository.getSubscriptionById(
          vehicle.linkedSubscriptionId!,
        );
      }

      // Fallback: if no linked ID, search by UID + plate (survives vehicle deletion)
      if (subscription == null && userId != null && vehicle.plate.isNotEmpty) {
        subscription = await _subscriptionRepository
            .checkExistingSubscriptionByPlate(userId, vehicle.plate);
      }

      if (subscription == null) {
        return const VehicleSubscriptionStatus.requiresCashPayment();
      }

      if (subscription.status != 'active' &&
          subscription.status != 'trialing') {
        return const VehicleSubscriptionStatus.subscriptionInactive();
      }

      return const VehicleSubscriptionStatus.canUseSubscription(
        remainingWashes: 4,
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
