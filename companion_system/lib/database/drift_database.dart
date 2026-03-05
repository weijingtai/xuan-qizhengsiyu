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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v1→v2: 将流派名从书名改为派名，新增流派
            await customStatement(
              "UPDATE ge_ju_schools SET name = '果老派' WHERE id = 'guo_lao'",
            );
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
          if (from < 3) {
            // v2→v3: 合并 jixiong + level 为 7 级单字段，删除 level 列
            await customStatement('''
              CREATE TABLE ge_ju_rules_v3 (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                pattern_id TEXT NOT NULL,
                school_id TEXT NOT NULL,
                jixiong TEXT NOT NULL,
                ge_ju_type TEXT NOT NULL,
                scope TEXT NOT NULL,
                coordinate_system TEXT,
                conditions TEXT,
                assertion TEXT,
                brief TEXT,
                chapter TEXT,
                original_text TEXT,
                explanation TEXT,
                notes TEXT,
                version TEXT NOT NULL,
                version_remark TEXT,
                is_active INTEGER NOT NULL DEFAULT 1,
                is_verified INTEGER NOT NULL DEFAULT 0,
                priority INTEGER NOT NULL DEFAULT 0,
                view_count INTEGER NOT NULL DEFAULT 0,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL,
                UNIQUE(pattern_id, school_id)
              )
            ''');
            await customStatement('''
              INSERT INTO ge_ju_rules_v3
              SELECT id, pattern_id, school_id,
                CASE
                  WHEN jixiong = '平' THEN '平'
                  WHEN level = '大' AND jixiong = '吉' THEN '大吉'
                  WHEN level = '中' AND jixiong = '吉' THEN '吉'
                  WHEN level = '小' AND jixiong = '吉' THEN '小吉'
                  WHEN level = '小' AND jixiong = '凶' THEN '小凶'
                  WHEN level = '中' AND jixiong = '凶' THEN '凶'
                  WHEN level = '大' AND jixiong = '凶' THEN '大凶'
                  ELSE '平'
                END,
                ge_ju_type, scope, coordinate_system, conditions, assertion,
                brief, chapter, original_text, explanation, notes, version,
                version_remark, is_active, is_verified, priority, view_count,
                created_at, updated_at
              FROM ge_ju_rules
            ''');
            await customStatement('DROP TABLE ge_ju_rules');
            await customStatement(
                'ALTER TABLE ge_ju_rules_v3 RENAME TO ge_ju_rules');
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
