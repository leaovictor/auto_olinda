import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  // Coordinates for Olinda/Jardim Atlântico as seen in logs
  final lat = -7.9774;
  final lng = -34.84;

  final url = Uri.parse(
    'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&current=temperature_2m,weather_code,is_day&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=America%2FSao_Paulo',
  );

  print('Fetching: $url');

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      print('\n--- CURRENT ---');
      print(data['current']);

      print('\n--- DAILY ---');
      final daily = data['daily'];
      final times = daily['time'] as List;
      final codes = daily['weather_code'] as List;
      final maxTemps = daily['temperature_2m_max'] as List;

      for (var i = 0; i < times.length; i++) {
        print(
          'Date: ${times[i]} | Code: ${codes[i]} | MaxTemp: ${maxTemps[i]}',
        );
      }
    } else {
      print('Error: ${response.statusCode}');
      print(response.body);
    }
  } catch (e) {
    print('Exception: $e');
  }
}
