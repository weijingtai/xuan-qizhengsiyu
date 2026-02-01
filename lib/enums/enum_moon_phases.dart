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

  static EnumMoonPhases fromAngle(double phaseAngle,
      {double offsetDegree = 1}) {
    // if phase_angle < 1 or phase_angle >= 359:
    // return "新月"
    // elif phase_angle < 90:
    // return "峨眉月"
    // elif phase_angle == 90:
    // return "上弦月"
    // elif phase_angle < 180:
    // return "盈凸月"
    // elif phase_angle == 180:
    // return "满月"
    // elif phase_angle < 270:
    // return "亏凸月"
    // elif phase_angle == 270:
    // return "下弦月"
    // elif phase_angle < 359:
    // return "残月"
    if (phaseAngle < 1 + offsetDegree || phaseAngle >= 359 - offsetDegree) {
      return New;
    } else if (phaseAngle < 90 + offsetDegree) {
      return E_Mei;
    } else if (phaseAngle <= 90 + offsetDegree ||
        phaseAngle >= 90 - offsetDegree) {
      return Shang_Xian;
    } else if (phaseAngle < 180 + offsetDegree) {
      return Ying_Tu;
    } else if (phaseAngle <= 180 + offsetDegree ||
        phaseAngle >= 180 - offsetDegree) {
      return Full;
    } else if (phaseAngle < 270 + offsetDegree) {
      return Kui_Tu;
    } else if (phaseAngle <= 270 + offsetDegree ||
        phaseAngle >= 270 - offsetDegree) {
      return Xia_Xian;
    }
    return Can_Yue;
  }
}
