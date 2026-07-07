import 'package:qizhengsiyu/enums/enum_school.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';

class SavedSchoolProfile {
  final String id, name, school, classicBook;
  final BasePanelConfig config;
  const SavedSchoolProfile({
    required this.id, required this.name, required this.school,
    required this.classicBook, required this.config,
  });
}

/// 用户自定义流派档案存取端口。
/// 具体实现在 data 层，通过 DI 注入。
abstract class UserSchoolProfileServicePort {
  Future<String> saveCurrentAsProfile({
    required String name,
    required EnumSchoolType school,
    required String classicBook,
    required BasePanelConfig config,
  });

  Future<List<SavedSchoolProfile>> listAll();
  Future<void> delete(String uuid);
}
