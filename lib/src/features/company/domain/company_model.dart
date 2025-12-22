import 'package:aquaclean_mobile/src/features/auth/domain/address.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'company_model.freezed.dart';
part 'company_model.g.dart';

@freezed
abstract class Company with _$Company {
  const factory Company({
    required String id,
    required String name,
    required String ownerId,
    String? logoUrl,
    String? primaryColor,
    Address? address,
    @JsonKey(fromJson: _geoPointFromJson, toJson: _geoPointToJson)
    Object?
    geoPoint, // GeoPoint or Map depending on context, using Object to be safe
    @Default(true) bool isActive,
    @Default([]) List<String> categories, // e.g., 'lava-jato', 'estetica'
    @Default(0.0) double rating,
    @Default(0) int reviewCount,
    @Default('09:00 - 18:00') String openingHours,
  }) = _Company;

  factory Company.fromJson(Map<String, dynamic> json) =>
      _$CompanyFromJson(json);
}

// Helpers for GeoPoint serialization
GeoPoint? _geoPointFromJson(Object? json) {
  if (json is GeoPoint) return json;
  if (json is Map<String, dynamic>) {
    return GeoPoint(
      (json['latitude'] as num).toDouble(),
      (json['longitude'] as num).toDouble(),
    );
  }
  return null;
}

Object? _geoPointToJson(Object? geoPoint) {
  if (geoPoint is GeoPoint) {
    return {'latitude': geoPoint.latitude, 'longitude': geoPoint.longitude};
  }
  return geoPoint;
}
