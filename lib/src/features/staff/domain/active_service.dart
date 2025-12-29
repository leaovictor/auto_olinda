import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'active_service.freezed.dart';
part 'active_service.g.dart';

enum ServiceStatus {
  @JsonValue('fila')
  fila,
  @JsonValue('lavando')
  lavando,
  @JsonValue('pronto')
  pronto,
  @JsonValue('entregue')
  entregue,
}

class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

class NullableTimestampConverter
    implements JsonConverter<DateTime?, Timestamp?> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(Timestamp? timestamp) {
    return timestamp?.toDate();
  }

  @override
  Timestamp? toJson(DateTime? date) =>
      date != null ? Timestamp.fromDate(date) : null;
}

@freezed
abstract class ActiveService with _$ActiveService {
  factory ActiveService({
    required String id,
    @Default('') String plate,
    @Default('') String vehicleModel,
    @Default(ServiceStatus.fila) ServiceStatus status,
    @TimestampConverter() required DateTime startedAt,
    @NullableTimestampConverter() DateTime? finishedAt,
    @Default('') String staffId,
    @Default('') String serviceType,
    @Default([]) List<String> photos,
    @Default('') String clientLink,
  }) = _ActiveService;

  factory ActiveService.fromJson(Map<String, dynamic> json) =>
      _$ActiveServiceFromJson(json);

  factory ActiveService.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActiveService.fromJson(data..['id'] = doc.id);
  }
}
