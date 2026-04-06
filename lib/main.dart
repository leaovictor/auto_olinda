import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'src/config/stripe_config.dart';
import 'src/app.dart';
import 'src/features/onboarding/data/onboarding_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Background handler must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure path-based URL strategy for SEO (removes # from URLs)
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Connect to Firebase Emulators in Debug Mode
  if (kDebugMode) {
    try {
      final host = kIsWeb ? 'localhost' : '10.0.2.2';
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
      FirebaseStorage.instance.useStorageEmulator(host, 9199);
      debugPrint('🔥 Connected to Firebase Emulators ($host)');
    } catch (e) {
      debugPrint('🔥 Failed to connect to Firebase Emulators: $e');
    }
  }

  // Initialize Stripe with default key first to ensure basic functionality
  Stripe.publishableKey = StripeConfig.publishableKey;
  await Stripe.instance.applySettings();

  // Note: Dynamic key fetching will happen inside the app (e.g. at Splash or Home),
  // or via StripeConfigService when needed.
  // The 'getPublicStripeConfig' function requires the user to be (likely) initialized/auth?
  // If we call it here, it might fail if auth is not ready or if it's too early.
  // We will keep the default static key for startup and let the app refresh it later.

  // Initialize date formatting for pt_BR locale
  await initializeDateFormatting('pt_BR', null);

  // Set background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
