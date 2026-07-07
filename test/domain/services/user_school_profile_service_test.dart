import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_school.dart';
import 'package:qizhengsiyu/data/datasources/local/app_database.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/data/services/user_school_profile_service.dart';

void main() {
  test('保存当前配置为命名档案 → 可列出', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final svc = UserSchoolProfileService(db.userSchoolProfileDao);
    final id = await svc.saveCurrentAsProfile(
      name: '自定义A', school: EnumSchoolType.Customerized,
      classicBook: '', config: BasePanelConfig.defaultBasicPanelConfig(),
    );
    expect(id, isNotEmpty);
    final list = await svc.listAll();
    expect(list.any((e) => e.uuid == id), isTrue);
  });
}
