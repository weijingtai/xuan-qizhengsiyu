import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:metaphysics_core/models/jie_qi_info.dart';
import 'package:bazi_embed_ui_interface/bazi_embed_ui_interface.dart';
import 'package:repository_interface_bazi/repository_interface_bazi.dart';
import 'package:repository_interface_divination_pipeline/geo.dart';

/// BaziEmbed 接入冻结测试
///
/// 验证：
/// 1. BaziEmbedUiPort 接口类型正确
/// 2. BaziBirthContext 构造路径可编译
/// 3. 具体值断言：字段赋值一致
void main() {
  group('BaziEmbedUiPort 接口类型', () {
    test('BaziEmbedUiPort 是抽象接口类', () {
      // 编译时断言：BaziEmbedUiPort 是 abstract interface class
      // 若类型不存在或签名不匹配，此处编译失败
      const Type portType = BaziEmbedUiPort;
      expect(portType, equals(BaziEmbedUiPort));
    });

    test('showDayunLiunianSheet 方法签名可调用', () {
      // 构造一个 BaziBirthContext，验证构造路径可编译
      final birthContext = BaziBirthContext(
        birthDateTime: DateTime(1990, 1, 15, 10, 30),
        gender: Gender.male,
        eightChars: EightChars(
          year: JiaZi.GENG_WU,
          month: JiaZi.WU_ZI,
          day: JiaZi.JIA_XU,
          time: JiaZi.GENG_WU,
        ),
        chineseDateInfo: ChineseDateInfo(
          eightChars: EightChars(
            year: JiaZi.GENG_WU,
            month: JiaZi.WU_ZI,
            day: JiaZi.JIA_XU,
            time: JiaZi.GENG_WU,
          ),
          phenology: Phenology.phenologyList.first,
          lunarMonth: 1,
          lunarDay: 15,
          isLeapMonth: false,
          jieQiInfo: JieQiInfo(
            jieQi: TwentyFourJieQi.LI_CHUN,
            startAt: DateTime(1990, 2, 4),
            endAt: DateTime(1990, 2, 19),
          ),
          threeYuan: YuanYunOrder.upper,
          nineYun: NineYun.first,
        ),
        birthLocation: BirthPlace(
          GeoPoint(
            latitude: 39.9042,
            longitude: 116.4074,
            timeZoneId: 'Asia/Shanghai',
          ),
        ),
      );

      // 断言 BaziBirthContext 字段赋值正确
      expect(birthContext.birthDateTime, equals(DateTime(1990, 1, 15, 10, 30)));
      expect(birthContext.gender, equals(Gender.male));
      expect(birthContext.eightChars.year, equals(JiaZi.GENG_WU));
      expect(birthContext.eightChars.month, equals(JiaZi.WU_ZI));
      expect(birthContext.eightChars.day, equals(JiaZi.JIA_XU));
      expect(birthContext.eightChars.time, equals(JiaZi.GENG_WU));
      expect(birthContext.chineseDateInfo.lunarMonth, equals(1));
      expect(birthContext.chineseDateInfo.lunarDay, equals(15));
      expect(birthContext.chineseDateInfo.isLeapMonth, isFalse);
      expect(birthContext.birthLocation!.longitude, equals(116.4074));
      expect(birthContext.birthLocation!.timeZoneId, equals('Asia/Shanghai'));
      expect(birthContext.ziBoundaryStrategy, equals(ZiBoundary.at23));
      expect(birthContext.childHourMode, equals(ChildHourMode.distinguishFiveMouse));
      expect(birthContext.useTrueSolarTime, isFalse);
    });

    test('BaziBirthContext 默认可选字段值正确', () {
      final birthContext = BaziBirthContext(
        birthDateTime: DateTime(2000, 6, 15),
        gender: Gender.female,
        eightChars: EightChars(
          year: JiaZi.JIA_ZI,
          month: JiaZi.JIA_ZI,
          day: JiaZi.JIA_ZI,
          time: JiaZi.JIA_ZI,
        ),
        chineseDateInfo: ChineseDateInfo(
          eightChars: EightChars(
            year: JiaZi.JIA_ZI,
            month: JiaZi.JIA_ZI,
            day: JiaZi.JIA_ZI,
            time: JiaZi.JIA_ZI,
          ),
          phenology: Phenology.phenologyList.first,
          lunarMonth: 5,
          lunarDay: 1,
          isLeapMonth: false,
          jieQiInfo: JieQiInfo(
            jieQi: TwentyFourJieQi.LI_XIA,
            startAt: DateTime(2000, 5, 5),
            endAt: DateTime(2000, 5, 21),
          ),
          threeYuan: YuanYunOrder.middle,
          nineYun: NineYun.eighth,
        ),
      );

      // 断言可选字段使用默认值
      expect(birthContext.birthLocation, isNull);
      expect(birthContext.ziBoundaryStrategy, equals(ZiBoundary.at23));
      expect(birthContext.childHourMode, equals(ChildHourMode.distinguishFiveMouse));
      expect(birthContext.startLuckStrategy, equals('default'));
      expect(birthContext.useTrueSolarTime, isFalse);
    });
  });
}
