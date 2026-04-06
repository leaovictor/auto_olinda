import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../features/booking/domain/booking.dart';
import '../../../features/notifications/domain/user_notification.dart';
import '../../admin/data/analytics_repository.dart';
import '../../../core/tenant/tenant_firestore.dart';
import '../../../core/tenant/tenant_service.dart';

// Conditional import for platform detection (web-safe)
import 'notification_platform_helper.dart';

// Web-safe import for checking iOS in PWA/browser
import 'package:web/web.dart' as web;

/// Detect if running on iOS web/PWA by checking userAgent
/// Returns false on non-web platforms
bool _isIOSWeb() {
  if (!kIsWeb) return false;
  try {
    final userAgent = web.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('iphone') ||
        userAgent.contains('ipad') ||
        userAgent.contains('ipod');
  } catch (e) {
    // debugPrint('📱 NotificationService: Error detecting iOS: $e');
    return false;
  }
}

class NotificationService {
  final String _tenantId;

  NotificationService(this._tenantId);

  FirebaseMessaging? _firebaseMessaging;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _notificationSubscription;

  /// Audio player for notification bell sound
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Callback for foreground FCM messages (used on web to show in-app toast)
  void Function(RemoteMessage message)? _onForegroundMessage;

  /// Callback for notification taps (to handle navigation)
  void Function(String? bookingId)? _onNotificationTap;

  /// Set a callback to be called when FCM message arrives in foreground (web only)
  void setForegroundMessageCallback(
    void Function(RemoteMessage message)? callback,
  ) {
    _onForegroundMessage = callback;
  }

  /// Set a callback to be called when a notification is tapped
  void setNotificationTapCallback(void Function(String? bookingId)? callback) {
    _onNotificationTap = callback;
  }

