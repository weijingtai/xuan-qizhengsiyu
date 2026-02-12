// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ge_ju_dao.dart';

// ignore_for_file: type=lint
mixin _$GeJuDaoMixin on DatabaseAccessor<AppDatabase> {
  $GeJuRulesTableTable get geJuRulesTable => attachedDatabase.geJuRulesTable;
  $GeJuAnnotationsTableTable get geJuAnnotationsTable =>
      attachedDatabase.geJuAnnotationsTable;
  $GeJuConditionSetsTableTable get geJuConditionSetsTable =>
      attachedDatabase.geJuConditionSetsTable;
  $GeJuUserPreferencesTableTable get geJuUserPreferencesTable =>
      attachedDatabase.geJuUserPreferencesTable;
  $GeJuDeletionRecordsTableTable get geJuDeletionRecordsTable =>
      attachedDatabase.geJuDeletionRecordsTable;
  $GeJuSchoolsTableTable get geJuSchoolsTable =>
      attachedDatabase.geJuSchoolsTable;
  GeJuDaoManager get managers => GeJuDaoManager(this);
}

class GeJuDaoManager {
  final _$GeJuDaoMixin _db;
  GeJuDaoManager(this._db);
  $$GeJuRulesTableTableTableManager get geJuRulesTable =>
      $$GeJuRulesTableTableTableManager(
          _db.attachedDatabase, _db.geJuRulesTable);
  $$GeJuAnnotationsTableTableTableManager get geJuAnnotationsTable =>
      $$GeJuAnnotationsTableTableTableManager(
          _db.attachedDatabase, _db.geJuAnnotationsTable);
  $$GeJuConditionSetsTableTableTableManager get geJuConditionSetsTable =>
      $$GeJuConditionSetsTableTableTableManager(
          _db.attachedDatabase, _db.geJuConditionSetsTable);
  $$GeJuUserPreferencesTableTableTableManager get geJuUserPreferencesTable =>
      $$GeJuUserPreferencesTableTableTableManager(
          _db.attachedDatabase, _db.geJuUserPreferencesTable);
  $$GeJuDeletionRecordsTableTableTableManager get geJuDeletionRecordsTable =>
      $$GeJuDeletionRecordsTableTableTableManager(
          _db.attachedDatabase, _db.geJuDeletionRecordsTable);
  $$GeJuSchoolsTableTableTableManager get geJuSchoolsTable =>
      $$GeJuSchoolsTableTableTableManager(
          _db.attachedDatabase, _db.geJuSchoolsTable);
}
