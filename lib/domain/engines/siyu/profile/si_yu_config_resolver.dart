import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/si_yu_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/spec/si_yu_group_spec.dart';
import 'built_in_profiles.dart';

class SiYuConfigResolver {
  ({CelestialCoordinateSystem coordinate, Map<SiYuGroup, SiYuGroupSpec> groups})
      resolve({
    required String profileId,
    Map<SiYuGroup, SiYuGroupSpec> overrides = const {},
    CelestialCoordinateSystem? coordinateOverride,
  }) {
    final p = BuiltInSiYuProfiles.byId(profileId);
    final groups = <SiYuGroup, SiYuGroupSpec>{...p.groups, ...overrides};
    return (coordinate: coordinateOverride ?? p.coordinate, groups: groups);
  }
}
