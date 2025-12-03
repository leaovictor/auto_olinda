import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic timestamp) {
    if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    // Handle Firestore Timestamp
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    // Handle int (millisecondsSinceEpoch)
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return DateTime.now(); // Fallback
  }

  @override
  dynamic toJson(DateTime date) => date.toIso8601String();
}
