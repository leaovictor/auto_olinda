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

      // Create notification data
      final notificationData = NewBookingNotificationData.fromCarWash(
        booking: booking,
        user: user,
        vehicle: vehicle,
        services: services,
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

      // Create notification data
      final notificationData = NewBookingNotificationData.fromAesthetic(
        booking: booking,
        service: service,
      );

      // Trigger notification
      _triggerNotification(notificationData);
    } catch (e) {
      debugPrint(
        '🔔 NewBookingNotificationService: Error handling aesthetic booking: $e',
      );
    }
  }

  /// Trigger the notification with sound and callback
  void _triggerNotification(NewBookingNotificationData data) {
    debugPrint(
      '🔔 NEW BOOKING DETECTED: ${data.bookingId} - ${data.clientName}',
    );

    // Play alert sound
    _playAlertSound();

    // Trigger callback
    _onNewBooking?.call(data);
  }

  /// Play the alert sound
  Future<void> _playAlertSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/agenda.mp3'));
      debugPrint('🔔 Alert sound played');
    } catch (e) {
      debugPrint('🔔 Error playing alert sound: $e');
    }
  }
}
