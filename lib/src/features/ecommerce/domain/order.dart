import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';
part 'order.g.dart';

@freezed
abstract class Order with _$Order {
  const factory Order({
    required String id,
    required String userId,
    required String serviceId,
    required double amount,
    required String currency,
    required String status, // paid, pending, failed
    required String method, // stripe, subscription_credit
    @TimestampConverter() required DateTime createdAt,
    String? bookingId,
    String? stripeSessionId,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

class TimestampConverter implements JsonConverter<DateTime, Object> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is Timestamp) {
      return json.toDate();
    }
    return DateTime.parse(json as String);
  }

  @override
  Object toJson(DateTime object) => object.toIso8601String();
}
