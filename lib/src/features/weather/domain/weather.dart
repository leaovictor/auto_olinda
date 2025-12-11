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
    @Default([]) List<DailyWeather> dailyForecast,
  }) = _Weather;

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);
}

@freezed
abstract class DailyWeather with _$DailyWeather {
  const factory DailyWeather({
    required DateTime date,
    required double maxTemp,
    required double minTemp,
    required int precipitationProbability,
    required int weatherCode,
  }) = _DailyWeather;

  factory DailyWeather.fromJson(Map<String, dynamic> json) =>
      _$DailyWeatherFromJson(json);
}
