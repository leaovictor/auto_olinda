import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_tag.freezed.dart';
part 'review_tag.g.dart';

/// Tag que pode ser selecionada pelo cliente ao avaliar um serviço
/// Similar ao sistema de tags do iFood (ex: "Entrega Rápida", "Super Atencioso")
@freezed
abstract class ReviewTag with _$ReviewTag {
  const factory ReviewTag({
    required String id,
    required String label, // Ex: "Serviço Rápido"
    required String emoji, // Ex: "⭐"
    @Default(true) bool isActive, // Controle de ativação/desativação
    @Default(0) int displayOrder, // Ordem de exibição
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _ReviewTag;

  factory ReviewTag.fromJson(Map<String, dynamic> json) =>
      _$ReviewTagFromJson(json);
}
