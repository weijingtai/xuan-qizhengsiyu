import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/usecases/get_school_profiles_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/apply_school_profile_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/get_si_yu_profiles_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/validate_panel_config_usecase.dart';

/// 默认配置 — 与 PanelConfigViewModel.getPreviousPanelConfig() 同款参数
PanelConfig buildDefaultConfig() {
  return PanelConfig(
    celestialCoordinateSystem: CelestialCoordinateSystem.Ecliptic,
    houseDivisionSystem: HouseDivisionSystem.equal,
    panelSystemType: PanelSystemType.Tropical,
    constellationSystemType: ConstellationSystemType.Classical,
    settleLifeType: EnumSettleLifeType.Mao,
    settleBodyType: EnumSettleBodyType.moon,
    islifeGongBySunRealTimeLocation: true,
    zhouTianModelOverride: null,
    projectionOverride: null,
  );
}

void main() {
  test('GetSchoolProfilesUseCase 暴露内建流派档案', () {
    final uc = GetSchoolProfilesUseCase();
    expect(uc.all(), isNotEmpty);
    expect(uc.byId('guolao_guolaoxingzong').classicBook, '果老星宗');
  });

  test('GetSiYuProfilesUseCase 暴露内建四余档案', () {
    final uc = GetSiYuProfilesUseCase();
    expect(uc.all(), isNotEmpty);
    expect(uc.byId('guolao_ecliptic').id, 'guolao_ecliptic');
  });

  test('ApplySchoolProfileUseCase 应用档案改写坐标制式', () {
    final school = GetSchoolProfilesUseCase().byId('guolao_guolaoxingzong');
    final applied =
        ApplySchoolProfileUseCase().execute(buildDefaultConfig(), school);
    expect(applied.celestialCoordinateSystem, school.coordinate);
  });

  test('ValidatePanelConfigUseCase 对默认配置产出校验结果', () {
    final check = ValidatePanelConfigUseCase().execute(buildDefaultConfig());
    expect(check, isNotNull);
  });
}
