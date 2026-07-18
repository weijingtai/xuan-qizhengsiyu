import 'dart:developer' as developer;
import 'package:timezone/timezone.dart' as tz;
import 'package:metaphysics_core/utils/celestial_rise_set_calculator.dart';
import 'package:metaphysics_core/helpers/solar_time_calculator.dart';
import 'package:metaphysics_core/adapters/lunar_adapter.dart';
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/entities/models/rise_set_display_data.dart';

/// 日月出没 + 真太阳时 + 阴历信息计算(原 QiZhengSiYuViewModel._computeRiseSetData 上移)。
final class ComputeRiseSetUseCase {
  RiseSetDisplayData? execute(
    ObserverPosition observer, {
    required String? locationName,
  }) {
    try {
      // 日月出没（UTC）
      final dailyInfo = CelestialRiseSetCalculator.calculateDaily(
        utcDateTime: observer.utcDateTime,
        longitude: observer.longitude,
        latitude: observer.latitude,
        altitude: observer.altitude,
      );

      // UTC → 本地时区
      final loc = tz.getLocation(observer.timezone);
      DateTime? toLocal(DateTime? utc) =>
          utc != null ? tz.TZDateTime.from(utc, loc) : null;

      // 真太阳时
      final trueSolarTime = SolarTimeCalculator(
        dateTime: observer.utcDateTime,
        longitude: observer.longitude,
      ).getTrueSolarTime();

      // 阴历信息（基于本地时间）
      final lunar = LunarAdapter.fromDate(observer.dateTime);
      final lunarDateString =
          '${lunar.getYearInGanZhi()}年${lunar.getMonthInChinese()}${lunar.getDayInChinese()}日';
      final lunarTimeString = '${lunar.getTimeZhi()}时';
      final jieQiInfo = lunar.getJieQi();

      return RiseSetDisplayData(
        sunRise: toLocal(dailyInfo.sun.rise),
        sunSet: toLocal(dailyInfo.sun.set_),
        moonRise: toLocal(dailyInfo.moon.rise),
        moonSet: toLocal(dailyInfo.moon.set_),
        trueSolarTime: trueSolarTime,
        longitude: observer.longitude,
        latitude: observer.latitude,
        timezone: observer.timezone,
        lunarDateString: lunarDateString,
        lunarTimeString: lunarTimeString,
        isDayBirth: observer.isDayBirth,
        fourPillarsDisplay: observer.fourZhuEightChar,
        localDateTime: observer.dateTime,
        locationName: locationName,
        jieQiInfo: jieQiInfo,
      );
    } catch (e) {
      developer.log('Error computing rise/set data: $e');
      return null;
    }
  }
}
