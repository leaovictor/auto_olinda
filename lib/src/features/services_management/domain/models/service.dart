import 'package:freezed_annotation/freezed_annotation.dart';

part 'service.freezed.dart';
part 'service.g.dart';

@freezed
abstract class Service with _$Service {
  const factory Service({
    required String id,
    required String tenantId,
    required String name,
    String? description,
    String? category, // 'wash' | 'polish' | 'detailing' | 'maintenance'
    required double price,
    double? discountedPrice,
    @Default(30) int durationMinutes,
    String? imageUrl,
    @Default(true) bool isActive,
    @Default(0) int sortOrder,
    @Default([]) List<String> tags, // quick wash, premium, eco-friendly
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Service;

  factory Service.fromJson(Map<String, dynamic> json) => _$ServiceFromJson(json);
}
