import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_image.freezed.dart';
part 'product_image.g.dart';

@freezed
class ProductImage with _$ProductImage {
  const factory ProductImage({
    @JsonKey(fromJson: _parseRequiredInt) required int id,
    @JsonKey(name: 'product_id', fromJson: _parseRequiredInt) required int productId,
    required String path,
    required String url,
    @JsonKey(name: 'is_primary') @Default(false) bool isPrimary,
    @JsonKey(fromJson: _parseInt) @Default(0) int order,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _ProductImage;

  factory ProductImage.fromJson(Map<String, dynamic> json) => _$ProductImageFromJson(json);
}

// Fonctions helper pour parsing sécurisé
int _parseRequiredInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  if (value == null) return 0; // Retourner 0 au lieu de lancer une exception
  return 0;
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
} 