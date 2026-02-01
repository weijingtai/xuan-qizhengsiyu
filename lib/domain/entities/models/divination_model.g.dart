// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'divination_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QiZhengSiYuDivination _$QiZhengSiYuDivinationFromJson(
        Map<String, dynamic> json) =>
    QiZhengSiYuDivination(
      divinationLocation:
          Address.fromJson(json['divinationLocation'] as Map<String, dynamic>),
      question: json['question'] as String,
      divinationAt: DateTime.parse(json['divinationAt'] as String),
      details: json['details'] as String?,
      divinationPerson: json['divinationPerson'] == null
          ? null
          : DivinationPerson.fromJson(
              json['divinationPerson'] as Map<String, dynamic>),
      divinationPersonLocation: json['divinationPersonLocation'] == null
          ? null
          : Address.fromJson(
              json['divinationPersonLocation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QiZhengSiYuDivinationToJson(
        QiZhengSiYuDivination instance) =>
    <String, dynamic>{
      'question': instance.question,
      'details': instance.details,
      'divinationAt': instance.divinationAt.toIso8601String(),
      'divinationPerson': instance.divinationPerson,
      'divinationPersonLocation': instance.divinationPersonLocation,
      'divinationLocation': instance.divinationLocation,
    };
