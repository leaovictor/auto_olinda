import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Representa um registro imutável de aceite do NDA
class NdaAcceptanceRecord {
  final String ndaVersion;
  final String ndaHash;
  final DateTime acceptedAt;
  final String ipAddress;
  final String deviceInfo;
  final String userId;
  final String userEmail;

  NdaAcceptanceRecord({
    required this.ndaVersion,
    required this.ndaHash,
    required this.acceptedAt,
    required this.ipAddress,
    required this.deviceInfo,
    required this.userId,
    required this.userEmail,
  });

  Map<String, dynamic> toJson() => {
    'ndaVersion': ndaVersion,
    'ndaHash': ndaHash,
    'acceptedAt': acceptedAt.toIso8601String(),
    'ipAddress': ipAddress,
    'deviceInfo': deviceInfo,
    'userId': userId,
    'userEmail': userEmail,
  };

  factory NdaAcceptanceRecord.fromJson(Map<String, dynamic> json) {
    return NdaAcceptanceRecord(
      ndaVersion: json['ndaVersion'] as String,
      ndaHash: json['ndaHash'] as String,
      acceptedAt: DateTime.parse(json['acceptedAt'] as String),
      ipAddress: json['ipAddress'] as String,
      deviceInfo: json['deviceInfo'] as String,
      userId: json['userId'] as String,
      userEmail: json['userEmail'] as String,
    );
  }
}

/// Utilitário para gerar hash SHA-256 do texto do NDA
class NdaHashGenerator {
  static String generateHash(String ndaText) {
    final bytes = utf8.encode(ndaText);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

/// Versões do NDA - Controle de versão centralizado
class NdaVersions {
  static const String currentVersion = 'V1.0';

  static const Map<String, String> versionHistory = {
    'V1.0': '2024-12-13', // Data de criação da versão
  };

  /// Verifica se a versão aceita pelo usuário é a atual
  static bool isVersionCurrent(String? acceptedVersion) {
    return acceptedVersion == currentVersion;
  }
}
