import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'drift_database.g.dart';

@DriftDatabase(tables: [
  GeJuPatterns,
  GeJuSchools,
  GeJuRules,
  GeJuVersions,
  GeJuCategories,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openDatabase());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // 1. 将流派名从书名改为派名
            await customStatement(
              "UPDATE ge_ju_schools SET name = '果老派' WHERE id = 'guo_lao'",
            );

            // 2. 清理章节字段：移除"果老星宗·"和"果老星宗"，若仅剩《》则置null
            await customStatement('''
              UPDATE ge_ju_rules
              SET chapter = CASE
                WHEN REPLACE(REPLACE(chapter, '果老星宗·', ''), '果老星宗', '') IN ('《》', '')
                  THEN NULL
                ELSE REPLACE(REPLACE(chapter, '果老星宗·', ''), '果老星宗', '')
              END
              WHERE chapter IS NOT NULL
                AND (chapter LIKE '%果老星宗·%' OR chapter LIKE '%果老星宗%')
            ''');

            // 3. 新增流派（若不存在）
            final nowMs = DateTime.now().millisecondsSinceEpoch ~/ 1000;
            await customStatement(
              "INSERT OR IGNORE INTO ge_ju_schools (id, name, type, is_active, rule_count, created_at) "
              "VALUES ('qin_tang', '琴堂派', 'school', 1, 0, $nowMs)",
            );
            await customStatement(
              "INSERT OR IGNORE INTO ge_ju_schools (id, name, type, is_active, rule_count, created_at) "
              "VALUES ('tian_guan', '天官派', 'school', 1, 0, $nowMs)",
            );
          }
        },
      );
}

QueryExecutor _openDatabase() {
  return LazyDatabase(() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(docsDir.path, 'ge_ju_database.sqlite'));

    // 每次启动都从 assets 覆盖，以 assets 版本为唯一数据源
    final data = await rootBundle.load('assets/ge_ju_database.sqlite');
    await dbFile.writeAsBytes(data.buffer.asUint8List());

    return NativeDatabase(dbFile);
  });
}
