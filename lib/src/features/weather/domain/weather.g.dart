// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Weather _$WeatherFromJson(Map<String, dynamic> json) => _Weather(
  temperature: (json['temperature'] as num).toDouble(),
  relativeHumidity: (json['relativeHumidity'] as num).toInt(),
  isDay: json['isDay'] as bool,
  precipitation: (json['precipitation'] as num).toDouble(),
  weatherCode: (json['weatherCode'] as num).toInt(),
  dailyForecast:
      (json['dailyForecast'] as List<dynamic>?)
          ?.map((e) => DailyWeather.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$WeatherToJson(_Weather instance) => <String, dynamic>{
  'temperature': instance.temperature,
  'relativeHumidity': instance.relativeHumidity,
  'isDay': instance.isDay,
  'precipitation': instance.precipitation,
  'weatherCode': instance.weatherCode,
  'dailyForecast': instance.dailyForecast.map((e) => e.toJson()).toList(),
};

_DailyWeather _$DailyWeatherFromJson(Map<String, dynamic> json) =>
    _DailyWeather(
      date: DateTime.parse(json['date'] as String),
      maxTemp: (json['maxTemp'] as num).toDouble(),
      minTemp: (json['minTemp'] as num).toDouble(),
      precipitationProbability: (json['precipitationProbability'] as num)
          .toInt(),
      weatherCode: (json['weatherCode'] as num).toInt(),
    );

Map<String, dynamic> _$DailyWeatherToJson(_DailyWeather instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'maxTemp': instance.maxTemp,
      'minTemp': instance.minTemp,
      'precipitationProbability': instance.precipitationProbability,
      'weatherCode': instance.weatherCode,
    };
