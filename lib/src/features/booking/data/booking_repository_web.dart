// Web stub for booking repository helpers
// File operations are not supported on web

/// Stub class to satisfy type requirements on web
/// This is never actually used on web since photo upload is mobile-only
class File {
  final String path;
  File(this.path);
}

/// Upload a photo file to storage (web stub - throws)
Future<String> uploadPhotoImpl(File file, String path) async {
  throw UnsupportedError('Photo upload is not supported on web');
}
