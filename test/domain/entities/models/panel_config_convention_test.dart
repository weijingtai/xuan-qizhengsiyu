import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';

void main() {
  test('默认配置为旧法', () {
    expect(PanelConfig.defaultPanelConfig().rahuKetuConvention,
        EnumRahuKetuConvention.luoJiangJiSheng);
  });

  test('旧 JSON 缺 rahuKetuConvention -> 默认旧法，不抛异常', () {
    final json = PanelConfig.defaultPanelConfig().toJson();
    json.remove('rahuKetuConvention');
    final restored = PanelConfig.fromJson(json);
    expect(restored.rahuKetuConvention,
        EnumRahuKetuConvention.luoJiangJiSheng);
  });

  test('新法可序列化往返', () {
    final cfg = PanelConfig.defaultPanelConfig()
      ..rahuKetuConvention = EnumRahuKetuConvention.luoShengJiJiang;
    final restored = PanelConfig.fromJson(cfg.toJson());
    expect(restored.rahuKetuConvention,
        EnumRahuKetuConvention.luoShengJiJiang);
  });
}
