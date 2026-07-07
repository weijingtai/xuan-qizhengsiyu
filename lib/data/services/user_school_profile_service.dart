import 'package:uuid/uuid.dart';
import 'package:qizhengsiyu/enums/enum_school.dart';
import 'package:qizhengsiyu/data/datasources/local/app_database.dart';
import 'package:qizhengsiyu/data/datasources/local/daos/user_school_profile_dao.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/services/user_school_profile_service_port.dart';

class UserSchoolProfileService implements UserSchoolProfileServicePort {
  final UserSchoolProfileDao _dao;
  const UserSchoolProfileService(this._dao);

  @override
  Future<String> saveCurrentAsProfile({
    required String name,
    required EnumSchoolType school,
    required String classicBook,
    required BasePanelConfig config,
  }) async {
    final id = 'user_${const Uuid().v4()}';
    await _dao.upsert(
      uuid: id, name: name, school: school.name,
      classicBook: classicBook, config: config,
    );
    return id;
  }

  @override
  Future<List<UserSchoolProfileTableData>> listAll() => _dao.listAll();
  
  @override
  Future<void> delete(String uuid) => _dao.softDelete(uuid);
}
