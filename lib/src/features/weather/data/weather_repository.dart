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
      );
    } catch (e) {
      throw Exception('Error fetching weather: $e');
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
