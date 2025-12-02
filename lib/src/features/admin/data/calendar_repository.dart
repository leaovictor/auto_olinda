import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/calendar_config.dart';

part 'calendar_repository.g.dart';

class CalendarRepository {
  final FirebaseFirestore _firestore;

  CalendarRepository(this._firestore);

  Future<List<WeeklySchedule>> getWeeklySchedule() async {
    final snapshot = await _firestore
        .collection('config')
        .doc('calendar')
        .get();
    if (!snapshot.exists ||
        snapshot.data() == null ||
        !snapshot.data()!.containsKey('weeklySchedule')) {
      // Return default schedule if not configured
      return List.generate(
        7,
        (index) => WeeklySchedule(
          dayOfWeek: index + 1,
          isOpen: index < 5, // Mon-Fri open by default
          startHour: 8,
          endHour: 18,
          capacityPerHour: 2,
        ),
      );
    }

    final List<dynamic> data = snapshot.data()!['weeklySchedule'];
    return data.map((e) => WeeklySchedule.fromJson(e)).toList();
  }

  Future<void> saveWeeklySchedule(List<WeeklySchedule> schedule) async {
    await _firestore.collection('config').doc('calendar').set({
      'weeklySchedule': schedule.map((e) => e.toJson()).toList(),
    }, SetOptions(merge: true));
  }

  Future<List<BlockedDate>> getBlockedDates() async {
    final snapshot = await _firestore
        .collection('config')
        .doc('calendar')
        .collection('blocked_dates')
        .get();
    return snapshot.docs
        .map((doc) => BlockedDate.fromJson(doc.data()))
        .toList();
  }

  Future<void> blockDate(BlockedDate blockedDate) async {
    // Use date string as ID to prevent duplicates
    final dateId = blockedDate.date.toIso8601String().split('T')[0];
    await _firestore
        .collection('config')
        .doc('calendar')
        .collection('blocked_dates')
        .doc(dateId)
        .set(blockedDate.toJson());
  }

  Future<void> unblockDate(DateTime date) async {
    final dateId = date.toIso8601String().split('T')[0];
    await _firestore
        .collection('config')
        .doc('calendar')
        .collection('blocked_dates')
        .doc(dateId)
        .delete();
  }
}

@Riverpod(keepAlive: true)
CalendarRepository calendarRepository(Ref ref) {
  return CalendarRepository(ref.watch(firebaseFirestoreProvider));
}

@riverpod
Future<List<WeeklySchedule>> weeklySchedule(Ref ref) {
  return ref.watch(calendarRepositoryProvider).getWeeklySchedule();
}

@riverpod
Future<List<BlockedDate>> blockedDates(Ref ref) {
  return ref.watch(calendarRepositoryProvider).getBlockedDates();
}
