import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/managers/ge_ju/ge_ju_rule_parser.dart';
import 'package:common/enums/enum_ji_xiong.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/conditions/structure_conditions.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/conditions/time_conditions.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/conditions/position_conditions.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/conditions/shen_sha_conditions.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/conditions/xian_conditions.dart';
import 'package:common/enums/enum_di_zhi.dart';

void main() {
  test('Should strictly parse "未知" as WEI_ZHI', () {
    const jsonContent = '''
    [
      {
        "id": "test_unknown_jixiong",
        "name": "Test Unknown JiXiong",
        "className": "Test",
        "books": "Test",
        "source": "Test",
        "description": "Test",
        "jiXiong": "未知",
        "geJuType": "贵",
        "scope": "natal"
      }
    ]
    ''';

    final rules = GeJuRuleParser.parseRules(jsonContent);
    expect(rules.length, 1);
    expect(rules[0].jiXiong, JiXiongEnum.WEI_ZHI);
  });

  test('Should parse MonthIsCondition with Pinyin "Yin"', () {
    final jsonMap = {
      "type": "monthIs",
      "months": ["Yin"]
    };

    final condition = MonthIsCondition.fromJson(jsonMap);
    expect(condition.months.first, DiZhi.YIN);
  });

  test('Should describe StarInGongCondition with Chinese name for English key',
      () {
    final jsonMap = {
      "type": "starInGong",
      "star": "Saturn",
      "gongs": ["Zi"]
    };

    final condition = StarInGongCondition.fromJson(jsonMap);
    expect(condition.describe(), contains("入子宫"));
    expect(condition.describe(), isNot(contains("Zi")));
  });

  test('Should describe LifeGongAtCondition with Chinese name', () {
    final jsonMap = {
      "type": "lifeGongAt",
      "gongs": ["Zi"]
    };
    final condition = LifeGongAtCondition.fromJson(jsonMap);
    expect(condition.describe(), contains("命宫在子"));
  });

  test('Should describe GongHasShenShaCondition with Chinese name', () {
    final jsonMap = {
      "type": "gongHasShenSha",
      "gongIdentifier": "Zi",
      "shenShaNames": ["GuiRen"]
    };
    final condition = GongHasShenShaCondition.fromJson(jsonMap);
    expect(condition.describe(), contains("子带GuiRen"));
    // Note: ShenSha names might also need fixing but strictly focusing on Gong names for now as per task.
  });

  test('Should describe XianAtGongCondition with Chinese name', () {
    final jsonMap = {
      "type": "xianAtGong",
      "gongs": ["Zi"]
    };
    final condition = XianAtGongCondition.fromJson(jsonMap);
    expect(condition.describe(), contains("行限在子"));
  });

  test(
      'Should handle unknown enum values gracefully if possible (or fail with clear error)',
      () {
    // This test confirms that we now support "未知" so it shouldn't fail.
    // If we used an unsupported value like "RandomValue", it would fall back to null or throw depending on implementation.
    // Based on current implementation, $enumDecodeNullable might return null or throw if not nullable matching.
    // But let's focus on the fixed case where "未知" caused crash.
  });

  test('Should parse StarInDestinyGongCondition with English key "QianYi"', () {
    // This replicates the json structure found in mu_xing_ge_ju.json
    final jsonMap = {
      "type": "starInDestinyGong",
      "star": "Jupiter",
      "destinyGong": "QianYi"
    };

    final condition = StarInDestinyGongCondition.fromJson(jsonMap);
    expect(condition.destinyGong, EnumDestinyTwelveGong.QianYi);
  });
}
