// Conditional export for platform-specific implementations
// Uses conditional imports to pick the right implementation at compile time

export 'notification_platform_helper_io.dart'
    if (dart.library.html) 'notification_platform_helper_web.dart';
