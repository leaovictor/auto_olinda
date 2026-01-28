import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../shared/enums/vehicle_category.dart';
import '../../domain/pricing_matrix.dart';
import '../../data/pricing_repository.dart';

part 'get_vehicle_price_usecase.g.dart';

class GetVehiclePriceUseCase {
  final PricingRepository _pricingRepository;

  GetVehiclePriceUseCase(this._pricingRepository);

  Future<double> call({
    required VehicleCategory category,
    required String serviceType,
  }) async {
    final pricingMatrix = await _pricingRepository.getPricingMatrix();
    // Using extension method from PricingMatrixExtensions
    final price = pricingMatrix.getPriceForService(category, serviceType);

    if (price == null) {
      throw Exception(
        'Price not found for category ${category.displayName} and service $serviceType',
      );
    }

    return price;
  }
}

@riverpod
GetVehiclePriceUseCase getVehiclePriceUseCase(Ref ref) {
  return GetVehiclePriceUseCase(ref.watch(pricingRepositoryProvider));
}
