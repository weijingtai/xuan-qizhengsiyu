// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'star_angle_raw_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StarAngleRawInfo _$StarAngleRawInfoFromJson(Map<String, dynamic> json) =>
    StarAngleRawInfo(
      panelSystemType:
          $enumDecode(_$PanelSystemTypeEnumMap, json['panelSystemType']),
      coordinateSystem: $enumDecode(
          _$CelestialCoordinateSystemEnumMap, json['coordinateSystem']),
      angle: (json['angle'] as num).toDouble(),
      speed: (json['speed'] as num).toDouble(),
    );

Map<String, dynamic> _$StarAngleRawInfoToJson(StarAngleRawInfo instance) =>
    <String, dynamic>{
      'panelSystemType': _$PanelSystemTypeEnumMap[instance.panelSystemType]!,
      'coordinateSystem':
          _$CelestialCoordinateSystemEnumMap[instance.coordinateSystem]!,
      'angle': instance.angle,
      'speed': instance.speed,
    };

const _$PanelSystemTypeEnumMap = {
  PanelSystemType.tropical: '回归制',
  PanelSystemType.sidereal: '恒星制',
};

const _$CelestialCoordinateSystemEnumMap = {
  CelestialCoordinateSystem.ecliptic: '黄道制',
  CelestialCoordinateSystem.equatorial: '赤道制',
  CelestialCoordinateSystem.skyEquatorial: '天赤道制',
  CelestialCoordinateSystem.pseudoEcliptic: '似黄道恒星制',
};
