import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../weather/domain/weather.dart';
import '../../weather/data/weather_repository.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class WeatherCard extends ConsumerWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(currentWeatherProvider);

    return weatherAsync.when(
      data: (weather) => _ImmersiveWeatherCard(weather: weather),
      loading: () => const ShimmerLoading.rectangular(height: 140),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

class _ImmersiveWeatherCard extends StatelessWidget {
  final Weather weather;

  const _ImmersiveWeatherCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final condition = _WeatherCondition.fromCode(
      weather.weatherCode,
      weather.isDay,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          gradient: condition.gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: condition.shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background decorations
            ...condition.decorations,

            // Content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Temperature display
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  weather.temperature.toStringAsFixed(0),
                                  style: theme.textTheme.headlineLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        height: 1,
                                      ),
                                ),
                                Text(
                                  '°C',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Olinda, PE',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Flexible(
                              child: Text(
                                condition.message,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontWeight: FontWeight.w900,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Main weather icon
                      condition.mainIcon,
                    ],
                  ),
                ),

                // 5-Day Forecast Row
                if (weather.dailyForecast.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: weather.dailyForecast.map((daily) {
                        return _ForecastItem(daily: daily);
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, duration: 400.ms);
  }
}

class _WeatherCondition {
  final LinearGradient gradient;
  final Color shadowColor;
  final String message;
  final List<Widget> decorations;
  final Widget mainIcon;

  _WeatherCondition({
    required this.gradient,
    required this.shadowColor,
    required this.message,
    required this.decorations,
    required this.mainIcon,
  });

  static _WeatherCondition fromCode(int code, bool isDay) {
    // Clear sky or Mainly clear
    if (code == 0 || code == 1) {
      if (isDay) {
        return _WeatherCondition.sunny();
      } else {
        return _WeatherCondition.clearNight();
      }
    }
    // Partly cloudy
    else if (code == 2) {
      if (isDay) {
        return _WeatherCondition.partlyCloudy();
      } else {
        return _WeatherCondition.cloudyNight();
      }
    }
    // Overcast
    else if (code == 3) {
      return _WeatherCondition.overcast(isDay);
    }
    // Fog
    else if (code >= 45 && code <= 48) {
      return _WeatherCondition.foggy();
    }
    // Drizzle
    else if (code >= 51 && code <= 57) {
      return _WeatherCondition.drizzle(isDay);
    }
    // Rain
    else if (code >= 61 && code <= 67) {
      return _WeatherCondition.rainy(isDay);
    }
    // Snow (unlikely in Olinda but handle it)
    else if (code >= 71 && code <= 77) {
      return _WeatherCondition.snowy();
    }
    // Rain showers
    else if (code >= 80 && code <= 82) {
      return isDay
          ? _WeatherCondition.rainShowers()
          : _WeatherCondition.rainy(false);
    }
    // Thunderstorm
    else if (code >= 95) {
      return _WeatherCondition.thunderstorm();
    }

    // Default fallback
    return isDay
        ? _WeatherCondition.partlyCloudy()
        : _WeatherCondition.cloudyNight();
  }

