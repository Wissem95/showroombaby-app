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