import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

import 'zhu_luo_san_xian_calculator.dart';
import 'zhu_luo_san_xian_config.dart';
import 'zhu_luo_san_xian_tables.dart';

const Map<EnumStars, ZhuLuoRuler> _starToZhuLuoRuler = {
  EnumStars.Sun: ZhuLuoRuler.sun,
  EnumStars.Moon: ZhuLuoRuler.moon,
  EnumStars.Mars: ZhuLuoRuler.mars,
  EnumStars.Mercury: ZhuLuoRuler.mercury,
  EnumStars.Jupiter: ZhuLuoRuler.jupiter,
  EnumStars.Venus: ZhuLuoRuler.venus,
  EnumStars.Saturn: ZhuLuoRuler.saturn,
};

Map<ZhuLuoRuler, EnumTwelveGong> zhuLuoRulerPalacesFromStarPalaces(
  Map<EnumStars, EnumTwelveGong> starPalaces,
) {
  final missingStars = <EnumStars>[];
  final result = <ZhuLuoRuler, EnumTwelveGong>{};

  for (final entry in _starToZhuLuoRuler.entries) {
    final palace = starPalaces[entry.key];
    if (palace == null) {
      missingStars.add(entry.key);
      continue;
    }
    result[entry.value] = palace;
  }

  if (missingStars.isNotEmpty) {
    throw StateError(
      'Missing star palaces for Zhu Luo San Xian: '
      '${missingStars.map((star) => star.name).join(', ')}',
    );
  }

  return Map.unmodifiable(result);
}

ZhuLuoInput buildZhuLuoInputFromStarPalaces({
  required EnumTwelveGong lifePalace,
  required BirthSect birthSect,
  required Map<EnumStars, EnumTwelveGong> starPalaces,
  required int maxAge,
  required ZhuLuoAlgorithmConfig config,
}) {
  return ZhuLuoInput(
    lifePalace: lifePalace,
    birthSect: birthSect,
    rulerPalaces: zhuLuoRulerPalacesFromStarPalaces(starPalaces),
    maxAge: maxAge,
    config: config,
  );
}

ZhuLuoInput buildZhuLuoInputFromPanel({
  required BasePanelModel panel,
  required BirthSect birthSect,
  required int maxAge,
  required ZhuLuoAlgorithmConfig config,
}) {
  final starPalaces = <EnumStars, EnumTwelveGong>{};

  for (final entry in panel.enteredGongMapper.entries) {
    if (_starToZhuLuoRuler.containsKey(entry.key)) {
      starPalaces[entry.key] = entry.value.gong;
    }
  }

  return buildZhuLuoInputFromStarPalaces(
    lifePalace: panel.bodyLifeModel.lifeGong,
    birthSect: birthSect,
    starPalaces: starPalaces,
    maxAge: maxAge,
    config: config,
  );
}
