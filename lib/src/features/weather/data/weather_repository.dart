import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_meteo/open_meteo.dart';
import '../domain/weather.dart';

class WeatherRepository {
  // Coordinates for Avenida Fagundes Varela, Jardim Atlântico, Olinda
  static const double _latitude = -7.9774;
  static const double _longitude = -34.8416;

  final _weatherApi = WeatherApi();

  Future<Weather> fetchCurrentWeather() async {
    try {
      final result = await _weatherApi.request(
        locations: {
          OpenMeteoLocation(latitude: _latitude, longitude: _longitude),
        },
        current: {
          WeatherCurrent.temperature_2m,
          WeatherCurrent.relative_humidity_2m,
          WeatherCurrent.is_day,
          WeatherCurrent.precipitation,
          WeatherCurrent.weather_code,
        },
        daily: {
          WeatherDaily.weather_code,
          WeatherDaily.temperature_2m_max,
          WeatherDaily.temperature_2m_min,
          WeatherDaily.precipitation_probability_max,
        },
      );

      if (result.segments.isEmpty) {
        throw Exception('No weather data available');
      }

      final currentData = result.segments.first.currentData;

      return Weather(
        temperature: currentData[WeatherCurrent.temperature_2m]?.value ?? 0.0,
        relativeHumidity:
            currentData[WeatherCurrent.relative_humidity_2m]?.value.toInt() ??
            0,
        isDay: currentData[WeatherCurrent.is_day]?.value == 1.0,
        precipitation: currentData[WeatherCurrent.precipitation]?.value ?? 0.0,
        weatherCode:
            currentData[WeatherCurrent.weather_code]?.value.toInt() ?? 0,
        dailyForecast: _mapDailyForecast(result.segments.first.dailyData),
      );
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  List<DailyWeather> _mapDailyForecast(Map dailyData) {
    if (dailyData.isEmpty) return [];

    try {
      // Helper to get the inner map values (date -> value)
      // The API returns ParameterValues object which has a 'values' property that is a Map<String/DateTime, dynamic>
      Map<dynamic, dynamic> getValuesMap(dynamic key) {
        final paramValues = dailyData[key] as dynamic;
        if (paramValues == null) return {};
        // Access .values property which seems to be the Map
        return paramValues.values as Map<dynamic, dynamic>? ?? {};
      }

      final weatherCodesMap = getValuesMap(WeatherDaily.weather_code);
      final maxTempsMap = getValuesMap(WeatherDaily.temperature_2m_max);
      final minTempsMap = getValuesMap(WeatherDaily.temperature_2m_min);
      final precipProbsMap = getValuesMap(
        WeatherDaily.precipitation_probability_max,
      );

      // Use keys from one of the maps as timestamps (assuming they are consistent)
      // They seem to be ordered.
      final dates = maxTempsMap.keys.toList();

      final List<DailyWeather> forecast = [];

      for (var i = 0; i < dates.length && i < 5; i++) {
        final dateKey = dates[i];

        // Parse date if it's a String, otherwise cast
        DateTime date;
        if (dateKey is String) {
          date = DateTime.parse(dateKey);
        } else if (dateKey is DateTime) {
          date = dateKey;
        } else {
          date = DateTime.now().add(Duration(days: i));
        }

        forecast.add(
          DailyWeather(
            date: date,
            maxTemp: (maxTempsMap[dateKey] as num?)?.toDouble() ?? 0.0,
            minTemp: (minTempsMap[dateKey] as num?)?.toDouble() ?? 0.0,
            precipitationProbability:
                (precipProbsMap[dateKey] as num?)?.toInt() ?? 0,
            weatherCode: (weatherCodesMap[dateKey] as num?)?.toInt() ?? 0,
          ),
        );
      }
      return forecast;
    } catch (e) {
      print('Error parsing daily forecast: $e');
      return [];
    }
  }
}

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository();
});

final currentWeatherProvider = FutureProvider<Weather>((ref) async {
  final repository = ref.watch(weatherRepositoryProvider);
  return repository.fetchCurrentWeather();
});
