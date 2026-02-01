// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'star_position_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StarPositionStatusDatasetModel<T>
    _$StarPositionStatusDatasetModelFromJson<T extends Enum>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
        StarPositionStatusDatasetModel<T>(
          id: (json['id'] as num).toInt(),
          className: json['className'] as String,
          star: $enumDecode(_$EnumStarsEnumMap, json['star']),
          starPositionStatusType: $enumDecode(
              _$EnumStarGongPositionStatusTypeEnumMap,
              json['starPositionStatusType']),
          positionList:
              (json['positionList'] as List<dynamic>).map(fromJsonT).toList(),
          descriptionList: (json['descriptionList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
          geJuList: (json['geJuList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
        );

Map<String, dynamic> _$StarPositionStatusDatasetModelToJson<T extends Enum>(
  StarPositionStatusDatasetModel<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'id': instance.id,
      'className': instance.className,
      'star': _$EnumStarsEnumMap[instance.star]!,
      'starPositionStatusType': _$EnumStarGongPositionStatusTypeEnumMap[
          instance.starPositionStatusType]!,
      'positionList': instance.positionList.map(toJsonT).toList(),
      'descriptionList': instance.descriptionList,
      'geJuList': instance.geJuList,
    };

const _$EnumStarsEnumMap = {
  EnumStars.Sun: '日',
  EnumStars.Moon: '月',
  EnumStars.Mercury: '水',
  EnumStars.Mars: '火',
  EnumStars.Saturn: '土',
  EnumStars.Venus: '金',
  EnumStars.Jupiter: '木',
  EnumStars.Qi: '炁',
  EnumStars.Luo: '罗',
  EnumStars.Ji: '计',
  EnumStars.Bei: '孛',
};

const _$EnumStarGongPositionStatusTypeEnumMap = {
  EnumStarGongPositionStatusType.Miao: '庙',
  EnumStarGongPositionStatusType.Wang: '旺',
  EnumStarGongPositionStatusType.Xi: '喜',
  EnumStarGongPositionStatusType.Le: '乐',
  EnumStarGongPositionStatusType.Nu: '怒',
  EnumStarGongPositionStatusType.Xian: '凶',
  EnumStarGongPositionStatusType.Zheng: '正',
  EnumStarGongPositionStatusType.Pian: '偏',
  EnumStarGongPositionStatusType.Yuan: '垣',
  EnumStarGongPositionStatusType.Dian: '殿',
  EnumStarGongPositionStatusType.Xiong: '凶',
  EnumStarGongPositionStatusType.Gui: '贵',
};
