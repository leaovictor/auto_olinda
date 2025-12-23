import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/data/auth_repository.dart';
import '../../booking/data/booking_repository.dart';
import '../../booking/domain/booking.dart';
import '../../booking/domain/service_package.dart';
import '../../profile/domain/vehicle.dart';
import '../../services/data/independent_service_repository.dart';
import '../../services/domain/service_booking.dart';
import '../../subscription/data/subscription_repository.dart';
import '../domain/new_booking_notification_data.dart';

part 'new_booking_notification_service.g.dart';

/// A callback type for when a new booking notification should be displayed
typedef OnNewBookingCallback = void Function(NewBookingNotificationData data);

/// Service that monitors Firestore for new bookings and triggers notifications
/// Works globally across all admin screens
@Riverpod(keepAlive: true)
class NewBookingNotificationService extends _$NewBookingNotificationService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<QuerySnapshot>? _carWashSubscription;
  StreamSubscription<QuerySnapshot>? _aestheticSubscription;

  // Track IDs to avoid duplicate notifications
  final Set<String> _notifiedCarWashIds = {};
  final Set<String> _notifiedAestheticIds = {};

  // Callback to trigger UI notification
  OnNewBookingCallback? _onNewBooking;

  // Flag to indicate initial load is complete
  bool _carWashInitialized = false;
  bool _aestheticInitialized = false;

  @override
  void build() {
    ref.onDispose(() {
      _carWashSubscription?.cancel();
      _aestheticSubscription?.cancel();
      _audioPlayer.dispose();
    });
  }

  /// Set the callback for when a new booking is detected
  void setOnNewBookingCallback(OnNewBookingCallback callback) {
    _onNewBooking = callback;
  }

  /// Start listening for new bookings
  /// Should be called when admin panel is mounted
  void startListening() {
    _listenToCarWashBookings();
    _listenToAestheticBookings();
  }

  /// Stop listening for new bookings
  void stopListening() {
    _carWashSubscription?.cancel();
    _aestheticSubscription?.cancel();
    _carWashSubscription = null;
    _aestheticSubscription = null;
    _carWashInitialized = false;
    _aestheticInitialized = false;
  }

  /// Listen to car wash bookings (appointments collection)
  void _listenToCarWashBookings() {
    final firestore = FirebaseFirestore.instance;

    // Get bookings from the last 24 hours to avoid old notifications
    final yesterday = DateTime.now().subtract(const Duration(hours: 24));

    _carWashSubscription = firestore
        .collection('appointments')
        .where('scheduledTime', isGreaterThan: Timestamp.fromDate(yesterday))
        .orderBy('scheduledTime', descending: false)
        .snapshots()
        .listen(
          (snapshot) async {
            for (var change in snapshot.docChanges) {
              final docId = change.doc.id;

              // Skip if already notified
              if (_notifiedCarWashIds.contains(docId)) continue;

              // On initial load, just add IDs without notifying
              if (!_carWashInitialized) {
                _notifiedCarWashIds.add(docId);
                continue;
              }

              // Only notify for newly added documents
              if (change.type == DocumentChangeType.added) {
                _notifiedCarWashIds.add(docId);
                await _handleNewCarWashBooking(change.doc);
              }
            }

            _carWashInitialized = true;
          },
          onError: (e) {
            debugPrint(
              '🔔 NewBookingNotificationService: Error listening to car wash bookings: $e',
            );
          },
        );
  }

  /// Listen to aesthetic service bookings
  void _listenToAestheticBookings() {
    final firestore = FirebaseFirestore.instance;

    // Get bookings from the last 24 hours
    final yesterday = DateTime.now().subtract(const Duration(hours: 24));

    _aestheticSubscription = firestore
        .collection('service_bookings')
        .where('scheduledTime', isGreaterThan: Timestamp.fromDate(yesterday))
        .orderBy('scheduledTime', descending: false)
        .snapshots()
        .listen(
          (snapshot) async {
            for (var change in snapshot.docChanges) {
              final docId = change.doc.id;

              // Skip if already notified
              if (_notifiedAestheticIds.contains(docId)) continue;

              // On initial load, just add IDs without notifying
              if (!_aestheticInitialized) {
                _notifiedAestheticIds.add(docId);
                continue;
              }

              // Only notify for newly added documents
              if (change.type == DocumentChangeType.added) {
                _notifiedAestheticIds.add(docId);
                await _handleNewAestheticBooking(change.doc);
              }
            }

            _aestheticInitialized = true;
          },
          onError: (e) {
            debugPrint(
              '🔔 NewBookingNotificationService: Error listening to aesthetic bookings: $e',
            );
          },
        );
  }

  /// Handle a new car wash booking
  Future<void> _handleNewCarWashBooking(DocumentSnapshot doc) async {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return;

      // Parse the booking
      final booking = Booking.fromJson({
        ...data,
        'id': doc.id,
        'scheduledTime': (data['scheduledTime'] as Timestamp)
            .toDate()
            .toIso8601String(),
      });

      // Fetch user details
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.getUserProfile(booking.userId);

      // Fetch vehicle details
      Vehicle? vehicle;
      try {
        final bookingRepo = ref.read(bookingRepositoryProvider);
        vehicle = await bookingRepo.getVehicle(booking.vehicleId);
      } catch (e) {
        debugPrint('🔔 Could not fetch vehicle: $e');
      }

      // Fetch services
      final bookingRepo = ref.read(bookingRepositoryProvider);
      final serviceFutures = booking.serviceIds.map(
        (id) => bookingRepo.getService(id),
      );
      final fetchedServices = await Future.wait(serviceFutures);
      final services = fetchedServices.whereType<ServicePackage>().toList();

      // Fetch subscription info
      final subscriptionRepo = ref.read(subscriptionRepositoryProvider);
      final subscription = await subscriptionRepo.getAnyUserSubscription(
        booking.userId,
      );
      final plan = subscription != null
          ? await subscriptionRepo.getSubscriptionPlan(subscription.planId)
          : null;

      // Fetch booking history to determine if new or returning client
      final historyData = await _getClientBookingHistory(booking.userId);

      // Create notification data
      final notificationData = NewBookingNotificationData.fromCarWash(
        booking: booking,
        user: user,
        vehicle: vehicle,
        services: services,
        subscription: subscription,
        plan: plan,
        totalBookings: historyData['totalBookings'] as int,
        isNewClient: historyData['isNewClient'] as bool,
        isReturningAfterLongTime:
            historyData['isReturningAfterLongTime'] as bool,
        totalSpent: historyData['totalSpent'] as double,
      );

      // Trigger notification
      _triggerNotification(notificationData);
    } catch (e) {
      debugPrint(
        '🔔 NewBookingNotificationService: Error handling car wash booking: $e',
      );
    }
  }

  /// Handle a new aesthetic service booking
  Future<void> _handleNewAestheticBooking(DocumentSnapshot doc) async {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return;

      // Parse the booking
      final booking = ServiceBooking.fromJson({
        ...data,
        'id': doc.id,
        'scheduledTime': (data['scheduledTime'] as Timestamp)
            .toDate()
            .toIso8601String(),
        'createdAt': data['createdAt'] != null
            ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
            : null,
      });

      // Fetch service details
      final serviceRepo = ref.read(independentServiceRepositoryProvider);
      final service = await serviceRepo.getService(booking.serviceId);

      // Fetch subscription info
      final subscriptionRepo = ref.read(subscriptionRepositoryProvider);
      final subscription = await subscriptionRepo.getAnyUserSubscription(
        booking.userId,
      );
      final plan = subscription != null
          ? await subscriptionRepo.getSubscriptionPlan(subscription.planId)
          : null;

      // Fetch booking history to determine if new or returning client
      final historyData = await _getClientBookingHistory(booking.userId);

      // Create notification data
      final notificationData = NewBookingNotificationData.fromAesthetic(
        booking: booking,
        service: service,
        subscription: subscription,
        plan: plan,
        totalBookings: historyData['totalBookings'] as int,
        isNewClient: historyData['isNewClient'] as bool,
        isReturningAfterLongTime:
            historyData['isReturningAfterLongTime'] as bool,
        totalSpent: historyData['totalSpent'] as double,
      );

      // Trigger notification
      _triggerNotification(notificationData);
    } catch (e) {
      debugPrint(
        '🔔 NewBookingNotificationService: Error handling aesthetic booking: $e',
      );
    }
  }

  /// Fetches the client's booking history and returns analysis data
  Future<Map<String, dynamic>> _getClientBookingHistory(String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Fetch all car wash bookings
      final carWashDocs = await firestore
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .get();

      // Fetch all aesthetic bookings
      final aestheticDocs = await firestore
          .collection('service_bookings')
          .where('userId', isEqualTo: userId)
          .get();

      final totalBookings = carWashDocs.docs.length + aestheticDocs.docs.length;

      // Calculate total spent
      double totalSpent = 0.0;
      for (var doc in carWashDocs.docs) {
        totalSpent += (doc.data()['totalPrice'] as num?)?.toDouble() ?? 0.0;
      }
      for (var doc in aestheticDocs.docs) {
        totalSpent += (doc.data()['totalPrice'] as num?)?.toDouble() ?? 0.0;
      }

      // Determine if this is a new client (first booking)
      final isNewClient = totalBookings <= 1;

      // Check if returning after a long time (last booking > 60 days ago)
      bool isReturningAfterLongTime = false;
      if (!isNewClient) {
        final sixtyDaysAgo = DateTime.now().subtract(const Duration(days: 60));

        DateTime? lastBookingTime;

        // Find the second most recent car wash booking
        if (carWashDocs.docs.length > 1) {
          final sortedDocs = carWashDocs.docs.toList()
            ..sort((a, b) {
              final aTime = (a.data()['scheduledTime'] as Timestamp?)?.toDate();
              final bTime = (b.data()['scheduledTime'] as Timestamp?)?.toDate();
              if (aTime == null || bTime == null) return 0;
              return bTime.compareTo(aTime); // Descending
            });

          if (sortedDocs.length > 1) {
            final timestamp =
                sortedDocs[1].data()['scheduledTime'] as Timestamp?;
            if (timestamp != null) {
              lastBookingTime = timestamp.toDate();
            }
          }
        }

        // Find the second most recent aesthetic booking
        if (aestheticDocs.docs.length > 1) {
          final sortedDocs = aestheticDocs.docs.toList()
            ..sort((a, b) {
              final aTime = (a.data()['scheduledTime'] as Timestamp?)?.toDate();
              final bTime = (b.data()['scheduledTime'] as Timestamp?)?.toDate();
              if (aTime == null || bTime == null) return 0;
              return bTime.compareTo(aTime); // Descending
            });

          if (sortedDocs.length > 1) {
            final timestamp =
                sortedDocs[1].data()['scheduledTime'] as Timestamp?;
            if (timestamp != null) {
              final aestheticTime = timestamp.toDate();
              if (lastBookingTime == null ||
                  aestheticTime.isAfter(lastBookingTime)) {
                lastBookingTime = aestheticTime;
              }
            }
          }
        }

        if (lastBookingTime != null && lastBookingTime.isBefore(sixtyDaysAgo)) {
          isReturningAfterLongTime = true;
        }
      }

      return {
        'totalBookings': totalBookings,
        'isNewClient': isNewClient,
        'isReturningAfterLongTime': isReturningAfterLongTime,
        'totalSpent': totalSpent,
      };
    } catch (e) {
      debugPrint('🔔 Error fetching client history: $e');
      return {
        'totalBookings': 0,
        'isNewClient': false,
        'isReturningAfterLongTime': false,
        'totalSpent': 0.0,
      };
    }
  }

  /// Trigger the notification with sound and callback
  void _triggerNotification(NewBookingNotificationData data) {
    debugPrint(
      '🔔 NEW BOOKING DETECTED: ${data.bookingId} - ${data.clientName}',
    );

    // Play alert sound based on booking type
    _playAlertSound(data.type);

    // Trigger callback
    _onNewBooking?.call(data);
  }

  /// Play the alert sound based on booking type
  Future<void> _playAlertSound(NewBookingType type) async {
    try {
      final audioFile = type == NewBookingType.carWash
          ? 'audio/agenda.mp3'
          : 'audio/bell-notification-430417.mp3';

      await _audioPlayer.play(AssetSource(audioFile));
      debugPrint('🔔 Alert sound played: $audioFile');
    } catch (e) {
      debugPrint('🔔 Error playing alert sound: $e');
    }
  }
}
