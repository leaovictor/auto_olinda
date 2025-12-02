import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_event.freezed.dart';
part 'admin_event.g.dart';

enum AdminEventType { task, payment, meeting, other }

@freezed
class AdminEvent with _$AdminEvent {
  const factory AdminEvent({
    required String id,
    required String title,
    String? description,
    required DateTime date,
    DateTime? remindAt,
    @Default(AdminEventType.task) AdminEventType type,
    @Default(false) bool isDone,
  }) = _AdminEvent;

  factory AdminEvent.fromJson(Map<String, dynamic> json) =>
      _$AdminEventFromJson(json);
}
