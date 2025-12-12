import 'package:flutter/material.dart';

/// WMO Weather Code to Portuguese text mapping
/// Based on Open-Meteo weather codes
class WeatherCodeHelper {
  /// Convert WMO weather code to Portuguese description
  static String codeToText(int code) {
    if (code == 0) return "Céu limpo";
    if (code == 1) return "Predominantemente limpo";
    if (code == 2) return "Parcialmente nublado";
    if (code == 3) return "Encoberto";

    if (code == 45 || code == 48) return "Nevoeiro";

    if (code == 51 || code == 53 || code == 55) return "Garoa";
    if (code == 56 || code == 57) return "Garoa congelante";

    if (code == 61 || code == 63 || code == 65) return "Chuva";
    if (code == 66 || code == 67) return "Chuva congelante";

    if (code == 71 || code == 73 || code == 75) return "Neve";
    if (code == 77) return "Grãos de neve";

    if (code == 80 || code == 81 || code == 82) return "Pancadas de chuva";
    if (code == 85 || code == 86) return "Pancadas de neve";

    if (code == 95) return "Trovoadas";
    if (code == 96 || code == 99) return "Trovoadas com granizo";

    return "Condição desconhecida";
  }

  /// Convert WMO weather code to contextual car wash message
  static String codeToCarWashMessage(int code, bool isDay) {
    if (code == 0) {
      return isDay
          ? "Céu limpo! Dia perfeito para lavar o carro. ☀️"
          : "Noite estrelada. Descanse bem! 🌙";
    }
    if (code == 1) {
      return isDay
          ? "Predominantemente limpo. Ótimo para uma lavagem! ☀️"
          : "Noite clara. Bons sonhos! 🌙";
    }
    if (code == 2) {
      return isDay
          ? "Parcialmente nublado. Ainda dá pra lavar! ⛅"
          : "Noite com algumas nuvens. ☁️";
    }
    if (code == 3) {
      return isDay
          ? "Céu encoberto. Talvez esperar um pouco? ☁️"
          : "Noite nublada. Bons sonhos! ☁️";
    }

    if (code == 45 || code == 48) {
      return "Nevoeiro. Dirija com cuidado! 🌫️";
    }

    if (code == 51 || code == 53 || code == 55) {
      return "Garoa leve. Melhor aguardar! 🌧️";
    }
    if (code == 56 || code == 57) {
      return "Garoa congelante. Cuidado nas estradas! ❄️";
    }

    if (code == 61 || code == 63 || code == 65) {
      return "Chuva! Melhor agendar pra depois. 🌧️";
    }
    if (code == 66 || code == 67) {
      return "Chuva congelante! Fique em segurança. ❄️";
    }

    if (code == 71 || code == 73 || code == 75) {
      return "Neve?! Em Olinda?! ❄️";
    }
    if (code == 77) {
      return "Grãos de neve! Raro por aqui. ❄️";
    }

    if (code == 80 || code == 81 || code == 82) {
      return "Pancadas de chuva! Aguarde uma brecha. 🌦️";
    }
    if (code == 85 || code == 86) {
      return "Pancadas de neve! Muito raro. ❄️";
    }

    if (code == 95) {
      return "Trovoadas! Fique em segurança. ⛈️";
    }
    if (code == 96 || code == 99) {
      return "Trovoadas com granizo! Cuidado! ⛈️";
    }

    return "Condição desconhecida";
  }

  /// Get appropriate icon for weather code
  static IconData codeToIcon(int code, bool isDay) {
    // Clear
    if (code == 0 || code == 1) {
      return isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round;
    }
    // Partly cloudy
    if (code == 2) {
      return isDay ? Icons.wb_cloudy : Icons.nights_stay;
    }
    // Overcast
    if (code == 3) {
      return Icons.cloud;
    }
    // Fog
    if (code == 45 || code == 48) {
      return Icons.foggy;
    }
    // Drizzle
    if (code >= 51 && code <= 57) {
      return Icons.grain;
    }
    // Rain
    if (code >= 61 && code <= 67) {
      return Icons.water_drop;
    }
    // Snow
    if (code >= 71 && code <= 77) {
      return Icons.ac_unit;
    }
    // Rain showers
    if (code >= 80 && code <= 86) {
      return Icons.shower;
    }
    // Thunderstorm
    if (code >= 95) {
      return Icons.bolt;
    }

    return Icons.wb_cloudy;
  }

  /// Get icon color for weather code
  static Color codeToIconColor(int code, bool isDay) {
    // Clear sunny
    if (code == 0 || code == 1) {
      return isDay ? Colors.amber : Colors.white;
    }
    // Thunderstorm
    if (code >= 95) {
      return Colors.amber;
    }
    // Snow
    if (code >= 71 && code <= 77 ||
        code == 85 ||
        code == 86 ||
        code == 56 ||
        code == 57 ||
        code == 66 ||
        code == 67) {
      return Colors.lightBlue.shade100;
    }

    return Colors.white;
  }
}
