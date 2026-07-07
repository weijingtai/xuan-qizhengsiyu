import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_school.dart';
import 'package:qizhengsiyu/enums/enum_zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/engines/school/built_in_school_profiles.dart';
import 'package:qizhengsiyu/domain/engines/school/school_config_resolver.dart';

void main() {
  final r = SchoolConfigResolver();
  final base = BasePanelConfig.defaultBasicPanelConfig();

  test('三派默认档案套配后 A 层关键值符合基线', () {
    final gl = r.applyProfile(
        base, BuiltInSchoolProfiles.defaultForSchool(EnumSchoolType.GuoLao));
    expect(gl.celestialCoordinateSystem, CelestialCoordinateSystem.Ecliptic);
    expect(gl.zhouTianModelOverride, isNull);

    final qt = r.applyProfile(
        base, BuiltInSchoolProfiles.defaultForSchool(EnumSchoolType.QinTang));
    expect(qt.celestialCoordinateSystem, CelestialCoordinateSystem.SkyEquatorial);
    expect(qt.zhouTianModelOverride, EnumZhouTianModel.degree36525);
  });

  test('不选流派：默认 config A 层字段全默认（回归红线）', () {
    expect(base.celestialCoordinateSystem, CelestialCoordinateSystem.Ecliptic);
    expect(base.zhouTianModelOverride, isNull);
    expect(base.zeroPointRef, isNull);
    expect(base.starInnDegreeOverrides, isNull);
  });
}
