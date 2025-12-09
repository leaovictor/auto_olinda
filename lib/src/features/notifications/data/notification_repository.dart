import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/user_notification.dart';

/// Repository for managing user notifications
class NotificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotificationRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Get stream of user notifications
  Stream<List<UserNotification>> watchNotifications() {
    final userId = _userId;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            // Handle Firestore Timestamp conversion
            DateTime timestamp;
            if (data['timestamp'] is Timestamp) {
              timestamp = (data['timestamp'] as Timestamp).toDate();
            } else {
              timestamp = DateTime.now();
            }

            return UserNotification(
              id: doc.id,
              title: data['title'] ?? '',
              body: data['body'] ?? '',
              isRead: data['isRead'] ?? false,
              timestamp: timestamp,
              bookingId: data['bookingId'],
              type: data['type'] ?? 'info',
            );
          }).toList();
        });
  }

  /// Get count of unread notifications
  Stream<int> watchUnreadCount() {
    final userId = _userId;
    if (userId == null) return Stream.value(0);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    final userId = _userId;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final userId = _userId;
    if (userId == null) return;

    final batch = _firestore.batch();
    final unread = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }
}

// Providers
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final userNotificationsProvider = StreamProvider<List<UserNotification>>((ref) {
  return ref.watch(notificationRepositoryProvider).watchNotifications();
});

final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  return ref.watch(notificationRepositoryProvider).watchUnreadCount();
});
