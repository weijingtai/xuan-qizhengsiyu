import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_school.dart';
import 'package:qizhengsiyu/enums/enum_zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/engines/school/school_profile.dart';
import 'package:qizhengsiyu/domain/engines/school/built_in_school_profiles.dart';

void main() {
  test('内置档案至少覆盖果老/琴堂/天官三派', () {
    final schools =
        BuiltInSchoolProfiles.all.map((p) => p.school).toSet();
    expect(schools.contains(EnumSchoolType.GuoLao), isTrue);
    expect(schools.contains(EnumSchoolType.QinTang), isTrue);
    expect(schools.contains(EnumSchoolType.TianGuan), isTrue);
  });

  test('果老默认档案=黄道坐标、360 度制', () {
    final p = BuiltInSchoolProfiles.defaultForSchool(EnumSchoolType.GuoLao);
    expect(p.coordinate, CelestialCoordinateSystem.Ecliptic);
    expect(p.zhouTianModelOverride, isNull); // 360 度制默认不覆写
  });

  test('琴堂默认档案=天赤道、365.25 度制', () {
    final p = BuiltInSchoolProfiles.defaultForSchool(EnumSchoolType.QinTang);
    expect(p.coordinate, CelestialCoordinateSystem.SkyEquatorial);
    expect(p.zhouTianModelOverride, EnumZhouTianModel.degree36525);
  });

  test('byId 命中；未知 id 回落默认档案', () {
    expect(BuiltInSchoolProfiles.byId(BuiltInSchoolProfiles.defaultId).id,
        BuiltInSchoolProfiles.defaultId);
    expect(BuiltInSchoolProfiles.byId('__不存在__').id,
        BuiltInSchoolProfiles.defaultId);
  });

  test('bySchool 返回该派全部典籍档案且非空', () {
    final books = BuiltInSchoolProfiles.bySchool(EnumSchoolType.GuoLao);
    expect(books, isNotEmpty);
    expect(books.every((p) => p.school == EnumSchoolType.GuoLao), isTrue);
  });
}
