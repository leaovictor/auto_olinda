import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

@freezed
abstract class Customer with _$Customer {
  const factory Customer({
    required String id,
    required String tenantId,
    required String name,
    String? email,
    String? phone,
    String? whatsapp,
    String? cpf,
    String? cnpj,
    @Default('active') String status, // active | inactive | blocked
    @Default([]) List<CustomerVehicle> vehicles,
    DateTime? firstVisitAt,
    DateTime? lastVisitAt,
    @Default(0) int visitCount,
    @Default(0.0) double lifetimeValue,
    @Default([]) List<String> activeSubscriptionIds,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);
}

@freezed
abstract class CustomerVehicle with _$CustomerVehicle {
  const factory CustomerVehicle({
    required String id,
    required String customerId,
    required String brand,
    required String model,
    required String plate,
    String? color,
    String? vehicleType, // hatch | sedan | suv | moto | pickup
    String? imageUrl,
    @Default(0) int visitCount,
    DateTime? addedAt,
  }) = _CustomerVehicle;

  factory CustomerVehicle.fromJson(Map<String, dynamic> json) => _$CustomerVehicleFromJson(json);
}
