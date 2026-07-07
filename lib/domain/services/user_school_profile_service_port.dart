import 'package:qizhengsiyu/enums/enum_school.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';

/// 用户自定义流派档案存取端口。
/// 具体实现在 data 层，通过 DI 注入。
abstract class UserSchoolProfileServicePort {
  Future<String> saveCurrentAsProfile({
    required String name,
    required EnumSchoolType school,
    required String classicBook,
    required BasePanelConfig config,
  });

  Future<List<dynamic>> listAll();
  Future<void> delete(String uuid);
}
