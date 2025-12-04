import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'routing/app_router.dart';

import 'features/auth/data/auth_repository.dart';
import 'features/notifications/data/notification_service.dart';
import 'core/providers/connectivity_provider.dart';
import 'core/widgets/no_connection_screen.dart';

class AquaCleanApp extends ConsumerWidget {
  const AquaCleanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    // Listen for notifications when user is logged in
    ref.listen(authRepositoryProvider, (previous, next) {
      final user = next.currentUser;
      if (user != null) {
        ref
            .read(notificationServiceProvider)
            .listenToUserNotifications(user.uid);
      }
    });

    final theme = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'AquaClean Pro',
      theme: theme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: goRouter,
      builder: (context, child) {
        return Consumer(
          builder: (context, ref, _) {
            final isConnected = ref.watch(isConnectedProvider);
            return Stack(
              children: [
                if (child != null) child,
                if (!isConnected)
                  const Positioned.fill(child: NoConnectionScreen()),
              ],
            );
          },
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
