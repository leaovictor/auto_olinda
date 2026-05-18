import 'package:freezed_annotation/freezed_annotation.dart';
import '../../auth/domain/address.dart';
import '../../../shared/utils/timestamp_converter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'store.freezed.dart';
part 'store.g.dart';

@freezed
class Store with _$Store {
  const factory Store({
    required String id,
    required String name,
    required String slug,
    required String ownerId,
    Address? address,
    String? logoUrl,
    String? bannerUrl,
    String? phoneNumber,
    String? whatsappNumber,
    @Default('active') String status,
    @TimestampConverter() DateTime? createdAt,
    @Default({}) Map<String, dynamic> settings,
  }) = _Store;

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);
}
