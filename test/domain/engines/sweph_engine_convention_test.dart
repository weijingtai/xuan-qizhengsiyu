import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_stars_info.dart';
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';

StarsAngle _angle() => StarsAngle(
      sun: 0, moon: 0, venus: 0, venusSpeed: 0, jupiter: 0, jupiterSpeed: 0,
      mars: 0, marsSpeed: 0, saturn: 0, saturnSpeed: 0, water: 0, waterSpeed: 0,
      northNode: 30, southNode: 210, lilith: 100, qi: 50,
    );

void main() {
  test('config 旧法 -> 罗=降(210)、计=升(30)', () {
    final cfg = PanelConfig.defaultPanelConfig();
    final m = _angle().toMap(convention: cfg.rahuKetuConvention);
    expect(m[EnumStars.Luo]!.angle, closeTo(210, 1e-9));
    expect(m[EnumStars.Ji]!.angle, closeTo(30, 1e-9));
  });

  test('config 新法 -> 罗计互换', () {
    final cfg = PanelConfig.defaultPanelConfig()
      ..rahuKetuConvention = EnumRahuKetuConvention.luoShengJiJiang;
    final m = _angle().toMap(convention: cfg.rahuKetuConvention);
    expect(m[EnumStars.Luo]!.angle, closeTo(30, 1e-9));
    expect(m[EnumStars.Ji]!.angle, closeTo(210, 1e-9));
  });
}
