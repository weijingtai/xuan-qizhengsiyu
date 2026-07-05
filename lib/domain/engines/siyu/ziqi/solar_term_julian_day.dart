import 'package:sweph/sweph.dart';

/// 求某年 12 月冬至（太阳地心黄经=270°）的儒略日。
/// [julianCalendar]：1582 年前应传 true（儒略历），如 1281 辛巳。
double winterSolsticeJulianDay(int decemberYear, {bool julianCalendar = false}) {
  final calType =
      julianCalendar ? CalendarType.SE_JUL_CAL : CalendarType.SE_GREG_CAL;
  double jd = Sweph.swe_julday(decemberYear, 12, 22, 0, calType);
  for (int i = 0; i < 10; i++) {
    final lon = Sweph.swe_calc(
            jd, HeavenlyBody.SE_SUN, SwephFlag.SEFLG_SWIEPH)
        .longitude;
    // 到 270° 的最短带符号角差
    final diff = ((270.0 - lon + 540.0) % 360.0) - 180.0;
    if (diff.abs() < 1e-5) break;
    jd += diff / 0.98565; // 太阳日行约 0.98565°
  }
  return jd;
}
