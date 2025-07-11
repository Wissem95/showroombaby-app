# 📦 Modèles de Données - ShowroomBaby

## Modèles principaux avec Freezed

### 1. User Model (core/models/user.dart)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required int id,
    required String email,
    required String username,
    String? name,
    String? firstName,
    String? lastName,
    String? avatar,
    String? phone,
    String? street,
    String? city,
    String? zipcode,
    String? country,
    double? latitude,
    double? longitude,
    double? rating,
    @Default('USER') String role,
    @Default(false) bool isEmailVerified,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

### 2. Product Model (core/models/product.dart)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';
import 'category.dart';
import 'product_image.dart';

part 'product.freezed.dart';
part 'product.g.dart';

enum ProductCondition {
  @JsonValue('NEW')
  newCondition,
  @JsonValue('LIKE_NEW')
  likeNew,
  @JsonValue('GOOD')
  good,
  @JsonValue('FAIR')
  fair,
}

enum ProductStatus {
  @JsonValue('DRAFT')
  draft,
  @JsonValue('PUBLISHED')
  published,
  @JsonValue('SOLD')
  sold,
  @JsonValue('ARCHIVED')
  archived,
}

@freezed
class Product with _$Product {
  const factory Product({
    required int id,
    required String title,
    required String description,
    required double price,
    required ProductCondition condition,
    required ProductStatus status,
    required int userId,
    required int categoryId,
    int? subcategoryId,
    String? brand,
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? zipcode,
    String? phone,
    @Default(false) bool hidePhone,
    @Default(0) int viewCount,
    User? seller,
    Category? category,
    Category? subcategory,
    @Default([]) List<ProductImage> images,
    @Default(false) bool isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}
```

### 3. Category Model (core/models/category.dart)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
class Category with _$Category {
  const factory Category({
    required int id,
    required String name,
    String? description,
    String? icon,
    int? parentId,
    @Default([]) List<Category> subcategories,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}
```

### 4. ProductImage Model (core/models/product_image.dart)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_image.freezed.dart';
part 'product_image.g.dart';

@freezed
class ProductImage with _$ProductImage {
  const factory ProductImage({
    required int id,
    required int productId,
    required String path,
    required String url,
    @Default(false) bool isPrimary,
    @Default(0) int order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProductImage;

  factory ProductImage.fromJson(Map<String, dynamic> json) => _$ProductImageFromJson(json);
}
```

### 5. Message Model (core/models/message.dart)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';
import 'product.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@freezed
class Message with _$Message {
  const factory Message({
    required int id,
    required String content,
    required int senderId,
    required int recipientId,
    int? productId,
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
```

### 6. Conversation Model (core/models/conversation.dart)

```dart
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
    required int unreadCount,
    Product? product,
    @Default(false) bool isArchived,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);
}
```

### 7. Notification Model (core/models/notification.dart)

```dart
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
```

### 8. Favorite Model (core/models/favorite.dart)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'product.dart';
import 'user.dart';

part 'favorite.freezed.dart';
part 'favorite.g.dart';

@freezed
class Favorite with _$Favorite {
  const factory Favorite({
    required int id,
    required int userId,
    required int productId,
    Product? product,
    User? user,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Favorite;

  factory Favorite.fromJson(Map<String, dynamic> json) => _$FavoriteFromJson(json);
}
```

### 9. Report Model (core/models/report.dart)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';
import 'product.dart';

part 'report.freezed.dart';
part 'report.g.dart';

enum ReportReason {
  @JsonValue('inappropriate')
  inappropriate,
  @JsonValue('fake')
  fake,
  @JsonValue('offensive')
  offensive,
  @JsonValue('spam')
  spam,
  @JsonValue('other')
  other,
}

@freezed
class Report with _$Report {
  const factory Report({
    required int id,
    required int reporterId,
    required int productId,
    required ReportReason reason,
    String? description,
    User? reporter,
    Product? product,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
}
```

### 10. Modèles de réponse API (core/models/api_response.dart)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

@freezed
class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    required bool success,
    String? message,
    T? data,
    Map<String, dynamic>? meta,
    List<String>? errors,
  }) = _ApiResponse<T>;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);
}

@freezed
class PaginatedResponse<T> with _$PaginatedResponse<T> {
  const factory PaginatedResponse({
    required List<T> items,
    required int total,
    required int page,
    required int limit,
    required int totalPages,
  }) = _PaginatedResponse<T>;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$PaginatedResponseFromJson(json, fromJsonT);
}

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String accessToken,
    required User user,
    String? message,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
}
```

### 11. Modèles de filtres (core/models/filters.dart)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'product.dart';

part 'filters.freezed.dart';
part 'filters.g.dart';

@freezed
class ProductFilters with _$ProductFilters {
  const factory ProductFilters({
    String? query,
    int? categoryId,
    int? subcategoryId,
    double? minPrice,
    double? maxPrice,
    ProductCondition? condition,
    double? latitude,
    double? longitude,
    double? radius,
    String? sortBy, // 'price', 'date', 'views', 'distance'
  }) = _ProductFilters;

  factory ProductFilters.fromJson(Map<String, dynamic> json) => _$ProductFiltersFromJson(json);
}

@freezed
class LocationData with _$LocationData {
  const factory LocationData({
    required double latitude,
    required double longitude,
    String? address,
    String? city,
    String? zipcode,
  }) = _LocationData;

  factory LocationData.fromJson(Map<String, dynamic> json) => _$LocationDataFromJson(json);
}
```

## Instructions d'utilisation

1. Créez tous ces fichiers dans le dossier `core/models/`
2. Ajoutez les imports nécessaires
3. Exécutez `flutter pub run build_runner build` pour générer les fichiers `.freezed.dart` et `.g.dart`
4. Ces modèles couvrent toutes les entités de votre backend Laravel
5. Utilisez ces modèles dans vos providers et services

Les modèles sont maintenant prêts pour être utilisés avec Riverpod et votre API !
