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