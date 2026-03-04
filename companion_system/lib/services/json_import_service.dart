/// JSON 格局数据导入服务
library;

import 'dart:convert';
import 'dart:io';

import 'package:companion_system/database/drift_database.dart';
import 'package:drift/drift.dart' show Value, InsertMode;

class ImportResult {
  final int patternsImported;
  final int rulesImported;
  final int categoriesCreated;
  final int schoolsCreated;
  final int skipped;
  final List<String> errors;

  const ImportResult({
    required this.patternsImported,
    required this.rulesImported,
    required this.categoriesCreated,
    required this.schoolsCreated,
    required this.skipped,
    required this.errors,
  });
}

class JsonImportService {
  final AppDatabase db;

  JsonImportService(this.db);

  // 已知流派名称 → ID 映射
  static const _schoolIdMap = {
    '果老星宗': 'guo_lao',
    '董氏七政': 'dongshi',
    '紫微斗数': 'ziwei',
  };

  // 已知分类名称 → ID 映射
  static const _categoryIdMap = {
    '通用格局': 'common',
    '星曜格局': 'mutually',
  };

  /// 从文件夹路径导入所有 *ge_ju*.json 文件
  Future<ImportResult> importFromDirectory(
    String dirPath, {
    void Function(String currentFile, int total, int done)? onProgress,
  }) async {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      return ImportResult(
        patternsImported: 0,
        rulesImported: 0,
        categoriesCreated: 0,
        schoolsCreated: 0,
        skipped: 0,
        errors: ['目录不存在: $dirPath'],
      );
    }

    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();

