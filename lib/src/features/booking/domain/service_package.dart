import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_package.freezed.dart';
part 'service_package.g.dart';

@freezed
abstract class ServicePackage with _$ServicePackage {
  const factory ServicePackage({
    required String id,
    required String title,
    required String description,
    required double price,
    required int durationMinutes,

    String? iconUrl,
    @Default(false) bool isPopular,
    @Default([]) List<String> steps, // Custom wash steps defined by admin
  }) = _ServicePackage;

  factory ServicePackage.fromJson(Map<String, dynamic> json) =>
      _$ServicePackageFromJson(json);
}
