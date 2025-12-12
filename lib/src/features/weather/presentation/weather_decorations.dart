import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Weather decorations that can be used across the app
class WeatherDecorations {
  /// Get appropriate decorations for a weather code
  static List<Widget> fromCode(int code, bool isDay) {
    // Clear sky
    if (code == 0 || code == 1) {
      return isDay ? [const SunRaysDecoration()] : [const StarsDecoration()];
    }
    // Partly cloudy
    else if (code == 2) {
      return isDay
          ? [const CloudsDecoration(cloudCount: 2)]
          : [const StarsDecoration(starCount: 6), const CloudsDecoration()];
    }
    // Overcast
    else if (code == 3) {
      return [const CloudsDecoration(cloudCount: 4)];
    }
    // Fog
    else if (code >= 45 && code <= 48) {
      return [const FogDecoration()];
    }
    // Drizzle
    else if (code >= 51 && code <= 57) {
      return [const RainDecoration(intensity: RainIntensity.light)];
    }
    // Rain
    else if (code >= 61 && code <= 67) {
      return [const RainDecoration(intensity: RainIntensity.heavy)];
    }
    // Snow
    else if (code >= 71 && code <= 77) {
      return [const SnowDecoration()];
    }
    // Rain showers
    else if (code >= 80 && code <= 82) {
      return [const RainDecoration(intensity: RainIntensity.light)];
    }
    // Thunderstorm
    else if (code >= 95) {
      return [
        const RainDecoration(intensity: RainIntensity.heavy),
        const LightningDecoration(),
      ];
    }
    return isDay ? [const CloudsDecoration()] : [const StarsDecoration()];
  }
}

/// Animated sun rays radiating from corner
class SunRaysDecoration extends StatelessWidget {
  const SunRaysDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -40,
      right: -40,
      child:
          Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.yellow.withValues(alpha: 0.6),
                      Colors.orange.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
                duration: 3.seconds,
                curve: Curves.easeInOut,
              ),
    );
  }
}

/// Twinkling stars for night
class StarsDecoration extends StatelessWidget {
  final int starCount;
  const StarsDecoration({super.key, this.starCount = 12});

  @override
  Widget build(BuildContext context) {
    final random = Random(42); // Fixed seed for consistent positions
    return Positioned.fill(
      child: Stack(
        children: List.generate(starCount, (index) {
          final top = random.nextDouble() * 120;
          final left = random.nextDouble() * 280;
          final size = 2.0 + random.nextDouble() * 3;
          final delay = random.nextInt(2000);

          return Positioned(
            top: top,
            left: left,
            child:
                Container(
                      width: size,
                      height: size,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    )
                    .animate(
                      delay: Duration(milliseconds: delay),
                      onPlay: (c) => c.repeat(reverse: true),
                    )
                    .fadeOut(duration: 800.ms),
          );
        }),
      ),
    );
  }
}

/// Floating clouds decoration
class CloudsDecoration extends StatelessWidget {
  final int cloudCount;
  const CloudsDecoration({super.key, this.cloudCount = 2});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Cloud 1 - top left
          Positioned(top: 10, left: -20, child: _buildCloud(80, 0.3, 0)),
          // Cloud 2 - bottom right
          if (cloudCount >= 2)
            Positioned(bottom: 20, right: 60, child: _buildCloud(60, 0.2, 500)),
          // Cloud 3 - middle
          if (cloudCount >= 3)
            Positioned(top: 50, left: 100, child: _buildCloud(50, 0.15, 1000)),
        ],
      ),
    );
  }

  Widget _buildCloud(double size, double opacity, int delay) {
    return Icon(
          Icons.cloud,
          size: size,
          color: Colors.white.withValues(alpha: opacity),
        )
        .animate(
          delay: Duration(milliseconds: delay),
          onPlay: (c) => c.repeat(reverse: true),
        )
        .moveX(begin: 0, end: 15, duration: 4.seconds, curve: Curves.easeInOut);
  }
}

/// Fog effect
class FogDecoration extends StatelessWidget {
  const FogDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 30,
          left: 0,
          right: 0,
          child:
              Container(
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveX(begin: -20, end: 20, duration: 5.seconds),
        ),
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child:
              Container(
                    height: 25,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.2),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  )
                  .animate(
                    delay: 500.ms,
                    onPlay: (c) => c.repeat(reverse: true),
                  )
                  .moveX(begin: 20, end: -20, duration: 6.seconds),
        ),
      ],
    );
  }
}

