import 'package:qizhengsiyu/enums/enum_school.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_zhou_tian_model.dart';
import 'school_profile.dart';

/// 内置流派档案。每个「流派 × 典籍」一档；同派多典籍各出一档。
class BuiltInSchoolProfiles {
  static const defaultId = 'guolao_guolaoxingzong';

  // 果老·黄道（《果老星宗》）：现代黄道 + 360 度制，关联果老黄道四余档案
  static const _guoLao = SchoolProfile(
    id: 'guolao_guolaoxingzong',
    name: '果老派·果老星宗',
    school: EnumSchoolType.GuoLao,
    classicBook: '果老星宗',
    coordinate: CelestialCoordinateSystem.Ecliptic,
    panelSystemType: PanelSystemType.Tropical,
    constellationSystemType: ConstellationSystemType.Classical,
    siYuProfileId: 'guolao_ecliptic',
  );

  // 天官·黄道（《天官星经》）：现代黄道 + 360 度制
  static const _tianGuan = SchoolProfile(
    id: 'tianguan_tianguanxingjing',
    name: '天官派·天官星经',
    school: EnumSchoolType.TianGuan,
    classicBook: '天官星经',
    coordinate: CelestialCoordinateSystem.Ecliptic,
    panelSystemType: PanelSystemType.Tropical,
    constellationSystemType: ConstellationSystemType.Classical,
    siYuProfileId: 'guolao_ecliptic',
  );

  // 琴堂·天赤道（《星学大成》）：天赤道 365.25 + 恒星制
  static const _qinTang = SchoolProfile(
    id: 'qintang_xingxuedacheng',
    name: '琴堂派·星学大成',
    school: EnumSchoolType.QinTang,
    classicBook: '星学大成',
    coordinate: CelestialCoordinateSystem.SkyEquatorial,
    panelSystemType: PanelSystemType.Sidereal,
    constellationSystemType: ConstellationSystemType.Classical,
    zhouTianModelOverride: EnumZhouTianModel.degree36525,
    siYuProfileId: 'qintang_chidao',
  );

  static const List<SchoolProfile> all = [_guoLao, _tianGuan, _qinTang];

  static SchoolProfile byId(String id) =>
      all.firstWhere((p) => p.id == id, orElse: () => byId(defaultId));

  static List<SchoolProfile> bySchool(EnumSchoolType school) =>
      all.where((p) => p.school == school).toList();

  static SchoolProfile defaultForSchool(EnumSchoolType school) {
    final list = bySchool(school);
    return list.isNotEmpty ? list.first : byId(defaultId);
  }
}
