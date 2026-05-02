import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklySchedule {
  final int dayOfWeek; // 1=Mon, 7=Sun
  final bool isOpen;
  final int startHour;
  final int endHour;
  final int capacityPerHour;
  final List<TimeSlotConfig> slots;

  WeeklySchedule({
    required this.dayOfWeek,
    required this.isOpen,
    required this.startHour,
    required this.endHour,
    required this.capacityPerHour,
    this.slots = const [],
  });

  factory WeeklySchedule.fromJson(Map<String, dynamic> json) {
    return WeeklySchedule(
      dayOfWeek: json['dayOfWeek'] as int,
      isOpen: json['isOpen'] as bool? ?? false,
      startHour: json['startHour'] as int? ?? 8,
      endHour: json['endHour'] as int? ?? 18,
      capacityPerHour: json['capacityPerHour'] as int? ?? 1,
      slots: (json['slots'] as List?)
              ?.map((e) => TimeSlotConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek,
        'isOpen': isOpen,
        'startHour': startHour,
        'endHour': endHour,
        'capacityPerHour': capacityPerHour,
        'slots': slots.map((e) => e.toJson()).toList(),
      };
}

class TimeSlotConfig {
  final String time; // "HH:mm"
  final int capacity;
  final bool isBlocked;

  TimeSlotConfig({
    required this.time,
    required this.capacity,
    this.isBlocked = false,
  });

  factory TimeSlotConfig.fromJson(Map<String, dynamic> json) {
    return TimeSlotConfig(
      time: json['time'] as String,
      capacity: json['capacity'] as int? ?? 1,
      isBlocked: json['isBlocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'time': time,
        'capacity': capacity,
        'isBlocked': isBlocked,
      };
}

class BlockedDate {
  final String id;
  final DateTime date;
  final String reason;

  BlockedDate({
    required this.id,
    required this.date,
    required this.reason,
  });

  factory BlockedDate.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BlockedDate(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      reason: data['reason'] ?? '',
    );
  }
}
