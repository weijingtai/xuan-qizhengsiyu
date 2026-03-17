import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'ge_ju_builtin_database.g.dart';

/// 镜像 companion_system ge_ju_patterns 表（只读）
class BuiltinGeJuPatterns extends Table {
  @override
  String get tableName => 'ge_ju_patterns';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get aliases => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 镜像 companion_system ge_ju_schools 表（只读）
class BuiltinGeJuSchools extends Table {
  @override
  String get tableName => 'ge_ju_schools';

  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 镜像 companion_system ge_ju_rules 表 v3（只读，无 level 列）
class BuiltinGeJuRules extends Table {
  @override
  String get tableName => 'ge_ju_rules';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get patternId => text().named('pattern_id')();
  TextColumn get schoolId => text().named('school_id')();
  TextColumn get jixiong => text()();
  TextColumn get geJuType => text().named('ge_ju_type')();
  TextColumn get scope => text()();
  TextColumn get conditions => text().nullable()();
  TextColumn get brief => text().nullable()();
  TextColumn get explanation => text().nullable()();
  TextColumn get version => text()();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
}

@DriftDatabase(
    tables: [BuiltinGeJuPatterns, BuiltinGeJuSchools, BuiltinGeJuRules])
class GeJuBuiltInDatabase extends _$GeJuBuiltInDatabase {
  GeJuBuiltInDatabase(super.e);

  @override
  int get schemaVersion => 1;

  // 每次从 assets 覆盖，schema 始终最新，无需真正迁移
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {},
      onUpgrade: (Migrator m, int from, int to) async {},
    );
  }
}

/// 创建只读连接（每次启动从 assets 覆盖到 app support）
QueryExecutor createGeJuBuiltInConnection() {
  return LazyDatabase(() async {
    final supportDir = await getApplicationSupportDirectory();
    final dbFile = File(p.join(supportDir.path, 'ge_ju_builtin.sqlite'));

    final data = await rootBundle
        .load('assets/qizhengsiyu/ge_ju/ge_ju_database.sqlite');
    await dbFile.writeAsBytes(data.buffer.asUint8List());

    return NativeDatabase(dbFile, logStatements: false);
  });
}
