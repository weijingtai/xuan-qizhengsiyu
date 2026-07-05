import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/enums/enum_zi_qi_algorithm.dart';

void main() {
  test('默认配置具有正确的默认紫气算法/周期/历元/标准', () {
    final cfg = PanelConfig.defaultPanelConfig();
    expect(cfg.ziQiAlgorithm, EnumZiQiAlgorithm.guoLaoQinTang);
    expect(cfg.ziQiPeriod, EnumZiQiPeriod.years28);
    expect(cfg.ziQiEpochSet, EnumZiQiEpochSet.shouShiNvXiu);
    expect(cfg.ziQiChiDaoStandard, EnumZiQiChiDaoStandard.moira);
  });

  test('旧 JSON 缺紫气字段 -> 默认回落，不抛异常', () {
    final json = PanelConfig.defaultPanelConfig().toJson();
    json.remove('ziQiAlgorithm');
    json.remove('ziQiPeriod');
    json.remove('ziQiEpochSet');
    json.remove('ziQiChiDaoStandard');
    final restored = PanelConfig.fromJson(json);
    expect(restored.ziQiAlgorithm, EnumZiQiAlgorithm.guoLaoQinTang);
    expect(restored.ziQiPeriod, EnumZiQiPeriod.years28);
    expect(restored.ziQiEpochSet, EnumZiQiEpochSet.shouShiNvXiu);
    expect(restored.ziQiChiDaoStandard, EnumZiQiChiDaoStandard.moira);
  });

  test('新配置可正常序列化往返', () {
    final cfg = PanelConfig.defaultPanelConfig()
      ..ziQiAlgorithm = EnumZiQiAlgorithm.shixian
      ..ziQiPeriod = EnumZiQiPeriod.years29
      ..ziQiEpochSet = EnumZiQiEpochSet.fuTianJiXiu
      ..ziQiChiDaoStandard = EnumZiQiChiDaoStandard.shouShiOrthodox;
    final restored = PanelConfig.fromJson(cfg.toJson());
    expect(restored.ziQiAlgorithm, EnumZiQiAlgorithm.shixian);
    expect(restored.ziQiPeriod, EnumZiQiPeriod.years29);
    expect(restored.ziQiEpochSet, EnumZiQiEpochSet.fuTianJiXiu);
    expect(restored.ziQiChiDaoStandard, EnumZiQiChiDaoStandard.shouShiOrthodox);
  });
}
