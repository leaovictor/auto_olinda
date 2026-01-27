import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'location_service.g.dart';

class LocationService {
  /// Check if location services are available on the device/browser
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      // print('LocationService: isLocationServiceEnabled error: $e');
      // On web, this might throw. Assume enabled if error occurs.
      return true;
    }
  }

  /// Check and request location permissions
  Future<bool> checkPermission() async {
    try {
      // First check if service is enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled && !kIsWeb) {
        // print('LocationService: Location services are disabled');
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      // print('LocationService: Current permission status: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        // print('LocationService: Permission after request: $permission');

        if (permission == LocationPermission.denied) {
          // print('LocationService: Permission denied by user');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // print('LocationService: Permission denied forever');
        return false;
      }

      return true;
    } catch (e) {
      // On some platforms/web configurations, checkPermission might fail.
      // In that case, we return true to let getCurrentPosition try (it triggers permission prompt on web).
      // print('LocationService: checkPermission error: $e');
      return kIsWeb; // Return true only for web, false for other platforms
    }
  }

  /// Get the current location
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        // print('LocationService: No permission to access location');
        return null;
      }

      // print('LocationService: Requesting current position...');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        ),
      );

      // print(
      //   'LocationService: Got position: ${position.latitude}, ${position.longitude}',
      // );
      return position;
    } catch (e) {
      // print('LocationService: getCurrentPosition error: $e');
      if (kIsWeb) {
        // print('LocationService: Make sure you are using HTTPS or localhost');
        // print('LocationService: Check browser console for permission errors');
      }
      return null;
    }
  }

  /// Stream of position updates
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).handleError((error) {
      // print('LocationService: getPositionStream error: $error');
      if (kIsWeb) {
        // print(
        //   'LocationService: Ensure HTTPS is being used for geolocation to work',
        // );
      }
    });
  }
}

@riverpod
LocationService locationService(LocationServiceRef ref) {
  return LocationService();
}

@riverpod
Stream<Position> userLocationStream(UserLocationStreamRef ref) {
  final service = ref.watch(locationServiceProvider);
  return service.getPositionStream();
}
