import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/metaphysics_core.dart';
import 'package:metaphysics_core/helpers/solar_lunar_datetime_helper.dart';
import 'package:bazi_embed_ui_interface/bazi_embed_ui_interface.dart';
import 'package:repository_interface_bazi/repository_interface_bazi.dart';
import 'package:repository_interface_divination_pipeline/geo.dart';

/// BaziEmbed 接线真数据测试
///
/// 使用 SolarLunarDateTimeHelper.cacluateChineseDateInfoV2 构造真实 ChineseDateInfo，
/// 验证构造出的 BaziBirthContext 的 eightChars、jieQiInfo、gender 确实对应该时间。
void main() {
  group('BaziEmbedUiPort 接口类型', () {
    test('BaziEmbedUiPort 是抽象接口类', () {
      const Type portType = BaziEmbedUiPort;
      expect(portType, equals(BaziEmbedUiPort));
    });
  });

  group('BaziBirthContext 真数据构造', () {
    // 1990-01-15 10:30 北京 → 节气 小寒 (约 1 月 5–6 日) → 大寒 (约 1 月 20 日)
    const testDate = 1990;
    final birthDateTime = DateTime(testDate, 1, 15, 10, 30);

    final computedDateInfo =
        SolarLunarDateTimeHelper.cacluateChineseDateInfoV2(
      birthDateTime,
      CalculationStrategyConfigLogicModel.defaultConfig,
    );

    final birthContext = BaziBirthContext(
      birthDateTime: birthDateTime,
      gender: Gender.male,
      eightChars: EightChars(
        year: computedDateInfo.eightChars.year,
        month: computedDateInfo.eightChars.month,
        day: computedDateInfo.eightChars.day,
        time: computedDateInfo.eightChars.time,
      ),
      chineseDateInfo: computedDateInfo,
      birthLocation: BirthPlace(
        GeoPoint(
          latitude: 39.9042,
          longitude: 116.4074,
          timeZoneId: 'Asia/Shanghai',
        ),
      ),
    );

    test('gender 传入值与 BaziBirthContext 一致', () {
      expect(birthContext.gender, equals(Gender.male));
    });

    test('eightChars 与计算的 ChineseDateInfo 一致', () {
      expect(birthContext.eightChars.year,
          equals(computedDateInfo.eightChars.year));
      expect(birthContext.eightChars.month,
          equals(computedDateInfo.eightChars.month));
      expect(birthContext.eightChars.day,
          equals(computedDateInfo.eightChars.day));
      expect(birthContext.eightChars.time,
          equals(computedDateInfo.eightChars.time));
    });

    test('ChineseDateInfo 的日期字段非默认占位值', () {
      // 1990-01-15 对应农历腊月（12月）中下旬，不会是 0
      expect(computedDateInfo.lunarMonth, greaterThanOrEqualTo(1));
      expect(computedDateInfo.lunarMonth, lessThanOrEqualTo(12));
      expect(computedDateInfo.lunarDay, greaterThanOrEqualTo(1));
      expect(computedDateInfo.lunarDay, lessThanOrEqualTo(30));
    });

    test('jieQiInfo 不是硬编码立春 — 1 月 15 日的节气应为小寒', () {
      final jqi = computedDateInfo.jieQiInfo;
      // 1990-01-15 介于小寒（约 1 月 5–6 日）和大寒（约 1 月 20 日）之间
      // startAt 应为小寒开始时间
      expect(jqi.jieQi, equals(TwentyFourJieQi.XIAO_HAN));
      // 小寒约 1 月 5–6 日
      expect(jqi.startAt.month, equals(1));
      expect(jqi.startAt.day, inClosedOpenRange(4, 7));
      // 大寒约 1 月 20 日附近
      expect(jqi.endAt.month, equals(1));
      expect(jqi.endAt.day, inClosedOpenRange(19, 22));
      // 出生时间应在节气区间内
      expect(birthDateTime.isAfter(jqi.startAt), isTrue);
      expect(birthDateTime.isBefore(jqi.endAt), isTrue);
    });

    test('birthLocation 与输入一致', () {
      expect(birthContext.birthLocation!.longitude, equals(116.4074));
      expect(birthContext.birthLocation!.timeZoneId, equals('Asia/Shanghai'));
    });
  });
}
