import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'firebase_options.dart';
import 'src/config/stripe_config.dart';
import 'src/app.dart';
import 'src/features/notifications/data/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/features/onboarding/data/onboarding_repository.dart';

// Background handler must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Stripe
  Stripe.publishableKey = StripeConfig.publishableKey;
  await Stripe.instance.applySettings();

  // Initialize date formatting for pt_BR locale
  await initializeDateFormatting('pt_BR', null);

  // Set background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        onboardingRepositoryProvider.overrideWithValue(
          OnboardingRepository(sharedPreferences),
        ),
      ],
      child: const AquaCleanApp(),
    ),
  );
}
