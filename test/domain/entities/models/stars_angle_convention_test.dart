import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_stars_info.dart';
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';

StarsAngle _sample() => StarsAngle(
      sun: 0, moon: 0, venus: 0, venusSpeed: 0, jupiter: 0, jupiterSpeed: 0,
      mars: 0, marsSpeed: 0, saturn: 0, saturnSpeed: 0, water: 0, waterSpeed: 0,
      northNode: 30, // 升交点
      southNode: 210, // 降交点
      lilith: 100, qi: 50,
    );

void main() {
  test('默认(旧法) toMap: 罗=降(210), 计=升(30)', () {
    final m = _sample().toMap();
    expect(m[EnumStars.Luo]!.angle, closeTo(210, 1e-9));
    expect(m[EnumStars.Ji]!.angle, closeTo(30, 1e-9));
  });

  test('新法 toMap: 罗=升(30), 计=降(210)', () {
    final m = _sample()
        .toMap(convention: EnumRahuKetuConvention.luoShengJiJiang);
    expect(m[EnumStars.Luo]!.angle, closeTo(30, 1e-9));
    expect(m[EnumStars.Ji]!.angle, closeTo(210, 1e-9));
  });

  test('getByStar 默认旧法与 toMap 一致', () {
    final s = _sample();
    expect(s.getByStar(EnumStars.Luo), closeTo(210, 1e-9));
    expect(s.getByStar(EnumStars.Ji), closeTo(30, 1e-9));
    expect(
        s.getByStar(EnumStars.Luo,
            convention: EnumRahuKetuConvention.luoShengJiJiang),
        closeTo(30, 1e-9));
  });

  test('fromMapper(旧法) 能从罗计还原中性升降交点', () {
    final m = _sample().toMap();
    final back = StarsAngle.fromMapper(m);
    expect(back.northNode, closeTo(30, 1e-9));
    expect(back.southNode, closeTo(210, 1e-9));
  });
}
