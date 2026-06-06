import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

enum ZhuLuoRuler { sun, moon, mars, mercury, jupiter, venus, saturn }

enum BirthSect { day, night }

enum LimitStage { first, middle, last }

List<ZhuLuoRuler> zhuLuoLimitRulers(EnumTwelveGong lifePalace, BirthSect sect) {
  const triplicityDay = <ZhuLuoRuler, List<ZhuLuoRuler>>{
    ZhuLuoRuler.mercury: [ZhuLuoRuler.saturn, ZhuLuoRuler.mercury, ZhuLuoRuler.jupiter],
    ZhuLuoRuler.moon: [ZhuLuoRuler.venus, ZhuLuoRuler.moon, ZhuLuoRuler.mars],
    ZhuLuoRuler.mars: [ZhuLuoRuler.sun, ZhuLuoRuler.jupiter, ZhuLuoRuler.saturn],
    ZhuLuoRuler.jupiter: [ZhuLuoRuler.venus, ZhuLuoRuler.mars, ZhuLuoRuler.moon],
  };

  const triplicityNight = <ZhuLuoRuler, List<ZhuLuoRuler>>{
    ZhuLuoRuler.mercury: [ZhuLuoRuler.mercury, ZhuLuoRuler.saturn, ZhuLuoRuler.jupiter],
    ZhuLuoRuler.moon: [ZhuLuoRuler.moon, ZhuLuoRuler.venus, ZhuLuoRuler.mars],
    ZhuLuoRuler.mars: [ZhuLuoRuler.jupiter, ZhuLuoRuler.sun, ZhuLuoRuler.saturn],
    ZhuLuoRuler.jupiter: [ZhuLuoRuler.mars, ZhuLuoRuler.venus, ZhuLuoRuler.moon],
  };

  final firstRuler = _triplicityFirstRuler(lifePalace);
  final table = sect == BirthSect.day ? triplicityDay : triplicityNight;
  return List.unmodifiable(table[firstRuler]!);
}

int rulerNumber(ZhuLuoRuler ruler) {
  switch (ruler) {
    case ZhuLuoRuler.moon:
    case ZhuLuoRuler.mercury:
      return 1;
    case ZhuLuoRuler.sun:
    case ZhuLuoRuler.mars:
      return 2;
    case ZhuLuoRuler.jupiter:
      return 3;
    case ZhuLuoRuler.venus:
      return 4;
    case ZhuLuoRuler.saturn:
      return 5;
  }
}

int rulerDuration(ZhuLuoRuler ruler) {
  switch (ruler) {
    case ZhuLuoRuler.moon:
    case ZhuLuoRuler.mercury:
      return 24;
    case ZhuLuoRuler.sun:
    case ZhuLuoRuler.mars:
      return 28;
    case ZhuLuoRuler.jupiter:
      return 30;
    case ZhuLuoRuler.venus:
    case ZhuLuoRuler.saturn:
      return 26;
  }
}

ZhuLuoRuler _triplicityFirstRuler(EnumTwelveGong palace) {
  switch (palace) {
    // 子申辰: Mercury
    case EnumTwelveGong.Zi:
    case EnumTwelveGong.Shen:
    case EnumTwelveGong.Chen:
      return ZhuLuoRuler.mercury;
    // 巳酉丑: Moon
    case EnumTwelveGong.Si:
    case EnumTwelveGong.You:
    case EnumTwelveGong.Chou:
      return ZhuLuoRuler.moon;
    // 寅午戌: Mars
    case EnumTwelveGong.Yin:
    case EnumTwelveGong.Wu:
    case EnumTwelveGong.Xu:
      return ZhuLuoRuler.mars;
    // 亥卯未: Jupiter
    case EnumTwelveGong.Hai:
    case EnumTwelveGong.Mao:
    case EnumTwelveGong.Wei:
      return ZhuLuoRuler.jupiter;
  }
}
