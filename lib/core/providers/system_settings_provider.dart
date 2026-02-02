import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'system_settings_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<Map<String, dynamic>?> systemSettings(Ref ref) {
  return FirebaseFirestore.instance
      .collection('settings')
      .doc('admin')
      .snapshots()
      .map((doc) => doc.exists ? doc.data() : null);
}

@riverpod
String? supportPhoneNumber(Ref ref) {
  return ref.watch(systemSettingsProvider).valueOrNull?['whatsappSupportNumber']
      as String?;
}
