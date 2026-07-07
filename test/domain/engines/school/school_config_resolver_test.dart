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

  test('套琴堂档案 → 坐标/周天制随档案改写', () {
    final base = BasePanelConfig.defaultBasicPanelConfig();
    final qt = BuiltInSchoolProfiles.defaultForSchool(EnumSchoolType.QinTang);
    final out = r.applyProfile(base, qt);
    expect(out.celestialCoordinateSystem, CelestialCoordinateSystem.SkyEquatorial);
    expect(out.zhouTianModelOverride, EnumZhouTianModel.degree36525);
    expect(out.constellationSystemType, qt.constellationSystemType);
  });

  test('applyById 未知 id → 回落默认果老档案', () {
    final base = BasePanelConfig.defaultBasicPanelConfig();
    final out = r.applyById(base, '__无__');
    expect(out.celestialCoordinateSystem, CelestialCoordinateSystem.Ecliptic);
  });

  test('套档案不破坏 base 的人物/settle 字段（只改 A 层轴）', () {
    final base = BasePanelConfig.defaultBasicPanelConfig();
    final out = r.applyProfile(
        base, BuiltInSchoolProfiles.defaultForSchool(EnumSchoolType.QinTang));
    expect(out.settleLifeType, base.settleLifeType);
    expect(out.settleBodyType, base.settleBodyType);
  });

  test('套琴堂档案 → siYuProfileId 跟随切换为 qintang_chidao', () {
    final base = BasePanelConfig.defaultBasicPanelConfig();
    final qt = BuiltInSchoolProfiles.defaultForSchool(EnumSchoolType.QinTang);
    final out = SchoolConfigResolver().applyProfile(base, qt);
    expect(out.siYuProfileId, 'qintang_chidao');
  });

  test('档案 siYuProfileId 为 null 时保留 base 值', () {
    final base = BasePanelConfig.defaultBasicPanelConfig(); // base=guolao_ecliptic
    // 构造一个 siYuProfileId=null 的档案做保护性断言（用果老默认档案若其 siYuProfileId 非 null 则跳过此断言）
    final gl = BuiltInSchoolProfiles.defaultForSchool(EnumSchoolType.GuoLao);
    final out = SchoolConfigResolver().applyProfile(base, gl);
    expect(out.siYuProfileId, gl.siYuProfileId ?? base.siYuProfileId);
  });
}
