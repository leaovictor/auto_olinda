import 'package:flutter/material.dart';

/// Weather theme data for use across the app
class WeatherTheme {
  final LinearGradient gradient;
  final Color primaryColor;
  final Color textColor;

  const WeatherTheme({
    required this.gradient,
    required this.primaryColor,
    this.textColor = Colors.white,
  });

  /// Get weather theme from WMO weather code
  static WeatherTheme fromCode(int code, bool isDay) {
    // Clear sky or Mainly clear
    if (code == 0 || code == 1) {
      if (isDay) {
        return const WeatherTheme(
          gradient: LinearGradient(
            colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          primaryColor: Color(0xFF2F80ED),
        );
      } else {
        return const WeatherTheme(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          primaryColor: Color(0xFF2C5364),
        );
      }
    }
    // Partly cloudy
    else if (code == 2) {
      if (isDay) {
        return const WeatherTheme(
          gradient: LinearGradient(
            colors: [Color(0xFF89CFF0), Color(0xFF6BB3D9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          primaryColor: Color(0xFF6BB3D9),
        );
      } else {
        return const WeatherTheme(
          gradient: LinearGradient(
            colors: [Color(0xFF232526), Color(0xFF414345)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          primaryColor: Color(0xFF414345),
        );
      }
    }
    // Overcast
    else if (code == 3) {
      if (isDay) {
        return const WeatherTheme(
          gradient: LinearGradient(
            colors: [Color(0xFF757F9A), Color(0xFFD7DDE8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          primaryColor: Color(0xFF757F9A),
        );
      } else {
        return const WeatherTheme(
          gradient: LinearGradient(
            colors: [Color(0xFF232526), Color(0xFF414345)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          primaryColor: Color(0xFF414345),
        );
      }
    }
    // Fog
    else if (code >= 45 && code <= 48) {
      return const WeatherTheme(
        gradient: LinearGradient(
          colors: [Color(0xFFB0BEC5), Color(0xFF78909C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        primaryColor: Color(0xFF78909C),
      );
    }
    // Drizzle
    else if (code >= 51 && code <= 57) {
      return WeatherTheme(
        gradient: LinearGradient(
          colors: isDay
              ? [const Color(0xFF616161), const Color(0xFF9BC5C3)]
              : [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        primaryColor: const Color(0xFF616161),
      );
    }
    // Rain
    else if (code >= 61 && code <= 67) {
      return WeatherTheme(
        gradient: LinearGradient(
          colors: isDay
              ? [const Color(0xFF4B6584), const Color(0xFF778899)]
              : [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        primaryColor: const Color(0xFF4B6584),
      );
    }
    // Snow
    else if (code >= 71 && code <= 77) {
      return const WeatherTheme(
        gradient: LinearGradient(
          colors: [Color(0xFFE0E5EC), Color(0xFFB0C4DE)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        primaryColor: Color(0xFFB0C4DE),
      );
    }
    // Rain showers
    else if (code >= 80 && code <= 82) {
      return const WeatherTheme(
        gradient: LinearGradient(
          colors: [Color(0xFF667db6), Color(0xFF0082c8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        primaryColor: Color(0xFF0082c8),
      );
    }
    // Thunderstorm
    else if (code >= 95) {
      return const WeatherTheme(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF4A235A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        primaryColor: Color(0xFF4A235A),
      );
    }

    // Default fallback
    return isDay
        ? const WeatherTheme(
            gradient: LinearGradient(
              colors: [Color(0xFF89CFF0), Color(0xFF6BB3D9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            primaryColor: Color(0xFF6BB3D9),
          )
        : const WeatherTheme(
            gradient: LinearGradient(
              colors: [Color(0xFF232526), Color(0xFF414345)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            primaryColor: Color(0xFF414345),
          );
  }
}
