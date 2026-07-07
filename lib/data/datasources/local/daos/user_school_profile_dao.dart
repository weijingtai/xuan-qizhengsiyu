import 'package:drift/drift.dart';
import '../../../../domain/entities/models/panel_config.dart';
import '../app_database.dart';
import '../tables/user_school_profile_table.dart';

part 'user_school_profile_dao.g.dart';

@DriftAccessor(tables: [UserSchoolProfileTable])
class UserSchoolProfileDao extends DatabaseAccessor<AppDatabase>
    with _$UserSchoolProfileDaoMixin {
  UserSchoolProfileDao(AppDatabase db) : super(db);

  Future<void> upsert({
    required String uuid,
    required String name,
    required String school,
    required String classicBook,
    required BasePanelConfig config,
  }) {
    final now = DateTime.now();
    return into(userSchoolProfileTable).insertOnConflictUpdate(
      UserSchoolProfileTableCompanion.insert(
        uuid: uuid,
        name: name,
        school: school,
        classicBook: classicBook,
        panelConfig: config,
        createdAt: now,
        lastUpdatedAt: now,
      ),
    );
  }

  Future<List<UserSchoolProfileTableData>> listAll() {
    return (select(userSchoolProfileTable)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.lastUpdatedAt)]))
        .get();
  }

  Future<void> softDelete(String uuid) {
    return (update(userSchoolProfileTable)..where((t) => t.uuid.equals(uuid)))
        .write(UserSchoolProfileTableCompanion(deletedAt: Value(DateTime.now())));
  }
}
