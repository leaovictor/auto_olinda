// IO implementation for booking repository helpers
import 'dart:io';

// Re-export File for use in booking_repository.dart
export 'dart:io' show File;

/// Upload a photo file to storage (mobile implementation)
Future<String> uploadPhotoImpl(File file, String path) async {
  // Mock upload for now
  await Future.delayed(const Duration(seconds: 1));
  return 'https://picsum.photos/200/300?random=${DateTime.now().millisecondsSinceEpoch}';
}
