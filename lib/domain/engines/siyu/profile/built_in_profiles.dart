import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/si_yu_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/spec/si_yu_group_spec.dart';
import 'si_yu_profile.dart';

class BuiltInSiYuProfiles {
  static const defaultId = 'guolao_ecliptic';

  // 果老·黄道：罗计星历(罗降计升=0)、月孛星历、紫气黄道平行
  static final _guoLaoEcliptic = SiYuProfile(
    id: 'guolao_ecliptic', name: '果老·黄道',
    coordinate: CelestialCoordinateSystem.Ecliptic,
    groups: {
      SiYuGroup.luoJi: const SiYuGroupSpec(kind: 'ephemeris_node', rahuKetuConventionIndex: 0),
      SiYuGroup.yueBo: const SiYuGroupSpec(kind: 'ephemeris_apogee'),
      SiYuGroup.ziQi: const SiYuGroupSpec(kind: 'linear_ziqi', params: {
        'totalDegree': 360, 'dailyMotion': 0.0352, 'direction': 1,
        'epochJulianDay': 2461226.135, 'epochPosition': 329.0, // 占位:黄道女宿历元,待黄道紫气校准
      }),
    },
  );

  // 琴堂·天赤道：紫气天赤道 Moira 实测(已验证常数)
  static final _qinTangChiDao = SiYuProfile(
    id: 'qintang_chidao', name: '琴堂·天赤道',
    coordinate: CelestialCoordinateSystem.SkyEquatorial,
    groups: {
      SiYuGroup.luoJi: const SiYuGroupSpec(kind: 'ephemeris_node', rahuKetuConventionIndex: 0),
      SiYuGroup.yueBo: const SiYuGroupSpec(kind: 'ephemeris_apogee'),
      SiYuGroup.ziQi: const SiYuGroupSpec(kind: 'linear_ziqi', params: {
        'totalDegree': 365.25, 'dailyMotion': 0.0356771, 'direction': 1,
        'epochJulianDay': 2461226.135, 'epochPosition': 333.843, // Moira 锚 2026=翼宿4°38'36''
      }),
    },
  );

  static final List<SiYuProfile> all = [_guoLaoEcliptic, _qinTangChiDao];
  static SiYuProfile byId(String id) =>
      all.firstWhere((p) => p.id == id, orElse: () => _guoLaoEcliptic);
}
