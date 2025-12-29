import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'lead_client.freezed.dart';
part 'lead_client.g.dart';

enum LeadStatus {
  @JsonValue('lead_nao_cadastrado')
  leadNaoCadastrado,
  @JsonValue('converted')
  converted,
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

@freezed
abstract class LeadClient with _$LeadClient {
  const factory LeadClient({
    required String plate,
    required String phoneNumber,
    required String vehicleModel,
    required LeadStatus status,
    String? uid,
    String? fcmToken,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime lastServiceAt,
  }) = _LeadClient;

  factory LeadClient.fromJson(Map<String, dynamic> json) =>
      _$LeadClientFromJson(json);

  factory LeadClient.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeadClient.fromJson(data);
  }
}
