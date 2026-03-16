import 'package:flutter_test/flutter_test.dart';
import 'package:common/utils/celestial_rise_set_calculator.dart';
import 'package:sweph/sweph.dart';
import 'package:timezone/data/latest.dart' as tz_data;

/// 天体出没计算器测试
///
/// sweph 相关测试需要原生绑定，在纯 `flutter test` 环境下
/// 通过 skip 参数跳过。可通过集成测试或 example app 验证。
///
/// 已知参考数据（北京 2024 春分 3月20日）：
/// - 日出约 06:12 CST (22:12 UTC 前一天)
/// - 日落约 18:21 CST (10:21 UTC)
void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
  });

  // 北京坐标
  const beijingLon = 116.4074;
  const beijingLat = 39.9042;
  const skipMsg = 'Sweph native bindings not available in flutter test';

  group('CelestialRiseSetCalculator', () {
    group('calculate() — 太阳升落', () {
      test('北京 2024 春分日出约 06:12 CST', skip: skipMsg, () {
        // 2024-03-20 00:00 UTC (春分当天)
        final utc = DateTime.utc(2024, 3, 20);

        final result = CelestialRiseSetCalculator.calculate(
          utcDateTime: utc,
          longitude: beijingLon,
          latitude: beijingLat,
          body: HeavenlyBody.SE_SUN,
        );

        expect(result.rise, isNotNull);
        expect(result.set_, isNotNull);
        expect(result.transit, isNotNull);

        // 日出约 22:12 UTC (前一天) = 06:12 CST
        final riseHourUtc = result.rise!.hour + result.rise!.minute / 60.0;
        expect(riseHourUtc, closeTo(22.2, 0.25)); // ±15 min

        // 日落约 10:21 UTC = 18:21 CST
        final setHourUtc = result.set_!.hour + result.set_!.minute / 60.0;
        expect(setHourUtc, closeTo(10.35, 0.25));
      });

      test('北京 2024 夏至日出早于春分', skip: skipMsg, () {
        final equinox = DateTime.utc(2024, 3, 20);
        final solstice = DateTime.utc(2024, 6, 21);

        final equinoxResult = CelestialRiseSetCalculator.calculate(
          utcDateTime: equinox,
          longitude: beijingLon,
          latitude: beijingLat,
          body: HeavenlyBody.SE_SUN,
        );

        final solsticeResult = CelestialRiseSetCalculator.calculate(
          utcDateTime: solstice,
          longitude: beijingLon,
          latitude: beijingLat,
          body: HeavenlyBody.SE_SUN,
        );

        expect(equinoxResult.rise, isNotNull);
        expect(solsticeResult.rise, isNotNull);
        // 夏至日落更晚（UTC 时间更大）
        expect(
            solsticeResult.set_!.hour, greaterThan(equinoxResult.set_!.hour));
      });
    });

    group('calculate() — 月亮升落', () {
      test('北京某日月出月落应有值', skip: skipMsg, () {
        final utc = DateTime.utc(2024, 3, 20);

        final result = CelestialRiseSetCalculator.calculate(
          utcDateTime: utc,
          longitude: beijingLon,
          latitude: beijingLat,
          body: HeavenlyBody.SE_MOON,
        );

        expect(result.rise, isNotNull);
        expect(result.set_, isNotNull);
      });
    });

    group('calculateDaily()', () {
      test('日月出没一次获取', skip: skipMsg, () {
        final utc = DateTime.utc(2024, 3, 20);

        final daily = CelestialRiseSetCalculator.calculateDaily(
          utcDateTime: utc,
          longitude: beijingLon,
          latitude: beijingLat,
        );

        expect(daily.sun.rise, isNotNull);
        expect(daily.sun.set_, isNotNull);
        expect(daily.moon.rise, isNotNull);
        expect(daily.twilight, isNull);
      });

      test('包含晨昏蒙影', skip: skipMsg, () {
        final utc = DateTime.utc(2024, 3, 20);

        final daily = CelestialRiseSetCalculator.calculateDaily(
          utcDateTime: utc,
          longitude: beijingLon,
          latitude: beijingLat,
          includeTwilight: true,
        );

        expect(daily.twilight, isNotNull);
        expect(daily.twilight!.civilDawn, isNotNull);
        expect(daily.twilight!.civilDusk, isNotNull);

        // 民用晨光应在日出之前
        expect(daily.twilight!.civilDawn!.isBefore(daily.sun.rise!), isTrue);
        // 民用昏影应在日落之后
        expect(daily.twilight!.civilDusk!.isAfter(daily.sun.set_!), isTrue);
      });
    });

    group('calculateTwilight()', () {
      test('晨昏蒙影顺序: 天文 < 航海 < 民用 < 日出', skip: skipMsg, () {
        final utc = DateTime.utc(2024, 3, 20);

        final twilight = CelestialRiseSetCalculator.calculateTwilight(
          utcDateTime: utc,
          longitude: beijingLon,
          latitude: beijingLat,
        );

        expect(twilight.astronomicalDawn, isNotNull);
        expect(twilight.nauticalDawn, isNotNull);
        expect(twilight.civilDawn, isNotNull);

        // 天文晨光 < 航海晨光 < 民用晨光
        expect(twilight.astronomicalDawn!.isBefore(twilight.nauticalDawn!),
            isTrue);
        expect(twilight.nauticalDawn!.isBefore(twilight.civilDawn!), isTrue);

        // 民用昏影 < 航海昏影 < 天文昏影
        expect(twilight.civilDusk!.isBefore(twilight.nauticalDusk!), isTrue);
        expect(twilight.nauticalDusk!.isBefore(twilight.astronomicalDusk!),
            isTrue);
      });
    });

    group('isDayTime()', () {
      test('北京正午应为昼', skip: skipMsg, () {
        // 2024-03-20 12:00 CST = 04:00 UTC
        final noonUtc = DateTime.utc(2024, 3, 20, 4, 0);

        final isDay = CelestialRiseSetCalculator.isDayTime(
          utcDateTime: noonUtc,
          longitude: beijingLon,
          latitude: beijingLat,
        );

        expect(isDay, isTrue);
      });

      test('北京午夜应为夜', skip: skipMsg, () {
        // 2024-03-20 00:00 CST = 2024-03-19 16:00 UTC
        final midnightUtc = DateTime.utc(2024, 3, 19, 16, 0);

        final isDay = CelestialRiseSetCalculator.isDayTime(
          utcDateTime: midnightUtc,
          longitude: beijingLon,
          latitude: beijingLat,
        );

        expect(isDay, isFalse);
      });

      test('北京傍晚日落前后判断', skip: skipMsg, () {
        // 日落前 18:00 CST = 10:00 UTC — 应为昼
        final beforeSunset = DateTime.utc(2024, 3, 20, 10, 0);
        expect(
          CelestialRiseSetCalculator.isDayTime(
            utcDateTime: beforeSunset,
            longitude: beijingLon,
            latitude: beijingLat,
          ),
          isTrue,
        );

        // 日落后 19:00 CST = 11:00 UTC — 应为夜
        final afterSunset = DateTime.utc(2024, 3, 20, 11, 0);
        expect(
          CelestialRiseSetCalculator.isDayTime(
            utcDateTime: afterSunset,
            longitude: beijingLon,
            latitude: beijingLat,
          ),
          isFalse,
        );
      });
    });

    group('calculateFromLocalTime()', () {
      test('本地时间转换后结果与 UTC 一致', skip: skipMsg, () {
        // 2024-03-20 08:00 CST = 2024-03-20 00:00 UTC
        final localTime = DateTime(2024, 3, 20, 8, 0);

        final fromLocal = CelestialRiseSetCalculator.calculateFromLocalTime(
          localDateTime: localTime,
          timezone: 'Asia/Shanghai',
          longitude: beijingLon,
          latitude: beijingLat,
          body: HeavenlyBody.SE_SUN,
        );

        final fromUtc = CelestialRiseSetCalculator.calculate(
          utcDateTime: DateTime.utc(2024, 3, 20, 0, 0),
          longitude: beijingLon,
          latitude: beijingLat,
          body: HeavenlyBody.SE_SUN,
        );

        expect(fromLocal.rise, equals(fromUtc.rise));
        expect(fromLocal.set_, equals(fromUtc.set_));
      });
    });
  });

  group('数据类', () {
    test('CelestialRiseSetResult toString', () {
      const result = CelestialRiseSetResult();
      expect(result.toString(), contains('CelestialRiseSetResult'));
      expect(result.rise, isNull);
      expect(result.set_, isNull);
      expect(result.transit, isNull);
    });

    test('CelestialRiseSetResult 含值', () {
      final now = DateTime.utc(2024, 1, 1, 6, 0);
      final result = CelestialRiseSetResult(
        rise: now,
        set_: now.add(const Duration(hours: 12)),
        transit: now.add(const Duration(hours: 6)),
      );
      expect(result.rise, equals(now));
      expect(result.set_, equals(now.add(const Duration(hours: 12))));
      expect(result.transit, equals(now.add(const Duration(hours: 6))));
    });

    test('TwilightInfo toString', () {
      const info = TwilightInfo();
      expect(info.toString(), contains('TwilightInfo'));
    });

    test('DailyRiseSetInfo toString', () {
      const info = DailyRiseSetInfo(
        sun: CelestialRiseSetResult(),
        moon: CelestialRiseSetResult(),
      );
      expect(info.toString(), contains('DailyRiseSetInfo'));
      expect(info.twilight, isNull);
    });
  });
}