enum RainIntensity { light, heavy }

/// Animated rain drops
class RainDecoration extends StatelessWidget {
  final RainIntensity intensity;
  const RainDecoration({super.key, required this.intensity});

  @override
  Widget build(BuildContext context) {
    final dropCount = intensity == RainIntensity.heavy ? 15 : 8;
    final random = Random(42);

    return Positioned.fill(
      child: ClipRect(
        child: Stack(
          children: List.generate(dropCount, (index) {
            final left = random.nextDouble() * 320;
            final delay = random.nextInt(1000);
            final duration = 600 + random.nextInt(400);

            return Positioned(
              top: -10,
              left: left,
              child:
                  Container(
                        width: 2,
                        height: intensity == RainIntensity.heavy ? 20 : 12,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )
                      .animate(
                        delay: Duration(milliseconds: delay),
                        onPlay: (c) => c.repeat(),
                      )
                      .moveY(
                        begin: 0,
                        end: 200,
                        duration: Duration(milliseconds: duration),
                        curve: Curves.linear,
                      )
                      .fadeOut(delay: Duration(milliseconds: duration - 200)),
            );
          }),
        ),
      ),
    );
  }
}

/// Snow decoration
class SnowDecoration extends StatelessWidget {
  const SnowDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    final random = Random(42);
    return Positioned.fill(
      child: ClipRect(
        child: Stack(
          children: List.generate(12, (index) {
            final left = random.nextDouble() * 320;
            final delay = random.nextInt(2000);
            final duration = 2000 + random.nextInt(1000);

            return Positioned(
              top: -10,
              left: left,
              child: const Icon(Icons.ac_unit, size: 10, color: Colors.white70)
                  .animate(
                    delay: Duration(milliseconds: delay),
                    onPlay: (c) => c.repeat(),
                  )
                  .moveY(
                    begin: 0,
                    end: 200,
                    duration: Duration(milliseconds: duration),
                    curve: Curves.easeIn,
                  )
                  .rotate(end: 1, duration: Duration(milliseconds: duration)),
            );
          }),
        ),
      ),
    );
  }
}

/// Lightning flash effect
class LightningDecoration extends StatelessWidget {
  const LightningDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(color: Colors.white.withValues(alpha: 0.0))
          .animate(delay: 2.seconds, onPlay: (c) => c.repeat())
          .then(delay: 3.seconds)
          .custom(
            duration: 100.ms,
            builder: (context, value, child) =>
                Container(color: Colors.white.withValues(alpha: value * 0.3)),
          )
          .then(delay: 100.ms)
          .custom(
            duration: 80.ms,
            builder: (context, value, child) => Container(
              color: Colors.white.withValues(alpha: (1 - value) * 0.2),
            ),
          ),
    );
  }
}

/// Weather icon helper
class WeatherIcon extends StatelessWidget {
  final int weatherCode;
  final bool isDay;
  final double size;

  const WeatherIcon({
    super.key,
    required this.weatherCode,
    required this.isDay,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color = Colors.white;

    // Clear
    if (weatherCode == 0 || weatherCode == 1) {
      icon = isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round;
      color = isDay ? Colors.amber : Colors.white;
    }
    // Partly cloudy
    else if (weatherCode == 2) {
      icon = isDay ? Icons.wb_cloudy : Icons.nights_stay;
    }
    // Overcast
    else if (weatherCode == 3) {
      icon = Icons.cloud;
    }
    // Fog
    else if (weatherCode >= 45 && weatherCode <= 48) {
      icon = Icons.foggy;
    }
    // Drizzle / Rain
    else if (weatherCode >= 51 && weatherCode <= 67) {
      icon = Icons.grain;
    }
    // Snow
    else if (weatherCode >= 71 && weatherCode <= 77) {
      icon = Icons.ac_unit;
    }
    // Showers
    else if (weatherCode >= 80 && weatherCode <= 82) {
      icon = Icons.water_drop;
    }
    // Thunderstorm
    else if (weatherCode >= 95) {
      icon = Icons.bolt;
      color = Colors.amber;
    } else {
      icon = Icons.wb_cloudy;
    }

    return Icon(icon, size: size, color: color);
  }
}