  // ☀️ Sunny Day
  factory _WeatherCondition.sunny() {
    return _WeatherCondition(
      gradient: const LinearGradient(
        colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shadowColor: const Color(0xFF2F80ED).withValues(alpha: 0.4),
      message: 'Céu limpo! Dia perfeito para lavar o carro. ☀️',
      decorations: const [_SunRaysDecoration()],
      mainIcon: const _AnimatedSunIcon(),
    );
  }

  // 🌙 Clear Night
  factory _WeatherCondition.clearNight() {
    return _WeatherCondition(
      gradient: const LinearGradient(
        colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      shadowColor: const Color(0xFF0F2027).withValues(alpha: 0.5),
      message: 'Noite estrelada. Descanse bem! 🌙',
      decorations: const [_StarsDecoration()],
      mainIcon: const _AnimatedMoonIcon(),
    );
  }

  // ⛅ Partly Cloudy Day
  factory _WeatherCondition.partlyCloudy() {
    return _WeatherCondition(
      gradient: const LinearGradient(
        colors: [Color(0xFF89CFF0), Color(0xFF6BB3D9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shadowColor: const Color(0xFF6BB3D9).withValues(alpha: 0.4),
      message: 'Parcialmente nublado. Ainda dá pra lavar! ⛅',
      decorations: const [_CloudsDecoration(cloudCount: 3)],
      mainIcon: const _SunWithCloudIcon(),
    );
  }

  // 🌥️ Cloudy Night
  factory _WeatherCondition.cloudyNight() {
    return _WeatherCondition(
      gradient: const LinearGradient(
        colors: [Color(0xFF232526), Color(0xFF414345)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      shadowColor: const Color(0xFF232526).withValues(alpha: 0.5),
      message: 'Noite nublada. Bons sonhos! ☁️',
      decorations: const [_StarsDecoration(starCount: 5), _CloudsDecoration()],
      mainIcon: const _MoonWithCloudIcon(),
    );
  }

  // 🌫️ Foggy
  factory _WeatherCondition.foggy() {
    return _WeatherCondition(
      gradient: const LinearGradient(
        colors: [Color(0xFFB0BEC5), Color(0xFF78909C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      shadowColor: const Color(0xFF78909C).withValues(alpha: 0.3),
      message: 'Nevoeiro. Dirija com cuidado! 🌫️',
      decorations: const [_FogDecoration()],
      mainIcon: const Icon(Icons.foggy, color: Colors.white70, size: 60),
    );
  }

  // 🌧️ Drizzle
  factory _WeatherCondition.drizzle(bool isDay) {
    return _WeatherCondition(
      gradient: LinearGradient(
        colors: isDay
            ? [const Color(0xFF616161), const Color(0xFF9BC5C3)]
            : [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      shadowColor: const Color(0xFF616161).withValues(alpha: 0.4),
      message: 'Garoa. Talvez esperar um pouco? 🌧️',
      decorations: [_RainDecoration(intensity: RainIntensity.light)],
      mainIcon: const _DrizzleIcon(),
    );
  }

  // 🌧️ Rainy
  factory _WeatherCondition.rainy(bool isDay) {
    return _WeatherCondition(
      gradient: LinearGradient(
        colors: isDay
            ? [const Color(0xFF4B6584), const Color(0xFF778899)]
            : [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      shadowColor: const Color(0xFF4B6584).withValues(alpha: 0.5),
      message: 'Chuva! Melhor agendar pra depois. 🌧️',
      decorations: [_RainDecoration(intensity: RainIntensity.heavy)],
      mainIcon: const _RainCloudIcon(),
    );
  }

  // ❄️ Snowy (unlikely but handled)
  factory _WeatherCondition.snowy() {
    return _WeatherCondition(
      gradient: const LinearGradient(
        colors: [Color(0xFFE0E5EC), Color(0xFFB0C4DE)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      shadowColor: const Color(0xFFB0C4DE).withValues(alpha: 0.4),
      message: 'Neve?! Em Olinda?! ❄️',
      decorations: const [_SnowDecoration()],
      mainIcon: const Icon(Icons.ac_unit, color: Colors.white, size: 60),
    );
  }

  // ⛈️ Thunderstorm
  factory _WeatherCondition.thunderstorm() {
    return _WeatherCondition(
      gradient: const LinearGradient(
        colors: [Color(0xFF1A1A2E), Color(0xFF4A235A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      shadowColor: const Color(0xFF4A235A).withValues(alpha: 0.5),
      message: 'Trovoadas! Fique em segurança. ⛈️',
      decorations: [
        _RainDecoration(intensity: RainIntensity.heavy),
        const _LightningDecoration(),
      ],
      mainIcon: const _ThunderstormIcon(),
    );
  }
  // ☁️ Overcast
  factory _WeatherCondition.overcast(bool isDay) {
    if (!isDay) return _WeatherCondition.cloudyNight();

    return _WeatherCondition(
      gradient: const LinearGradient(
        colors: [Color(0xFF757F9A), Color(0xFFD7DDE8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shadowColor: const Color(0xFF757F9A).withValues(alpha: 0.5),
      message: 'Céu encoberto. Talvez esperar um pouco? ☁️',
      decorations: const [_CloudsDecoration(cloudCount: 4)],
      mainIcon: const Icon(Icons.cloud, color: Colors.white, size: 70),
    );
  }

  // 🌦️ Rain Showers (Sun + Rain)
  factory _WeatherCondition.rainShowers() {
    return _WeatherCondition(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF667db6),
          Color(0xFF0082c8),
          Color(0xFF0082c8),
          Color(0xFF667db6),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shadowColor: const Color(0xFF0082c8).withValues(alpha: 0.4),
      message: 'Pancadas de chuva! Aguarde uma brecha. 🌦️',
      decorations: [_RainDecoration(intensity: RainIntensity.light)],
      mainIcon: const _SunWithRainIcon(),
    );
  }
}

// ========== ANIMATED DECORATIONS ==========

/// Animated sun rays radiating from corner
class _SunRaysDecoration extends StatelessWidget {
  const _SunRaysDecoration();

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

/// Animated sun icon
class _AnimatedSunIcon extends StatelessWidget {
  const _AnimatedSunIcon();

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.wb_sunny_rounded, color: Colors.amber.shade300, size: 70)
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.1, 1.1),
          duration: 2.seconds,
        )
        .shimmer(
          duration: 3.seconds,
          color: Colors.yellow.withValues(alpha: 0.3),
        );
  }
}

/// Twinkling stars for night
class _StarsDecoration extends StatelessWidget {
  final int starCount;
  const _StarsDecoration({this.starCount = 12});

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

/// Animated moon icon
class _AnimatedMoonIcon extends StatelessWidget {
  const _AnimatedMoonIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
          children: [
            // Glow effect
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
            const Icon(Icons.nightlight_round, color: Colors.white, size: 70),
          ],
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.05, 1.05),
          duration: 4.seconds,
        );
  }
}

/// Floating clouds decoration
class _CloudsDecoration extends StatelessWidget {
  final int cloudCount;
  const _CloudsDecoration({this.cloudCount = 2});

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

/// Sun with cloud for partly cloudy
class _SunWithCloudIcon extends StatelessWidget {
  const _SunWithCloudIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 70,
      child: Stack(
        children: [
          // Sun behind
          Positioned(
            top: 0,
            right: 0,
            child:
                Icon(
                      Icons.wb_sunny_rounded,
                      color: Colors.amber.shade300,
                      size: 45,
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.1, 1.1),
                      duration: 2.seconds,
                    ),
          ),
          // Cloud in front
          Positioned(
            bottom: 0,
            left: 0,
            child: const Icon(Icons.cloud, color: Colors.white, size: 50)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveX(begin: 0, end: 5, duration: 3.seconds),
          ),
        ],
      ),
    );
  }
}

/// Sun with rain for showers
class _SunWithRainIcon extends StatelessWidget {
  const _SunWithRainIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 70,
      child: Stack(
        children: [
          // Sun behind
          Positioned(
            top: 0,
            right: 0,
            child:
                Icon(
                      Icons.wb_sunny_rounded,
                      color: Colors.amber.shade300,
                      size: 45,
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.1, 1.1),
                      duration: 2.seconds,
                    ),
          ),
          // Cloud in front
          Positioned(
            bottom: 0,
            left: 0,
            child: const Icon(Icons.cloud, color: Colors.white70, size: 50),
          ),
          // Rain drops
          Positioned(
            bottom: 5,
            left: 15,
            child: Row(
              children: List.generate(
                3,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child:
                      Container(
                            width: 2,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )
                          .animate(
                            delay: Duration(milliseconds: i * 200),
                            onPlay: (c) => c.repeat(),
                          )
                          .moveY(begin: 0, end: 8, duration: 500.ms)
                          .fadeOut(delay: 300.ms),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Moon with cloud for cloudy night
class _MoonWithCloudIcon extends StatelessWidget {
  const _MoonWithCloudIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 70,
      child: Stack(
        children: [
          // Moon behind
          const Positioned(
            top: 0,
            right: 5,
            child: Icon(
              Icons.nightlight_round,
              color: Colors.white70,
              size: 40,
            ),
          ),
          // Cloud in front
          Positioned(
            bottom: 0,
            left: 0,
            child: const Icon(Icons.cloud, color: Colors.white54, size: 50)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveX(begin: 0, end: 5, duration: 3.seconds),
          ),
        ],
      ),
    );
  }
}

/// Fog effect
class _FogDecoration extends StatelessWidget {
  const _FogDecoration();

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
class _RainDecoration extends StatelessWidget {
  final RainIntensity intensity;
  const _RainDecoration({required this.intensity});

  @override
  Widget build(BuildContext context) {
    final dropCount = intensity == RainIntensity.heavy ? 15 : 8;
    final random = Random(42);

    return Positioned.fill(
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
                      end: 400,
                      duration: Duration(milliseconds: duration),
                      curve: Curves.linear,
                    )
                    .fadeOut(delay: Duration(milliseconds: duration - 200)),
          );
        }),
      ),
    );
  }
}

/// Drizzle icon
class _DrizzleIcon extends StatelessWidget {
  const _DrizzleIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.grain, color: Colors.white70, size: 60);
  }
}

/// Rain cloud icon
class _RainCloudIcon extends StatelessWidget {
  const _RainCloudIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 70,
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 10,
            child: Icon(Icons.cloud, size: 55, color: Colors.white70),
          ),
          // Rain drops
          Positioned(
            bottom: 5,
            left: 20,
            child: Row(
              children: List.generate(
                3,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child:
                      Container(
                            width: 3,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white54,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )
                          .animate(
                            delay: Duration(milliseconds: i * 200),
                            onPlay: (c) => c.repeat(),
                          )
                          .moveY(begin: 0, end: 8, duration: 500.ms)
                          .fadeOut(delay: 300.ms),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Snow decoration
class _SnowDecoration extends StatelessWidget {
  const _SnowDecoration();

  @override
  Widget build(BuildContext context) {
    final random = Random(42);
    return Positioned.fill(
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
                  end: 400,
                  duration: Duration(milliseconds: duration),
                  curve: Curves.easeIn,
                )
                .rotate(end: 1, duration: Duration(milliseconds: duration)),
          );
        }),
      ),
    );
  }
}

/// Lightning flash effect
class _LightningDecoration extends StatelessWidget {
  const _LightningDecoration();

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

class _ForecastItem extends StatelessWidget {
  final DailyWeather daily;

  const _ForecastItem({required this.daily});

  String _getWeekday(DateTime date) {
    const weekdays = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];
    return weekdays[date.weekday - 1];
  }

  Color _getWashStatusColor(int precipProb) {
    if (precipProb < 30) return Colors.greenAccent; // Good to wash
    if (precipProb < 60) return Colors.orangeAccent; // Risky
    return Colors.redAccent; // Bad
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final condition = _WeatherCondition.fromCode(daily.weatherCode, true);
    final statusColor = _getWashStatusColor(daily.precipitationProbability);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _getWeekday(daily.date),
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 30,
          height: 30,
          child: FittedBox(child: condition.mainIcon),
        ),
        const SizedBox(height: 4),
        Text(
          '${daily.maxTemp.round()}°',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
        ),
      ],
    );
  }
}

/// Thunderstorm icon
class _ThunderstormIcon extends StatelessWidget {
  const _ThunderstormIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 70,
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 10,
            child: Icon(Icons.cloud, size: 50, color: Colors.white60),
          ),
          // Lightning bolt
          Positioned(
            bottom: 0,
            left: 30,
            child: const Icon(Icons.bolt, size: 40, color: Colors.amber)
                .animate(delay: 1.seconds, onPlay: (c) => c.repeat())
                .then(delay: 2.seconds)
                .fadeIn(duration: 50.ms)
                .then()
                .fadeOut(duration: 100.ms)
                .then(delay: 200.ms)
                .fadeIn(duration: 50.ms)
                .then()
                .fadeOut(duration: 150.ms),
          ),
        ],
      ),
    );
  }
}
