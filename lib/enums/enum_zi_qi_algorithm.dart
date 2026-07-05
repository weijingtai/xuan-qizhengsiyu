import 'package:json_annotation/json_annotation.dart';

/// 紫气行度算法流派（可扩展；默认果老/琴堂授时常数）。
enum EnumZiQiAlgorithm {
  @JsonValue("果老琴堂")
  guoLaoQinTang("果老/琴堂（授时辛巳元）"),
  @JsonValue("耶律天官")
  yelvTianguan("耶律天官（中气闰余粗算宫度）"),
  @JsonValue("清时宪")
  shixian("清时宪（乾隆甲子元）");

  final String name;
  const EnumZiQiAlgorithm(this.name);
}

/// 紫气周期口诀（两套每年差约 1.2°，可配）。
enum EnumZiQiPeriod {
  years28(10227.1792), // 28年十闰
  years29(10592.0);    // 29年一闰周
  final double days;
  const EnumZiQiPeriod(this.days);
}

/// 果老/琴堂紫气「历元常数集」——两套互相冲突的史料，可选，默认授时·女宿。
enum EnumZiQiEpochSet {
  @JsonValue("授时女宿")
  shouShiNvXiu("授时·女宿（1280 女宿二度≈295°）"),
  @JsonValue("符天箕宿")
  fuTianJiXiu("符天·箕宿（1281 辛巳冬至箕宿初度）");

  final String name;
  const EnumZiQiEpochSet(this.name);
}

/// 天赤道·女宿紫气的「标准」二选一（用户可选）：
/// - 授时正典：文本正统常数（周期 10227.1792 日、女宿二度历元）；
/// - Moira 实测：与主流软件 Moira 对齐（周期 10237.7 日、锚 2026 实测点）。
/// 两者每约百年差约 1.5°，长程差更大；由用户按"合典籍"或"合 Moira"选择。
enum EnumZiQiChiDaoStandard {
  @JsonValue("授时正典")
  shouShiOrthodox("授时正典（10227.1792 日·女宿二度）"),
  @JsonValue("Moira实测")
  moira("Moira 实测（10237.7 日·锚2026翼宿）");

  final String name;
  const EnumZiQiChiDaoStandard(this.name);
}
