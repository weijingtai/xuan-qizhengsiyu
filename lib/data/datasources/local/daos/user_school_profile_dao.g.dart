// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_school_profile_dao.dart';

// ignore_for_file: type=lint
mixin _$UserSchoolProfileDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserSchoolProfileTableTable get userSchoolProfileTable =>
      attachedDatabase.userSchoolProfileTable;
  UserSchoolProfileDaoManager get managers => UserSchoolProfileDaoManager(this);
}

class UserSchoolProfileDaoManager {
  final _$UserSchoolProfileDaoMixin _db;
  UserSchoolProfileDaoManager(this._db);
  $$UserSchoolProfileTableTableTableManager get userSchoolProfileTable =>
      $$UserSchoolProfileTableTableTableManager(
        _db.attachedDatabase,
        _db.userSchoolProfileTable,
      );
}
