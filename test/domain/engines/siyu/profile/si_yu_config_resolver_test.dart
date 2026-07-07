import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/si_yu_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/spec/si_yu_group_spec.dart';
import 'package:qizhengsiyu/domain/engines/siyu/profile/built_in_profiles.dart';
import 'package:qizhengsiyu/domain/engines/siyu/profile/si_yu_config_resolver.dart';

void main() {
  final r = SiYuConfigResolver();
  test('无覆盖=档案默认', () {
    final out = r.resolve(profileId: BuiltInSiYuProfiles.defaultId);
    expect(out.groups.containsKey(SiYuGroup.ziQi), isTrue);
  });
  test('单项覆盖紫气组', () {
    const ov = SiYuGroupSpec(kind: 'linear_ziqi', params: {'dailyMotion': 0.9});
    final out = r.resolve(profileId: BuiltInSiYuProfiles.defaultId,
        overrides: {SiYuGroup.ziQi: ov});
    expect(out.groups[SiYuGroup.ziQi]!.params['dailyMotion'], 0.9);
  });
  test('星制覆盖', () {
    final out = r.resolve(profileId: BuiltInSiYuProfiles.defaultId,
        coordinateOverride: CelestialCoordinateSystem.Equatorial);
    expect(out.coordinate, CelestialCoordinateSystem.Equatorial);
  });
}
