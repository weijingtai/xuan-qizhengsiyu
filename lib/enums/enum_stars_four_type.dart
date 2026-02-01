import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

enum EnumStarsFourType {
  @JsonValue("恩")
  En("恩"),
  @JsonValue("难")
  Nan("难"),
  @JsonValue("仇")
  Chou("仇"),
  @JsonValue("用")
  Yong("用"),
  @JsonValue("无")
  Unknown("无");

  final String name;
  const EnumStarsFourType(this.name);

  /// @description:
  ///  根据星体间的 "生克泻耗同"
  static EnumStarsFourType getByFiveXingRelationship(
      FiveXingRelationship relationship) {
    switch (relationship) {
      case FiveXingRelationship.SHENG:
        return En;
      case FiveXingRelationship.KE:
        return Nan;
      case FiveXingRelationship.XIE:
        return Yong;
      case FiveXingRelationship.HAO:
        return Chou;
      default:
        return Unknown;
    }
  }

  /// @description:
  /// 获取所有星体的四化关系
  static Map<EnumStars, Map<EnumStarsFourType, Set<EnumStars>>>
      getStarsFourTypeMapper() {
    return Map.fromEntries(EnumStars.allStars
        .map((s) => MapEntry(s, getStarsRelationshipMapper(s))));
  }

  /// @description:
  ///  根据星体获取其四化关系
  static Map<EnumStarsFourType, Set<EnumStars>> getStarsRelationshipMapper(
      EnumStars star) {
    switch (star) {
      case EnumStars.Saturn: // 土星
        return {
          En: {EnumStars.Mars, EnumStars.Luo}, // 火罗（火生土）
          Nan: {EnumStars.Jupiter, EnumStars.Qi}, // 木气（木克土）
          Chou: {EnumStars.Mercury, EnumStars.Bei}, // 水孛（水生木）
          Yong: {EnumStars.Venus}, // 金星（金克木）
        };
      case EnumStars.Jupiter: // 木星
        return {
          En: {EnumStars.Mercury, EnumStars.Bei}, // 水孛（水生木）
          Nan: {EnumStars.Venus}, // 金星（金克木）
          Chou: {EnumStars.Saturn, EnumStars.Ji}, // 土计（土生金）
          Yong: {EnumStars.Mars, EnumStars.Luo}, // 火罗（火克金）
        };
      case EnumStars.Mars: // 火星
        return {
          En: {EnumStars.Jupiter, EnumStars.Qi}, // 木气（木生火）
          Nan: {EnumStars.Mercury, EnumStars.Bei}, // 水孛（水克火）
          Chou: {EnumStars.Venus}, // 金星（金生水）
          Yong: {EnumStars.Saturn, EnumStars.Ji}, // 土计（土克水）
        };
      case EnumStars.Venus: // 金星
        return {
          En: {EnumStars.Saturn, EnumStars.Ji}, // 土计（土生金）
          Nan: {EnumStars.Mars, EnumStars.Luo}, // 火罗（火克金）
          Chou: {EnumStars.Jupiter, EnumStars.Qi}, // 木气（木生火）
          Yong: {EnumStars.Mercury, EnumStars.Bei}, // 水孛（水克火）
        };
      case EnumStars.Mercury: // 水星
        return {
          En: {EnumStars.Venus}, // 金星（金生水）
          Nan: {EnumStars.Saturn, EnumStars.Ji}, // 土计（土克水）
          Chou: {EnumStars.Mars, EnumStars.Luo}, // 火罗（火生土）
          Yong: {EnumStars.Jupiter, EnumStars.Qi}, // 木气（木克土）
        };
      case EnumStars.Sun: // 太阳
        return {
          En: {EnumStars.Venus, EnumStars.Mercury}, // 金水（护卫君王）
          Nan: {EnumStars.Jupiter, EnumStars.Qi}, // 木气（克太阳）
          Chou: {EnumStars.Saturn, EnumStars.Ji}, // 土计（生木气）
          Yong: {EnumStars.Mars, EnumStars.Luo}, // 火罗（克木气）
        };
      case EnumStars.Moon: // 月亮
        return {
          En: {EnumStars.Venus}, // 金星（滋养月华）
          Nan: {EnumStars.Saturn, EnumStars.Ji}, // 土计（克月亮）
          Chou: {EnumStars.Mars, EnumStars.Luo}, // 火罗（生土计）
          Yong: {EnumStars.Jupiter, EnumStars.Qi}, // 木气（克土计）
        };
      case EnumStars.Luo: // 罗睺（火余）
        return {
          En: {EnumStars.Jupiter, EnumStars.Qi}, // 木气（木生火）
          Nan: {EnumStars.Mercury, EnumStars.Bei}, // 水孛（水克火）
          Chou: {EnumStars.Venus}, // 金星（金生水）
          Yong: {EnumStars.Saturn, EnumStars.Ji}, // 土计（土克水）
        };
      case EnumStars.Ji: // 计都（土余）
        return {
          En: {EnumStars.Mars, EnumStars.Luo}, // 火罗（火生土）
          Nan: {EnumStars.Jupiter, EnumStars.Qi}, // 木气（木克土）
          Chou: {EnumStars.Mercury, EnumStars.Bei}, // 水孛（水生木）
          Yong: {EnumStars.Venus}, // 金星（金克木）
        };
      case EnumStars.Bei: // 月孛（水余）
        return {
          En: {EnumStars.Venus}, // 金星（金生水）
          Nan: {EnumStars.Saturn, EnumStars.Ji}, // 土计（土克水）
          Chou: {EnumStars.Mars, EnumStars.Luo}, // 火罗（火生土）
          Yong: {EnumStars.Jupiter, EnumStars.Qi}, // 木气（木克土）
        };
      case EnumStars.Qi: // 紫气（木余）
        return {
          En: {EnumStars.Mercury, EnumStars.Bei}, // 水孛（水生木）
          Nan: {EnumStars.Venus}, // 金星（金克木）
          Chou: {EnumStars.Saturn, EnumStars.Ji}, // 土计（土生金）
          Yong: {EnumStars.Mars, EnumStars.Luo}, // 火罗（火克金）
        };
      default:
        return {};
    }
  }
}
