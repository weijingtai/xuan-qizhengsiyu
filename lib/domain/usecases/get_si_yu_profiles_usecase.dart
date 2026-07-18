import 'package:qizhengsiyu/domain/entities/models/si_yu_profile.dart';
import 'package:qizhengsiyu/domain/engines/siyu/profile/built_in_profiles.dart';

/// 四余档案查询用例。
final class GetSiYuProfilesUseCase {
  List<SiYuProfile> all() => BuiltInSiYuProfiles.all;
  SiYuProfile byId(String id) => BuiltInSiYuProfiles.byId(id);
}