  /// Handle notification tap - extracts bookingId from payload and calls callback
  void _handleNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) return;
    // debugPrint(
    //   '📱 NotificationService: Handling notification tap with payload: $payload',
    // );
    _onNotificationTap?.call(payload);
  }

  /// Play notification bell sound
  Future<void> playNotificationSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/bicycle-bell-155622.mp3'));
      // debugPrint('🔔 NotificationService: Playing notification sound');
    } catch (e) {
      // debugPrint('🔔 NotificationService: Error playing sound: $e');
    }
  }

  /// Flag to indicate if we're running on iOS web (limited notification support)
  bool _isIOSWebMode = false;

  /// Flag to track if permissions were already requested
  bool _permissionsRequested = false;

  /// Basic initialization without requesting permissions
  /// This can be called at app startup
  Future<void> initialize() async {
    // Desktop platforms don't support Firebase Messaging
    if (!kIsWeb && isDesktopPlatform()) {
      // debugPrint('📱 NotificationService: Desktop platform - skipping');
      return;
    }

    // Check if running on iOS web/PWA - skip push notifications but allow in-app
    // iOS Safari has limited Web Push support and requesting permission can cause issues
    if (kIsWeb && _isIOSWeb()) {
      // debugPrint(
      //   '📱 NotificationService: iOS web/PWA detected - using in-app notifications only',
      // );
      _isIOSWebMode = true;
      // Don't return - we still want Firestore-based in-app notifications
      // Just skip FCM initialization below
    }

    // Skip FCM for iOS web - only use Firestore-based in-app notifications
    if (_isIOSWebMode) {
      // debugPrint(
      //   '📱 NotificationService: iOS mode - skipping FCM, using Firestore notifications',
      // );
      return;
    }

    try {
      _firebaseMessaging = FirebaseMessaging.instance;
    } catch (e) {
      // debugPrint(
      //   '📱 NotificationService: Failed to get FirebaseMessaging instance: $e',
      // );
      return;
    }

    // Setup message listeners (web)
    if (kIsWeb) {
      // debugPrint('📱 NotificationService: Web platform - setting up FCM web push');
      // On web, foreground messages are handled via callback (to show toast)
      // Background messages are handled by the service worker
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // debugPrint('📱 Web foreground message: ${message.notification?.title}');
        // Call the callback to show in-app notification (e.g., toast)
        _onForegroundMessage?.call(message);
      });
    }

    // debugPrint('📱 NotificationService: Basic initialization complete');
  }

  /// Full initialization with permission requests
  /// Should be called after user login
  Future<void> initializeWithPermissions() async {
    // Don't request permissions multiple times
    if (_permissionsRequested) {
      // debugPrint('📱 NotificationService: Permissions already requested');
      return;
    }

    // Desktop platforms don't support Firebase Messaging
    if (!kIsWeb && isDesktopPlatform()) {
      return;
    }

    // Skip for iOS web mode
    if (_isIOSWebMode || _firebaseMessaging == null) {
      return;
    }

    _permissionsRequested = true;

    // 1. Request Permission
    NotificationSettings settings = await _firebaseMessaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // debugPrint('📱 NotificationService: Permission granted');
    } else {
      // debugPrint('📱 NotificationService: Permission denied');
      return;
    }

    // 2. Setup Local Notifications (mobile only - not supported on web)
    if (!kIsWeb) {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // debugPrint(
          //   '📱 NotificationService: Notification tapped - ${response.payload}',
          // );
          // Handle notification tap - payload could contain bookingId
          _handleNotificationTap(response.payload);
        },
      );

      // Request notification permissions for Android 13+ (API 33+)
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        // debugPrint(
        //   '📱 NotificationService: Android notification permission granted: $granted',
        // );
      }

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              'high_importance_channel', // id
              'High Importance Notifications', // title
              description:
                  'This channel is used for important notifications.', // description
              importance: Importance.max,
            ),
          );

      // 3. Foreground Message Handler (mobile only)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        // If 'notification' is present, FCM SDK shows it in system tray IF app is in background.
        // If app is in foreground, we show it manually.
        if (notification != null && android != null) {
          _showLocalNotification(
            title: notification.title,
            body: notification.body,
          );
        }
      });
    }

    // 4. Token Refresh Handler
    _firebaseMessaging!.onTokenRefresh.listen((newToken) {
      // debugPrint('📱 NotificationService: Token refreshed');
      _saveTokenToDatabase(newToken);
    });

    // 5. Get and save initial token
    await saveCurrentToken();

    // debugPrint('📱 NotificationService: Full initialization with permissions complete');
  }

  // VAPID Key from Firebase Console > Project Settings > Cloud Messaging > Web Push certificates
  static const String _vapidKey =
      'BHLEVXbqtO_82TtHFQPe9hTfaJQXUvSJLwlshZLonEWdbc7XOCbMdJf4M9nnjkYE69Yi2jZZiQwXGYBY4kg8lqU';

  Future<String?> getToken() async {
    if (_firebaseMessaging == null) return null;
    try {
      // For web, we need to provide the VAPID key
      final token = await _firebaseMessaging!.getToken(
        vapidKey: kIsWeb ? _vapidKey : null,
      );
      if (token != null) {
        // debugPrint('📱 NotificationService: Got FCM token');
      }
      return token;
    } catch (e) {
      // debugPrint('📱 NotificationService: Error getting token: $e');
      return null;
    }
  }

  Future<void> _saveTokenToDatabase(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (_tenantId.isNotEmpty) {
      await TenantFirestore.doc('users', user.uid, _tenantId).update({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> saveCurrentToken() async {
    final token = await getToken();
    if (token != null) {
      await _saveTokenToDatabase(token);
    }
  }

  /// Remove the FCM token from the current user's document before logout.
  /// This prevents notifications from being sent to the wrong user when
  /// another user logs in on the same device.
  Future<void> removeCurrentToken() async {
    final user = _auth.currentUser;
    if (user != null && _tenantId.isNotEmpty) {
      try {
        await TenantFirestore.doc('users', user.uid, _tenantId).update({
          'fcmToken': FieldValue.delete(),
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // ignore
      }
    }
  }

  Future<void> _showLocalNotification({
    String? title,
    String? body,
    String? bookingId,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
      title,
      body,
      platformChannelSpecifics,
      payload: bookingId, // Pass bookingId for navigation on tap
    );
  }

  // --- NEW LOGIC ---

  Future<void> sendStatusNotification({
    required String userId,
    required BookingStatus status,
    required String bookingId,
  }) async {
    String title = 'Atualização de Agendamento';
    String body = 'O status do seu agendamento mudou.';

    switch (status) {
      case BookingStatus.confirmed:
        title = 'Agendamento Confirmado!';
        body = 'Seu agendamento foi confirmado. Te esperamos lá!';
        break;
      case BookingStatus.washing:
        title = 'Lavagem Iniciada 🚿';
        body = 'Seu carro está tomando um banho agora.';
        break;
      case BookingStatus.drying:
        title = 'Secagem em Andamento 💨';
        body = 'Quase lá! Estamos dando o brilho final.';
        break;
      case BookingStatus.finished:
        title = 'Seu carro brilha! ✨';
        body = 'Tudo pronto. Pode vir retirar seu veículo.';
        break;
      case BookingStatus.cancelled:
        title = 'Agendamento Cancelado';
        body = 'Seu agendamento foi cancelado.';
        break;
      default:
        break;
    }

    final notification = UserNotification(
      id: '', // Firestore will generate
      title: title,
      body: body,
      timestamp: DateTime.now(),
      bookingId: bookingId,
      isRead: false,
    );

    // Write in-app notification scoped to tenant
    if (_tenantId.isNotEmpty) {
      await TenantFirestore.subCol('users', userId, 'notifications', _tenantId)
          .add(notification.toJson());
    } else {
      // Fallback for backward compat during migration
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add(notification.toJson());
    }

    // Log FCM notification for analytics
    try {
      final analyticsRepo = AnalyticsRepository(_firestore, _tenantId);
      final notificationType = status == BookingStatus.finished
          ? 'carro_pronto'
          : 'status_update';
      await analyticsRepo.logFcmNotification(
        userId: userId,
        notificationType: notificationType,
        bookingId: bookingId,
        title: title,
        body: body,
      );
      // debugPrint('📊 FCM notification logged: $notificationType');
    } catch (e) {
      // debugPrint('📊 Error logging FCM notification: $e');
    }
  }

  void listenToUserNotifications(String userId) {
    _notificationSubscription?.cancel();

    final notificationsQuery = _tenantId.isNotEmpty
        ? TenantFirestore.subCol('users', userId, 'notifications', _tenantId)
            .orderBy('timestamp', descending: true)
            .limit(1)
        : _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .limit(1);

    _notificationSubscription = notificationsQuery.snapshots().listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data();
              if (data != null) {
                // Check if notification is recent (e.g. within last 10 seconds)
                // to avoid showing old notifications on app start
                final timestampData = data['timestamp'];
                if (timestampData == null) continue;

                final timestamp = (timestampData as Timestamp).toDate();
                if (DateTime.now().difference(timestamp).inSeconds < 10) {
                  final bookingId = data['bookingId'] as String?;

                  // Play bell sound for the notification
                  playNotificationSound();

                  // Show local notification on mobile with bookingId for navigation
                  if (!kIsWeb) {
                    _showLocalNotification(
                      title: data['title'],
                      body: data['body'],
                      bookingId: bookingId,
                    );
                  }

                  // Also trigger the foreground callback for in-app banners
                  // This allows the app to show a banner even on mobile
                  if (_onForegroundMessage != null) {
                    // Create a synthetic RemoteMessage for the callback
                    final message = RemoteMessage(
                      notification: RemoteNotification(
                        title: data['title'],
                        body: data['body'],
                      ),
                      data: {
                        'bookingId': bookingId ?? '',
                        'type': data['type'] ?? 'status_update',
                        'status': data['status'] ?? '',
                      },
                    );
                    _onForegroundMessage?.call(message);
                  }
                }
              }
            }
          }
        });
  }

  void dispose() {
    _notificationSubscription?.cancel();
    _audioPlayer.dispose();
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final tenantId =
      ref.watch(tenantServiceProvider).valueOrNull?.tenantId ?? '';
  final service = NotificationService(tenantId);
  ref.onDispose(() => service.dispose());
  return service;
});
