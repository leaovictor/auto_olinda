import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../shared/extensions/vehicle_category_extension.dart';
import '../../../profile/domain/vehicle.dart';
import '../../domain/usecases/check_vehicle_subscription_status_usecase.dart';
import '../../domain/vehicle_subscription_status.dart';
import '../../../subscription_plans/domain/usecases/get_vehicle_price_usecase.dart';

part 'booking_creation_provider.g.dart';

@riverpod
class BookingCreation extends _$BookingCreation {
  @override
  BookingCreationState build() {
    return const BookingCreationState();
  }

  Future<void> selectVehicle(Vehicle vehicle) async {
    state = state.copyWith(
      selectedVehicle: vehicle,
      isLoading: true,
      error: null,
    );

    try {
      // Check subscription status
      final status = await ref
          .read(checkVehicleSubscriptionStatusUseCaseProvider)
          .call(vehicle.id);

      state = state.copyWith(subscriptionStatus: status, isLoading: false);

      // Recalculate price if service is already selected
      if (state.selectedService != null) {
        await selectService(state.selectedService!);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> selectService(String serviceType) async {
    state = state.copyWith(selectedService: serviceType);

    if (state.selectedVehicle == null) return;

    if (state.subscriptionStatus.canUseSubscription) {
      // If using subscription, price is 0
      state = state.copyWith(calculatedPrice: 0);
      return;
    }

    try {
      final price = await ref
          .read(getVehiclePriceUseCaseProvider)
          .call(
            category: state.selectedVehicle!.category,
            serviceType: serviceType,
          );

      state = state.copyWith(calculatedPrice: price);
    } catch (e) {
      state = state.copyWith(error: 'Erro ao calcular preço: $e');
    }
  }
}

class BookingCreationState {
  final Vehicle? selectedVehicle;
  final String? selectedService;
  final VehicleSubscriptionStatus subscriptionStatus;
  final double? calculatedPrice;
  final bool isLoading;
  final String? error;

  const BookingCreationState({
    this.selectedVehicle,
    this.selectedService,
    this.subscriptionStatus =
        const VehicleSubscriptionStatus.requiresCashPayment(),
    this.calculatedPrice,
    this.isLoading = false,
    this.error,
  });

  BookingCreationState copyWith({
    Vehicle? selectedVehicle,
    String? selectedService,
    VehicleSubscriptionStatus? subscriptionStatus,
    double? calculatedPrice,
    bool? isLoading,
    String? error,
  }) {
    return BookingCreationState(
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      selectedService: selectedService ?? this.selectedService,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      calculatedPrice: calculatedPrice ?? this.calculatedPrice,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get canProceed => selectedVehicle != null && selectedService != null;
}
