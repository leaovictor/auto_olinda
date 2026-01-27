import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'routes_service.g.dart';

class RouteData {
  final List<LatLng> points;
  final double distanceKm;
  final double durationMinutes;

  RouteData({
    required this.points,
    required this.distanceKm,
    required this.durationMinutes,
  });
}

class RoutesService {
  // TODO: Move this to a secure storage or environment variable
  final String _apiKey = 'AIzaSyBI6Cs2q9-Kmby3SQRHJ0dQYAcAWtm4xUE';
  final String _baseUrl =
      'https://routes.googleapis.com/directions/v2:computeRoutes';

  Future<RouteData?> getRoute(LatLng origin, LatLng destination) async {
    // Check for empty key
    if (_apiKey.isEmpty || _apiKey == 'YOUR_GOOGLE_ROUTES_API_KEY') {
      // print('⚠️ Google Routes API Key not set. Returning straight line route.');
      return RouteData(
        points: [origin, destination],
        distanceKm: 0,
        durationMinutes: 0,
      );
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _apiKey,
          'X-Goog-FieldMask':
              'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
        },
        body: jsonEncode({
          'origin': {
            'location': {
              'latLng': {
                'latitude': origin.latitude,
                'longitude': origin.longitude,
              },
            },
          },
          'destination': {
            'location': {
              'latLng': {
                'latitude': destination.latitude,
                'longitude': destination.longitude,
              },
            },
          },
          'travelMode': 'DRIVE',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final encodedPolyline = route['polyline']['encodedPolyline'];
          final distanceMeters = route['distanceMeters'];
          final durationString = route['duration']; // e.g., "1234s"

          // Simple decoding for now, or use a package if needed.
          // Since I don't have a decoder handy, I'll just use straight line for fallback
          // or rely on a package like `flutter_polyline_points` if I had it.
          // For now, let's assume valid polyline decoding is needed.
          // I will implement a simple polyline decoder.

          final points = PolylinePoints()
              .decodePolyline(encodedPolyline)
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList();

          final distanceKm = (distanceMeters as int) / 1000.0;
          final durationSeconds =
              int.tryParse(durationString.replaceAll('s', '')) ?? 0;
          final durationMinutes = durationSeconds / 60.0;

          return RouteData(
            points: points,
            distanceKm: distanceKm,
            durationMinutes: durationMinutes,
          );
        }
      } else {
        // print(
        //   'Error fetching route: ${response.statusCode} - ${response.body}',
        // );
      }
    } catch (e) {
      // print('Exception fetching route: $e');
    }
    return null;
  }
}

@riverpod
RoutesService routesService(RoutesServiceRef ref) {
  return RoutesService();
}
