import 'package:flutter_test/flutter_test.dart';
import 'package:open_meteo/open_meteo.dart';

void main() {
  test('Explore OpenMeteo API methods', () async {
    final location = OpenMeteoLocation(latitude: 0, longitude: 0);
    final api = WeatherApi();

    final result = await api.request(
      locations: {location},
      current: {
        WeatherCurrent.temperature_2m,
        WeatherCurrent.relative_humidity_2m,
        WeatherCurrent.is_day,
        WeatherCurrent.precipitation,
        WeatherCurrent.weather_code,
      },
    );

    expect(result.segments, isNotEmpty);
    final currentData = result.segments.first.currentData;
    expect(currentData, isNotNull);
    expect(currentData.containsKey(WeatherCurrent.temperature_2m), isTrue);
  });
}
