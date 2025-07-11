import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';
import 'product.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@freezed
class Message with _$Message {
  const factory Message({
    @JsonKey(fromJson: _parseRequiredInt) required int id,
    @JsonKey(fromJson: _parseRequiredString) required String content,
    @JsonKey(fromJson: _parseRequiredInt) required int senderId,
    @JsonKey(fromJson: _parseRequiredInt) required int recipientId,
    @JsonKey(fromJson: _parseOptionalInt) int? productId,
    @Default(false) bool read,
    @Default(false) bool archivedBySender,
    @Default(false) bool archivedByRecipient,
    User? sender,
    User? recipient,
    Product? product,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
}

String _parseRequiredString(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  return value.toString(); // Convertir en string si c'est un autre type
}

int _parseRequiredInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  if (value == null) return 0; // Retourner 0 au lieu de lancer une exception
  return 0;
}

int? _parseOptionalInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
} 