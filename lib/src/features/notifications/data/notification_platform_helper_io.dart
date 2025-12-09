// Web-safe platform detection helper
// This file is safe to import on web platforms

import 'dart:io' show Platform;

/// Returns true if running on a desktop platform (Linux, Windows, macOS)
/// This function is only called when NOT on web, so dart:io import is safe
bool isDesktopPlatform() {
  return Platform.isLinux || Platform.isWindows || Platform.isMacOS;
}
