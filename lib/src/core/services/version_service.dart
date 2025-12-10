import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current app version - INCREMENT THIS WHEN DEPLOYING NEW WEB VERSION
const String currentAppVersion = '1.0.2';

/// Service to check if a new version is available
class VersionService {
  final FirebaseFirestore _firestore;

  VersionService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Check if a newer version is available
  /// Returns true if update is required
  Future<bool> checkForUpdate() async {
    // Only check on web platform
    if (!kIsWeb) return false;

    try {
      final doc = await _firestore
          .collection('config')
          .doc('app_version')
          .get();

      if (!doc.exists) return false;

      final data = doc.data();
      if (data == null) return false;

      final requiredVersion = data['web_version'] as String?;
      final forceUpdate = data['force_update'] as bool? ?? false;

      if (requiredVersion == null) return false;

      // Compare versions
      if (forceUpdate && requiredVersion != currentAppVersion) {
        return true;
      }

      // Check if required version is newer
      return _isNewerVersion(requiredVersion, currentAppVersion);
    } catch (e) {
      debugPrint('VersionService: Error checking version: $e');
      return false;
    }
  }

  /// Compare two semantic versions (e.g., "1.0.1" > "1.0.0")
  bool _isNewerVersion(String remote, String local) {
    final remoteParts = remote.split('.').map(int.tryParse).toList();
    final localParts = local.split('.').map(int.tryParse).toList();

    for (int i = 0; i < remoteParts.length && i < localParts.length; i++) {
      final r = remoteParts[i] ?? 0;
      final l = localParts[i] ?? 0;
      if (r > l) return true;
      if (r < l) return false;
    }

    return remoteParts.length > localParts.length;
  }
}

final versionServiceProvider = Provider<VersionService>((ref) {
  return VersionService();
});

/// Provider that checks for updates
final updateRequiredProvider = FutureProvider<bool>((ref) async {
  return ref.read(versionServiceProvider).checkForUpdate();
});
