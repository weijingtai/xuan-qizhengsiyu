import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:qizhengsiyu/data/datasources/local/daos/ge_ju_dao.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_annotation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition_set.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_source.dart';
import 'package:uuid/uuid.dart';

// 条件导入: Web 使用 stub，非 Web 使用真实实现
import 'ge_ju_file_storage_stub.dart'
    if (dart.library.io) 'ge_ju_file_storage_io.dart' as file_storage;
import 'ge_ju_legacy_migrator_stub.dart'
    if (dart.library.io) 'ge_ju_legacy_migrator_io.dart' as migrator_io;

/// 旧格式用户规则 JSON → Drift DB 迁移器
///
/// 将 `{app_documents}/ge_ju/user_rules.json` 中的旧格式 GeJuRule
/// (含 variants) 迁移为三实体模型并存入 Drift DB。
class GeJuLegacyMigrator {
  final GeJuDao _dao;
  static const _uuid = Uuid();

  GeJuLegacyMigrator({required GeJuDao dao}) : _dao = dao;

  /// 检查并执行迁移（幂等）
  ///
  /// 如果旧 JSON 文件存在且未被标记为已迁移，则读取、转换、写入 DB。
  /// 成功后将旧文件重命名为 `.migrated.bak` 作为备份。
  Future<MigrationResult> migrateIfNeeded() async {
    if (kIsWeb) {
      return MigrationResult.skipped;
    }

    try {
      // 1. 检查旧文件是否存在
      final exists = await file_storage.userRulesFileExists();
      if (!exists) {
        return MigrationResult.skipped;
      }

      // 2. 读取旧文件内容
      final content = await file_storage.readUserRulesFile();
      if (content == null || content.trim().isEmpty) {
        return MigrationResult.skipped;
      }

      // 3. 解析旧格式规则
      final legacyRules = _parseLegacyRules(content);
      if (legacyRules.isEmpty) {
        await _markAsMigrated();
        return MigrationResult.skipped;
      }

      // 4. 检查 DB 中是否已有用户规则（避免重复迁移）
      final existingRules = await _dao.getAllRules();
      if (existingRules.isNotEmpty) {
        await _markAsMigrated();
        return MigrationResult.skipped;
      }

      // 5. 转换并写入 DB
      int rulesCount = 0;
      int annotationsCount = 0;
      int conditionSetsCount = 0;

      for (final rule in legacyRules) {
        // 只迁移用户创建的规则（ID 以 user_ 开头）
        if (!rule.id.startsWith('user_')) continue;

        // 转换 Rule（薄锚点）
        final newRule = GeJuRule(
          id: rule.id,
          name: rule.name,
          aliases: rule.aliases,
          disambiguationNote: rule.disambiguationNote,
          scope: rule.scope,
          coordinateSystem: rule.coordinateSystem,
          authorType: 'user',
          createdAt: rule.createdAt,
          updatedAt: rule.updatedAt,
        );
        await _dao.insertRule(newRule);
        rulesCount++;

        // 转换 Variants → Annotation + ConditionSet
        // ignore: deprecated_member_use_from_same_package
        final variants = rule.variants;
        for (int i = 0; i < variants.length; i++) {
          final variant = variants[i];
          final annId = 'user_${_uuid.v4()}';
          final csId = 'user_${_uuid.v4()}';
          final now = DateTime.now();

          GeJuSource? source;
          if (variant.books.isNotEmpty) {
            source = GeJuSource(
              bookName: variant.books,
              school: variant.schools.isNotEmpty ? variant.schools.first : 'user',
              section: variant.source.isNotEmpty ? variant.source : null,
            );
          }

          // Annotation
          final annotation = GeJuAnnotation(
            id: annId,
            ruleId: rule.id,
            schools: variant.schools.isNotEmpty ? variant.schools : null,
            source: source,
            authorType: 'user',
            version: '1.0',
            description: variant.description,
            jiXiong: variant.jiXiong,
            geJuType: variant.geJuType,
            className: variant.className,
            relatedConditionSetIds: [csId],
            createdAt: now,
            updatedAt: now,
          );
          await _dao.insertAnnotation(annotation);
          annotationsCount++;

          // ConditionSet
          final conditionSet = GeJuConditionSet(
            id: csId,
            ruleId: rule.id,
            label: variant.schools.isNotEmpty
                ? '${variant.schools.first}方案'
                : '默认方案',
            schools: variant.schools.isNotEmpty ? variant.schools : null,
            source: source,
            authorType: 'user',
            conditions: variant.conditions,
            relatedAnnotationIds: [annId],
            createdAt: now,
            updatedAt: now,
          );
          await _dao.insertConditionSet(conditionSet);
          conditionSetsCount++;
        }
      }

      // 6. 标记为已迁移（重命名旧文件）
      await _markAsMigrated();

      debugPrint('GeJu migration complete: $rulesCount rules, '
          '$annotationsCount annotations, $conditionSetsCount condition sets');

      return MigrationResult.migrated;
    } catch (e) {
      debugPrint('GeJu legacy migration error: $e');
      return MigrationResult.error;
    }
  }

  /// 解析旧格式规则 JSON
  List<GeJuRule> _parseLegacyRules(String content) {
    try {
      final decoded = jsonDecode(content);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((json) => GeJuRule.fromJson(json))
            .toList();
      } else if (decoded is Map<String, dynamic>) {
        return [GeJuRule.fromJson(decoded)];
      }
      return [];
    } catch (e) {
      debugPrint('Error parsing legacy rules: $e');
      return [];
    }
  }

  /// 将旧文件重命名为 .migrated.bak
  Future<void> _markAsMigrated() async {
    if (kIsWeb) return;
    try {
      await migrator_io.markUserRulesAsMigrated();
    } catch (e) {
      debugPrint('Warning: Could not rename legacy file: $e');
    }
  }
}

/// 迁移结果
enum MigrationResult {
  /// 跳过（无需迁移）
  skipped,
  /// 迁移成功
  migrated,
  /// 迁移出错（非致命，旧文件保留）
  error,
}
