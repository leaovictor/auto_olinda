import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather.freezed.dart';
part 'weather.g.dart';

@freezed
abstract class Weather with _$Weather {
  const factory Weather({
    required double temperature,
    required int relativeHumidity,
    required bool isDay,
    required double precipitation,
    required int weatherCode,
  }) = _Weather;

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);
}
