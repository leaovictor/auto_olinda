import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../features/booking/domain/booking.dart';
import '../../../features/notifications/domain/user_notification.dart';

// Conditional import for platform detection (web-safe)
import 'notification_platform_helper.dart';

class NotificationService {
  // These fields must be nullable or late initialized if we want to avoid initialization on unsupported platforms
  // But since they are final, we initialize them.
  // However, accessing .instance might crash on Linux for some plugins.
  // Let's use lazy initialization or try-catch if needed.
  // For now, we assume .instance is safe to call but methods might fail,
  // OR we just don't use them if platform is not supported.

  // FirebaseMessaging.instance might throw on Linux if not supported.
  // So we should only access it if supported.
  FirebaseMessaging? _firebaseMessaging;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _notificationSubscription;

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
    debugPrint(
      '📱 NotificationService: Handling notification tap with payload: $payload',
    );
    _onNotificationTap?.call(payload);
  }

  Future<void> initialize() async {
    // Desktop platforms don't support Firebase Messaging
    if (!kIsWeb && isDesktopPlatform()) {
      debugPrint('📱 NotificationService: Desktop platform - skipping');
      return;
    }

    try {
      _firebaseMessaging = FirebaseMessaging.instance;
    } catch (e) {
      debugPrint(
        '📱 NotificationService: Failed to get FirebaseMessaging instance: $e',
      );
      return;
    }

    // 1. Request Permission
    NotificationSettings settings = await _firebaseMessaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('📱 NotificationService: Permission granted');
    } else {
      debugPrint('📱 NotificationService: Permission denied');
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
          debugPrint(
            '📱 NotificationService: Notification tapped - ${response.payload}',
          );
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
        final granted = await androidPlugin.requestNotificationsPermission();
        debugPrint(
          '📱 NotificationService: Android notification permission granted: $granted',
        );
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
    } else {
      debugPrint('📱 NotificationService: Web platform - using FCM web push');
      // On web, foreground messages are handled via callback (to show toast)
      // Background messages are handled by the service worker
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('📱 Web foreground message: ${message.notification?.title}');
        // Call the callback to show in-app notification (e.g., toast)
        _onForegroundMessage?.call(message);
      });
    }

    // 4. Token Refresh Handler
    _firebaseMessaging!.onTokenRefresh.listen((newToken) {
      debugPrint('📱 NotificationService: Token refreshed');
      _saveTokenToDatabase(newToken);
    });

    // 5. Get and save initial token
    await saveCurrentToken();
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
        debugPrint('📱 NotificationService: Got FCM token');
      }
      return token;
    } catch (e) {
      debugPrint('📱 NotificationService: Error getting token: $e');
      return null;
    }
  }

  Future<void> _saveTokenToDatabase(String token) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
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
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': FieldValue.delete(),
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        debugPrint(
          '📱 NotificationService: Token removed for user ${user.uid}',
        );
      } catch (e) {
        debugPrint('📱 NotificationService: Error removing token: $e');
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

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add(notification.toJson());
  }

  void listenToUserNotifications(String userId) {
    _notificationSubscription?.cancel();
    _notificationSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
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
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  ref.onDispose(() => service.dispose());
  return service;
});
