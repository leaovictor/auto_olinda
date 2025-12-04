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
    final theme = Theme.of(context);

    return weatherAsync.when(
      data: (weather) {
        final info = _getWeatherInfo(weather.weatherCode, weather.isDay);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: weather.isDay
                  ? [
                      const Color(0xFF4FA8F5),
                      const Color(0xFF2D79C7),
                    ] // Day blue
                  : [
                      const Color(0xFF1A237E),
                      const Color(0xFF311B92),
                    ], // Night indigo
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(info.icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.temperature.toStringAsFixed(0)}°C em Olinda',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: -0.2);
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: ShimmerLoading.rectangular(height: 100),
      ),
      error: (err, stack) => const SizedBox.shrink(), // Hide on error
    );
  }

  ({IconData icon, String message}) _getWeatherInfo(int code, bool isDay) {
    // WMO Weather interpretation codes (https://open-meteo.com/en/docs)
    if (code == 0) {
      return (
        icon: isDay ? Icons.wb_sunny : Icons.nightlight_round,
        message: 'Céu limpo. Dia perfeito para lavar o carro!',
      );
    } else if (code >= 1 && code <= 3) {
      return (
        icon: isDay ? Icons.wb_cloudy : Icons.cloud,
        message: 'Parcialmente nublado. Bom para lavar.',
      );
    } else if (code >= 45 && code <= 48) {
      return (icon: Icons.foggy, message: 'Neblina. Dirija com cuidado.');
    } else if (code >= 51 && code <= 67) {
      return (
        icon: Icons.grain,
        message: 'Chuvisco leve. Talvez esperar um pouco?',
      );
    } else if (code >= 71 && code <= 77) {
      return (
        icon: Icons.ac_unit,
        message: 'Neve? Em Olinda?! Algo está errado.',
      );
    } else if (code >= 80 && code <= 82) {
      return (
        icon: Icons.water_drop,
        message: 'Pancadas de chuva. Melhor agendar para depois.',
      );
    } else if (code >= 95) {
      return (icon: Icons.flash_on, message: 'Tempestade! Fique seguro.');
    } else {
      // Rain (61, 63, 65)
      return (
        icon: Icons.umbrella,
        message: 'Está chovendo. Que tal agendar para amanhã?',
      );
    }
  }
}
