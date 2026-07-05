import 'package:json_annotation/json_annotation.dart';

/// 罗睺 / 计都 与月球白道升/降交点的归属约定（流派分歧，用户可选）。
///
/// 天文事实：星历给出月球平升交点黄经 N（逆行），降交点 = N + 180°。
/// 「谁是罗睺、谁是计都」是流派/历法的解释差异，不是天文差异。
enum EnumRahuKetuConvention {
  /// 古法正统（默认）：罗睺=降交点(N+180)、计都=升交点(N)。
  /// 依据《果老星宗》《开元占经》一行九执历：交初为罗、交中为计，俗称「南罗北计」。
  /// 天首=降交点=罗。即当前线上行为；勿反向理解（见规格书《罗计史料裁定》）。
  @JsonValue("罗降计升")
  luoJiangJiSheng("罗降计升（古法正统）",
      "罗睺取降交点、计都取升交点。果老星宗/开元占经/一行九执历古法，命理默认。"),

  /// 民间·西法：罗睺=升交点(N)、计都=降交点(N+180)。
  /// 清后期西法传入后民间混用，现代印度占星 Jyotish 默认此套，与古法正统相反。
  @JsonValue("罗升计降")
  luoShengJiJiang("罗升计降（民间·西法）",
      "罗睺取升交点、计都取降交点。清后期西法/印度 Jyotish，与古法正统相反、吉凶互换。");

  final String name;
  final String description;
  const EnumRahuKetuConvention(this.name, this.description);
}
