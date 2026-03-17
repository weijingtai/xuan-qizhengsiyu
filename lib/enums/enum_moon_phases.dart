import 'package:tyme/tyme.dart';

enum EnumMoonPhases {
  New("新月"),
  E_Mei("峨眉"),
  Shang_Xian("上弦"),
  Ying_Tu("盈凸"),
  Full("满月"),
  Kui_Tu("亏凸"),
  Xia_Xian("下弦"),
  Can_Yue("残月");

  final String name;
  const EnumMoonPhases(this.name);

  /// 从日月黄经差角度判断月相（8 区间，每 45° 一段）
  static EnumMoonPhases fromAngle(double phaseAngle,
      {double offsetDegree = 1}) {
    // 归一化到 [0, 360)
    phaseAngle = phaseAngle % 360;
    if (phaseAngle < 0) phaseAngle += 360;

    // 新月: ~0° (含 360° 附近)
    if (phaseAngle < 0 + offsetDegree || phaseAngle > 360 - offsetDegree) {
      return New;
    }
    // 峨眉: 0°~90°
    if (phaseAngle < 90 - offsetDegree) return E_Mei;
    // 上弦: ~90°
    if (phaseAngle <= 90 + offsetDegree) return Shang_Xian;
    // 盈凸: 90°~180°
    if (phaseAngle < 180 - offsetDegree) return Ying_Tu;
    // 满月: ~180°
    if (phaseAngle <= 180 + offsetDegree) return Full;
    // 亏凸: 180°~270°
    if (phaseAngle < 270 - offsetDegree) return Kui_Tu;
    // 下弦: ~270°
    if (phaseAngle <= 270 + offsetDegree) return Xia_Xian;
    // 残月: 270°~360°
    return Can_Yue;
  }

  /// 从日月黄经度数计算月相（Sweph 天文方案）
  static EnumMoonPhases fromSunMoonAngle(
      double moonLongitude, double sunLongitude) {
    final phaseAngle = (moonLongitude - sunLongitude) % 360;
    return fromAngle(phaseAngle);
  }

  /// 从 tyme Phase 索引转换（tyme Phase.getIndex() 返回 0-7）
  static EnumMoonPhases fromTymePhaseIndex(int phaseIndex) {
    return EnumMoonPhases.values[phaseIndex % 8];
  }

  /// 从出生日期时间计算月相（tyme 农历方案）
  static EnumMoonPhases fromDateTime(DateTime dateTime) {
    final solarDay =
        SolarDay.fromYmd(dateTime.year, dateTime.month, dateTime.day);
    final phase = solarDay.getPhase();
    return fromTymePhaseIndex(phase.getIndex());
  }
}
