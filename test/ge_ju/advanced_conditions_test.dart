import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';

/// 数据超前于模型的条件类型补全测试（2026-08-10）。
///
/// 验证 10 种新条件类型：
/// 1. fromJson → toJson round-trip（type 不丢失）
/// 2. 真实源数据样例（rules 文档）可完整解析为 GeJuRule（不再 UnimplementedError）
void main() {
  group('10 种补全条件 fromJson/toJson round-trip', () {
    const cases = <Map<String, dynamic>>[
      {'type': 'yearBranch', 'branch': 'YIN'},
      {
        'type': 'jupiterSeasonPosition',
        'season': 'winter',
        'positions': ['巳', '申'],
      },
      {'type': 'gongDegree', 'gong': 'Life', 'degree': '尾度'},
      {'type': 'bodyLifeHarmony'},
      {'type': 'sunMoonHarmony'},
      {'type': 'waterFireBalance'},
      {'type': 'fivePlanetsAlignment'},
      {'type': 'sevenPlanetsInPalace'},
      {'type': 'lifeLordInFavorablePlace'},
      {'type': 'officialStarPatterns'},
    ];

    for (final json in cases) {
      test('${json['type']} round-trip', () {
        final condition = GeJuCondition.fromJson(json);
        final back = condition.toJson();
        expect(back['type'], json['type'], reason: 'type 不得丢失');
        expect(condition.describe(), isNotEmpty);
      });
    }
  });

  test('真实数据样例：含 yearBranch 的规则完整解析', () {
    final rule = GeJuRule.fromJson({
      'id': 'test_year_branch',
      'name': '测试年支',
      'variants': [
        {
          'source': '测试',
          'description': '测试年支',
          'conditions': {
            'type': 'and',
            'conditions': [
              {'type': 'yearBranch', 'branch': 'YIN'},
              {'type': 'seasonIs', 'seasons': ['WINTER']},
            ],
          },
        },
      ],
    });
    expect(rule.id, 'test_year_branch');
    expect(rule.variants.single.conditions, isNotNull);
  });

  test('真实数据样例：含 sunMoonHarmony 的规则完整解析', () {
    final rule = GeJuRule.fromJson({
      'id': 'test_sun_moon',
      'name': '测试日月调和',
      'variants': [
        {
          'source': '测试',
          'description': '测试日月调和',
          'conditions': {'type': 'sunMoonHarmony'},
        },
      ],
    });
    expect(rule.id, 'test_sun_moon');
  });
}
