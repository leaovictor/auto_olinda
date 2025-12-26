// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fcm_notification_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FcmNotificationLog _$FcmNotificationLogFromJson(Map<String, dynamic> json) =>
    _FcmNotificationLog(
      id: json['id'] as String,
      userId: json['userId'] as String,
      notificationType: json['notificationType'] as String,
      bookingId: json['bookingId'] as String?,
      sentAt: const TimestampConverter().fromJson(json['sentAt']),
      delivered: json['delivered'] as bool? ?? true,
      title: json['title'] as String?,
      body: json['body'] as String?,
    );

Map<String, dynamic> _$FcmNotificationLogToJson(_FcmNotificationLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'notificationType': instance.notificationType,
      'bookingId': instance.bookingId,
      'sentAt': const TimestampConverter().toJson(instance.sentAt),
      'delivered': instance.delivered,
      'title': instance.title,
      'body': instance.body,
    };
