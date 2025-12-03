import 'package:freezed_annotation/freezed_annotation.dart';

part 'service.freezed.dart';
part 'service.g.dart';

/// Represents a one-time service available for booking
@freezed
abstract class Service with _$Service {
  const factory Service({
    required String id,
    required String name,
    required String description,
    required double price,
    String? imageUrl,
    required Duration estimatedDuration,
    @Default(true) bool isActive,
    required List<String> features,
    String? stripeProductId,
    String? stripePriceId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Service;

  factory Service.fromJson(Map<String, dynamic> json) =>
      _$ServiceFromJson(json);
}

/// Custom JSON converter for Duration
class DurationConverter implements JsonConverter<Duration, int> {
  const DurationConverter();

  @override
  Duration fromJson(int json) => Duration(minutes: json);

  @override
  int toJson(Duration object) => object.inMinutes;
}
