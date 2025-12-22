import 'package:aquaclean_mobile/src/shared/utils/timestamp_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'address.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    @Default('client') String role,
    String? fcmToken,
    String? phoneNumber,
    String?
    assignedCompanyId, // ID of the company this user is associated with (as admin/staff)
    @Default(false) bool isWhatsApp,
    @Default('active') String status, // active, suspended, cancelled
    Address? address,
    String? ndaAcceptedVersion,
    @TimestampConverter() DateTime? ndaAcceptedAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
