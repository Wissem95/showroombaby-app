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