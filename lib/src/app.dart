import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:toastification/toastification.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'routing/app_router.dart';

import 'features/auth/data/auth_repository.dart';
import 'features/notifications/data/notification_service.dart';
import 'core/providers/connectivity_provider.dart';
import 'core/widgets/no_connection_screen.dart';
import 'core/services/version_service.dart';
import 'core/widgets/update_required_dialog.dart';

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

    // Set up foreground FCM message callback to show toast notifications on ALL platforms
    ref.read(notificationServiceProvider).setForegroundMessageCallback((
      message,
    ) {
      final title = message.notification?.title ?? 'Notificação';
      final body =
          message.notification?.body ?? 'Você tem uma nova notificação';
      final bookingId = message.data['bookingId'];
      final status = message.data['status'];

      // Use different icons based on notification type
      IconData icon = Icons.notifications_active;
      Color color = Colors.blue;

      if (status != null) {
        switch (status) {
          case 'finished':
            icon = Icons.celebration;
            color = Colors.green;
            break;
          case 'cancelled':
            icon = Icons.cancel;
            color = Colors.red;
            break;
          case 'washing':
          case 'vacuuming':
          case 'drying':
          case 'polishing':
            icon = Icons.water_drop;
            color = Colors.blue;
            break;
          case 'checkIn':
            icon = Icons.login;
            color = Colors.orange;
            break;
        }
      }

      toastification.show(
        type: ToastificationType.info,
        style: ToastificationStyle.flatColored,
        title: Text(title),
        description: Text(body),
        autoCloseDuration: const Duration(seconds: 5),
        alignment: Alignment.topCenter,
        primaryColor: color,
        borderRadius: BorderRadius.circular(12),
        showProgressBar: false,
        closeOnClick: true,
        pauseOnHover: true,
        icon: Icon(icon, color: color),
        callbacks: ToastificationCallbacks(
          onTap: (value) {
            if (bookingId != null && bookingId.isNotEmpty) {
              goRouter.push('/booking/$bookingId');
            }
          },
        ),
      );
    });

    // Set up notification tap callback for navigation (when tapping local notifications)
    ref.read(notificationServiceProvider).setNotificationTapCallback((
      bookingId,
    ) {
      if (bookingId != null && bookingId.isNotEmpty) {
        // Use post-frame callback to ensure context is available
        WidgetsBinding.instance.addPostFrameCallback((_) {
          goRouter.push('/booking/$bookingId');
        });
      }
    });

    if (kIsWeb) {
      // Check for app updates on web
      ref.listen(updateRequiredProvider, (previous, next) {
        next.whenData((updateRequired) {
          if (updateRequired) {
            // Use a post-frame callback to show dialog after build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final navigatorContext =
                  goRouter.routerDelegate.navigatorKey.currentContext;
              if (navigatorContext != null) {
                UpdateRequiredDialog.show(navigatorContext);
              }
            });
          }
        });
      });
    }

    final theme = ref.watch(themeProvider);

    return ToastificationWrapper(
      child: Sizer(
        builder: (context, orientation, screenType) {
          return MaterialApp.router(
            title: 'AquaClean',
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
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('pt', 'BR')],
          );
        },
      ),
    );
  }
}
