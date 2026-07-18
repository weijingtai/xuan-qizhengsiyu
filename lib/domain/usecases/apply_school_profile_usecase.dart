import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/school_profile.dart';
import 'package:qizhengsiyu/domain/engines/school/school_config_resolver.dart';

/// 把流派档案应用到面板配置(A 层默认覆写)。
final class ApplySchoolProfileUseCase {
  final SchoolConfigResolver _resolver = SchoolConfigResolver();

  BasePanelConfig execute(BasePanelConfig base, SchoolProfile profile) =>
      _resolver.applyProfile(base, profile);
}
