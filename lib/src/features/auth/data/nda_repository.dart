import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../domain/nda_acceptance.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

final ndaRepositoryProvider = Provider<NdaRepository>((ref) {
  return NdaRepository(FirebaseFirestore.instance);
});

class NdaRepository {
  final FirebaseFirestore _firestore;

  NdaRepository(this._firestore);

  /// Coleção de registros de aceite do NDA (tabela imutável)
  CollectionReference get _ndaAcceptanceCollection =>
      _firestore.collection('nda_acceptances');

  /// Salva o registro de aceite do NDA
  Future<void> recordNdaAcceptance({
    required String userId,
    required String userEmail,
    required String ndaText,
  }) async {
    final ndaHash = _generateHash(ndaText);
    final deviceInfo = await _getDeviceInfo();
    final ipAddress = await _getPublicIpAddress();

    final record = NdaAcceptanceRecord(
      ndaVersion: NdaVersions.currentVersion,
      ndaHash: ndaHash,
      acceptedAt: DateTime.now(),
      ipAddress: ipAddress,
      deviceInfo: deviceInfo,
      userId: userId,
      userEmail: userEmail,
    );

    // Salvar no Firestore com ID único baseado em userId + version
    await _ndaAcceptanceCollection
        .doc('${userId}_${NdaVersions.currentVersion}')
        .set({
          ...record.toJson(),
          'createdAt':
              FieldValue.serverTimestamp(), // Timestamp do servidor para maior precisão
        });

    // Também salvar no histórico do usuário
    await _firestore.collection('users').doc(userId).update({
      'ndaAcceptedVersion': NdaVersions.currentVersion,
      'ndaAcceptedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Verifica se o usuário aceitou a versão atual do NDA
  Future<bool> hasAcceptedCurrentVersion(String userId) async {
    try {
      final doc = await _ndaAcceptanceCollection
          .doc('${userId}_${NdaVersions.currentVersion}')
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Obtém a versão aceita pelo usuário
  Future<String?> getAcceptedVersion(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.data()?['ndaAcceptedVersion'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Gera hash SHA-256 do texto do NDA
  String _generateHash(String text) {
    final bytes = utf8.encode(text);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Obtém informações do dispositivo
  Future<String> _getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();

    try {
      if (kIsWeb) {
        final webInfo = await deviceInfoPlugin.webBrowserInfo;
        return 'Web: ${webInfo.browserName.name} - ${webInfo.platform}';
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        return 'Android: ${androidInfo.brand} ${androidInfo.model} - SDK ${androidInfo.version.sdkInt}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        return 'iOS: ${iosInfo.name} ${iosInfo.model} - ${iosInfo.systemVersion}';
      }
    } catch (e) {
      return 'Unknown Device';
    }
    return 'Unknown Device';
  }

  /// Obtém o IP público do usuário
  Future<String> _getPublicIpAddress() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.ipify.org?format=json'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['ip'] as String;
      }
    } catch (e) {
      // Fallback silencioso
    }
    return 'IP não disponível';
  }
}
