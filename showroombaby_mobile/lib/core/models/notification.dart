import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

enum NotificationType {
  @JsonValue('MESSAGE')
  message,
  @JsonValue('FAVORITE')
  favorite,
  @JsonValue('PRODUCT_SOLD')
  productSold,
  @JsonValue('SYSTEM')
  system,
}

@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required int id,
    required String title,
    required String content,
    required NotificationType type,
    required int userId,
    int? relatedId,
    @Default(false) bool read,
    @Default(false) bool archived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);
} 