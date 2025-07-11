import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';
import 'message.dart';
import 'product.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    required User otherUser,
    required Message lastMessage,
    @JsonKey(fromJson: _parseUnreadCount) @Default(0) int unreadCount,
    Product? product,
    @Default(false) bool isArchived,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);
}

int _parseUnreadCount(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
} 