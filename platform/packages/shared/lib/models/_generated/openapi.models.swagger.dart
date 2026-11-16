// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

import 'dart:convert';

import 'openapi.enums.swagger.dart' as enums;

part 'openapi.models.swagger.g.dart';

@JsonSerializable(explicitToJson: true)
class ApiError {
  const ApiError({required this.message, this.code});

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);

  static const toJsonFactory = _$ApiErrorToJson;
  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);

  @JsonKey(name: 'message')
  final String message;
  @JsonKey(name: 'code')
  final String? code;
  static const fromJsonFactory = _$ApiErrorFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiError &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(
                  other.message,
                  message,
                )) &&
            (identical(other.code, code) ||
                const DeepCollectionEquality().equals(other.code, code)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(message) ^
      const DeepCollectionEquality().hash(code) ^
      runtimeType.hashCode;
}

extension $ApiErrorExtension on ApiError {
  ApiError copyWith({String? message, String? code}) {
    return ApiError(message: message ?? this.message, code: code ?? this.code);
  }

  ApiError copyWithWrapped({Wrapped<String>? message, Wrapped<String?>? code}) {
    return ApiError(
      message: (message != null ? message.value : this.message),
      code: (code != null ? code.value : this.code),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class FarmProfile {
  const FarmProfile({
    this.id,
    this.ownerUser,
    this.farmName,
    this.farmSize,
    this.farmType,
    this.country,
    this.region,
    this.gpsLat,
    this.gpsLng,
    this.primaryCrop,
    this.secondaryCrop,
    this.createdAt,
    this.updatedAt,
  });

  factory FarmProfile.fromJson(Map<String, dynamic> json) =>
      _$FarmProfileFromJson(json);

  static const toJsonFactory = _$FarmProfileToJson;
  Map<String, dynamic> toJson() => _$FarmProfileToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'owner_user')
  final String? ownerUser;
  @JsonKey(name: 'farm_name')
  final String? farmName;
  @JsonKey(name: 'farm_size')
  final double? farmSize;
  @JsonKey(name: 'farm_type')
  final String? farmType;
  @JsonKey(name: 'country')
  final String? country;
  @JsonKey(name: 'region')
  final String? region;
  @JsonKey(name: 'gps_lat')
  final double? gpsLat;
  @JsonKey(name: 'gps_lng')
  final double? gpsLng;
  @JsonKey(name: 'primary_crop')
  final String? primaryCrop;
  @JsonKey(name: 'secondary_crop')
  final String? secondaryCrop;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  static const fromJsonFactory = _$FarmProfileFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is FarmProfile &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.ownerUser, ownerUser) ||
                const DeepCollectionEquality().equals(
                  other.ownerUser,
                  ownerUser,
                )) &&
            (identical(other.farmName, farmName) ||
                const DeepCollectionEquality().equals(
                  other.farmName,
                  farmName,
                )) &&
            (identical(other.farmSize, farmSize) ||
                const DeepCollectionEquality().equals(
                  other.farmSize,
                  farmSize,
                )) &&
            (identical(other.farmType, farmType) ||
                const DeepCollectionEquality().equals(
                  other.farmType,
                  farmType,
                )) &&
            (identical(other.country, country) ||
                const DeepCollectionEquality().equals(
                  other.country,
                  country,
                )) &&
            (identical(other.region, region) ||
                const DeepCollectionEquality().equals(other.region, region)) &&
            (identical(other.gpsLat, gpsLat) ||
                const DeepCollectionEquality().equals(other.gpsLat, gpsLat)) &&
            (identical(other.gpsLng, gpsLng) ||
                const DeepCollectionEquality().equals(other.gpsLng, gpsLng)) &&
            (identical(other.primaryCrop, primaryCrop) ||
                const DeepCollectionEquality().equals(
                  other.primaryCrop,
                  primaryCrop,
                )) &&
            (identical(other.secondaryCrop, secondaryCrop) ||
                const DeepCollectionEquality().equals(
                  other.secondaryCrop,
                  secondaryCrop,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(ownerUser) ^
      const DeepCollectionEquality().hash(farmName) ^
      const DeepCollectionEquality().hash(farmSize) ^
      const DeepCollectionEquality().hash(farmType) ^
      const DeepCollectionEquality().hash(country) ^
      const DeepCollectionEquality().hash(region) ^
      const DeepCollectionEquality().hash(gpsLat) ^
      const DeepCollectionEquality().hash(gpsLng) ^
      const DeepCollectionEquality().hash(primaryCrop) ^
      const DeepCollectionEquality().hash(secondaryCrop) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      runtimeType.hashCode;
}

extension $FarmProfileExtension on FarmProfile {
  FarmProfile copyWith({
    String? id,
    String? ownerUser,
    String? farmName,
    double? farmSize,
    String? farmType,
    String? country,
    String? region,
    double? gpsLat,
    double? gpsLng,
    String? primaryCrop,
    String? secondaryCrop,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FarmProfile(
      id: id ?? this.id,
      ownerUser: ownerUser ?? this.ownerUser,
      farmName: farmName ?? this.farmName,
      farmSize: farmSize ?? this.farmSize,
      farmType: farmType ?? this.farmType,
      country: country ?? this.country,
      region: region ?? this.region,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      primaryCrop: primaryCrop ?? this.primaryCrop,
      secondaryCrop: secondaryCrop ?? this.secondaryCrop,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  FarmProfile copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String?>? ownerUser,
    Wrapped<String?>? farmName,
    Wrapped<double?>? farmSize,
    Wrapped<String?>? farmType,
    Wrapped<String?>? country,
    Wrapped<String?>? region,
    Wrapped<double?>? gpsLat,
    Wrapped<double?>? gpsLng,
    Wrapped<String?>? primaryCrop,
    Wrapped<String?>? secondaryCrop,
    Wrapped<DateTime?>? createdAt,
    Wrapped<DateTime?>? updatedAt,
  }) {
    return FarmProfile(
      id: (id != null ? id.value : this.id),
      ownerUser: (ownerUser != null ? ownerUser.value : this.ownerUser),
      farmName: (farmName != null ? farmName.value : this.farmName),
      farmSize: (farmSize != null ? farmSize.value : this.farmSize),
      farmType: (farmType != null ? farmType.value : this.farmType),
      country: (country != null ? country.value : this.country),
      region: (region != null ? region.value : this.region),
      gpsLat: (gpsLat != null ? gpsLat.value : this.gpsLat),
      gpsLng: (gpsLng != null ? gpsLng.value : this.gpsLng),
      primaryCrop: (primaryCrop != null ? primaryCrop.value : this.primaryCrop),
      secondaryCrop: (secondaryCrop != null
          ? secondaryCrop.value
          : this.secondaryCrop),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class FarmProfileCreate {
  const FarmProfileCreate({
    this.farmName,
    this.farmSize,
    this.farmType,
    this.country,
    this.region,
    this.gpsLat,
    this.gpsLng,
    this.primaryCrop,
    this.secondaryCrop,
  });

  factory FarmProfileCreate.fromJson(Map<String, dynamic> json) =>
      _$FarmProfileCreateFromJson(json);

  static const toJsonFactory = _$FarmProfileCreateToJson;
  Map<String, dynamic> toJson() => _$FarmProfileCreateToJson(this);

  @JsonKey(name: 'farm_name')
  final String? farmName;
  @JsonKey(name: 'farm_size')
  final double? farmSize;
  @JsonKey(name: 'farm_type')
  final String? farmType;
  @JsonKey(name: 'country')
  final String? country;
  @JsonKey(name: 'region')
  final String? region;
  @JsonKey(name: 'gps_lat')
  final double? gpsLat;
  @JsonKey(name: 'gps_lng')
  final double? gpsLng;
  @JsonKey(name: 'primary_crop')
  final String? primaryCrop;
  @JsonKey(name: 'secondary_crop')
  final String? secondaryCrop;
  static const fromJsonFactory = _$FarmProfileCreateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is FarmProfileCreate &&
            (identical(other.farmName, farmName) ||
                const DeepCollectionEquality().equals(
                  other.farmName,
                  farmName,
                )) &&
            (identical(other.farmSize, farmSize) ||
                const DeepCollectionEquality().equals(
                  other.farmSize,
                  farmSize,
                )) &&
            (identical(other.farmType, farmType) ||
                const DeepCollectionEquality().equals(
                  other.farmType,
                  farmType,
                )) &&
            (identical(other.country, country) ||
                const DeepCollectionEquality().equals(
                  other.country,
                  country,
                )) &&
            (identical(other.region, region) ||
                const DeepCollectionEquality().equals(other.region, region)) &&
            (identical(other.gpsLat, gpsLat) ||
                const DeepCollectionEquality().equals(other.gpsLat, gpsLat)) &&
            (identical(other.gpsLng, gpsLng) ||
                const DeepCollectionEquality().equals(other.gpsLng, gpsLng)) &&
            (identical(other.primaryCrop, primaryCrop) ||
                const DeepCollectionEquality().equals(
                  other.primaryCrop,
                  primaryCrop,
                )) &&
            (identical(other.secondaryCrop, secondaryCrop) ||
                const DeepCollectionEquality().equals(
                  other.secondaryCrop,
                  secondaryCrop,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(farmName) ^
      const DeepCollectionEquality().hash(farmSize) ^
      const DeepCollectionEquality().hash(farmType) ^
      const DeepCollectionEquality().hash(country) ^
      const DeepCollectionEquality().hash(region) ^
      const DeepCollectionEquality().hash(gpsLat) ^
      const DeepCollectionEquality().hash(gpsLng) ^
      const DeepCollectionEquality().hash(primaryCrop) ^
      const DeepCollectionEquality().hash(secondaryCrop) ^
      runtimeType.hashCode;
}

extension $FarmProfileCreateExtension on FarmProfileCreate {
  FarmProfileCreate copyWith({
    String? farmName,
    double? farmSize,
    String? farmType,
    String? country,
    String? region,
    double? gpsLat,
    double? gpsLng,
    String? primaryCrop,
    String? secondaryCrop,
  }) {
    return FarmProfileCreate(
      farmName: farmName ?? this.farmName,
      farmSize: farmSize ?? this.farmSize,
      farmType: farmType ?? this.farmType,
      country: country ?? this.country,
      region: region ?? this.region,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      primaryCrop: primaryCrop ?? this.primaryCrop,
      secondaryCrop: secondaryCrop ?? this.secondaryCrop,
    );
  }

  FarmProfileCreate copyWithWrapped({
    Wrapped<String?>? farmName,
    Wrapped<double?>? farmSize,
    Wrapped<String?>? farmType,
    Wrapped<String?>? country,
    Wrapped<String?>? region,
    Wrapped<double?>? gpsLat,
    Wrapped<double?>? gpsLng,
    Wrapped<String?>? primaryCrop,
    Wrapped<String?>? secondaryCrop,
  }) {
    return FarmProfileCreate(
      farmName: (farmName != null ? farmName.value : this.farmName),
      farmSize: (farmSize != null ? farmSize.value : this.farmSize),
      farmType: (farmType != null ? farmType.value : this.farmType),
      country: (country != null ? country.value : this.country),
      region: (region != null ? region.value : this.region),
      gpsLat: (gpsLat != null ? gpsLat.value : this.gpsLat),
      gpsLng: (gpsLng != null ? gpsLng.value : this.gpsLng),
      primaryCrop: (primaryCrop != null ? primaryCrop.value : this.primaryCrop),
      secondaryCrop: (secondaryCrop != null
          ? secondaryCrop.value
          : this.secondaryCrop),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class FarmProfileListResponse {
  const FarmProfileListResponse({
    required this.data,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory FarmProfileListResponse.fromJson(Map<String, dynamic> json) =>
      _$FarmProfileListResponseFromJson(json);

  static const toJsonFactory = _$FarmProfileListResponseToJson;
  Map<String, dynamic> toJson() => _$FarmProfileListResponseToJson(this);

  @JsonKey(name: 'data', defaultValue: <FarmProfile>[])
  final List<FarmProfile> data;
  @JsonKey(name: 'limit')
  final int limit;
  @JsonKey(name: 'offset')
  final int offset;
  @JsonKey(name: 'total')
  final int total;
  static const fromJsonFactory = _$FarmProfileListResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is FarmProfileListResponse &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)) &&
            (identical(other.limit, limit) ||
                const DeepCollectionEquality().equals(other.limit, limit)) &&
            (identical(other.offset, offset) ||
                const DeepCollectionEquality().equals(other.offset, offset)) &&
            (identical(other.total, total) ||
                const DeepCollectionEquality().equals(other.total, total)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(data) ^
      const DeepCollectionEquality().hash(limit) ^
      const DeepCollectionEquality().hash(offset) ^
      const DeepCollectionEquality().hash(total) ^
      runtimeType.hashCode;
}

extension $FarmProfileListResponseExtension on FarmProfileListResponse {
  FarmProfileListResponse copyWith({
    List<FarmProfile>? data,
    int? limit,
    int? offset,
    int? total,
  }) {
    return FarmProfileListResponse(
      data: data ?? this.data,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  FarmProfileListResponse copyWithWrapped({
    Wrapped<List<FarmProfile>>? data,
    Wrapped<int>? limit,
    Wrapped<int>? offset,
    Wrapped<int>? total,
  }) {
    return FarmProfileListResponse(
      data: (data != null ? data.value : this.data),
      limit: (limit != null ? limit.value : this.limit),
      offset: (offset != null ? offset.value : this.offset),
      total: (total != null ? total.value : this.total),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Activity {
  const Activity({
    this.id,
    this.ownerUser,
    required this.activityType,
    this.crop,
    required this.activityDate,
    this.gpsLat,
    this.gpsLng,
    this.notes,
    this.seasonLabel,
    this.yieldQuantity,
    this.yieldUnit,
    this.createdAt,
    this.updatedAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  static const toJsonFactory = _$ActivityToJson;
  Map<String, dynamic> toJson() => _$ActivityToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'owner_user')
  final String? ownerUser;
  @JsonKey(name: 'activity_type')
  final String activityType;
  @JsonKey(name: 'crop')
  final String? crop;
  @JsonKey(name: 'activity_date', toJson: _dateToJson)
  final DateTime activityDate;
  @JsonKey(name: 'gps_lat')
  final double? gpsLat;
  @JsonKey(name: 'gps_lng')
  final double? gpsLng;
  @JsonKey(name: 'notes')
  final String? notes;
  @JsonKey(name: 'season_label')
  final String? seasonLabel;
  @JsonKey(name: 'yield_quantity')
  final double? yieldQuantity;
  @JsonKey(name: 'yield_unit')
  final String? yieldUnit;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  static const fromJsonFactory = _$ActivityFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Activity &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.ownerUser, ownerUser) ||
                const DeepCollectionEquality().equals(
                  other.ownerUser,
                  ownerUser,
                )) &&
            (identical(other.activityType, activityType) ||
                const DeepCollectionEquality().equals(
                  other.activityType,
                  activityType,
                )) &&
            (identical(other.crop, crop) ||
                const DeepCollectionEquality().equals(other.crop, crop)) &&
            (identical(other.activityDate, activityDate) ||
                const DeepCollectionEquality().equals(
                  other.activityDate,
                  activityDate,
                )) &&
            (identical(other.gpsLat, gpsLat) ||
                const DeepCollectionEquality().equals(other.gpsLat, gpsLat)) &&
            (identical(other.gpsLng, gpsLng) ||
                const DeepCollectionEquality().equals(other.gpsLng, gpsLng)) &&
            (identical(other.notes, notes) ||
                const DeepCollectionEquality().equals(other.notes, notes)) &&
            (identical(other.seasonLabel, seasonLabel) ||
                const DeepCollectionEquality().equals(
                  other.seasonLabel,
                  seasonLabel,
                )) &&
            (identical(other.yieldQuantity, yieldQuantity) ||
                const DeepCollectionEquality().equals(
                  other.yieldQuantity,
                  yieldQuantity,
                )) &&
            (identical(other.yieldUnit, yieldUnit) ||
                const DeepCollectionEquality().equals(
                  other.yieldUnit,
                  yieldUnit,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(ownerUser) ^
      const DeepCollectionEquality().hash(activityType) ^
      const DeepCollectionEquality().hash(crop) ^
      const DeepCollectionEquality().hash(activityDate) ^
      const DeepCollectionEquality().hash(gpsLat) ^
      const DeepCollectionEquality().hash(gpsLng) ^
      const DeepCollectionEquality().hash(notes) ^
      const DeepCollectionEquality().hash(seasonLabel) ^
      const DeepCollectionEquality().hash(yieldQuantity) ^
      const DeepCollectionEquality().hash(yieldUnit) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      runtimeType.hashCode;
}

extension $ActivityExtension on Activity {
  Activity copyWith({
    String? id,
    String? ownerUser,
    String? activityType,
    String? crop,
    DateTime? activityDate,
    double? gpsLat,
    double? gpsLng,
    String? notes,
    String? seasonLabel,
    double? yieldQuantity,
    String? yieldUnit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Activity(
      id: id ?? this.id,
      ownerUser: ownerUser ?? this.ownerUser,
      activityType: activityType ?? this.activityType,
      crop: crop ?? this.crop,
      activityDate: activityDate ?? this.activityDate,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      notes: notes ?? this.notes,
      seasonLabel: seasonLabel ?? this.seasonLabel,
      yieldQuantity: yieldQuantity ?? this.yieldQuantity,
      yieldUnit: yieldUnit ?? this.yieldUnit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Activity copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String?>? ownerUser,
    Wrapped<String>? activityType,
    Wrapped<String?>? crop,
    Wrapped<DateTime>? activityDate,
    Wrapped<double?>? gpsLat,
    Wrapped<double?>? gpsLng,
    Wrapped<String?>? notes,
    Wrapped<String?>? seasonLabel,
    Wrapped<double?>? yieldQuantity,
    Wrapped<String?>? yieldUnit,
    Wrapped<DateTime?>? createdAt,
    Wrapped<DateTime?>? updatedAt,
  }) {
    return Activity(
      id: (id != null ? id.value : this.id),
      ownerUser: (ownerUser != null ? ownerUser.value : this.ownerUser),
      activityType: (activityType != null
          ? activityType.value
          : this.activityType),
      crop: (crop != null ? crop.value : this.crop),
      activityDate: (activityDate != null
          ? activityDate.value
          : this.activityDate),
      gpsLat: (gpsLat != null ? gpsLat.value : this.gpsLat),
      gpsLng: (gpsLng != null ? gpsLng.value : this.gpsLng),
      notes: (notes != null ? notes.value : this.notes),
      seasonLabel: (seasonLabel != null ? seasonLabel.value : this.seasonLabel),
      yieldQuantity: (yieldQuantity != null
          ? yieldQuantity.value
          : this.yieldQuantity),
      yieldUnit: (yieldUnit != null ? yieldUnit.value : this.yieldUnit),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ActivityCreate {
  const ActivityCreate({
    required this.activityType,
    this.crop,
    required this.activityDate,
    this.gpsLat,
    this.gpsLng,
    this.notes,
    this.seasonLabel,
    this.yieldQuantity,
    this.yieldUnit,
  });

  factory ActivityCreate.fromJson(Map<String, dynamic> json) =>
      _$ActivityCreateFromJson(json);

  static const toJsonFactory = _$ActivityCreateToJson;
  Map<String, dynamic> toJson() => _$ActivityCreateToJson(this);

  @JsonKey(name: 'activity_type')
  final String activityType;
  @JsonKey(name: 'crop')
  final String? crop;
  @JsonKey(name: 'activity_date', toJson: _dateToJson)
  final DateTime activityDate;
  @JsonKey(name: 'gps_lat')
  final double? gpsLat;
  @JsonKey(name: 'gps_lng')
  final double? gpsLng;
  @JsonKey(name: 'notes')
  final String? notes;
  @JsonKey(name: 'season_label')
  final String? seasonLabel;
  @JsonKey(name: 'yield_quantity')
  final double? yieldQuantity;
  @JsonKey(name: 'yield_unit')
  final String? yieldUnit;
  static const fromJsonFactory = _$ActivityCreateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ActivityCreate &&
            (identical(other.activityType, activityType) ||
                const DeepCollectionEquality().equals(
                  other.activityType,
                  activityType,
                )) &&
            (identical(other.crop, crop) ||
                const DeepCollectionEquality().equals(other.crop, crop)) &&
            (identical(other.activityDate, activityDate) ||
                const DeepCollectionEquality().equals(
                  other.activityDate,
                  activityDate,
                )) &&
            (identical(other.gpsLat, gpsLat) ||
                const DeepCollectionEquality().equals(other.gpsLat, gpsLat)) &&
            (identical(other.gpsLng, gpsLng) ||
                const DeepCollectionEquality().equals(other.gpsLng, gpsLng)) &&
            (identical(other.notes, notes) ||
                const DeepCollectionEquality().equals(other.notes, notes)) &&
            (identical(other.seasonLabel, seasonLabel) ||
                const DeepCollectionEquality().equals(
                  other.seasonLabel,
                  seasonLabel,
                )) &&
            (identical(other.yieldQuantity, yieldQuantity) ||
                const DeepCollectionEquality().equals(
                  other.yieldQuantity,
                  yieldQuantity,
                )) &&
            (identical(other.yieldUnit, yieldUnit) ||
                const DeepCollectionEquality().equals(
                  other.yieldUnit,
                  yieldUnit,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(activityType) ^
      const DeepCollectionEquality().hash(crop) ^
      const DeepCollectionEquality().hash(activityDate) ^
      const DeepCollectionEquality().hash(gpsLat) ^
      const DeepCollectionEquality().hash(gpsLng) ^
      const DeepCollectionEquality().hash(notes) ^
      const DeepCollectionEquality().hash(seasonLabel) ^
      const DeepCollectionEquality().hash(yieldQuantity) ^
      const DeepCollectionEquality().hash(yieldUnit) ^
      runtimeType.hashCode;
}

extension $ActivityCreateExtension on ActivityCreate {
  ActivityCreate copyWith({
    String? activityType,
    String? crop,
    DateTime? activityDate,
    double? gpsLat,
    double? gpsLng,
    String? notes,
    String? seasonLabel,
    double? yieldQuantity,
    String? yieldUnit,
  }) {
    return ActivityCreate(
      activityType: activityType ?? this.activityType,
      crop: crop ?? this.crop,
      activityDate: activityDate ?? this.activityDate,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      notes: notes ?? this.notes,
      seasonLabel: seasonLabel ?? this.seasonLabel,
      yieldQuantity: yieldQuantity ?? this.yieldQuantity,
      yieldUnit: yieldUnit ?? this.yieldUnit,
    );
  }

  ActivityCreate copyWithWrapped({
    Wrapped<String>? activityType,
    Wrapped<String?>? crop,
    Wrapped<DateTime>? activityDate,
    Wrapped<double?>? gpsLat,
    Wrapped<double?>? gpsLng,
    Wrapped<String?>? notes,
    Wrapped<String?>? seasonLabel,
    Wrapped<double?>? yieldQuantity,
    Wrapped<String?>? yieldUnit,
  }) {
    return ActivityCreate(
      activityType: (activityType != null
          ? activityType.value
          : this.activityType),
      crop: (crop != null ? crop.value : this.crop),
      activityDate: (activityDate != null
          ? activityDate.value
          : this.activityDate),
      gpsLat: (gpsLat != null ? gpsLat.value : this.gpsLat),
      gpsLng: (gpsLng != null ? gpsLng.value : this.gpsLng),
      notes: (notes != null ? notes.value : this.notes),
      seasonLabel: (seasonLabel != null ? seasonLabel.value : this.seasonLabel),
      yieldQuantity: (yieldQuantity != null
          ? yieldQuantity.value
          : this.yieldQuantity),
      yieldUnit: (yieldUnit != null ? yieldUnit.value : this.yieldUnit),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ActivityUpdate {
  const ActivityUpdate({
    this.activityType,
    this.crop,
    this.activityDate,
    this.gpsLat,
    this.gpsLng,
    this.notes,
    this.seasonLabel,
    this.yieldQuantity,
    this.yieldUnit,
  });

  factory ActivityUpdate.fromJson(Map<String, dynamic> json) =>
      _$ActivityUpdateFromJson(json);

  static const toJsonFactory = _$ActivityUpdateToJson;
  Map<String, dynamic> toJson() => _$ActivityUpdateToJson(this);

  @JsonKey(name: 'activity_type')
  final String? activityType;
  @JsonKey(name: 'crop')
  final String? crop;
  @JsonKey(name: 'activity_date', toJson: _dateToJson)
  final DateTime? activityDate;
  @JsonKey(name: 'gps_lat')
  final double? gpsLat;
  @JsonKey(name: 'gps_lng')
  final double? gpsLng;
  @JsonKey(name: 'notes')
  final String? notes;
  @JsonKey(name: 'season_label')
  final String? seasonLabel;
  @JsonKey(name: 'yield_quantity')
  final double? yieldQuantity;
  @JsonKey(name: 'yield_unit')
  final String? yieldUnit;
  static const fromJsonFactory = _$ActivityUpdateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ActivityUpdate &&
            (identical(other.activityType, activityType) ||
                const DeepCollectionEquality().equals(
                  other.activityType,
                  activityType,
                )) &&
            (identical(other.crop, crop) ||
                const DeepCollectionEquality().equals(other.crop, crop)) &&
            (identical(other.activityDate, activityDate) ||
                const DeepCollectionEquality().equals(
                  other.activityDate,
                  activityDate,
                )) &&
            (identical(other.gpsLat, gpsLat) ||
                const DeepCollectionEquality().equals(other.gpsLat, gpsLat)) &&
            (identical(other.gpsLng, gpsLng) ||
                const DeepCollectionEquality().equals(other.gpsLng, gpsLng)) &&
            (identical(other.notes, notes) ||
                const DeepCollectionEquality().equals(other.notes, notes)) &&
            (identical(other.seasonLabel, seasonLabel) ||
                const DeepCollectionEquality().equals(
                  other.seasonLabel,
                  seasonLabel,
                )) &&
            (identical(other.yieldQuantity, yieldQuantity) ||
                const DeepCollectionEquality().equals(
                  other.yieldQuantity,
                  yieldQuantity,
                )) &&
            (identical(other.yieldUnit, yieldUnit) ||
                const DeepCollectionEquality().equals(
                  other.yieldUnit,
                  yieldUnit,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(activityType) ^
      const DeepCollectionEquality().hash(crop) ^
      const DeepCollectionEquality().hash(activityDate) ^
      const DeepCollectionEquality().hash(gpsLat) ^
      const DeepCollectionEquality().hash(gpsLng) ^
      const DeepCollectionEquality().hash(notes) ^
      const DeepCollectionEquality().hash(seasonLabel) ^
      const DeepCollectionEquality().hash(yieldQuantity) ^
      const DeepCollectionEquality().hash(yieldUnit) ^
      runtimeType.hashCode;
}

extension $ActivityUpdateExtension on ActivityUpdate {
  ActivityUpdate copyWith({
    String? activityType,
    String? crop,
    DateTime? activityDate,
    double? gpsLat,
    double? gpsLng,
    String? notes,
    String? seasonLabel,
    double? yieldQuantity,
    String? yieldUnit,
  }) {
    return ActivityUpdate(
      activityType: activityType ?? this.activityType,
      crop: crop ?? this.crop,
      activityDate: activityDate ?? this.activityDate,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      notes: notes ?? this.notes,
      seasonLabel: seasonLabel ?? this.seasonLabel,
      yieldQuantity: yieldQuantity ?? this.yieldQuantity,
      yieldUnit: yieldUnit ?? this.yieldUnit,
    );
  }

  ActivityUpdate copyWithWrapped({
    Wrapped<String?>? activityType,
    Wrapped<String?>? crop,
    Wrapped<DateTime?>? activityDate,
    Wrapped<double?>? gpsLat,
    Wrapped<double?>? gpsLng,
    Wrapped<String?>? notes,
    Wrapped<String?>? seasonLabel,
    Wrapped<double?>? yieldQuantity,
    Wrapped<String?>? yieldUnit,
  }) {
    return ActivityUpdate(
      activityType: (activityType != null
          ? activityType.value
          : this.activityType),
      crop: (crop != null ? crop.value : this.crop),
      activityDate: (activityDate != null
          ? activityDate.value
          : this.activityDate),
      gpsLat: (gpsLat != null ? gpsLat.value : this.gpsLat),
      gpsLng: (gpsLng != null ? gpsLng.value : this.gpsLng),
      notes: (notes != null ? notes.value : this.notes),
      seasonLabel: (seasonLabel != null ? seasonLabel.value : this.seasonLabel),
      yieldQuantity: (yieldQuantity != null
          ? yieldQuantity.value
          : this.yieldQuantity),
      yieldUnit: (yieldUnit != null ? yieldUnit.value : this.yieldUnit),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ActivityListResponse {
  const ActivityListResponse({
    required this.data,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory ActivityListResponse.fromJson(Map<String, dynamic> json) =>
      _$ActivityListResponseFromJson(json);

  static const toJsonFactory = _$ActivityListResponseToJson;
  Map<String, dynamic> toJson() => _$ActivityListResponseToJson(this);

  @JsonKey(name: 'data', defaultValue: <Activity>[])
  final List<Activity> data;
  @JsonKey(name: 'limit')
  final int limit;
  @JsonKey(name: 'offset')
  final int offset;
  @JsonKey(name: 'total')
  final int total;
  static const fromJsonFactory = _$ActivityListResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ActivityListResponse &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)) &&
            (identical(other.limit, limit) ||
                const DeepCollectionEquality().equals(other.limit, limit)) &&
            (identical(other.offset, offset) ||
                const DeepCollectionEquality().equals(other.offset, offset)) &&
            (identical(other.total, total) ||
                const DeepCollectionEquality().equals(other.total, total)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(data) ^
      const DeepCollectionEquality().hash(limit) ^
      const DeepCollectionEquality().hash(offset) ^
      const DeepCollectionEquality().hash(total) ^
      runtimeType.hashCode;
}

extension $ActivityListResponseExtension on ActivityListResponse {
  ActivityListResponse copyWith({
    List<Activity>? data,
    int? limit,
    int? offset,
    int? total,
  }) {
    return ActivityListResponse(
      data: data ?? this.data,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  ActivityListResponse copyWithWrapped({
    Wrapped<List<Activity>>? data,
    Wrapped<int>? limit,
    Wrapped<int>? offset,
    Wrapped<int>? total,
  }) {
    return ActivityListResponse(
      data: (data != null ? data.value : this.data),
      limit: (limit != null ? limit.value : this.limit),
      offset: (offset != null ? offset.value : this.offset),
      total: (total != null ? total.value : this.total),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ActivityFile {
  const ActivityFile({
    this.id,
    this.activityId,
    required this.storagePath,
    this.fileType,
    this.createdAt,
  });

  factory ActivityFile.fromJson(Map<String, dynamic> json) =>
      _$ActivityFileFromJson(json);

  static const toJsonFactory = _$ActivityFileToJson;
  Map<String, dynamic> toJson() => _$ActivityFileToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'activity_id')
  final String? activityId;
  @JsonKey(name: 'storage_path')
  final String storagePath;
  @JsonKey(name: 'file_type')
  final String? fileType;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  static const fromJsonFactory = _$ActivityFileFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ActivityFile &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.activityId, activityId) ||
                const DeepCollectionEquality().equals(
                  other.activityId,
                  activityId,
                )) &&
            (identical(other.storagePath, storagePath) ||
                const DeepCollectionEquality().equals(
                  other.storagePath,
                  storagePath,
                )) &&
            (identical(other.fileType, fileType) ||
                const DeepCollectionEquality().equals(
                  other.fileType,
                  fileType,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(activityId) ^
      const DeepCollectionEquality().hash(storagePath) ^
      const DeepCollectionEquality().hash(fileType) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $ActivityFileExtension on ActivityFile {
  ActivityFile copyWith({
    String? id,
    String? activityId,
    String? storagePath,
    String? fileType,
    DateTime? createdAt,
  }) {
    return ActivityFile(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      storagePath: storagePath ?? this.storagePath,
      fileType: fileType ?? this.fileType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  ActivityFile copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String?>? activityId,
    Wrapped<String>? storagePath,
    Wrapped<String?>? fileType,
    Wrapped<DateTime?>? createdAt,
  }) {
    return ActivityFile(
      id: (id != null ? id.value : this.id),
      activityId: (activityId != null ? activityId.value : this.activityId),
      storagePath: (storagePath != null ? storagePath.value : this.storagePath),
      fileType: (fileType != null ? fileType.value : this.fileType),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ActivityFileCreate {
  const ActivityFileCreate({required this.storagePath, this.fileType});

  factory ActivityFileCreate.fromJson(Map<String, dynamic> json) =>
      _$ActivityFileCreateFromJson(json);

  static const toJsonFactory = _$ActivityFileCreateToJson;
  Map<String, dynamic> toJson() => _$ActivityFileCreateToJson(this);

  @JsonKey(name: 'storage_path')
  final String storagePath;
  @JsonKey(name: 'file_type')
  final String? fileType;
  static const fromJsonFactory = _$ActivityFileCreateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ActivityFileCreate &&
            (identical(other.storagePath, storagePath) ||
                const DeepCollectionEquality().equals(
                  other.storagePath,
                  storagePath,
                )) &&
            (identical(other.fileType, fileType) ||
                const DeepCollectionEquality().equals(
                  other.fileType,
                  fileType,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(storagePath) ^
      const DeepCollectionEquality().hash(fileType) ^
      runtimeType.hashCode;
}

extension $ActivityFileCreateExtension on ActivityFileCreate {
  ActivityFileCreate copyWith({String? storagePath, String? fileType}) {
    return ActivityFileCreate(
      storagePath: storagePath ?? this.storagePath,
      fileType: fileType ?? this.fileType,
    );
  }

  ActivityFileCreate copyWithWrapped({
    Wrapped<String>? storagePath,
    Wrapped<String?>? fileType,
  }) {
    return ActivityFileCreate(
      storagePath: (storagePath != null ? storagePath.value : this.storagePath),
      fileType: (fileType != null ? fileType.value : this.fileType),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ActivityFileUpdate {
  const ActivityFileUpdate({this.storagePath, this.fileType});

  factory ActivityFileUpdate.fromJson(Map<String, dynamic> json) =>
      _$ActivityFileUpdateFromJson(json);

  static const toJsonFactory = _$ActivityFileUpdateToJson;
  Map<String, dynamic> toJson() => _$ActivityFileUpdateToJson(this);

  @JsonKey(name: 'storage_path')
  final String? storagePath;
  @JsonKey(name: 'file_type')
  final String? fileType;
  static const fromJsonFactory = _$ActivityFileUpdateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ActivityFileUpdate &&
            (identical(other.storagePath, storagePath) ||
                const DeepCollectionEquality().equals(
                  other.storagePath,
                  storagePath,
                )) &&
            (identical(other.fileType, fileType) ||
                const DeepCollectionEquality().equals(
                  other.fileType,
                  fileType,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(storagePath) ^
      const DeepCollectionEquality().hash(fileType) ^
      runtimeType.hashCode;
}

extension $ActivityFileUpdateExtension on ActivityFileUpdate {
  ActivityFileUpdate copyWith({String? storagePath, String? fileType}) {
    return ActivityFileUpdate(
      storagePath: storagePath ?? this.storagePath,
      fileType: fileType ?? this.fileType,
    );
  }

  ActivityFileUpdate copyWithWrapped({
    Wrapped<String?>? storagePath,
    Wrapped<String?>? fileType,
  }) {
    return ActivityFileUpdate(
      storagePath: (storagePath != null ? storagePath.value : this.storagePath),
      fileType: (fileType != null ? fileType.value : this.fileType),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ActivityFileListResponse {
  const ActivityFileListResponse({
    required this.data,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory ActivityFileListResponse.fromJson(Map<String, dynamic> json) =>
      _$ActivityFileListResponseFromJson(json);

  static const toJsonFactory = _$ActivityFileListResponseToJson;
  Map<String, dynamic> toJson() => _$ActivityFileListResponseToJson(this);

  @JsonKey(name: 'data', defaultValue: <ActivityFile>[])
  final List<ActivityFile> data;
  @JsonKey(name: 'limit')
  final int limit;
  @JsonKey(name: 'offset')
  final int offset;
  @JsonKey(name: 'total')
  final int total;
  static const fromJsonFactory = _$ActivityFileListResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ActivityFileListResponse &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)) &&
            (identical(other.limit, limit) ||
                const DeepCollectionEquality().equals(other.limit, limit)) &&
            (identical(other.offset, offset) ||
                const DeepCollectionEquality().equals(other.offset, offset)) &&
            (identical(other.total, total) ||
                const DeepCollectionEquality().equals(other.total, total)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(data) ^
      const DeepCollectionEquality().hash(limit) ^
      const DeepCollectionEquality().hash(offset) ^
      const DeepCollectionEquality().hash(total) ^
      runtimeType.hashCode;
}

extension $ActivityFileListResponseExtension on ActivityFileListResponse {
  ActivityFileListResponse copyWith({
    List<ActivityFile>? data,
    int? limit,
    int? offset,
    int? total,
  }) {
    return ActivityFileListResponse(
      data: data ?? this.data,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  ActivityFileListResponse copyWithWrapped({
    Wrapped<List<ActivityFile>>? data,
    Wrapped<int>? limit,
    Wrapped<int>? offset,
    Wrapped<int>? total,
  }) {
    return ActivityFileListResponse(
      data: (data != null ? data.value : this.data),
      limit: (limit != null ? limit.value : this.limit),
      offset: (offset != null ? offset.value : this.offset),
      total: (total != null ? total.value : this.total),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Expense {
  const Expense({
    this.id,
    this.ownerUser,
    required this.amount,
    this.category,
    required this.expenseDate,
    this.notes,
    this.seasonLabel,
    this.receiptFileId,
    this.createdAt,
    this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);

  static const toJsonFactory = _$ExpenseToJson;
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'owner_user')
  final String? ownerUser;
  @JsonKey(name: 'amount')
  final double amount;
  @JsonKey(name: 'category')
  final String? category;
  @JsonKey(name: 'expense_date', toJson: _dateToJson)
  final DateTime expenseDate;
  @JsonKey(name: 'notes')
  final String? notes;
  @JsonKey(name: 'season_label')
  final String? seasonLabel;
  @JsonKey(name: 'receipt_file_id')
  final String? receiptFileId;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  static const fromJsonFactory = _$ExpenseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Expense &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.ownerUser, ownerUser) ||
                const DeepCollectionEquality().equals(
                  other.ownerUser,
                  ownerUser,
                )) &&
            (identical(other.amount, amount) ||
                const DeepCollectionEquality().equals(other.amount, amount)) &&
            (identical(other.category, category) ||
                const DeepCollectionEquality().equals(
                  other.category,
                  category,
                )) &&
            (identical(other.expenseDate, expenseDate) ||
                const DeepCollectionEquality().equals(
                  other.expenseDate,
                  expenseDate,
                )) &&
            (identical(other.notes, notes) ||
                const DeepCollectionEquality().equals(other.notes, notes)) &&
            (identical(other.seasonLabel, seasonLabel) ||
                const DeepCollectionEquality().equals(
                  other.seasonLabel,
                  seasonLabel,
                )) &&
            (identical(other.receiptFileId, receiptFileId) ||
                const DeepCollectionEquality().equals(
                  other.receiptFileId,
                  receiptFileId,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(ownerUser) ^
      const DeepCollectionEquality().hash(amount) ^
      const DeepCollectionEquality().hash(category) ^
      const DeepCollectionEquality().hash(expenseDate) ^
      const DeepCollectionEquality().hash(notes) ^
      const DeepCollectionEquality().hash(seasonLabel) ^
      const DeepCollectionEquality().hash(receiptFileId) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      runtimeType.hashCode;
}

extension $ExpenseExtension on Expense {
  Expense copyWith({
    String? id,
    String? ownerUser,
    double? amount,
    String? category,
    DateTime? expenseDate,
    String? notes,
    String? seasonLabel,
    String? receiptFileId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      ownerUser: ownerUser ?? this.ownerUser,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      expenseDate: expenseDate ?? this.expenseDate,
      notes: notes ?? this.notes,
      seasonLabel: seasonLabel ?? this.seasonLabel,
      receiptFileId: receiptFileId ?? this.receiptFileId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Expense copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String?>? ownerUser,
    Wrapped<double>? amount,
    Wrapped<String?>? category,
    Wrapped<DateTime>? expenseDate,
    Wrapped<String?>? notes,
    Wrapped<String?>? seasonLabel,
    Wrapped<String?>? receiptFileId,
    Wrapped<DateTime?>? createdAt,
    Wrapped<DateTime?>? updatedAt,
  }) {
    return Expense(
      id: (id != null ? id.value : this.id),
      ownerUser: (ownerUser != null ? ownerUser.value : this.ownerUser),
      amount: (amount != null ? amount.value : this.amount),
      category: (category != null ? category.value : this.category),
      expenseDate: (expenseDate != null ? expenseDate.value : this.expenseDate),
      notes: (notes != null ? notes.value : this.notes),
      seasonLabel: (seasonLabel != null ? seasonLabel.value : this.seasonLabel),
      receiptFileId: (receiptFileId != null
          ? receiptFileId.value
          : this.receiptFileId),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ExpenseCreate {
  const ExpenseCreate({
    required this.amount,
    this.category,
    required this.expenseDate,
    this.notes,
    this.seasonLabel,
    this.receiptFileId,
  });

  factory ExpenseCreate.fromJson(Map<String, dynamic> json) =>
      _$ExpenseCreateFromJson(json);

  static const toJsonFactory = _$ExpenseCreateToJson;
  Map<String, dynamic> toJson() => _$ExpenseCreateToJson(this);

  @JsonKey(name: 'amount')
  final double amount;
  @JsonKey(name: 'category')
  final String? category;
  @JsonKey(name: 'expense_date', toJson: _dateToJson)
  final DateTime expenseDate;
  @JsonKey(name: 'notes')
  final String? notes;
  @JsonKey(name: 'season_label')
  final String? seasonLabel;
  @JsonKey(name: 'receipt_file_id')
  final String? receiptFileId;
  static const fromJsonFactory = _$ExpenseCreateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ExpenseCreate &&
            (identical(other.amount, amount) ||
                const DeepCollectionEquality().equals(other.amount, amount)) &&
            (identical(other.category, category) ||
                const DeepCollectionEquality().equals(
                  other.category,
                  category,
                )) &&
            (identical(other.expenseDate, expenseDate) ||
                const DeepCollectionEquality().equals(
                  other.expenseDate,
                  expenseDate,
                )) &&
            (identical(other.notes, notes) ||
                const DeepCollectionEquality().equals(other.notes, notes)) &&
            (identical(other.seasonLabel, seasonLabel) ||
                const DeepCollectionEquality().equals(
                  other.seasonLabel,
                  seasonLabel,
                )) &&
            (identical(other.receiptFileId, receiptFileId) ||
                const DeepCollectionEquality().equals(
                  other.receiptFileId,
                  receiptFileId,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(amount) ^
      const DeepCollectionEquality().hash(category) ^
      const DeepCollectionEquality().hash(expenseDate) ^
      const DeepCollectionEquality().hash(notes) ^
      const DeepCollectionEquality().hash(seasonLabel) ^
      const DeepCollectionEquality().hash(receiptFileId) ^
      runtimeType.hashCode;
}

extension $ExpenseCreateExtension on ExpenseCreate {
  ExpenseCreate copyWith({
    double? amount,
    String? category,
    DateTime? expenseDate,
    String? notes,
    String? seasonLabel,
    String? receiptFileId,
  }) {
    return ExpenseCreate(
      amount: amount ?? this.amount,
      category: category ?? this.category,
      expenseDate: expenseDate ?? this.expenseDate,
      notes: notes ?? this.notes,
      seasonLabel: seasonLabel ?? this.seasonLabel,
      receiptFileId: receiptFileId ?? this.receiptFileId,
    );
  }

  ExpenseCreate copyWithWrapped({
    Wrapped<double>? amount,
    Wrapped<String?>? category,
    Wrapped<DateTime>? expenseDate,
    Wrapped<String?>? notes,
    Wrapped<String?>? seasonLabel,
    Wrapped<String?>? receiptFileId,
  }) {
    return ExpenseCreate(
      amount: (amount != null ? amount.value : this.amount),
      category: (category != null ? category.value : this.category),
      expenseDate: (expenseDate != null ? expenseDate.value : this.expenseDate),
      notes: (notes != null ? notes.value : this.notes),
      seasonLabel: (seasonLabel != null ? seasonLabel.value : this.seasonLabel),
      receiptFileId: (receiptFileId != null
          ? receiptFileId.value
          : this.receiptFileId),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ExpenseUpdate {
  const ExpenseUpdate({
    this.amount,
    this.category,
    this.expenseDate,
    this.notes,
    this.seasonLabel,
    this.receiptFileId,
  });

  factory ExpenseUpdate.fromJson(Map<String, dynamic> json) =>
      _$ExpenseUpdateFromJson(json);

  static const toJsonFactory = _$ExpenseUpdateToJson;
  Map<String, dynamic> toJson() => _$ExpenseUpdateToJson(this);

  @JsonKey(name: 'amount')
  final double? amount;
  @JsonKey(name: 'category')
  final String? category;
  @JsonKey(name: 'expense_date', toJson: _dateToJson)
  final DateTime? expenseDate;
  @JsonKey(name: 'notes')
  final String? notes;
  @JsonKey(name: 'season_label')
  final String? seasonLabel;
  @JsonKey(name: 'receipt_file_id')
  final String? receiptFileId;
  static const fromJsonFactory = _$ExpenseUpdateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ExpenseUpdate &&
            (identical(other.amount, amount) ||
                const DeepCollectionEquality().equals(other.amount, amount)) &&
            (identical(other.category, category) ||
                const DeepCollectionEquality().equals(
                  other.category,
                  category,
                )) &&
            (identical(other.expenseDate, expenseDate) ||
                const DeepCollectionEquality().equals(
                  other.expenseDate,
                  expenseDate,
                )) &&
            (identical(other.notes, notes) ||
                const DeepCollectionEquality().equals(other.notes, notes)) &&
            (identical(other.seasonLabel, seasonLabel) ||
                const DeepCollectionEquality().equals(
                  other.seasonLabel,
                  seasonLabel,
                )) &&
            (identical(other.receiptFileId, receiptFileId) ||
                const DeepCollectionEquality().equals(
                  other.receiptFileId,
                  receiptFileId,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(amount) ^
      const DeepCollectionEquality().hash(category) ^
      const DeepCollectionEquality().hash(expenseDate) ^
      const DeepCollectionEquality().hash(notes) ^
      const DeepCollectionEquality().hash(seasonLabel) ^
      const DeepCollectionEquality().hash(receiptFileId) ^
      runtimeType.hashCode;
}

extension $ExpenseUpdateExtension on ExpenseUpdate {
  ExpenseUpdate copyWith({
    double? amount,
    String? category,
    DateTime? expenseDate,
    String? notes,
    String? seasonLabel,
    String? receiptFileId,
  }) {
    return ExpenseUpdate(
      amount: amount ?? this.amount,
      category: category ?? this.category,
      expenseDate: expenseDate ?? this.expenseDate,
      notes: notes ?? this.notes,
      seasonLabel: seasonLabel ?? this.seasonLabel,
      receiptFileId: receiptFileId ?? this.receiptFileId,
    );
  }

  ExpenseUpdate copyWithWrapped({
    Wrapped<double?>? amount,
    Wrapped<String?>? category,
    Wrapped<DateTime?>? expenseDate,
    Wrapped<String?>? notes,
    Wrapped<String?>? seasonLabel,
    Wrapped<String?>? receiptFileId,
  }) {
    return ExpenseUpdate(
      amount: (amount != null ? amount.value : this.amount),
      category: (category != null ? category.value : this.category),
      expenseDate: (expenseDate != null ? expenseDate.value : this.expenseDate),
      notes: (notes != null ? notes.value : this.notes),
      seasonLabel: (seasonLabel != null ? seasonLabel.value : this.seasonLabel),
      receiptFileId: (receiptFileId != null
          ? receiptFileId.value
          : this.receiptFileId),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ExpenseListResponse {
  const ExpenseListResponse({
    required this.data,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory ExpenseListResponse.fromJson(Map<String, dynamic> json) =>
      _$ExpenseListResponseFromJson(json);

  static const toJsonFactory = _$ExpenseListResponseToJson;
  Map<String, dynamic> toJson() => _$ExpenseListResponseToJson(this);

  @JsonKey(name: 'data', defaultValue: <Expense>[])
  final List<Expense> data;
  @JsonKey(name: 'limit')
  final int limit;
  @JsonKey(name: 'offset')
  final int offset;
  @JsonKey(name: 'total')
  final int total;
  static const fromJsonFactory = _$ExpenseListResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ExpenseListResponse &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)) &&
            (identical(other.limit, limit) ||
                const DeepCollectionEquality().equals(other.limit, limit)) &&
            (identical(other.offset, offset) ||
                const DeepCollectionEquality().equals(other.offset, offset)) &&
            (identical(other.total, total) ||
                const DeepCollectionEquality().equals(other.total, total)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(data) ^
      const DeepCollectionEquality().hash(limit) ^
      const DeepCollectionEquality().hash(offset) ^
      const DeepCollectionEquality().hash(total) ^
      runtimeType.hashCode;
}

extension $ExpenseListResponseExtension on ExpenseListResponse {
  ExpenseListResponse copyWith({
    List<Expense>? data,
    int? limit,
    int? offset,
    int? total,
  }) {
    return ExpenseListResponse(
      data: data ?? this.data,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  ExpenseListResponse copyWithWrapped({
    Wrapped<List<Expense>>? data,
    Wrapped<int>? limit,
    Wrapped<int>? offset,
    Wrapped<int>? total,
  }) {
    return ExpenseListResponse(
      data: (data != null ? data.value : this.data),
      limit: (limit != null ? limit.value : this.limit),
      offset: (offset != null ? offset.value : this.offset),
      total: (total != null ? total.value : this.total),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class IncomeRecord {
  const IncomeRecord({
    this.id,
    this.ownerUser,
    this.crop,
    this.buyer,
    required this.incomeDate,
    this.pricePerUnit,
    this.quantitySold,
    this.totalRevenue,
    this.seasonLabel,
    this.documentFileId,
    this.createdAt,
    this.updatedAt,
  });

  factory IncomeRecord.fromJson(Map<String, dynamic> json) =>
      _$IncomeRecordFromJson(json);

  static const toJsonFactory = _$IncomeRecordToJson;
  Map<String, dynamic> toJson() => _$IncomeRecordToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'owner_user')
  final String? ownerUser;
  @JsonKey(name: 'crop')
  final String? crop;
  @JsonKey(name: 'buyer')
  final String? buyer;
  @JsonKey(name: 'income_date', toJson: _dateToJson)
  final DateTime incomeDate;
  @JsonKey(name: 'price_per_unit')
  final double? pricePerUnit;
  @JsonKey(name: 'quantity_sold')
  final double? quantitySold;
  @JsonKey(name: 'total_revenue')
  final double? totalRevenue;
  @JsonKey(name: 'season_label')
  final String? seasonLabel;
  @JsonKey(name: 'document_file_id')
  final String? documentFileId;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  static const fromJsonFactory = _$IncomeRecordFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is IncomeRecord &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.ownerUser, ownerUser) ||
                const DeepCollectionEquality().equals(
                  other.ownerUser,
                  ownerUser,
                )) &&
            (identical(other.crop, crop) ||
                const DeepCollectionEquality().equals(other.crop, crop)) &&
            (identical(other.buyer, buyer) ||
                const DeepCollectionEquality().equals(other.buyer, buyer)) &&
            (identical(other.incomeDate, incomeDate) ||
                const DeepCollectionEquality().equals(
                  other.incomeDate,
                  incomeDate,
                )) &&
            (identical(other.pricePerUnit, pricePerUnit) ||
                const DeepCollectionEquality().equals(
                  other.pricePerUnit,
                  pricePerUnit,
                )) &&
            (identical(other.quantitySold, quantitySold) ||
                const DeepCollectionEquality().equals(
                  other.quantitySold,
                  quantitySold,
                )) &&
            (identical(other.totalRevenue, totalRevenue) ||
                const DeepCollectionEquality().equals(
                  other.totalRevenue,
                  totalRevenue,
                )) &&
            (identical(other.seasonLabel, seasonLabel) ||
                const DeepCollectionEquality().equals(
                  other.seasonLabel,
                  seasonLabel,
                )) &&
            (identical(other.documentFileId, documentFileId) ||
                const DeepCollectionEquality().equals(
                  other.documentFileId,
                  documentFileId,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(ownerUser) ^
      const DeepCollectionEquality().hash(crop) ^
      const DeepCollectionEquality().hash(buyer) ^
      const DeepCollectionEquality().hash(incomeDate) ^
      const DeepCollectionEquality().hash(pricePerUnit) ^
      const DeepCollectionEquality().hash(quantitySold) ^
      const DeepCollectionEquality().hash(totalRevenue) ^
      const DeepCollectionEquality().hash(seasonLabel) ^
      const DeepCollectionEquality().hash(documentFileId) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      runtimeType.hashCode;
}

extension $IncomeRecordExtension on IncomeRecord {
  IncomeRecord copyWith({
    String? id,
    String? ownerUser,
    String? crop,
    String? buyer,
    DateTime? incomeDate,
    double? pricePerUnit,
    double? quantitySold,
    double? totalRevenue,
    String? seasonLabel,
    String? documentFileId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IncomeRecord(
      id: id ?? this.id,
      ownerUser: ownerUser ?? this.ownerUser,
      crop: crop ?? this.crop,
      buyer: buyer ?? this.buyer,
      incomeDate: incomeDate ?? this.incomeDate,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      quantitySold: quantitySold ?? this.quantitySold,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      seasonLabel: seasonLabel ?? this.seasonLabel,
      documentFileId: documentFileId ?? this.documentFileId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  IncomeRecord copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String?>? ownerUser,
    Wrapped<String?>? crop,
    Wrapped<String?>? buyer,
    Wrapped<DateTime>? incomeDate,
    Wrapped<double?>? pricePerUnit,
    Wrapped<double?>? quantitySold,
    Wrapped<double?>? totalRevenue,
    Wrapped<String?>? seasonLabel,
    Wrapped<String?>? documentFileId,
    Wrapped<DateTime?>? createdAt,
    Wrapped<DateTime?>? updatedAt,
  }) {
    return IncomeRecord(
      id: (id != null ? id.value : this.id),
      ownerUser: (ownerUser != null ? ownerUser.value : this.ownerUser),
      crop: (crop != null ? crop.value : this.crop),
      buyer: (buyer != null ? buyer.value : this.buyer),
      incomeDate: (incomeDate != null ? incomeDate.value : this.incomeDate),
      pricePerUnit: (pricePerUnit != null
          ? pricePerUnit.value
          : this.pricePerUnit),
      quantitySold: (quantitySold != null
          ? quantitySold.value
          : this.quantitySold),
      totalRevenue: (totalRevenue != null
          ? totalRevenue.value
          : this.totalRevenue),
      seasonLabel: (seasonLabel != null ? seasonLabel.value : this.seasonLabel),
      documentFileId: (documentFileId != null
          ? documentFileId.value
          : this.documentFileId),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class IncomeRecordCreate {
  const IncomeRecordCreate({
    this.crop,
    this.buyer,
    required this.incomeDate,
    this.pricePerUnit,
    this.quantitySold,
    this.totalRevenue,
    this.seasonLabel,
    this.documentFileId,
  });

  factory IncomeRecordCreate.fromJson(Map<String, dynamic> json) =>
      _$IncomeRecordCreateFromJson(json);

  static const toJsonFactory = _$IncomeRecordCreateToJson;
  Map<String, dynamic> toJson() => _$IncomeRecordCreateToJson(this);

  @JsonKey(name: 'crop')
  final String? crop;
  @JsonKey(name: 'buyer')
  final String? buyer;
  @JsonKey(name: 'income_date', toJson: _dateToJson)
  final DateTime incomeDate;
  @JsonKey(name: 'price_per_unit')
  final double? pricePerUnit;
  @JsonKey(name: 'quantity_sold')
  final double? quantitySold;
  @JsonKey(name: 'total_revenue')
  final double? totalRevenue;
  @JsonKey(name: 'season_label')
  final String? seasonLabel;
  @JsonKey(name: 'document_file_id')
  final String? documentFileId;
  static const fromJsonFactory = _$IncomeRecordCreateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is IncomeRecordCreate &&
            (identical(other.crop, crop) ||
                const DeepCollectionEquality().equals(other.crop, crop)) &&
            (identical(other.buyer, buyer) ||
                const DeepCollectionEquality().equals(other.buyer, buyer)) &&
            (identical(other.incomeDate, incomeDate) ||
                const DeepCollectionEquality().equals(
                  other.incomeDate,
                  incomeDate,
                )) &&
            (identical(other.pricePerUnit, pricePerUnit) ||
                const DeepCollectionEquality().equals(
                  other.pricePerUnit,
                  pricePerUnit,
                )) &&
            (identical(other.quantitySold, quantitySold) ||
                const DeepCollectionEquality().equals(
                  other.quantitySold,
                  quantitySold,
                )) &&
            (identical(other.totalRevenue, totalRevenue) ||
                const DeepCollectionEquality().equals(
                  other.totalRevenue,
                  totalRevenue,
                )) &&
            (identical(other.seasonLabel, seasonLabel) ||
                const DeepCollectionEquality().equals(
                  other.seasonLabel,
                  seasonLabel,
                )) &&
            (identical(other.documentFileId, documentFileId) ||
                const DeepCollectionEquality().equals(
                  other.documentFileId,
                  documentFileId,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(crop) ^
      const DeepCollectionEquality().hash(buyer) ^
      const DeepCollectionEquality().hash(incomeDate) ^
      const DeepCollectionEquality().hash(pricePerUnit) ^
      const DeepCollectionEquality().hash(quantitySold) ^
      const DeepCollectionEquality().hash(totalRevenue) ^
      const DeepCollectionEquality().hash(seasonLabel) ^
      const DeepCollectionEquality().hash(documentFileId) ^
      runtimeType.hashCode;
}

extension $IncomeRecordCreateExtension on IncomeRecordCreate {
  IncomeRecordCreate copyWith({
    String? crop,
    String? buyer,
    DateTime? incomeDate,
    double? pricePerUnit,
    double? quantitySold,
    double? totalRevenue,
    String? seasonLabel,
    String? documentFileId,
  }) {
    return IncomeRecordCreate(
      crop: crop ?? this.crop,
      buyer: buyer ?? this.buyer,
      incomeDate: incomeDate ?? this.incomeDate,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      quantitySold: quantitySold ?? this.quantitySold,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      seasonLabel: seasonLabel ?? this.seasonLabel,
      documentFileId: documentFileId ?? this.documentFileId,
    );
  }

  IncomeRecordCreate copyWithWrapped({
    Wrapped<String?>? crop,
    Wrapped<String?>? buyer,
    Wrapped<DateTime>? incomeDate,
    Wrapped<double?>? pricePerUnit,
    Wrapped<double?>? quantitySold,
    Wrapped<double?>? totalRevenue,
    Wrapped<String?>? seasonLabel,
    Wrapped<String?>? documentFileId,
  }) {
    return IncomeRecordCreate(
      crop: (crop != null ? crop.value : this.crop),
      buyer: (buyer != null ? buyer.value : this.buyer),
      incomeDate: (incomeDate != null ? incomeDate.value : this.incomeDate),
      pricePerUnit: (pricePerUnit != null
          ? pricePerUnit.value
          : this.pricePerUnit),
      quantitySold: (quantitySold != null
          ? quantitySold.value
          : this.quantitySold),
      totalRevenue: (totalRevenue != null
          ? totalRevenue.value
          : this.totalRevenue),
      seasonLabel: (seasonLabel != null ? seasonLabel.value : this.seasonLabel),
      documentFileId: (documentFileId != null
          ? documentFileId.value
          : this.documentFileId),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class IncomeRecordUpdate {
  const IncomeRecordUpdate({
    this.crop,
    this.buyer,
    this.incomeDate,
    this.pricePerUnit,
    this.quantitySold,
    this.totalRevenue,
    this.seasonLabel,
    this.documentFileId,
  });

  factory IncomeRecordUpdate.fromJson(Map<String, dynamic> json) =>
      _$IncomeRecordUpdateFromJson(json);

  static const toJsonFactory = _$IncomeRecordUpdateToJson;
  Map<String, dynamic> toJson() => _$IncomeRecordUpdateToJson(this);

  @JsonKey(name: 'crop')
  final String? crop;
  @JsonKey(name: 'buyer')
  final String? buyer;
  @JsonKey(name: 'income_date', toJson: _dateToJson)
  final DateTime? incomeDate;
  @JsonKey(name: 'price_per_unit')
  final double? pricePerUnit;
  @JsonKey(name: 'quantity_sold')
  final double? quantitySold;
  @JsonKey(name: 'total_revenue')
  final double? totalRevenue;
  @JsonKey(name: 'season_label')
  final String? seasonLabel;
  @JsonKey(name: 'document_file_id')
  final String? documentFileId;
  static const fromJsonFactory = _$IncomeRecordUpdateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is IncomeRecordUpdate &&
            (identical(other.crop, crop) ||
                const DeepCollectionEquality().equals(other.crop, crop)) &&
            (identical(other.buyer, buyer) ||
                const DeepCollectionEquality().equals(other.buyer, buyer)) &&
            (identical(other.incomeDate, incomeDate) ||
                const DeepCollectionEquality().equals(
                  other.incomeDate,
                  incomeDate,
                )) &&
            (identical(other.pricePerUnit, pricePerUnit) ||
                const DeepCollectionEquality().equals(
                  other.pricePerUnit,
                  pricePerUnit,
                )) &&
            (identical(other.quantitySold, quantitySold) ||
                const DeepCollectionEquality().equals(
                  other.quantitySold,
                  quantitySold,
                )) &&
            (identical(other.totalRevenue, totalRevenue) ||
                const DeepCollectionEquality().equals(
                  other.totalRevenue,
                  totalRevenue,
                )) &&
            (identical(other.seasonLabel, seasonLabel) ||
                const DeepCollectionEquality().equals(
                  other.seasonLabel,
                  seasonLabel,
                )) &&
            (identical(other.documentFileId, documentFileId) ||
                const DeepCollectionEquality().equals(
                  other.documentFileId,
                  documentFileId,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(crop) ^
      const DeepCollectionEquality().hash(buyer) ^
      const DeepCollectionEquality().hash(incomeDate) ^
      const DeepCollectionEquality().hash(pricePerUnit) ^
      const DeepCollectionEquality().hash(quantitySold) ^
      const DeepCollectionEquality().hash(totalRevenue) ^
      const DeepCollectionEquality().hash(seasonLabel) ^
      const DeepCollectionEquality().hash(documentFileId) ^
      runtimeType.hashCode;
}

extension $IncomeRecordUpdateExtension on IncomeRecordUpdate {
  IncomeRecordUpdate copyWith({
    String? crop,
    String? buyer,
    DateTime? incomeDate,
    double? pricePerUnit,
    double? quantitySold,
    double? totalRevenue,
    String? seasonLabel,
    String? documentFileId,
  }) {
    return IncomeRecordUpdate(
      crop: crop ?? this.crop,
      buyer: buyer ?? this.buyer,
      incomeDate: incomeDate ?? this.incomeDate,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      quantitySold: quantitySold ?? this.quantitySold,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      seasonLabel: seasonLabel ?? this.seasonLabel,
      documentFileId: documentFileId ?? this.documentFileId,
    );
  }

  IncomeRecordUpdate copyWithWrapped({
    Wrapped<String?>? crop,
    Wrapped<String?>? buyer,
    Wrapped<DateTime?>? incomeDate,
    Wrapped<double?>? pricePerUnit,
    Wrapped<double?>? quantitySold,
    Wrapped<double?>? totalRevenue,
    Wrapped<String?>? seasonLabel,
    Wrapped<String?>? documentFileId,
  }) {
    return IncomeRecordUpdate(
      crop: (crop != null ? crop.value : this.crop),
      buyer: (buyer != null ? buyer.value : this.buyer),
      incomeDate: (incomeDate != null ? incomeDate.value : this.incomeDate),
      pricePerUnit: (pricePerUnit != null
          ? pricePerUnit.value
          : this.pricePerUnit),
      quantitySold: (quantitySold != null
          ? quantitySold.value
          : this.quantitySold),
      totalRevenue: (totalRevenue != null
          ? totalRevenue.value
          : this.totalRevenue),
      seasonLabel: (seasonLabel != null ? seasonLabel.value : this.seasonLabel),
      documentFileId: (documentFileId != null
          ? documentFileId.value
          : this.documentFileId),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class IncomeRecordListResponse {
  const IncomeRecordListResponse({
    required this.data,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory IncomeRecordListResponse.fromJson(Map<String, dynamic> json) =>
      _$IncomeRecordListResponseFromJson(json);

  static const toJsonFactory = _$IncomeRecordListResponseToJson;
  Map<String, dynamic> toJson() => _$IncomeRecordListResponseToJson(this);

  @JsonKey(name: 'data', defaultValue: <IncomeRecord>[])
  final List<IncomeRecord> data;
  @JsonKey(name: 'limit')
  final int limit;
  @JsonKey(name: 'offset')
  final int offset;
  @JsonKey(name: 'total')
  final int total;
  static const fromJsonFactory = _$IncomeRecordListResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is IncomeRecordListResponse &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)) &&
            (identical(other.limit, limit) ||
                const DeepCollectionEquality().equals(other.limit, limit)) &&
            (identical(other.offset, offset) ||
                const DeepCollectionEquality().equals(other.offset, offset)) &&
            (identical(other.total, total) ||
                const DeepCollectionEquality().equals(other.total, total)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(data) ^
      const DeepCollectionEquality().hash(limit) ^
      const DeepCollectionEquality().hash(offset) ^
      const DeepCollectionEquality().hash(total) ^
      runtimeType.hashCode;
}

extension $IncomeRecordListResponseExtension on IncomeRecordListResponse {
  IncomeRecordListResponse copyWith({
    List<IncomeRecord>? data,
    int? limit,
    int? offset,
    int? total,
  }) {
    return IncomeRecordListResponse(
      data: data ?? this.data,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  IncomeRecordListResponse copyWithWrapped({
    Wrapped<List<IncomeRecord>>? data,
    Wrapped<int>? limit,
    Wrapped<int>? offset,
    Wrapped<int>? total,
  }) {
    return IncomeRecordListResponse(
      data: (data != null ? data.value : this.data),
      limit: (limit != null ? limit.value : this.limit),
      offset: (offset != null ? offset.value : this.offset),
      total: (total != null ? total.value : this.total),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class SeasonBudget {
  const SeasonBudget({
    this.id,
    this.ownerUser,
    required this.seasonLabel,
    this.category,
    required this.budgetAmount,
    this.createdAt,
    this.updatedAt,
  });

  factory SeasonBudget.fromJson(Map<String, dynamic> json) =>
      _$SeasonBudgetFromJson(json);

  static const toJsonFactory = _$SeasonBudgetToJson;
  Map<String, dynamic> toJson() => _$SeasonBudgetToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'owner_user')
  final String? ownerUser;
  @JsonKey(name: 'season_label')
  final String seasonLabel;
  @JsonKey(name: 'category')
  final String? category;
  @JsonKey(name: 'budget_amount')
  final double budgetAmount;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  static const fromJsonFactory = _$SeasonBudgetFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is SeasonBudget &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.ownerUser, ownerUser) ||
                const DeepCollectionEquality().equals(
                  other.ownerUser,
                  ownerUser,
                )) &&
            (identical(other.seasonLabel, seasonLabel) ||
                const DeepCollectionEquality().equals(
                  other.seasonLabel,
                  seasonLabel,
                )) &&
            (identical(other.category, category) ||
                const DeepCollectionEquality().equals(
                  other.category,
                  category,
                )) &&
            (identical(other.budgetAmount, budgetAmount) ||
                const DeepCollectionEquality().equals(
                  other.budgetAmount,
                  budgetAmount,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(ownerUser) ^
      const DeepCollectionEquality().hash(seasonLabel) ^
      const DeepCollectionEquality().hash(category) ^
      const DeepCollectionEquality().hash(budgetAmount) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      runtimeType.hashCode;
}

extension $SeasonBudgetExtension on SeasonBudget {
  SeasonBudget copyWith({
    String? id,
    String? ownerUser,
    String? seasonLabel,
    String? category,
    double? budgetAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SeasonBudget(
      id: id ?? this.id,
      ownerUser: ownerUser ?? this.ownerUser,
      seasonLabel: seasonLabel ?? this.seasonLabel,
      category: category ?? this.category,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  SeasonBudget copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String?>? ownerUser,
    Wrapped<String>? seasonLabel,
    Wrapped<String?>? category,
    Wrapped<double>? budgetAmount,
    Wrapped<DateTime?>? createdAt,
    Wrapped<DateTime?>? updatedAt,
  }) {
    return SeasonBudget(
      id: (id != null ? id.value : this.id),
      ownerUser: (ownerUser != null ? ownerUser.value : this.ownerUser),
      seasonLabel: (seasonLabel != null ? seasonLabel.value : this.seasonLabel),
      category: (category != null ? category.value : this.category),
      budgetAmount: (budgetAmount != null
          ? budgetAmount.value
          : this.budgetAmount),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class SeasonBudgetCreate {
  const SeasonBudgetCreate({
    required this.seasonLabel,
    this.category,
    required this.budgetAmount,
  });

  factory SeasonBudgetCreate.fromJson(Map<String, dynamic> json) =>
      _$SeasonBudgetCreateFromJson(json);

  static const toJsonFactory = _$SeasonBudgetCreateToJson;
  Map<String, dynamic> toJson() => _$SeasonBudgetCreateToJson(this);

  @JsonKey(name: 'season_label')
  final String seasonLabel;
  @JsonKey(name: 'category')
  final String? category;
  @JsonKey(name: 'budget_amount')
  final double budgetAmount;
  static const fromJsonFactory = _$SeasonBudgetCreateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is SeasonBudgetCreate &&
            (identical(other.seasonLabel, seasonLabel) ||
                const DeepCollectionEquality().equals(
                  other.seasonLabel,
                  seasonLabel,
                )) &&
            (identical(other.category, category) ||
                const DeepCollectionEquality().equals(
                  other.category,
                  category,
                )) &&
            (identical(other.budgetAmount, budgetAmount) ||
                const DeepCollectionEquality().equals(
                  other.budgetAmount,
                  budgetAmount,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(seasonLabel) ^
      const DeepCollectionEquality().hash(category) ^
      const DeepCollectionEquality().hash(budgetAmount) ^
      runtimeType.hashCode;
}

extension $SeasonBudgetCreateExtension on SeasonBudgetCreate {
  SeasonBudgetCreate copyWith({
    String? seasonLabel,
    String? category,
    double? budgetAmount,
  }) {
    return SeasonBudgetCreate(
      seasonLabel: seasonLabel ?? this.seasonLabel,
      category: category ?? this.category,
      budgetAmount: budgetAmount ?? this.budgetAmount,
    );
  }

  SeasonBudgetCreate copyWithWrapped({
    Wrapped<String>? seasonLabel,
    Wrapped<String?>? category,
    Wrapped<double>? budgetAmount,
  }) {
    return SeasonBudgetCreate(
      seasonLabel: (seasonLabel != null ? seasonLabel.value : this.seasonLabel),
      category: (category != null ? category.value : this.category),
      budgetAmount: (budgetAmount != null
          ? budgetAmount.value
          : this.budgetAmount),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class SeasonBudgetUpdate {
  const SeasonBudgetUpdate({
    this.seasonLabel,
    this.category,
    this.budgetAmount,
  });

  factory SeasonBudgetUpdate.fromJson(Map<String, dynamic> json) =>
      _$SeasonBudgetUpdateFromJson(json);

  static const toJsonFactory = _$SeasonBudgetUpdateToJson;
  Map<String, dynamic> toJson() => _$SeasonBudgetUpdateToJson(this);

  @JsonKey(name: 'season_label')
  final String? seasonLabel;
  @JsonKey(name: 'category')
  final String? category;
  @JsonKey(name: 'budget_amount')
  final double? budgetAmount;
  static const fromJsonFactory = _$SeasonBudgetUpdateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is SeasonBudgetUpdate &&
            (identical(other.seasonLabel, seasonLabel) ||
                const DeepCollectionEquality().equals(
                  other.seasonLabel,
                  seasonLabel,
                )) &&
            (identical(other.category, category) ||
                const DeepCollectionEquality().equals(
                  other.category,
                  category,
                )) &&
            (identical(other.budgetAmount, budgetAmount) ||
                const DeepCollectionEquality().equals(
                  other.budgetAmount,
                  budgetAmount,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(seasonLabel) ^
      const DeepCollectionEquality().hash(category) ^
      const DeepCollectionEquality().hash(budgetAmount) ^
      runtimeType.hashCode;
}

extension $SeasonBudgetUpdateExtension on SeasonBudgetUpdate {
  SeasonBudgetUpdate copyWith({
    String? seasonLabel,
    String? category,
    double? budgetAmount,
  }) {
    return SeasonBudgetUpdate(
      seasonLabel: seasonLabel ?? this.seasonLabel,
      category: category ?? this.category,
      budgetAmount: budgetAmount ?? this.budgetAmount,
    );
  }

  SeasonBudgetUpdate copyWithWrapped({
    Wrapped<String?>? seasonLabel,
    Wrapped<String?>? category,
    Wrapped<double?>? budgetAmount,
  }) {
    return SeasonBudgetUpdate(
      seasonLabel: (seasonLabel != null ? seasonLabel.value : this.seasonLabel),
      category: (category != null ? category.value : this.category),
      budgetAmount: (budgetAmount != null
          ? budgetAmount.value
          : this.budgetAmount),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class SeasonBudgetListResponse {
  const SeasonBudgetListResponse({
    required this.data,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory SeasonBudgetListResponse.fromJson(Map<String, dynamic> json) =>
      _$SeasonBudgetListResponseFromJson(json);

  static const toJsonFactory = _$SeasonBudgetListResponseToJson;
  Map<String, dynamic> toJson() => _$SeasonBudgetListResponseToJson(this);

  @JsonKey(name: 'data', defaultValue: <SeasonBudget>[])
  final List<SeasonBudget> data;
  @JsonKey(name: 'limit')
  final int limit;
  @JsonKey(name: 'offset')
  final int offset;
  @JsonKey(name: 'total')
  final int total;
  static const fromJsonFactory = _$SeasonBudgetListResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is SeasonBudgetListResponse &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)) &&
            (identical(other.limit, limit) ||
                const DeepCollectionEquality().equals(other.limit, limit)) &&
            (identical(other.offset, offset) ||
                const DeepCollectionEquality().equals(other.offset, offset)) &&
            (identical(other.total, total) ||
                const DeepCollectionEquality().equals(other.total, total)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(data) ^
      const DeepCollectionEquality().hash(limit) ^
      const DeepCollectionEquality().hash(offset) ^
      const DeepCollectionEquality().hash(total) ^
      runtimeType.hashCode;
}

extension $SeasonBudgetListResponseExtension on SeasonBudgetListResponse {
  SeasonBudgetListResponse copyWith({
    List<SeasonBudget>? data,
    int? limit,
    int? offset,
    int? total,
  }) {
    return SeasonBudgetListResponse(
      data: data ?? this.data,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  SeasonBudgetListResponse copyWithWrapped({
    Wrapped<List<SeasonBudget>>? data,
    Wrapped<int>? limit,
    Wrapped<int>? offset,
    Wrapped<int>? total,
  }) {
    return SeasonBudgetListResponse(
      data: (data != null ? data.value : this.data),
      limit: (limit != null ? limit.value : this.limit),
      offset: (offset != null ? offset.value : this.offset),
      total: (total != null ? total.value : this.total),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AiCropPlan {
  const AiCropPlan({
    this.id,
    this.ownerUser,
    this.crop,
    this.priorityAction,
    this.recommendationText,
    this.createdAt,
  });

  factory AiCropPlan.fromJson(Map<String, dynamic> json) =>
      _$AiCropPlanFromJson(json);

  static const toJsonFactory = _$AiCropPlanToJson;
  Map<String, dynamic> toJson() => _$AiCropPlanToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'owner_user')
  final String? ownerUser;
  @JsonKey(name: 'crop')
  final String? crop;
  @JsonKey(name: 'priority_action')
  final String? priorityAction;
  @JsonKey(name: 'recommendation_text')
  final String? recommendationText;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  static const fromJsonFactory = _$AiCropPlanFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AiCropPlan &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.ownerUser, ownerUser) ||
                const DeepCollectionEquality().equals(
                  other.ownerUser,
                  ownerUser,
                )) &&
            (identical(other.crop, crop) ||
                const DeepCollectionEquality().equals(other.crop, crop)) &&
            (identical(other.priorityAction, priorityAction) ||
                const DeepCollectionEquality().equals(
                  other.priorityAction,
                  priorityAction,
                )) &&
            (identical(other.recommendationText, recommendationText) ||
                const DeepCollectionEquality().equals(
                  other.recommendationText,
                  recommendationText,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(ownerUser) ^
      const DeepCollectionEquality().hash(crop) ^
      const DeepCollectionEquality().hash(priorityAction) ^
      const DeepCollectionEquality().hash(recommendationText) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $AiCropPlanExtension on AiCropPlan {
  AiCropPlan copyWith({
    String? id,
    String? ownerUser,
    String? crop,
    String? priorityAction,
    String? recommendationText,
    DateTime? createdAt,
  }) {
    return AiCropPlan(
      id: id ?? this.id,
      ownerUser: ownerUser ?? this.ownerUser,
      crop: crop ?? this.crop,
      priorityAction: priorityAction ?? this.priorityAction,
      recommendationText: recommendationText ?? this.recommendationText,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  AiCropPlan copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String?>? ownerUser,
    Wrapped<String?>? crop,
    Wrapped<String?>? priorityAction,
    Wrapped<String?>? recommendationText,
    Wrapped<DateTime?>? createdAt,
  }) {
    return AiCropPlan(
      id: (id != null ? id.value : this.id),
      ownerUser: (ownerUser != null ? ownerUser.value : this.ownerUser),
      crop: (crop != null ? crop.value : this.crop),
      priorityAction: (priorityAction != null
          ? priorityAction.value
          : this.priorityAction),
      recommendationText: (recommendationText != null
          ? recommendationText.value
          : this.recommendationText),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AiCropPlanCreate {
  const AiCropPlanCreate({
    this.crop,
    this.priorityAction,
    this.recommendationText,
  });

  factory AiCropPlanCreate.fromJson(Map<String, dynamic> json) =>
      _$AiCropPlanCreateFromJson(json);

  static const toJsonFactory = _$AiCropPlanCreateToJson;
  Map<String, dynamic> toJson() => _$AiCropPlanCreateToJson(this);

  @JsonKey(name: 'crop')
  final String? crop;
  @JsonKey(name: 'priority_action')
  final String? priorityAction;
  @JsonKey(name: 'recommendation_text')
  final String? recommendationText;
  static const fromJsonFactory = _$AiCropPlanCreateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AiCropPlanCreate &&
            (identical(other.crop, crop) ||
                const DeepCollectionEquality().equals(other.crop, crop)) &&
            (identical(other.priorityAction, priorityAction) ||
                const DeepCollectionEquality().equals(
                  other.priorityAction,
                  priorityAction,
                )) &&
            (identical(other.recommendationText, recommendationText) ||
                const DeepCollectionEquality().equals(
                  other.recommendationText,
                  recommendationText,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(crop) ^
      const DeepCollectionEquality().hash(priorityAction) ^
      const DeepCollectionEquality().hash(recommendationText) ^
      runtimeType.hashCode;
}

extension $AiCropPlanCreateExtension on AiCropPlanCreate {
  AiCropPlanCreate copyWith({
    String? crop,
    String? priorityAction,
    String? recommendationText,
  }) {
    return AiCropPlanCreate(
      crop: crop ?? this.crop,
      priorityAction: priorityAction ?? this.priorityAction,
      recommendationText: recommendationText ?? this.recommendationText,
    );
  }

  AiCropPlanCreate copyWithWrapped({
    Wrapped<String?>? crop,
    Wrapped<String?>? priorityAction,
    Wrapped<String?>? recommendationText,
  }) {
    return AiCropPlanCreate(
      crop: (crop != null ? crop.value : this.crop),
      priorityAction: (priorityAction != null
          ? priorityAction.value
          : this.priorityAction),
      recommendationText: (recommendationText != null
          ? recommendationText.value
          : this.recommendationText),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AiCropPlanListResponse {
  const AiCropPlanListResponse({
    required this.data,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory AiCropPlanListResponse.fromJson(Map<String, dynamic> json) =>
      _$AiCropPlanListResponseFromJson(json);

  static const toJsonFactory = _$AiCropPlanListResponseToJson;
  Map<String, dynamic> toJson() => _$AiCropPlanListResponseToJson(this);

  @JsonKey(name: 'data', defaultValue: <AiCropPlan>[])
  final List<AiCropPlan> data;
  @JsonKey(name: 'limit')
  final int limit;
  @JsonKey(name: 'offset')
  final int offset;
  @JsonKey(name: 'total')
  final int total;
  static const fromJsonFactory = _$AiCropPlanListResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AiCropPlanListResponse &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)) &&
            (identical(other.limit, limit) ||
                const DeepCollectionEquality().equals(other.limit, limit)) &&
            (identical(other.offset, offset) ||
                const DeepCollectionEquality().equals(other.offset, offset)) &&
            (identical(other.total, total) ||
                const DeepCollectionEquality().equals(other.total, total)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(data) ^
      const DeepCollectionEquality().hash(limit) ^
      const DeepCollectionEquality().hash(offset) ^
      const DeepCollectionEquality().hash(total) ^
      runtimeType.hashCode;
}

extension $AiCropPlanListResponseExtension on AiCropPlanListResponse {
  AiCropPlanListResponse copyWith({
    List<AiCropPlan>? data,
    int? limit,
    int? offset,
    int? total,
  }) {
    return AiCropPlanListResponse(
      data: data ?? this.data,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  AiCropPlanListResponse copyWithWrapped({
    Wrapped<List<AiCropPlan>>? data,
    Wrapped<int>? limit,
    Wrapped<int>? offset,
    Wrapped<int>? total,
  }) {
    return AiCropPlanListResponse(
      data: (data != null ? data.value : this.data),
      limit: (limit != null ? limit.value : this.limit),
      offset: (offset != null ? offset.value : this.offset),
      total: (total != null ? total.value : this.total),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AiInsight {
  const AiInsight({
    this.id,
    this.ownerUser,
    this.category,
    this.insightText,
    this.createdAt,
  });

  factory AiInsight.fromJson(Map<String, dynamic> json) =>
      _$AiInsightFromJson(json);

  static const toJsonFactory = _$AiInsightToJson;
  Map<String, dynamic> toJson() => _$AiInsightToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'owner_user')
  final String? ownerUser;
  @JsonKey(name: 'category')
  final String? category;
  @JsonKey(name: 'insight_text')
  final String? insightText;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  static const fromJsonFactory = _$AiInsightFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AiInsight &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.ownerUser, ownerUser) ||
                const DeepCollectionEquality().equals(
                  other.ownerUser,
                  ownerUser,
                )) &&
            (identical(other.category, category) ||
                const DeepCollectionEquality().equals(
                  other.category,
                  category,
                )) &&
            (identical(other.insightText, insightText) ||
                const DeepCollectionEquality().equals(
                  other.insightText,
                  insightText,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(ownerUser) ^
      const DeepCollectionEquality().hash(category) ^
      const DeepCollectionEquality().hash(insightText) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $AiInsightExtension on AiInsight {
  AiInsight copyWith({
    String? id,
    String? ownerUser,
    String? category,
    String? insightText,
    DateTime? createdAt,
  }) {
    return AiInsight(
      id: id ?? this.id,
      ownerUser: ownerUser ?? this.ownerUser,
      category: category ?? this.category,
      insightText: insightText ?? this.insightText,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  AiInsight copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String?>? ownerUser,
    Wrapped<String?>? category,
    Wrapped<String?>? insightText,
    Wrapped<DateTime?>? createdAt,
  }) {
    return AiInsight(
      id: (id != null ? id.value : this.id),
      ownerUser: (ownerUser != null ? ownerUser.value : this.ownerUser),
      category: (category != null ? category.value : this.category),
      insightText: (insightText != null ? insightText.value : this.insightText),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AiInsightCreate {
  const AiInsightCreate({this.category, this.insightText});

  factory AiInsightCreate.fromJson(Map<String, dynamic> json) =>
      _$AiInsightCreateFromJson(json);

  static const toJsonFactory = _$AiInsightCreateToJson;
  Map<String, dynamic> toJson() => _$AiInsightCreateToJson(this);

  @JsonKey(name: 'category')
  final String? category;
  @JsonKey(name: 'insight_text')
  final String? insightText;
  static const fromJsonFactory = _$AiInsightCreateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AiInsightCreate &&
            (identical(other.category, category) ||
                const DeepCollectionEquality().equals(
                  other.category,
                  category,
                )) &&
            (identical(other.insightText, insightText) ||
                const DeepCollectionEquality().equals(
                  other.insightText,
                  insightText,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(category) ^
      const DeepCollectionEquality().hash(insightText) ^
      runtimeType.hashCode;
}

extension $AiInsightCreateExtension on AiInsightCreate {
  AiInsightCreate copyWith({String? category, String? insightText}) {
    return AiInsightCreate(
      category: category ?? this.category,
      insightText: insightText ?? this.insightText,
    );
  }

  AiInsightCreate copyWithWrapped({
    Wrapped<String?>? category,
    Wrapped<String?>? insightText,
  }) {
    return AiInsightCreate(
      category: (category != null ? category.value : this.category),
      insightText: (insightText != null ? insightText.value : this.insightText),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AiInsightListResponse {
  const AiInsightListResponse({
    required this.data,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory AiInsightListResponse.fromJson(Map<String, dynamic> json) =>
      _$AiInsightListResponseFromJson(json);

  static const toJsonFactory = _$AiInsightListResponseToJson;
  Map<String, dynamic> toJson() => _$AiInsightListResponseToJson(this);

  @JsonKey(name: 'data', defaultValue: <AiInsight>[])
  final List<AiInsight> data;
  @JsonKey(name: 'limit')
  final int limit;
  @JsonKey(name: 'offset')
  final int offset;
  @JsonKey(name: 'total')
  final int total;
  static const fromJsonFactory = _$AiInsightListResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AiInsightListResponse &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)) &&
            (identical(other.limit, limit) ||
                const DeepCollectionEquality().equals(other.limit, limit)) &&
            (identical(other.offset, offset) ||
                const DeepCollectionEquality().equals(other.offset, offset)) &&
            (identical(other.total, total) ||
                const DeepCollectionEquality().equals(other.total, total)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(data) ^
      const DeepCollectionEquality().hash(limit) ^
      const DeepCollectionEquality().hash(offset) ^
      const DeepCollectionEquality().hash(total) ^
      runtimeType.hashCode;
}

extension $AiInsightListResponseExtension on AiInsightListResponse {
  AiInsightListResponse copyWith({
    List<AiInsight>? data,
    int? limit,
    int? offset,
    int? total,
  }) {
    return AiInsightListResponse(
      data: data ?? this.data,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  AiInsightListResponse copyWithWrapped({
    Wrapped<List<AiInsight>>? data,
    Wrapped<int>? limit,
    Wrapped<int>? offset,
    Wrapped<int>? total,
  }) {
    return AiInsightListResponse(
      data: (data != null ? data.value : this.data),
      limit: (limit != null ? limit.value : this.limit),
      offset: (offset != null ? offset.value : this.offset),
      total: (total != null ? total.value : this.total),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AiMessage {
  const AiMessage({
    this.id,
    this.ownerUser,
    required this.sender,
    required this.messageText,
    this.createdAt,
  });

  factory AiMessage.fromJson(Map<String, dynamic> json) =>
      _$AiMessageFromJson(json);

  static const toJsonFactory = _$AiMessageToJson;
  Map<String, dynamic> toJson() => _$AiMessageToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'owner_user')
  final String? ownerUser;
  @JsonKey(
    name: 'sender',
    toJson: aiMessageSenderToJson,
    fromJson: aiMessageSenderFromJson,
  )
  final enums.AiMessageSender sender;
  @JsonKey(name: 'message_text')
  final String messageText;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  static const fromJsonFactory = _$AiMessageFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AiMessage &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.ownerUser, ownerUser) ||
                const DeepCollectionEquality().equals(
                  other.ownerUser,
                  ownerUser,
                )) &&
            (identical(other.sender, sender) ||
                const DeepCollectionEquality().equals(other.sender, sender)) &&
            (identical(other.messageText, messageText) ||
                const DeepCollectionEquality().equals(
                  other.messageText,
                  messageText,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(ownerUser) ^
      const DeepCollectionEquality().hash(sender) ^
      const DeepCollectionEquality().hash(messageText) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $AiMessageExtension on AiMessage {
  AiMessage copyWith({
    String? id,
    String? ownerUser,
    enums.AiMessageSender? sender,
    String? messageText,
    DateTime? createdAt,
  }) {
    return AiMessage(
      id: id ?? this.id,
      ownerUser: ownerUser ?? this.ownerUser,
      sender: sender ?? this.sender,
      messageText: messageText ?? this.messageText,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  AiMessage copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String?>? ownerUser,
    Wrapped<enums.AiMessageSender>? sender,
    Wrapped<String>? messageText,
    Wrapped<DateTime?>? createdAt,
  }) {
    return AiMessage(
      id: (id != null ? id.value : this.id),
      ownerUser: (ownerUser != null ? ownerUser.value : this.ownerUser),
      sender: (sender != null ? sender.value : this.sender),
      messageText: (messageText != null ? messageText.value : this.messageText),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AiMessageCreate {
  const AiMessageCreate({required this.sender, required this.messageText});

  factory AiMessageCreate.fromJson(Map<String, dynamic> json) =>
      _$AiMessageCreateFromJson(json);

  static const toJsonFactory = _$AiMessageCreateToJson;
  Map<String, dynamic> toJson() => _$AiMessageCreateToJson(this);

  @JsonKey(
    name: 'sender',
    toJson: aiMessageCreateSenderToJson,
    fromJson: aiMessageCreateSenderFromJson,
  )
  final enums.AiMessageCreateSender sender;
  @JsonKey(name: 'message_text')
  final String messageText;
  static const fromJsonFactory = _$AiMessageCreateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AiMessageCreate &&
            (identical(other.sender, sender) ||
                const DeepCollectionEquality().equals(other.sender, sender)) &&
            (identical(other.messageText, messageText) ||
                const DeepCollectionEquality().equals(
                  other.messageText,
                  messageText,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(sender) ^
      const DeepCollectionEquality().hash(messageText) ^
      runtimeType.hashCode;
}

extension $AiMessageCreateExtension on AiMessageCreate {
  AiMessageCreate copyWith({
    enums.AiMessageCreateSender? sender,
    String? messageText,
  }) {
    return AiMessageCreate(
      sender: sender ?? this.sender,
      messageText: messageText ?? this.messageText,
    );
  }

  AiMessageCreate copyWithWrapped({
    Wrapped<enums.AiMessageCreateSender>? sender,
    Wrapped<String>? messageText,
  }) {
    return AiMessageCreate(
      sender: (sender != null ? sender.value : this.sender),
      messageText: (messageText != null ? messageText.value : this.messageText),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AiMessageUpdate {
  const AiMessageUpdate({this.sender, this.messageText});

  factory AiMessageUpdate.fromJson(Map<String, dynamic> json) =>
      _$AiMessageUpdateFromJson(json);

  static const toJsonFactory = _$AiMessageUpdateToJson;
  Map<String, dynamic> toJson() => _$AiMessageUpdateToJson(this);

  @JsonKey(
    name: 'sender',
    toJson: aiMessageUpdateSenderNullableToJson,
    fromJson: aiMessageUpdateSenderNullableFromJson,
  )
  final enums.AiMessageUpdateSender? sender;
  @JsonKey(name: 'message_text')
  final String? messageText;
  static const fromJsonFactory = _$AiMessageUpdateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AiMessageUpdate &&
            (identical(other.sender, sender) ||
                const DeepCollectionEquality().equals(other.sender, sender)) &&
            (identical(other.messageText, messageText) ||
                const DeepCollectionEquality().equals(
                  other.messageText,
                  messageText,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(sender) ^
      const DeepCollectionEquality().hash(messageText) ^
      runtimeType.hashCode;
}

extension $AiMessageUpdateExtension on AiMessageUpdate {
  AiMessageUpdate copyWith({
    enums.AiMessageUpdateSender? sender,
    String? messageText,
  }) {
    return AiMessageUpdate(
      sender: sender ?? this.sender,
      messageText: messageText ?? this.messageText,
    );
  }

  AiMessageUpdate copyWithWrapped({
    Wrapped<enums.AiMessageUpdateSender?>? sender,
    Wrapped<String?>? messageText,
  }) {
    return AiMessageUpdate(
      sender: (sender != null ? sender.value : this.sender),
      messageText: (messageText != null ? messageText.value : this.messageText),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AiMessageListResponse {
  const AiMessageListResponse({
    required this.data,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory AiMessageListResponse.fromJson(Map<String, dynamic> json) =>
      _$AiMessageListResponseFromJson(json);

  static const toJsonFactory = _$AiMessageListResponseToJson;
  Map<String, dynamic> toJson() => _$AiMessageListResponseToJson(this);

  @JsonKey(name: 'data', defaultValue: <AiMessage>[])
  final List<AiMessage> data;
  @JsonKey(name: 'limit')
  final int limit;
  @JsonKey(name: 'offset')
  final int offset;
  @JsonKey(name: 'total')
  final int total;
  static const fromJsonFactory = _$AiMessageListResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AiMessageListResponse &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)) &&
            (identical(other.limit, limit) ||
                const DeepCollectionEquality().equals(other.limit, limit)) &&
            (identical(other.offset, offset) ||
                const DeepCollectionEquality().equals(other.offset, offset)) &&
            (identical(other.total, total) ||
                const DeepCollectionEquality().equals(other.total, total)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(data) ^
      const DeepCollectionEquality().hash(limit) ^
      const DeepCollectionEquality().hash(offset) ^
      const DeepCollectionEquality().hash(total) ^
      runtimeType.hashCode;
}

extension $AiMessageListResponseExtension on AiMessageListResponse {
  AiMessageListResponse copyWith({
    List<AiMessage>? data,
    int? limit,
    int? offset,
    int? total,
  }) {
    return AiMessageListResponse(
      data: data ?? this.data,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  AiMessageListResponse copyWithWrapped({
    Wrapped<List<AiMessage>>? data,
    Wrapped<int>? limit,
    Wrapped<int>? offset,
    Wrapped<int>? total,
  }) {
    return AiMessageListResponse(
      data: (data != null ? data.value : this.data),
      limit: (limit != null ? limit.value : this.limit),
      offset: (offset != null ? offset.value : this.offset),
      total: (total != null ? total.value : this.total),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CommunicationPreference {
  const CommunicationPreference({
    this.id,
    this.ownerUser,
    this.defaultChannel,
    this.notificationType,
    required this.emailEnabled,
    required this.smsEnabled,
    required this.whatsappEnabled,
    required this.inAppEnabled,
    this.updatedAt,
  });

  factory CommunicationPreference.fromJson(Map<String, dynamic> json) =>
      _$CommunicationPreferenceFromJson(json);

  static const toJsonFactory = _$CommunicationPreferenceToJson;
  Map<String, dynamic> toJson() => _$CommunicationPreferenceToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'owner_user')
  final String? ownerUser;
  @JsonKey(name: 'default_channel')
  final String? defaultChannel;
  @JsonKey(name: 'notification_type')
  final String? notificationType;
  @JsonKey(name: 'email_enabled', defaultValue: false)
  final bool emailEnabled;
  @JsonKey(name: 'sms_enabled', defaultValue: false)
  final bool smsEnabled;
  @JsonKey(name: 'whatsapp_enabled', defaultValue: false)
  final bool whatsappEnabled;
  @JsonKey(name: 'in_app_enabled', defaultValue: true)
  final bool inAppEnabled;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  static const fromJsonFactory = _$CommunicationPreferenceFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CommunicationPreference &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.ownerUser, ownerUser) ||
                const DeepCollectionEquality().equals(
                  other.ownerUser,
                  ownerUser,
                )) &&
            (identical(other.defaultChannel, defaultChannel) ||
                const DeepCollectionEquality().equals(
                  other.defaultChannel,
                  defaultChannel,
                )) &&
            (identical(other.notificationType, notificationType) ||
                const DeepCollectionEquality().equals(
                  other.notificationType,
                  notificationType,
                )) &&
            (identical(other.emailEnabled, emailEnabled) ||
                const DeepCollectionEquality().equals(
                  other.emailEnabled,
                  emailEnabled,
                )) &&
            (identical(other.smsEnabled, smsEnabled) ||
                const DeepCollectionEquality().equals(
                  other.smsEnabled,
                  smsEnabled,
                )) &&
            (identical(other.whatsappEnabled, whatsappEnabled) ||
                const DeepCollectionEquality().equals(
                  other.whatsappEnabled,
                  whatsappEnabled,
                )) &&
            (identical(other.inAppEnabled, inAppEnabled) ||
                const DeepCollectionEquality().equals(
                  other.inAppEnabled,
                  inAppEnabled,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(ownerUser) ^
      const DeepCollectionEquality().hash(defaultChannel) ^
      const DeepCollectionEquality().hash(notificationType) ^
      const DeepCollectionEquality().hash(emailEnabled) ^
      const DeepCollectionEquality().hash(smsEnabled) ^
      const DeepCollectionEquality().hash(whatsappEnabled) ^
      const DeepCollectionEquality().hash(inAppEnabled) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      runtimeType.hashCode;
}

extension $CommunicationPreferenceExtension on CommunicationPreference {
  CommunicationPreference copyWith({
    String? id,
    String? ownerUser,
    String? defaultChannel,
    String? notificationType,
    bool? emailEnabled,
    bool? smsEnabled,
    bool? whatsappEnabled,
    bool? inAppEnabled,
    DateTime? updatedAt,
  }) {
    return CommunicationPreference(
      id: id ?? this.id,
      ownerUser: ownerUser ?? this.ownerUser,
      defaultChannel: defaultChannel ?? this.defaultChannel,
      notificationType: notificationType ?? this.notificationType,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  CommunicationPreference copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String?>? ownerUser,
    Wrapped<String?>? defaultChannel,
    Wrapped<String?>? notificationType,
    Wrapped<bool>? emailEnabled,
    Wrapped<bool>? smsEnabled,
    Wrapped<bool>? whatsappEnabled,
    Wrapped<bool>? inAppEnabled,
    Wrapped<DateTime?>? updatedAt,
  }) {
    return CommunicationPreference(
      id: (id != null ? id.value : this.id),
      ownerUser: (ownerUser != null ? ownerUser.value : this.ownerUser),
      defaultChannel: (defaultChannel != null
          ? defaultChannel.value
          : this.defaultChannel),
      notificationType: (notificationType != null
          ? notificationType.value
          : this.notificationType),
      emailEnabled: (emailEnabled != null
          ? emailEnabled.value
          : this.emailEnabled),
      smsEnabled: (smsEnabled != null ? smsEnabled.value : this.smsEnabled),
      whatsappEnabled: (whatsappEnabled != null
          ? whatsappEnabled.value
          : this.whatsappEnabled),
      inAppEnabled: (inAppEnabled != null
          ? inAppEnabled.value
          : this.inAppEnabled),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CommunicationPreferenceCreate {
  const CommunicationPreferenceCreate({
    this.defaultChannel,
    this.notificationType,
    this.emailEnabled,
    this.smsEnabled,
    this.whatsappEnabled,
    this.inAppEnabled,
  });

  factory CommunicationPreferenceCreate.fromJson(Map<String, dynamic> json) =>
      _$CommunicationPreferenceCreateFromJson(json);

  static const toJsonFactory = _$CommunicationPreferenceCreateToJson;
  Map<String, dynamic> toJson() => _$CommunicationPreferenceCreateToJson(this);

  @JsonKey(name: 'default_channel')
  final String? defaultChannel;
  @JsonKey(name: 'notification_type')
  final String? notificationType;
  @JsonKey(name: 'email_enabled', defaultValue: false)
  final bool? emailEnabled;
  @JsonKey(name: 'sms_enabled', defaultValue: false)
  final bool? smsEnabled;
  @JsonKey(name: 'whatsapp_enabled', defaultValue: false)
  final bool? whatsappEnabled;
  @JsonKey(name: 'in_app_enabled', defaultValue: true)
  final bool? inAppEnabled;
  static const fromJsonFactory = _$CommunicationPreferenceCreateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CommunicationPreferenceCreate &&
            (identical(other.defaultChannel, defaultChannel) ||
                const DeepCollectionEquality().equals(
                  other.defaultChannel,
                  defaultChannel,
                )) &&
            (identical(other.notificationType, notificationType) ||
                const DeepCollectionEquality().equals(
                  other.notificationType,
                  notificationType,
                )) &&
            (identical(other.emailEnabled, emailEnabled) ||
                const DeepCollectionEquality().equals(
                  other.emailEnabled,
                  emailEnabled,
                )) &&
            (identical(other.smsEnabled, smsEnabled) ||
                const DeepCollectionEquality().equals(
                  other.smsEnabled,
                  smsEnabled,
                )) &&
            (identical(other.whatsappEnabled, whatsappEnabled) ||
                const DeepCollectionEquality().equals(
                  other.whatsappEnabled,
                  whatsappEnabled,
                )) &&
            (identical(other.inAppEnabled, inAppEnabled) ||
                const DeepCollectionEquality().equals(
                  other.inAppEnabled,
                  inAppEnabled,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(defaultChannel) ^
      const DeepCollectionEquality().hash(notificationType) ^
      const DeepCollectionEquality().hash(emailEnabled) ^
      const DeepCollectionEquality().hash(smsEnabled) ^
      const DeepCollectionEquality().hash(whatsappEnabled) ^
      const DeepCollectionEquality().hash(inAppEnabled) ^
      runtimeType.hashCode;
}

extension $CommunicationPreferenceCreateExtension
    on CommunicationPreferenceCreate {
  CommunicationPreferenceCreate copyWith({
    String? defaultChannel,
    String? notificationType,
    bool? emailEnabled,
    bool? smsEnabled,
    bool? whatsappEnabled,
    bool? inAppEnabled,
  }) {
    return CommunicationPreferenceCreate(
      defaultChannel: defaultChannel ?? this.defaultChannel,
      notificationType: notificationType ?? this.notificationType,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
    );
  }

  CommunicationPreferenceCreate copyWithWrapped({
    Wrapped<String?>? defaultChannel,
    Wrapped<String?>? notificationType,
    Wrapped<bool?>? emailEnabled,
    Wrapped<bool?>? smsEnabled,
    Wrapped<bool?>? whatsappEnabled,
    Wrapped<bool?>? inAppEnabled,
  }) {
    return CommunicationPreferenceCreate(
      defaultChannel: (defaultChannel != null
          ? defaultChannel.value
          : this.defaultChannel),
      notificationType: (notificationType != null
          ? notificationType.value
          : this.notificationType),
      emailEnabled: (emailEnabled != null
          ? emailEnabled.value
          : this.emailEnabled),
      smsEnabled: (smsEnabled != null ? smsEnabled.value : this.smsEnabled),
      whatsappEnabled: (whatsappEnabled != null
          ? whatsappEnabled.value
          : this.whatsappEnabled),
      inAppEnabled: (inAppEnabled != null
          ? inAppEnabled.value
          : this.inAppEnabled),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CommunicationPreferenceListResponse {
  const CommunicationPreferenceListResponse({
    required this.data,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory CommunicationPreferenceListResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$CommunicationPreferenceListResponseFromJson(json);

  static const toJsonFactory = _$CommunicationPreferenceListResponseToJson;
  Map<String, dynamic> toJson() =>
      _$CommunicationPreferenceListResponseToJson(this);

  @JsonKey(name: 'data', defaultValue: <CommunicationPreference>[])
  final List<CommunicationPreference> data;
  @JsonKey(name: 'limit')
  final int limit;
  @JsonKey(name: 'offset')
  final int offset;
  @JsonKey(name: 'total')
  final int total;
  static const fromJsonFactory = _$CommunicationPreferenceListResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CommunicationPreferenceListResponse &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)) &&
            (identical(other.limit, limit) ||
                const DeepCollectionEquality().equals(other.limit, limit)) &&
            (identical(other.offset, offset) ||
                const DeepCollectionEquality().equals(other.offset, offset)) &&
            (identical(other.total, total) ||
                const DeepCollectionEquality().equals(other.total, total)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(data) ^
      const DeepCollectionEquality().hash(limit) ^
      const DeepCollectionEquality().hash(offset) ^
      const DeepCollectionEquality().hash(total) ^
      runtimeType.hashCode;
}

extension $CommunicationPreferenceListResponseExtension
    on CommunicationPreferenceListResponse {
  CommunicationPreferenceListResponse copyWith({
    List<CommunicationPreference>? data,
    int? limit,
    int? offset,
    int? total,
  }) {
    return CommunicationPreferenceListResponse(
      data: data ?? this.data,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  CommunicationPreferenceListResponse copyWithWrapped({
    Wrapped<List<CommunicationPreference>>? data,
    Wrapped<int>? limit,
    Wrapped<int>? offset,
    Wrapped<int>? total,
  }) {
    return CommunicationPreferenceListResponse(
      data: (data != null ? data.value : this.data),
      limit: (limit != null ? limit.value : this.limit),
      offset: (offset != null ? offset.value : this.offset),
      total: (total != null ? total.value : this.total),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Notification {
  const Notification({
    this.id,
    this.ownerUser,
    this.notificationType,
    this.title,
    this.shortMessage,
    required this.status,
    this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  static const toJsonFactory = _$NotificationToJson;
  Map<String, dynamic> toJson() => _$NotificationToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'owner_user')
  final String? ownerUser;
  @JsonKey(name: 'notification_type')
  final String? notificationType;
  @JsonKey(name: 'title')
  final String? title;
  @JsonKey(name: 'short_message')
  final String? shortMessage;
  @JsonKey(
    name: 'status',
    toJson: notificationStatusToJson,
    fromJson: notificationStatusStatusFromJson,
  )
  final enums.NotificationStatus status;
  static enums.NotificationStatus notificationStatusStatusFromJson(
    Object? value,
  ) => notificationStatusFromJson(value, enums.NotificationStatus.pending);

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  static const fromJsonFactory = _$NotificationFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Notification &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.ownerUser, ownerUser) ||
                const DeepCollectionEquality().equals(
                  other.ownerUser,
                  ownerUser,
                )) &&
            (identical(other.notificationType, notificationType) ||
                const DeepCollectionEquality().equals(
                  other.notificationType,
                  notificationType,
                )) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.shortMessage, shortMessage) ||
                const DeepCollectionEquality().equals(
                  other.shortMessage,
                  shortMessage,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(ownerUser) ^
      const DeepCollectionEquality().hash(notificationType) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(shortMessage) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $NotificationExtension on Notification {
  Notification copyWith({
    String? id,
    String? ownerUser,
    String? notificationType,
    String? title,
    String? shortMessage,
    enums.NotificationStatus? status,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      ownerUser: ownerUser ?? this.ownerUser,
      notificationType: notificationType ?? this.notificationType,
      title: title ?? this.title,
      shortMessage: shortMessage ?? this.shortMessage,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Notification copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String?>? ownerUser,
    Wrapped<String?>? notificationType,
    Wrapped<String?>? title,
    Wrapped<String?>? shortMessage,
    Wrapped<enums.NotificationStatus>? status,
    Wrapped<DateTime?>? createdAt,
  }) {
    return Notification(
      id: (id != null ? id.value : this.id),
      ownerUser: (ownerUser != null ? ownerUser.value : this.ownerUser),
      notificationType: (notificationType != null
          ? notificationType.value
          : this.notificationType),
      title: (title != null ? title.value : this.title),
      shortMessage: (shortMessage != null
          ? shortMessage.value
          : this.shortMessage),
      status: (status != null ? status.value : this.status),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class NotificationCreate {
  const NotificationCreate({
    this.notificationType,
    this.title,
    this.shortMessage,
    this.status,
  });

  factory NotificationCreate.fromJson(Map<String, dynamic> json) =>
      _$NotificationCreateFromJson(json);

  static const toJsonFactory = _$NotificationCreateToJson;
  Map<String, dynamic> toJson() => _$NotificationCreateToJson(this);

  @JsonKey(name: 'notification_type')
  final String? notificationType;
  @JsonKey(name: 'title')
  final String? title;
  @JsonKey(name: 'short_message')
  final String? shortMessage;
  @JsonKey(
    name: 'status',
    toJson: notificationCreateStatusNullableToJson,
    fromJson: notificationCreateStatusStatusNullableFromJson,
  )
  final enums.NotificationCreateStatus? status;
  static enums.NotificationCreateStatus?
  notificationCreateStatusStatusNullableFromJson(Object? value) =>
      notificationCreateStatusNullableFromJson(
        value,
        enums.NotificationCreateStatus.pending,
      );

  static const fromJsonFactory = _$NotificationCreateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is NotificationCreate &&
            (identical(other.notificationType, notificationType) ||
                const DeepCollectionEquality().equals(
                  other.notificationType,
                  notificationType,
                )) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.shortMessage, shortMessage) ||
                const DeepCollectionEquality().equals(
                  other.shortMessage,
                  shortMessage,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(notificationType) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(shortMessage) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $NotificationCreateExtension on NotificationCreate {
  NotificationCreate copyWith({
    String? notificationType,
    String? title,
    String? shortMessage,
    enums.NotificationCreateStatus? status,
  }) {
    return NotificationCreate(
      notificationType: notificationType ?? this.notificationType,
      title: title ?? this.title,
      shortMessage: shortMessage ?? this.shortMessage,
      status: status ?? this.status,
    );
  }

  NotificationCreate copyWithWrapped({
    Wrapped<String?>? notificationType,
    Wrapped<String?>? title,
    Wrapped<String?>? shortMessage,
    Wrapped<enums.NotificationCreateStatus?>? status,
  }) {
    return NotificationCreate(
      notificationType: (notificationType != null
          ? notificationType.value
          : this.notificationType),
      title: (title != null ? title.value : this.title),
      shortMessage: (shortMessage != null
          ? shortMessage.value
          : this.shortMessage),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class NotificationListResponse {
  const NotificationListResponse({
    required this.data,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationListResponseFromJson(json);

  static const toJsonFactory = _$NotificationListResponseToJson;
  Map<String, dynamic> toJson() => _$NotificationListResponseToJson(this);

  @JsonKey(name: 'data', defaultValue: <Notification>[])
  final List<Notification> data;
  @JsonKey(name: 'limit')
  final int limit;
  @JsonKey(name: 'offset')
  final int offset;
  @JsonKey(name: 'total')
  final int total;
  static const fromJsonFactory = _$NotificationListResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is NotificationListResponse &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)) &&
            (identical(other.limit, limit) ||
                const DeepCollectionEquality().equals(other.limit, limit)) &&
            (identical(other.offset, offset) ||
                const DeepCollectionEquality().equals(other.offset, offset)) &&
            (identical(other.total, total) ||
                const DeepCollectionEquality().equals(other.total, total)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(data) ^
      const DeepCollectionEquality().hash(limit) ^
      const DeepCollectionEquality().hash(offset) ^
      const DeepCollectionEquality().hash(total) ^
      runtimeType.hashCode;
}

extension $NotificationListResponseExtension on NotificationListResponse {
  NotificationListResponse copyWith({
    List<Notification>? data,
    int? limit,
    int? offset,
    int? total,
  }) {
    return NotificationListResponse(
      data: data ?? this.data,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  NotificationListResponse copyWithWrapped({
    Wrapped<List<Notification>>? data,
    Wrapped<int>? limit,
    Wrapped<int>? offset,
    Wrapped<int>? total,
  }) {
    return NotificationListResponse(
      data: (data != null ? data.value : this.data),
      limit: (limit != null ? limit.value : this.limit),
      offset: (offset != null ? offset.value : this.offset),
      total: (total != null ? total.value : this.total),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class NotificationDeliveryLog {
  const NotificationDeliveryLog({
    this.id,
    this.notificationId,
    required this.channel,
    required this.deliveryStatus,
    this.deliveredAt,
    this.createdAt,
  });

  factory NotificationDeliveryLog.fromJson(Map<String, dynamic> json) =>
      _$NotificationDeliveryLogFromJson(json);

  static const toJsonFactory = _$NotificationDeliveryLogToJson;
  Map<String, dynamic> toJson() => _$NotificationDeliveryLogToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'notification_id')
  final String? notificationId;
  @JsonKey(name: 'channel')
  final String channel;
  @JsonKey(name: 'delivery_status')
  final String deliveryStatus;
  @JsonKey(name: 'delivered_at')
  final DateTime? deliveredAt;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  static const fromJsonFactory = _$NotificationDeliveryLogFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is NotificationDeliveryLog &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.notificationId, notificationId) ||
                const DeepCollectionEquality().equals(
                  other.notificationId,
                  notificationId,
                )) &&
            (identical(other.channel, channel) ||
                const DeepCollectionEquality().equals(
                  other.channel,
                  channel,
                )) &&
            (identical(other.deliveryStatus, deliveryStatus) ||
                const DeepCollectionEquality().equals(
                  other.deliveryStatus,
                  deliveryStatus,
                )) &&
            (identical(other.deliveredAt, deliveredAt) ||
                const DeepCollectionEquality().equals(
                  other.deliveredAt,
                  deliveredAt,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(notificationId) ^
      const DeepCollectionEquality().hash(channel) ^
      const DeepCollectionEquality().hash(deliveryStatus) ^
      const DeepCollectionEquality().hash(deliveredAt) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $NotificationDeliveryLogExtension on NotificationDeliveryLog {
  NotificationDeliveryLog copyWith({
    String? id,
    String? notificationId,
    String? channel,
    String? deliveryStatus,
    DateTime? deliveredAt,
    DateTime? createdAt,
  }) {
    return NotificationDeliveryLog(
      id: id ?? this.id,
      notificationId: notificationId ?? this.notificationId,
      channel: channel ?? this.channel,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  NotificationDeliveryLog copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String?>? notificationId,
    Wrapped<String>? channel,
    Wrapped<String>? deliveryStatus,
    Wrapped<DateTime?>? deliveredAt,
    Wrapped<DateTime?>? createdAt,
  }) {
    return NotificationDeliveryLog(
      id: (id != null ? id.value : this.id),
      notificationId: (notificationId != null
          ? notificationId.value
          : this.notificationId),
      channel: (channel != null ? channel.value : this.channel),
      deliveryStatus: (deliveryStatus != null
          ? deliveryStatus.value
          : this.deliveryStatus),
      deliveredAt: (deliveredAt != null ? deliveredAt.value : this.deliveredAt),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class NotificationDeliveryLogCreate {
  const NotificationDeliveryLogCreate({
    required this.channel,
    required this.deliveryStatus,
    this.deliveredAt,
  });

  factory NotificationDeliveryLogCreate.fromJson(Map<String, dynamic> json) =>
      _$NotificationDeliveryLogCreateFromJson(json);

  static const toJsonFactory = _$NotificationDeliveryLogCreateToJson;
  Map<String, dynamic> toJson() => _$NotificationDeliveryLogCreateToJson(this);

  @JsonKey(name: 'channel')
  final String channel;
  @JsonKey(name: 'delivery_status')
  final String deliveryStatus;
  @JsonKey(name: 'delivered_at')
  final DateTime? deliveredAt;
  static const fromJsonFactory = _$NotificationDeliveryLogCreateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is NotificationDeliveryLogCreate &&
            (identical(other.channel, channel) ||
                const DeepCollectionEquality().equals(
                  other.channel,
                  channel,
                )) &&
            (identical(other.deliveryStatus, deliveryStatus) ||
                const DeepCollectionEquality().equals(
                  other.deliveryStatus,
                  deliveryStatus,
                )) &&
            (identical(other.deliveredAt, deliveredAt) ||
                const DeepCollectionEquality().equals(
                  other.deliveredAt,
                  deliveredAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(channel) ^
      const DeepCollectionEquality().hash(deliveryStatus) ^
      const DeepCollectionEquality().hash(deliveredAt) ^
      runtimeType.hashCode;
}

extension $NotificationDeliveryLogCreateExtension
    on NotificationDeliveryLogCreate {
  NotificationDeliveryLogCreate copyWith({
    String? channel,
    String? deliveryStatus,
    DateTime? deliveredAt,
  }) {
    return NotificationDeliveryLogCreate(
      channel: channel ?? this.channel,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  NotificationDeliveryLogCreate copyWithWrapped({
    Wrapped<String>? channel,
    Wrapped<String>? deliveryStatus,
    Wrapped<DateTime?>? deliveredAt,
  }) {
    return NotificationDeliveryLogCreate(
      channel: (channel != null ? channel.value : this.channel),
      deliveryStatus: (deliveryStatus != null
          ? deliveryStatus.value
          : this.deliveryStatus),
      deliveredAt: (deliveredAt != null ? deliveredAt.value : this.deliveredAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class NotificationDeliveryLogUpdate {
  const NotificationDeliveryLogUpdate({
    this.channel,
    this.deliveryStatus,
    this.deliveredAt,
  });

  factory NotificationDeliveryLogUpdate.fromJson(Map<String, dynamic> json) =>
      _$NotificationDeliveryLogUpdateFromJson(json);

  static const toJsonFactory = _$NotificationDeliveryLogUpdateToJson;
  Map<String, dynamic> toJson() => _$NotificationDeliveryLogUpdateToJson(this);

  @JsonKey(name: 'channel')
  final String? channel;
  @JsonKey(name: 'delivery_status')
  final String? deliveryStatus;
  @JsonKey(name: 'delivered_at')
  final DateTime? deliveredAt;
  static const fromJsonFactory = _$NotificationDeliveryLogUpdateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is NotificationDeliveryLogUpdate &&
            (identical(other.channel, channel) ||
                const DeepCollectionEquality().equals(
                  other.channel,
                  channel,
                )) &&
            (identical(other.deliveryStatus, deliveryStatus) ||
                const DeepCollectionEquality().equals(
                  other.deliveryStatus,
                  deliveryStatus,
                )) &&
            (identical(other.deliveredAt, deliveredAt) ||
                const DeepCollectionEquality().equals(
                  other.deliveredAt,
                  deliveredAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(channel) ^
      const DeepCollectionEquality().hash(deliveryStatus) ^
      const DeepCollectionEquality().hash(deliveredAt) ^
      runtimeType.hashCode;
}

extension $NotificationDeliveryLogUpdateExtension
    on NotificationDeliveryLogUpdate {
  NotificationDeliveryLogUpdate copyWith({
    String? channel,
    String? deliveryStatus,
    DateTime? deliveredAt,
  }) {
    return NotificationDeliveryLogUpdate(
      channel: channel ?? this.channel,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  NotificationDeliveryLogUpdate copyWithWrapped({
    Wrapped<String?>? channel,
    Wrapped<String?>? deliveryStatus,
    Wrapped<DateTime?>? deliveredAt,
  }) {
    return NotificationDeliveryLogUpdate(
      channel: (channel != null ? channel.value : this.channel),
      deliveryStatus: (deliveryStatus != null
          ? deliveryStatus.value
          : this.deliveryStatus),
      deliveredAt: (deliveredAt != null ? deliveredAt.value : this.deliveredAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class NotificationDeliveryLogListResponse {
  const NotificationDeliveryLogListResponse({
    required this.data,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory NotificationDeliveryLogListResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$NotificationDeliveryLogListResponseFromJson(json);

  static const toJsonFactory = _$NotificationDeliveryLogListResponseToJson;
  Map<String, dynamic> toJson() =>
      _$NotificationDeliveryLogListResponseToJson(this);

  @JsonKey(name: 'data', defaultValue: <NotificationDeliveryLog>[])
  final List<NotificationDeliveryLog> data;
  @JsonKey(name: 'limit')
  final int limit;
  @JsonKey(name: 'offset')
  final int offset;
  @JsonKey(name: 'total')
  final int total;
  static const fromJsonFactory = _$NotificationDeliveryLogListResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is NotificationDeliveryLogListResponse &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)) &&
            (identical(other.limit, limit) ||
                const DeepCollectionEquality().equals(other.limit, limit)) &&
            (identical(other.offset, offset) ||
                const DeepCollectionEquality().equals(other.offset, offset)) &&
            (identical(other.total, total) ||
                const DeepCollectionEquality().equals(other.total, total)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(data) ^
      const DeepCollectionEquality().hash(limit) ^
      const DeepCollectionEquality().hash(offset) ^
      const DeepCollectionEquality().hash(total) ^
      runtimeType.hashCode;
}

extension $NotificationDeliveryLogListResponseExtension
    on NotificationDeliveryLogListResponse {
  NotificationDeliveryLogListResponse copyWith({
    List<NotificationDeliveryLog>? data,
    int? limit,
    int? offset,
    int? total,
  }) {
    return NotificationDeliveryLogListResponse(
      data: data ?? this.data,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  NotificationDeliveryLogListResponse copyWithWrapped({
    Wrapped<List<NotificationDeliveryLog>>? data,
    Wrapped<int>? limit,
    Wrapped<int>? offset,
    Wrapped<int>? total,
  }) {
    return NotificationDeliveryLogListResponse(
      data: (data != null ? data.value : this.data),
      limit: (limit != null ? limit.value : this.limit),
      offset: (offset != null ? offset.value : this.offset),
      total: (total != null ? total.value : this.total),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Reminder {
  const Reminder({
    this.id,
    this.ownerUser,
    this.relatedActivityId,
    this.relatedCrop,
    this.title,
    required this.reminderDatetime,
    this.deliveryChannel,
    required this.status,
    this.createdAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);

  static const toJsonFactory = _$ReminderToJson;
  Map<String, dynamic> toJson() => _$ReminderToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'owner_user')
  final String? ownerUser;
  @JsonKey(name: 'related_activity_id')
  final String? relatedActivityId;
  @JsonKey(name: 'related_crop')
  final String? relatedCrop;
  @JsonKey(name: 'title')
  final String? title;
  @JsonKey(name: 'reminder_datetime')
  final DateTime reminderDatetime;
  @JsonKey(name: 'delivery_channel')
  final String? deliveryChannel;
  @JsonKey(
    name: 'status',
    toJson: reminderStatusToJson,
    fromJson: reminderStatusStatusFromJson,
  )
  final enums.ReminderStatus status;
  static enums.ReminderStatus reminderStatusStatusFromJson(Object? value) =>
      reminderStatusFromJson(value, enums.ReminderStatus.scheduled);

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  static const fromJsonFactory = _$ReminderFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Reminder &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.ownerUser, ownerUser) ||
                const DeepCollectionEquality().equals(
                  other.ownerUser,
                  ownerUser,
                )) &&
            (identical(other.relatedActivityId, relatedActivityId) ||
                const DeepCollectionEquality().equals(
                  other.relatedActivityId,
                  relatedActivityId,
                )) &&
            (identical(other.relatedCrop, relatedCrop) ||
                const DeepCollectionEquality().equals(
                  other.relatedCrop,
                  relatedCrop,
                )) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.reminderDatetime, reminderDatetime) ||
                const DeepCollectionEquality().equals(
                  other.reminderDatetime,
                  reminderDatetime,
                )) &&
            (identical(other.deliveryChannel, deliveryChannel) ||
                const DeepCollectionEquality().equals(
                  other.deliveryChannel,
                  deliveryChannel,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(ownerUser) ^
      const DeepCollectionEquality().hash(relatedActivityId) ^
      const DeepCollectionEquality().hash(relatedCrop) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(reminderDatetime) ^
      const DeepCollectionEquality().hash(deliveryChannel) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $ReminderExtension on Reminder {
  Reminder copyWith({
    String? id,
    String? ownerUser,
    String? relatedActivityId,
    String? relatedCrop,
    String? title,
    DateTime? reminderDatetime,
    String? deliveryChannel,
    enums.ReminderStatus? status,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      ownerUser: ownerUser ?? this.ownerUser,
      relatedActivityId: relatedActivityId ?? this.relatedActivityId,
      relatedCrop: relatedCrop ?? this.relatedCrop,
      title: title ?? this.title,
      reminderDatetime: reminderDatetime ?? this.reminderDatetime,
      deliveryChannel: deliveryChannel ?? this.deliveryChannel,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Reminder copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String?>? ownerUser,
    Wrapped<String?>? relatedActivityId,
    Wrapped<String?>? relatedCrop,
    Wrapped<String?>? title,
    Wrapped<DateTime>? reminderDatetime,
    Wrapped<String?>? deliveryChannel,
    Wrapped<enums.ReminderStatus>? status,
    Wrapped<DateTime?>? createdAt,
  }) {
    return Reminder(
      id: (id != null ? id.value : this.id),
      ownerUser: (ownerUser != null ? ownerUser.value : this.ownerUser),
      relatedActivityId: (relatedActivityId != null
          ? relatedActivityId.value
          : this.relatedActivityId),
      relatedCrop: (relatedCrop != null ? relatedCrop.value : this.relatedCrop),
      title: (title != null ? title.value : this.title),
      reminderDatetime: (reminderDatetime != null
          ? reminderDatetime.value
          : this.reminderDatetime),
      deliveryChannel: (deliveryChannel != null
          ? deliveryChannel.value
          : this.deliveryChannel),
      status: (status != null ? status.value : this.status),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ReminderCreate {
  const ReminderCreate({
    this.relatedActivityId,
    this.relatedCrop,
    this.title,
    required this.reminderDatetime,
    this.deliveryChannel,
    this.status,
  });

  factory ReminderCreate.fromJson(Map<String, dynamic> json) =>
      _$ReminderCreateFromJson(json);

  static const toJsonFactory = _$ReminderCreateToJson;
  Map<String, dynamic> toJson() => _$ReminderCreateToJson(this);

  @JsonKey(name: 'related_activity_id')
  final String? relatedActivityId;
  @JsonKey(name: 'related_crop')
  final String? relatedCrop;
  @JsonKey(name: 'title')
  final String? title;
  @JsonKey(name: 'reminder_datetime')
  final DateTime reminderDatetime;
  @JsonKey(name: 'delivery_channel')
  final String? deliveryChannel;
  @JsonKey(
    name: 'status',
    toJson: reminderCreateStatusNullableToJson,
    fromJson: reminderCreateStatusStatusNullableFromJson,
  )
  final enums.ReminderCreateStatus? status;
  static enums.ReminderCreateStatus? reminderCreateStatusStatusNullableFromJson(
    Object? value,
  ) => reminderCreateStatusNullableFromJson(
    value,
    enums.ReminderCreateStatus.scheduled,
  );

  static const fromJsonFactory = _$ReminderCreateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ReminderCreate &&
            (identical(other.relatedActivityId, relatedActivityId) ||
                const DeepCollectionEquality().equals(
                  other.relatedActivityId,
                  relatedActivityId,
                )) &&
            (identical(other.relatedCrop, relatedCrop) ||
                const DeepCollectionEquality().equals(
                  other.relatedCrop,
                  relatedCrop,
                )) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.reminderDatetime, reminderDatetime) ||
                const DeepCollectionEquality().equals(
                  other.reminderDatetime,
                  reminderDatetime,
                )) &&
            (identical(other.deliveryChannel, deliveryChannel) ||
                const DeepCollectionEquality().equals(
                  other.deliveryChannel,
                  deliveryChannel,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(relatedActivityId) ^
      const DeepCollectionEquality().hash(relatedCrop) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(reminderDatetime) ^
      const DeepCollectionEquality().hash(deliveryChannel) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $ReminderCreateExtension on ReminderCreate {
  ReminderCreate copyWith({
    String? relatedActivityId,
    String? relatedCrop,
    String? title,
    DateTime? reminderDatetime,
    String? deliveryChannel,
    enums.ReminderCreateStatus? status,
  }) {
    return ReminderCreate(
      relatedActivityId: relatedActivityId ?? this.relatedActivityId,
      relatedCrop: relatedCrop ?? this.relatedCrop,
      title: title ?? this.title,
      reminderDatetime: reminderDatetime ?? this.reminderDatetime,
      deliveryChannel: deliveryChannel ?? this.deliveryChannel,
      status: status ?? this.status,
    );
  }

  ReminderCreate copyWithWrapped({
    Wrapped<String?>? relatedActivityId,
    Wrapped<String?>? relatedCrop,
    Wrapped<String?>? title,
    Wrapped<DateTime>? reminderDatetime,
    Wrapped<String?>? deliveryChannel,
    Wrapped<enums.ReminderCreateStatus?>? status,
  }) {
    return ReminderCreate(
      relatedActivityId: (relatedActivityId != null
          ? relatedActivityId.value
          : this.relatedActivityId),
      relatedCrop: (relatedCrop != null ? relatedCrop.value : this.relatedCrop),
      title: (title != null ? title.value : this.title),
      reminderDatetime: (reminderDatetime != null
          ? reminderDatetime.value
          : this.reminderDatetime),
      deliveryChannel: (deliveryChannel != null
          ? deliveryChannel.value
          : this.deliveryChannel),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ReminderUpdate {
  const ReminderUpdate({
    this.relatedActivityId,
    this.relatedCrop,
    this.title,
    this.reminderDatetime,
    this.deliveryChannel,
    this.status,
  });

  factory ReminderUpdate.fromJson(Map<String, dynamic> json) =>
      _$ReminderUpdateFromJson(json);

  static const toJsonFactory = _$ReminderUpdateToJson;
  Map<String, dynamic> toJson() => _$ReminderUpdateToJson(this);

  @JsonKey(name: 'related_activity_id')
  final String? relatedActivityId;
  @JsonKey(name: 'related_crop')
  final String? relatedCrop;
  @JsonKey(name: 'title')
  final String? title;
  @JsonKey(name: 'reminder_datetime')
  final DateTime? reminderDatetime;
  @JsonKey(name: 'delivery_channel')
  final String? deliveryChannel;
  @JsonKey(
    name: 'status',
    toJson: reminderUpdateStatusNullableToJson,
    fromJson: reminderUpdateStatusStatusNullableFromJson,
  )
  final enums.ReminderUpdateStatus? status;
  static enums.ReminderUpdateStatus? reminderUpdateStatusStatusNullableFromJson(
    Object? value,
  ) => reminderUpdateStatusNullableFromJson(
    value,
    enums.ReminderUpdateStatus.scheduled,
  );

  static const fromJsonFactory = _$ReminderUpdateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ReminderUpdate &&
            (identical(other.relatedActivityId, relatedActivityId) ||
                const DeepCollectionEquality().equals(
                  other.relatedActivityId,
                  relatedActivityId,
                )) &&
            (identical(other.relatedCrop, relatedCrop) ||
                const DeepCollectionEquality().equals(
                  other.relatedCrop,
                  relatedCrop,
                )) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.reminderDatetime, reminderDatetime) ||
                const DeepCollectionEquality().equals(
                  other.reminderDatetime,
                  reminderDatetime,
                )) &&
            (identical(other.deliveryChannel, deliveryChannel) ||
                const DeepCollectionEquality().equals(
                  other.deliveryChannel,
                  deliveryChannel,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(relatedActivityId) ^
      const DeepCollectionEquality().hash(relatedCrop) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(reminderDatetime) ^
      const DeepCollectionEquality().hash(deliveryChannel) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $ReminderUpdateExtension on ReminderUpdate {
  ReminderUpdate copyWith({
    String? relatedActivityId,
    String? relatedCrop,
    String? title,
    DateTime? reminderDatetime,
    String? deliveryChannel,
    enums.ReminderUpdateStatus? status,
  }) {
    return ReminderUpdate(
      relatedActivityId: relatedActivityId ?? this.relatedActivityId,
      relatedCrop: relatedCrop ?? this.relatedCrop,
      title: title ?? this.title,
      reminderDatetime: reminderDatetime ?? this.reminderDatetime,
      deliveryChannel: deliveryChannel ?? this.deliveryChannel,
      status: status ?? this.status,
    );
  }

  ReminderUpdate copyWithWrapped({
    Wrapped<String?>? relatedActivityId,
    Wrapped<String?>? relatedCrop,
    Wrapped<String?>? title,
    Wrapped<DateTime?>? reminderDatetime,
    Wrapped<String?>? deliveryChannel,
    Wrapped<enums.ReminderUpdateStatus?>? status,
  }) {
    return ReminderUpdate(
      relatedActivityId: (relatedActivityId != null
          ? relatedActivityId.value
          : this.relatedActivityId),
      relatedCrop: (relatedCrop != null ? relatedCrop.value : this.relatedCrop),
      title: (title != null ? title.value : this.title),
      reminderDatetime: (reminderDatetime != null
          ? reminderDatetime.value
          : this.reminderDatetime),
      deliveryChannel: (deliveryChannel != null
          ? deliveryChannel.value
          : this.deliveryChannel),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ReminderListResponse {
  const ReminderListResponse({
    required this.data,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory ReminderListResponse.fromJson(Map<String, dynamic> json) =>
      _$ReminderListResponseFromJson(json);

  static const toJsonFactory = _$ReminderListResponseToJson;
  Map<String, dynamic> toJson() => _$ReminderListResponseToJson(this);

  @JsonKey(name: 'data', defaultValue: <Reminder>[])
  final List<Reminder> data;
  @JsonKey(name: 'limit')
  final int limit;
  @JsonKey(name: 'offset')
  final int offset;
  @JsonKey(name: 'total')
  final int total;
  static const fromJsonFactory = _$ReminderListResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ReminderListResponse &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)) &&
            (identical(other.limit, limit) ||
                const DeepCollectionEquality().equals(other.limit, limit)) &&
            (identical(other.offset, offset) ||
                const DeepCollectionEquality().equals(other.offset, offset)) &&
            (identical(other.total, total) ||
                const DeepCollectionEquality().equals(other.total, total)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(data) ^
      const DeepCollectionEquality().hash(limit) ^
      const DeepCollectionEquality().hash(offset) ^
      const DeepCollectionEquality().hash(total) ^
      runtimeType.hashCode;
}

extension $ReminderListResponseExtension on ReminderListResponse {
  ReminderListResponse copyWith({
    List<Reminder>? data,
    int? limit,
    int? offset,
    int? total,
  }) {
    return ReminderListResponse(
      data: data ?? this.data,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  ReminderListResponse copyWithWrapped({
    Wrapped<List<Reminder>>? data,
    Wrapped<int>? limit,
    Wrapped<int>? offset,
    Wrapped<int>? total,
  }) {
    return ReminderListResponse(
      data: (data != null ? data.value : this.data),
      limit: (limit != null ? limit.value : this.limit),
      offset: (offset != null ? offset.value : this.offset),
      total: (total != null ? total.value : this.total),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class WeeklyReport {
  const WeeklyReport({
    this.id,
    this.ownerUser,
    this.reportText,
    this.deliveryPreference,
    this.createdAt,
  });

  factory WeeklyReport.fromJson(Map<String, dynamic> json) =>
      _$WeeklyReportFromJson(json);

  static const toJsonFactory = _$WeeklyReportToJson;
  Map<String, dynamic> toJson() => _$WeeklyReportToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'owner_user')
  final String? ownerUser;
  @JsonKey(name: 'report_text')
  final String? reportText;
  @JsonKey(name: 'delivery_preference')
  final String? deliveryPreference;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  static const fromJsonFactory = _$WeeklyReportFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is WeeklyReport &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.ownerUser, ownerUser) ||
                const DeepCollectionEquality().equals(
                  other.ownerUser,
                  ownerUser,
                )) &&
            (identical(other.reportText, reportText) ||
                const DeepCollectionEquality().equals(
                  other.reportText,
                  reportText,
                )) &&
            (identical(other.deliveryPreference, deliveryPreference) ||
                const DeepCollectionEquality().equals(
                  other.deliveryPreference,
                  deliveryPreference,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(ownerUser) ^
      const DeepCollectionEquality().hash(reportText) ^
      const DeepCollectionEquality().hash(deliveryPreference) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $WeeklyReportExtension on WeeklyReport {
  WeeklyReport copyWith({
    String? id,
    String? ownerUser,
    String? reportText,
    String? deliveryPreference,
    DateTime? createdAt,
  }) {
    return WeeklyReport(
      id: id ?? this.id,
      ownerUser: ownerUser ?? this.ownerUser,
      reportText: reportText ?? this.reportText,
      deliveryPreference: deliveryPreference ?? this.deliveryPreference,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  WeeklyReport copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String?>? ownerUser,
    Wrapped<String?>? reportText,
    Wrapped<String?>? deliveryPreference,
    Wrapped<DateTime?>? createdAt,
  }) {
    return WeeklyReport(
      id: (id != null ? id.value : this.id),
      ownerUser: (ownerUser != null ? ownerUser.value : this.ownerUser),
      reportText: (reportText != null ? reportText.value : this.reportText),
      deliveryPreference: (deliveryPreference != null
          ? deliveryPreference.value
          : this.deliveryPreference),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class WeeklyReportCreate {
  const WeeklyReportCreate({this.reportText, this.deliveryPreference});

  factory WeeklyReportCreate.fromJson(Map<String, dynamic> json) =>
      _$WeeklyReportCreateFromJson(json);

  static const toJsonFactory = _$WeeklyReportCreateToJson;
  Map<String, dynamic> toJson() => _$WeeklyReportCreateToJson(this);

  @JsonKey(name: 'report_text')
  final String? reportText;
  @JsonKey(name: 'delivery_preference')
  final String? deliveryPreference;
  static const fromJsonFactory = _$WeeklyReportCreateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is WeeklyReportCreate &&
            (identical(other.reportText, reportText) ||
                const DeepCollectionEquality().equals(
                  other.reportText,
                  reportText,
                )) &&
            (identical(other.deliveryPreference, deliveryPreference) ||
                const DeepCollectionEquality().equals(
                  other.deliveryPreference,
                  deliveryPreference,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(reportText) ^
      const DeepCollectionEquality().hash(deliveryPreference) ^
      runtimeType.hashCode;
}

extension $WeeklyReportCreateExtension on WeeklyReportCreate {
  WeeklyReportCreate copyWith({
    String? reportText,
    String? deliveryPreference,
  }) {
    return WeeklyReportCreate(
      reportText: reportText ?? this.reportText,
      deliveryPreference: deliveryPreference ?? this.deliveryPreference,
    );
  }

  WeeklyReportCreate copyWithWrapped({
    Wrapped<String?>? reportText,
    Wrapped<String?>? deliveryPreference,
  }) {
    return WeeklyReportCreate(
      reportText: (reportText != null ? reportText.value : this.reportText),
      deliveryPreference: (deliveryPreference != null
          ? deliveryPreference.value
          : this.deliveryPreference),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class WeeklyReportListResponse {
  const WeeklyReportListResponse({
    required this.data,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory WeeklyReportListResponse.fromJson(Map<String, dynamic> json) =>
      _$WeeklyReportListResponseFromJson(json);

  static const toJsonFactory = _$WeeklyReportListResponseToJson;
  Map<String, dynamic> toJson() => _$WeeklyReportListResponseToJson(this);

  @JsonKey(name: 'data', defaultValue: <WeeklyReport>[])
  final List<WeeklyReport> data;
  @JsonKey(name: 'limit')
  final int limit;
  @JsonKey(name: 'offset')
  final int offset;
  @JsonKey(name: 'total')
  final int total;
  static const fromJsonFactory = _$WeeklyReportListResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is WeeklyReportListResponse &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)) &&
            (identical(other.limit, limit) ||
                const DeepCollectionEquality().equals(other.limit, limit)) &&
            (identical(other.offset, offset) ||
                const DeepCollectionEquality().equals(other.offset, offset)) &&
            (identical(other.total, total) ||
                const DeepCollectionEquality().equals(other.total, total)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(data) ^
      const DeepCollectionEquality().hash(limit) ^
      const DeepCollectionEquality().hash(offset) ^
      const DeepCollectionEquality().hash(total) ^
      runtimeType.hashCode;
}

extension $WeeklyReportListResponseExtension on WeeklyReportListResponse {
  WeeklyReportListResponse copyWith({
    List<WeeklyReport>? data,
    int? limit,
    int? offset,
    int? total,
  }) {
    return WeeklyReportListResponse(
      data: data ?? this.data,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  WeeklyReportListResponse copyWithWrapped({
    Wrapped<List<WeeklyReport>>? data,
    Wrapped<int>? limit,
    Wrapped<int>? offset,
    Wrapped<int>? total,
  }) {
    return WeeklyReportListResponse(
      data: (data != null ? data.value : this.data),
      limit: (limit != null ? limit.value : this.limit),
      offset: (offset != null ? offset.value : this.offset),
      total: (total != null ? total.value : this.total),
    );
  }
}

String? aiMessageSenderNullableToJson(enums.AiMessageSender? aiMessageSender) {
  return aiMessageSender?.value;
}

String? aiMessageSenderToJson(enums.AiMessageSender aiMessageSender) {
  return aiMessageSender.value;
}

enums.AiMessageSender aiMessageSenderFromJson(
  Object? aiMessageSender, [
  enums.AiMessageSender? defaultValue,
]) {
  return enums.AiMessageSender.values.firstWhereOrNull(
        (e) => e.value == aiMessageSender,
      ) ??
      defaultValue ??
      enums.AiMessageSender.swaggerGeneratedUnknown;
}

enums.AiMessageSender? aiMessageSenderNullableFromJson(
  Object? aiMessageSender, [
  enums.AiMessageSender? defaultValue,
]) {
  if (aiMessageSender == null) {
    return null;
  }
  return enums.AiMessageSender.values.firstWhereOrNull(
        (e) => e.value == aiMessageSender,
      ) ??
      defaultValue;
}

String aiMessageSenderExplodedListToJson(
  List<enums.AiMessageSender>? aiMessageSender,
) {
  return aiMessageSender?.map((e) => e.value!).join(',') ?? '';
}

List<String> aiMessageSenderListToJson(
  List<enums.AiMessageSender>? aiMessageSender,
) {
  if (aiMessageSender == null) {
    return [];
  }

  return aiMessageSender.map((e) => e.value!).toList();
}

List<enums.AiMessageSender> aiMessageSenderListFromJson(
  List? aiMessageSender, [
  List<enums.AiMessageSender>? defaultValue,
]) {
  if (aiMessageSender == null) {
    return defaultValue ?? [];
  }

  return aiMessageSender
      .map((e) => aiMessageSenderFromJson(e.toString()))
      .toList();
}

List<enums.AiMessageSender>? aiMessageSenderNullableListFromJson(
  List? aiMessageSender, [
  List<enums.AiMessageSender>? defaultValue,
]) {
  if (aiMessageSender == null) {
    return defaultValue;
  }

  return aiMessageSender
      .map((e) => aiMessageSenderFromJson(e.toString()))
      .toList();
}

String? aiMessageCreateSenderNullableToJson(
  enums.AiMessageCreateSender? aiMessageCreateSender,
) {
  return aiMessageCreateSender?.value;
}

String? aiMessageCreateSenderToJson(
  enums.AiMessageCreateSender aiMessageCreateSender,
) {
  return aiMessageCreateSender.value;
}

enums.AiMessageCreateSender aiMessageCreateSenderFromJson(
  Object? aiMessageCreateSender, [
  enums.AiMessageCreateSender? defaultValue,
]) {
  return enums.AiMessageCreateSender.values.firstWhereOrNull(
        (e) => e.value == aiMessageCreateSender,
      ) ??
      defaultValue ??
      enums.AiMessageCreateSender.swaggerGeneratedUnknown;
}

enums.AiMessageCreateSender? aiMessageCreateSenderNullableFromJson(
  Object? aiMessageCreateSender, [
  enums.AiMessageCreateSender? defaultValue,
]) {
  if (aiMessageCreateSender == null) {
    return null;
  }
  return enums.AiMessageCreateSender.values.firstWhereOrNull(
        (e) => e.value == aiMessageCreateSender,
      ) ??
      defaultValue;
}

String aiMessageCreateSenderExplodedListToJson(
  List<enums.AiMessageCreateSender>? aiMessageCreateSender,
) {
  return aiMessageCreateSender?.map((e) => e.value!).join(',') ?? '';
}

List<String> aiMessageCreateSenderListToJson(
  List<enums.AiMessageCreateSender>? aiMessageCreateSender,
) {
  if (aiMessageCreateSender == null) {
    return [];
  }

  return aiMessageCreateSender.map((e) => e.value!).toList();
}

List<enums.AiMessageCreateSender> aiMessageCreateSenderListFromJson(
  List? aiMessageCreateSender, [
  List<enums.AiMessageCreateSender>? defaultValue,
]) {
  if (aiMessageCreateSender == null) {
    return defaultValue ?? [];
  }

  return aiMessageCreateSender
      .map((e) => aiMessageCreateSenderFromJson(e.toString()))
      .toList();
}

List<enums.AiMessageCreateSender>? aiMessageCreateSenderNullableListFromJson(
  List? aiMessageCreateSender, [
  List<enums.AiMessageCreateSender>? defaultValue,
]) {
  if (aiMessageCreateSender == null) {
    return defaultValue;
  }

  return aiMessageCreateSender
      .map((e) => aiMessageCreateSenderFromJson(e.toString()))
      .toList();
}

String? aiMessageUpdateSenderNullableToJson(
  enums.AiMessageUpdateSender? aiMessageUpdateSender,
) {
  return aiMessageUpdateSender?.value;
}

String? aiMessageUpdateSenderToJson(
  enums.AiMessageUpdateSender aiMessageUpdateSender,
) {
  return aiMessageUpdateSender.value;
}

enums.AiMessageUpdateSender aiMessageUpdateSenderFromJson(
  Object? aiMessageUpdateSender, [
  enums.AiMessageUpdateSender? defaultValue,
]) {
  return enums.AiMessageUpdateSender.values.firstWhereOrNull(
        (e) => e.value == aiMessageUpdateSender,
      ) ??
      defaultValue ??
      enums.AiMessageUpdateSender.swaggerGeneratedUnknown;
}

enums.AiMessageUpdateSender? aiMessageUpdateSenderNullableFromJson(
  Object? aiMessageUpdateSender, [
  enums.AiMessageUpdateSender? defaultValue,
]) {
  if (aiMessageUpdateSender == null) {
    return null;
  }
  return enums.AiMessageUpdateSender.values.firstWhereOrNull(
        (e) => e.value == aiMessageUpdateSender,
      ) ??
      defaultValue;
}

String aiMessageUpdateSenderExplodedListToJson(
  List<enums.AiMessageUpdateSender>? aiMessageUpdateSender,
) {
  return aiMessageUpdateSender?.map((e) => e.value!).join(',') ?? '';
}

List<String> aiMessageUpdateSenderListToJson(
  List<enums.AiMessageUpdateSender>? aiMessageUpdateSender,
) {
  if (aiMessageUpdateSender == null) {
    return [];
  }

  return aiMessageUpdateSender.map((e) => e.value!).toList();
}

List<enums.AiMessageUpdateSender> aiMessageUpdateSenderListFromJson(
  List? aiMessageUpdateSender, [
  List<enums.AiMessageUpdateSender>? defaultValue,
]) {
  if (aiMessageUpdateSender == null) {
    return defaultValue ?? [];
  }

  return aiMessageUpdateSender
      .map((e) => aiMessageUpdateSenderFromJson(e.toString()))
      .toList();
}

List<enums.AiMessageUpdateSender>? aiMessageUpdateSenderNullableListFromJson(
  List? aiMessageUpdateSender, [
  List<enums.AiMessageUpdateSender>? defaultValue,
]) {
  if (aiMessageUpdateSender == null) {
    return defaultValue;
  }

  return aiMessageUpdateSender
      .map((e) => aiMessageUpdateSenderFromJson(e.toString()))
      .toList();
}

String? notificationStatusNullableToJson(
  enums.NotificationStatus? notificationStatus,
) {
  return notificationStatus?.value;
}

String? notificationStatusToJson(enums.NotificationStatus notificationStatus) {
  return notificationStatus.value;
}

enums.NotificationStatus notificationStatusFromJson(
  Object? notificationStatus, [
  enums.NotificationStatus? defaultValue,
]) {
  return enums.NotificationStatus.values.firstWhereOrNull(
        (e) => e.value == notificationStatus,
      ) ??
      defaultValue ??
      enums.NotificationStatus.swaggerGeneratedUnknown;
}

enums.NotificationStatus? notificationStatusNullableFromJson(
  Object? notificationStatus, [
  enums.NotificationStatus? defaultValue,
]) {
  if (notificationStatus == null) {
    return null;
  }
  return enums.NotificationStatus.values.firstWhereOrNull(
        (e) => e.value == notificationStatus,
      ) ??
      defaultValue;
}

String notificationStatusExplodedListToJson(
  List<enums.NotificationStatus>? notificationStatus,
) {
  return notificationStatus?.map((e) => e.value!).join(',') ?? '';
}

List<String> notificationStatusListToJson(
  List<enums.NotificationStatus>? notificationStatus,
) {
  if (notificationStatus == null) {
    return [];
  }

  return notificationStatus.map((e) => e.value!).toList();
}

List<enums.NotificationStatus> notificationStatusListFromJson(
  List? notificationStatus, [
  List<enums.NotificationStatus>? defaultValue,
]) {
  if (notificationStatus == null) {
    return defaultValue ?? [];
  }

  return notificationStatus
      .map((e) => notificationStatusFromJson(e.toString()))
      .toList();
}

List<enums.NotificationStatus>? notificationStatusNullableListFromJson(
  List? notificationStatus, [
  List<enums.NotificationStatus>? defaultValue,
]) {
  if (notificationStatus == null) {
    return defaultValue;
  }

  return notificationStatus
      .map((e) => notificationStatusFromJson(e.toString()))
      .toList();
}

String? notificationCreateStatusNullableToJson(
  enums.NotificationCreateStatus? notificationCreateStatus,
) {
  return notificationCreateStatus?.value;
}

String? notificationCreateStatusToJson(
  enums.NotificationCreateStatus notificationCreateStatus,
) {
  return notificationCreateStatus.value;
}

enums.NotificationCreateStatus notificationCreateStatusFromJson(
  Object? notificationCreateStatus, [
  enums.NotificationCreateStatus? defaultValue,
]) {
  return enums.NotificationCreateStatus.values.firstWhereOrNull(
        (e) => e.value == notificationCreateStatus,
      ) ??
      defaultValue ??
      enums.NotificationCreateStatus.swaggerGeneratedUnknown;
}

enums.NotificationCreateStatus? notificationCreateStatusNullableFromJson(
  Object? notificationCreateStatus, [
  enums.NotificationCreateStatus? defaultValue,
]) {
  if (notificationCreateStatus == null) {
    return null;
  }
  return enums.NotificationCreateStatus.values.firstWhereOrNull(
        (e) => e.value == notificationCreateStatus,
      ) ??
      defaultValue;
}

String notificationCreateStatusExplodedListToJson(
  List<enums.NotificationCreateStatus>? notificationCreateStatus,
) {
  return notificationCreateStatus?.map((e) => e.value!).join(',') ?? '';
}

List<String> notificationCreateStatusListToJson(
  List<enums.NotificationCreateStatus>? notificationCreateStatus,
) {
  if (notificationCreateStatus == null) {
    return [];
  }

  return notificationCreateStatus.map((e) => e.value!).toList();
}

List<enums.NotificationCreateStatus> notificationCreateStatusListFromJson(
  List? notificationCreateStatus, [
  List<enums.NotificationCreateStatus>? defaultValue,
]) {
  if (notificationCreateStatus == null) {
    return defaultValue ?? [];
  }

  return notificationCreateStatus
      .map((e) => notificationCreateStatusFromJson(e.toString()))
      .toList();
}

List<enums.NotificationCreateStatus>?
notificationCreateStatusNullableListFromJson(
  List? notificationCreateStatus, [
  List<enums.NotificationCreateStatus>? defaultValue,
]) {
  if (notificationCreateStatus == null) {
    return defaultValue;
  }

  return notificationCreateStatus
      .map((e) => notificationCreateStatusFromJson(e.toString()))
      .toList();
}

String? reminderStatusNullableToJson(enums.ReminderStatus? reminderStatus) {
  return reminderStatus?.value;
}

String? reminderStatusToJson(enums.ReminderStatus reminderStatus) {
  return reminderStatus.value;
}

enums.ReminderStatus reminderStatusFromJson(
  Object? reminderStatus, [
  enums.ReminderStatus? defaultValue,
]) {
  return enums.ReminderStatus.values.firstWhereOrNull(
        (e) => e.value == reminderStatus,
      ) ??
      defaultValue ??
      enums.ReminderStatus.swaggerGeneratedUnknown;
}

enums.ReminderStatus? reminderStatusNullableFromJson(
  Object? reminderStatus, [
  enums.ReminderStatus? defaultValue,
]) {
  if (reminderStatus == null) {
    return null;
  }
  return enums.ReminderStatus.values.firstWhereOrNull(
        (e) => e.value == reminderStatus,
      ) ??
      defaultValue;
}

String reminderStatusExplodedListToJson(
  List<enums.ReminderStatus>? reminderStatus,
) {
  return reminderStatus?.map((e) => e.value!).join(',') ?? '';
}

List<String> reminderStatusListToJson(
  List<enums.ReminderStatus>? reminderStatus,
) {
  if (reminderStatus == null) {
    return [];
  }

  return reminderStatus.map((e) => e.value!).toList();
}

List<enums.ReminderStatus> reminderStatusListFromJson(
  List? reminderStatus, [
  List<enums.ReminderStatus>? defaultValue,
]) {
  if (reminderStatus == null) {
    return defaultValue ?? [];
  }

  return reminderStatus
      .map((e) => reminderStatusFromJson(e.toString()))
      .toList();
}

List<enums.ReminderStatus>? reminderStatusNullableListFromJson(
  List? reminderStatus, [
  List<enums.ReminderStatus>? defaultValue,
]) {
  if (reminderStatus == null) {
    return defaultValue;
  }

  return reminderStatus
      .map((e) => reminderStatusFromJson(e.toString()))
      .toList();
}

String? reminderCreateStatusNullableToJson(
  enums.ReminderCreateStatus? reminderCreateStatus,
) {
  return reminderCreateStatus?.value;
}

String? reminderCreateStatusToJson(
  enums.ReminderCreateStatus reminderCreateStatus,
) {
  return reminderCreateStatus.value;
}

enums.ReminderCreateStatus reminderCreateStatusFromJson(
  Object? reminderCreateStatus, [
  enums.ReminderCreateStatus? defaultValue,
]) {
  return enums.ReminderCreateStatus.values.firstWhereOrNull(
        (e) => e.value == reminderCreateStatus,
      ) ??
      defaultValue ??
      enums.ReminderCreateStatus.swaggerGeneratedUnknown;
}

enums.ReminderCreateStatus? reminderCreateStatusNullableFromJson(
  Object? reminderCreateStatus, [
  enums.ReminderCreateStatus? defaultValue,
]) {
  if (reminderCreateStatus == null) {
    return null;
  }
  return enums.ReminderCreateStatus.values.firstWhereOrNull(
        (e) => e.value == reminderCreateStatus,
      ) ??
      defaultValue;
}

String reminderCreateStatusExplodedListToJson(
  List<enums.ReminderCreateStatus>? reminderCreateStatus,
) {
  return reminderCreateStatus?.map((e) => e.value!).join(',') ?? '';
}

List<String> reminderCreateStatusListToJson(
  List<enums.ReminderCreateStatus>? reminderCreateStatus,
) {
  if (reminderCreateStatus == null) {
    return [];
  }

  return reminderCreateStatus.map((e) => e.value!).toList();
}

List<enums.ReminderCreateStatus> reminderCreateStatusListFromJson(
  List? reminderCreateStatus, [
  List<enums.ReminderCreateStatus>? defaultValue,
]) {
  if (reminderCreateStatus == null) {
    return defaultValue ?? [];
  }

  return reminderCreateStatus
      .map((e) => reminderCreateStatusFromJson(e.toString()))
      .toList();
}

List<enums.ReminderCreateStatus>? reminderCreateStatusNullableListFromJson(
  List? reminderCreateStatus, [
  List<enums.ReminderCreateStatus>? defaultValue,
]) {
  if (reminderCreateStatus == null) {
    return defaultValue;
  }

  return reminderCreateStatus
      .map((e) => reminderCreateStatusFromJson(e.toString()))
      .toList();
}

String? reminderUpdateStatusNullableToJson(
  enums.ReminderUpdateStatus? reminderUpdateStatus,
) {
  return reminderUpdateStatus?.value;
}

String? reminderUpdateStatusToJson(
  enums.ReminderUpdateStatus reminderUpdateStatus,
) {
  return reminderUpdateStatus.value;
}

enums.ReminderUpdateStatus reminderUpdateStatusFromJson(
  Object? reminderUpdateStatus, [
  enums.ReminderUpdateStatus? defaultValue,
]) {
  return enums.ReminderUpdateStatus.values.firstWhereOrNull(
        (e) => e.value == reminderUpdateStatus,
      ) ??
      defaultValue ??
      enums.ReminderUpdateStatus.swaggerGeneratedUnknown;
}

enums.ReminderUpdateStatus? reminderUpdateStatusNullableFromJson(
  Object? reminderUpdateStatus, [
  enums.ReminderUpdateStatus? defaultValue,
]) {
  if (reminderUpdateStatus == null) {
    return null;
  }
  return enums.ReminderUpdateStatus.values.firstWhereOrNull(
        (e) => e.value == reminderUpdateStatus,
      ) ??
      defaultValue;
}

String reminderUpdateStatusExplodedListToJson(
  List<enums.ReminderUpdateStatus>? reminderUpdateStatus,
) {
  return reminderUpdateStatus?.map((e) => e.value!).join(',') ?? '';
}

List<String> reminderUpdateStatusListToJson(
  List<enums.ReminderUpdateStatus>? reminderUpdateStatus,
) {
  if (reminderUpdateStatus == null) {
    return [];
  }

  return reminderUpdateStatus.map((e) => e.value!).toList();
}

List<enums.ReminderUpdateStatus> reminderUpdateStatusListFromJson(
  List? reminderUpdateStatus, [
  List<enums.ReminderUpdateStatus>? defaultValue,
]) {
  if (reminderUpdateStatus == null) {
    return defaultValue ?? [];
  }

  return reminderUpdateStatus
      .map((e) => reminderUpdateStatusFromJson(e.toString()))
      .toList();
}

List<enums.ReminderUpdateStatus>? reminderUpdateStatusNullableListFromJson(
  List? reminderUpdateStatus, [
  List<enums.ReminderUpdateStatus>? defaultValue,
]) {
  if (reminderUpdateStatus == null) {
    return defaultValue;
  }

  return reminderUpdateStatus
      .map((e) => reminderUpdateStatusFromJson(e.toString()))
      .toList();
}

// ignore: unused_element
String? _dateToJson(DateTime? date) {
  if (date == null) {
    return null;
  }

  final year = date.year.toString();
  final month = date.month < 10 ? '0${date.month}' : date.month.toString();
  final day = date.day < 10 ? '0${date.day}' : date.day.toString();

  return '$year-$month-$day';
}

class Wrapped<T> {
  final T value;
  const Wrapped.value(this.value);
}
