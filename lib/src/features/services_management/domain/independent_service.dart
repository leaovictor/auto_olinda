import 'package:freezed_annotation/freezed_annotation.dart';

part 'independent_service.freezed.dart';
part 'independent_service.g.dart';

/// Model for an independent service (e.g., insufilm application)
/// These services have their own calendar and availability, separate from car wash
@freezed
abstract class IndependentService with _$IndependentService {
  const factory IndependentService({
    required String id,
    required String title,
    required String description,
    required double price,
    required int durationMinutes,
    @Default('build') String iconName, // Material icon name
    @Default(true) bool isActive,
    @Default(false)
    bool requiresVehicle, // Some services might not need a vehicle
    String? imageUrl,
    DateTime? createdAt,
  }) = _IndependentService;

  factory IndependentService.fromJson(Map<String, dynamic> json) =>
      _$IndependentServiceFromJson(json);
}
