import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/si_yu_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/spec/si_yu_group_spec.dart';
import 'package:qizhengsiyu/domain/engines/siyu/spec/si_yu_algorithm_factory.dart';
import 'package:qizhengsiyu/domain/engines/siyu/profile/built_in_profiles.dart';
import 'package:qizhengsiyu/domain/engines/siyu/profile/si_yu_config_resolver.dart';

void main() {
  test('琴堂·天赤道档案 → 紫气用 Moira 常数产出', () {
    final resolved = SiYuConfigResolver().resolve(profileId: 'qintang_chidao');
    final f = SiYuAlgorithmFactory.withDefaults();
    final ziqi = f.build(resolved.groups[SiYuGroup.ziQi]!,
        CoordinateContext(totalDegree: 365.25));
    // 锚点日 JD → 应≈333.843(翼宿4°38'36'')
    final p = ziqi.computePositions(julianDay: 2461226.135, datetime: DateTime.utc(2026));
    expect(p[EnumStars.Qi], closeTo(333.843, 0.01));
  });
}
