import 'package:qizhengsiyu/enums/enum_school.dart';
import 'package:qizhengsiyu/domain/entities/models/school_profile.dart';
import 'package:qizhengsiyu/domain/engines/school/built_in_school_profiles.dart';

/// 流派档案查询用例 — UI 经此访问内建注册表,不再直接 import engines。
final class GetSchoolProfilesUseCase {
  List<SchoolProfile> all() => BuiltInSchoolProfiles.all;
  SchoolProfile byId(String id) => BuiltInSchoolProfiles.byId(id);
  List<SchoolProfile> bySchool(EnumSchoolType school) =>
      BuiltInSchoolProfiles.bySchool(school);
  SchoolProfile defaultForSchool(EnumSchoolType school) =>
      BuiltInSchoolProfiles.defaultForSchool(school);
}