    return _importFiles(files, onProgress: onProgress);
  }

  /// 从指定文件列表导入
  Future<ImportResult> importFromFiles(
    List<String> filePaths, {
    void Function(String currentFile, int total, int done)? onProgress,
  }) async {
    final files = filePaths.map((p) => File(p)).toList();
    return _importFiles(files, onProgress: onProgress);
  }

  Future<ImportResult> _importFiles(
    List<File> files, {
    void Function(String currentFile, int total, int done)? onProgress,
  }) async {
    int patternsImported = 0;
    int rulesImported = 0;
    int categoriesCreated = 0;
    int schoolsCreated = 0;
    int skipped = 0;
    final errors = <String>[];

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final fileName = file.uri.pathSegments.last;
      onProgress?.call(fileName, files.length, i);

      try {
        final content = await file.readAsString();
        final List<dynamic> records = json.decode(content) as List;

        for (final raw in records) {
          final map = raw as Map<String, dynamic>;
          try {
            final result = await _importRecord(map);
            patternsImported += result.$1;
            rulesImported += result.$2;
            categoriesCreated += result.$3;
            schoolsCreated += result.$4;
            skipped += result.$5;
          } catch (e) {
            final id = map['id'] ?? '?';
            errors.add('记录 $id: $e');
            skipped++;
          }
        }
      } catch (e) {
        errors.add('文件 $fileName: $e');
      }
    }

    onProgress?.call('完成', files.length, files.length);

    return ImportResult(
      patternsImported: patternsImported,
      rulesImported: rulesImported,
      categoriesCreated: categoriesCreated,
      schoolsCreated: schoolsCreated,
      skipped: skipped,
      errors: errors,
    );
  }

  /// 返回 (patternsInserted, rulesInserted, categoriesCreated, schoolsCreated, skipped)
  Future<(int, int, int, int, int)> _importRecord(
      Map<String, dynamic> map) async {
    final id = map['id'] as String;
    final name = map['name'] as String;
    final className = map['className'] as String? ?? '通用格局';
    final books = map['books'] as String? ?? '自定义';
    final source = map['source'] as String?;
    final description = map['description'] as String?;
    final jiXiongRaw = map['jiXiong'] as String? ?? '未知';
    final geJuType = _normalizeGeJuType(map['geJuType'] as String? ?? '贵');
    final scope = map['scope'] as String? ?? 'both';
    final conditionsRaw = map['conditions'];

    // 1. 确保分类存在
    final (categoryId, catCreated) = await _ensureCategory(className);

    // 2. 确保流派存在
    final (schoolId, schoolCreated) = await _ensureSchool(books);

    // 3. 拆分 jiXiong
    final (jixiong, level) = _splitJixiong(jiXiongRaw);

    // 4. conditions → JSON 字符串
    final conditionsStr =
        conditionsRaw != null ? json.encode(conditionsRaw) : null;

    final now = DateTime.now();

    // 5. 插入 Pattern（忽略重复）
    final patternCompanion = GeJuPatternsCompanion.insert(
      id: id,
      name: name,
      categoryId: categoryId,
      createdAt: now,
      description: Value(description),
    );
    final patternRows = await db
        .into(db.geJuPatterns)
        .insert(patternCompanion, mode: InsertMode.insertOrIgnore);
    final patternInserted = patternRows > 0 ? 1 : 0;
    if (patternRows == 0) {
      // Pattern 已存在，Rule 也跳过
      return (0, 0, catCreated ? 1 : 0, schoolCreated ? 1 : 0, 1);
    }

    // 6. 插入 Rule（忽略重复）
    final ruleCompanion = GeJuRulesCompanion.insert(
      patternId: id,
      schoolId: schoolId,
      jixiong: jixiong,
      level: level,
      geJuType: geJuType,
      scope: scope,
      version: '1.0.0',
      createdAt: now,
      updatedAt: now,
      chapter: Value(source),
      conditions: Value(conditionsStr),
    );
    final ruleRows = await db
        .into(db.geJuRules)
        .insert(ruleCompanion, mode: InsertMode.insertOrIgnore);
    final ruleInserted = ruleRows > 0 ? 1 : 0;

    return (
      patternInserted,
      ruleInserted,
      catCreated ? 1 : 0,
      schoolCreated ? 1 : 0,
      0,
    );
  }

  /// 确保分类存在，返回 (categoryId, wasCreated)
  Future<(String, bool)> _ensureCategory(String className) async {
    final id = _categoryIdMap[className] ?? _slugify(className);
    final existing = await (db.select(db.geJuCategories)
          ..where((c) => c.id.equals(id)))
        .getSingleOrNull();
    if (existing != null) return (id, false);

    await db.into(db.geJuCategories).insert(
          GeJuCategoriesCompanion.insert(
            id: id,
            name: className,
            createdAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrIgnore,
        );
    return (id, true);
  }

  /// 确保流派存在，返回 (schoolId, wasCreated)
  Future<(String, bool)> _ensureSchool(String books) async {
    final id = _schoolIdMap[books] ?? _slugify(books);
    final existing = await (db.select(db.geJuSchools)
          ..where((s) => s.id.equals(id)))
        .getSingleOrNull();
    if (existing != null) return (id, false);

    await db.into(db.geJuSchools).insert(
          GeJuSchoolsCompanion.insert(
            id: id,
            name: books,
            type: 'book',
            createdAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrIgnore,
        );
    return (id, true);
  }

  /// jiXiong 拆分为 (jixiong, level)
  (String, String) _splitJixiong(String raw) {
    return switch (raw) {
      '大吉' => ('吉', '大'),
      '吉' => ('吉', '中'),
      '小吉' => ('吉', '小'),
      '平' => ('平', '中'),
      '小凶' => ('凶', '小'),
      '凶' => ('凶', '中'),
      '大凶' => ('凶', '大'),
      _ => ('平', '中'), // 未知
    };
  }

  /// geJuType 规范化（数据库 TEXT 字段，直接存字符串）
  String _normalizeGeJuType(String raw) {
    const valid = {'贵', '富', '贫', '贱', '夭', '寿', '贤', '愚'};
    return valid.contains(raw) ? raw : '贵';
  }

  /// 中文名称 → slug ID（取首个汉字拼音首字母 + 时间戳兜底）
  String _slugify(String name) {
    // 简单映射：移除标点，取前8个字，转小写+下划线
    final clean = name
        .replaceAll(RegExp(r'[^\u4e00-\u9fa5a-zA-Z0-9]'), '')
        .toLowerCase();
    if (clean.isEmpty) {
      return 'cat_${DateTime.now().millisecondsSinceEpoch}';
    }
    // 用 Unicode 码点生成简短确定性 ID
    final code = clean.codeUnits
        .take(4)
        .map((c) => c.toRadixString(16))
        .join('_');
    return 'c_$code';
  }
}
