// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'star_enter_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnteredInfo _$EnteredInfoFromJson(Map<String, dynamic> json) => EnteredInfo(
      originalStar:
          StarDegree.fromJson(json['originalStar'] as Map<String, dynamic>),
      enterGongInfo:
          GongDegree.fromJson(json['enterGongInfo'] as Map<String, dynamic>),
      enterInnInfo: ConstellationDegree.fromJson(
          json['enterInnInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EnteredInfoToJson(EnteredInfo instance) =>
    <String, dynamic>{
      'originalStar': instance.originalStar,
      'enterGongInfo': instance.enterGongInfo,
      'enterInnInfo': instance.enterInnInfo,
    };
