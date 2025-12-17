import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_availability.freezed.dart';
part 'service_availability.g.dart';

/// Model for service availability on a specific date
/// Each service can have independent availability settings per day
@freezed
abstract class ServiceAvailability with _$ServiceAvailability {
  const factory ServiceAvailability({
    required String date, // YYYY-MM-DD
    required String serviceId, // Which independent service
    required bool isOpen,
    required Map<String, int> slots, // "09:00" -> 2 (number of available slots)
  }) = _ServiceAvailability;

  factory ServiceAvailability.fromJson(Map<String, dynamic> json) =>
      _$ServiceAvailabilityFromJson(json);
}
