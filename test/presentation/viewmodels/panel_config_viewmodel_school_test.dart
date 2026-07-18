import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_school.dart';
import 'package:qizhengsiyu/enums/enum_zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/usecases/get_school_profiles_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/apply_school_profile_usecase.dart';
import 'package:qizhengsiyu/presentation/viewmodels/panel_config_viewmodel.dart';

void main() {
  test('选琴堂 → config 套天赤道/365.25，且通知监听', () {
    final vm = PanelConfigViewModel(
      schoolProfiles: GetSchoolProfilesUseCase(),
      applyProfile: ApplySchoolProfileUseCase(),
    );
    var notified = 0;
    vm.addListener(() => notified++);

    vm.updateSchoolType(EnumSchoolType.QinTang);

    expect(vm.customConfig.celestialCoordinateSystem,
        CelestialCoordinateSystem.SkyEquatorial);
    expect(vm.customConfig.zhouTianModelOverride,
        EnumZhouTianModel.degree36525);
    expect(notified, greaterThan(0));
    expect(vm.isCustomized, isFalse); // 刚套档案未自定义
  });

  test('套档案后手改 config → isCustomized=true', () {
    final vm = PanelConfigViewModel(
      schoolProfiles: GetSchoolProfilesUseCase(),
      applyProfile: ApplySchoolProfileUseCase(),
    );
    vm.updateSchoolType(EnumSchoolType.GuoLao);
    vm.updateCustomConfig(PanelConfig(
      celestialCoordinateSystem: CelestialCoordinateSystem.SkyEquatorial,
      houseDivisionSystem: vm.customConfig.houseDivisionSystem,
      panelSystemType: vm.customConfig.panelSystemType,
      constellationSystemType: vm.customConfig.constellationSystemType,
      settleLifeType: vm.customConfig.settleLifeType,
      settleBodyType: vm.customConfig.settleBodyType,
      islifeGongBySunRealTimeLocation: vm.customConfig.islifeGongBySunRealTimeLocation,
    ));
    expect(vm.isCustomized, isTrue);
  });

  test('Customerized 流派 → 保持当前配置不变', () {
    final vm = PanelConfigViewModel(
      schoolProfiles: GetSchoolProfilesUseCase(),
      applyProfile: ApplySchoolProfileUseCase(),
    );
    final before = vm.customConfig.celestialCoordinateSystem;
    vm.updateSchoolType(EnumSchoolType.Customerized);
    expect(vm.customConfig.celestialCoordinateSystem, before);
  });
}
