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
);

Map<String, dynamic> _$WeatherToJson(_Weather instance) => <String, dynamic>{
  'temperature': instance.temperature,
  'relativeHumidity': instance.relativeHumidity,
  'isDay': instance.isDay,
  'precipitation': instance.precipitation,
  'weatherCode': instance.weatherCode,
};
