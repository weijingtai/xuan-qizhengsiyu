// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_life_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BodyLifeModel _$BodyLifeModelFromJson(Map<String, dynamic> json) =>
    BodyLifeModel(
      lifeGongInfo:
          GongDegree.fromJson(json['lifeGongInfo'] as Map<String, dynamic>),
      lifeConstellationInfo: ConstellationDegree.fromJson(
          json['lifeConstellationInfo'] as Map<String, dynamic>),
      bodyGongInfo:
          GongDegree.fromJson(json['bodyGongInfo'] as Map<String, dynamic>),
      bodyConstellationInfo: ConstellationDegree.fromJson(
          json['bodyConstellationInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BodyLifeModelToJson(BodyLifeModel instance) =>
    <String, dynamic>{
      'lifeGongInfo': instance.lifeGongInfo,
      'lifeConstellationInfo': instance.lifeConstellationInfo,
      'bodyGongInfo': instance.bodyGongInfo,
      'bodyConstellationInfo': instance.bodyConstellationInfo,
    };
