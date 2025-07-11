import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    @JsonKey(fromJson: _parseRequiredInt) required int id,
    @JsonKey(fromJson: _parseRequiredString) required String email,
    @JsonKey(fromJson: _parseRequiredString) required String username,
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