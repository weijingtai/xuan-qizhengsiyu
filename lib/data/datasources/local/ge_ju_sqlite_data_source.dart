import 'dart:convert';

import 'package:common/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:qizhengsiyu/data/datasources/local/ge_ju_builtin_database.dart';
import 'package:qizhengsiyu/data/datasources/local/ge_ju_local_data_source.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_alias.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_annotation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition_set.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_source.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju_model.dart';

/// companion_system SQLite → 主项目三实体模型 数据源
class GeJuSQLiteDataSource implements GeJuBuiltInDataSource {
  final GeJuBuiltInDatabase _db;

  GeJuSQLiteDataSource(this._db);

  // jixiong 字符串 → JiXiongEnum（xuan-common）
  static JiXiongEnum? _toJiXiong(String value) =>
      JiXiongEnum.fromName(value) == JiXiongEnum.WEI_ZHI
          ? null
          : JiXiongEnum.fromName(value);

  // ge_ju_type 字符串 → GeJuType（通过 JsonValue）
  static const _geJuTypeMap = <String, GeJuType>{
    '贵': GeJuType.gui,
    '富': GeJuType.fu,
    '贫': GeJuType.pin,
    '贱': GeJuType.jian,
    '夭': GeJuType.yao,
    '寿': GeJuType.shou,
    '贤': GeJuType.xian,
    '愚': GeJuType.yu,
    '其他': GeJuType.other,
  };

  @override
  Future<List<GeJuRule>> loadBuiltInRules() async {
    final rows = await _db.select(_db.builtinGeJuPatterns).get();
    final now = DateTime.now();
    return rows.map((row) {
      List<GeJuAlias> aliases = [];
      if (row.aliases != null && row.aliases!.isNotEmpty) {
        try {
          final list = jsonDecode(row.aliases!) as List<dynamic>;
          aliases = list
              .whereType<String>()
              .map((name) => GeJuAlias(name: name))
              .toList();
        } catch (_) {}
      }
      return GeJuRule(
        id: row.id,
        name: row.name,
        aliases: aliases,
        scope: GeJuScope.natal,
        authorType: 'built-in',
        createdAt: now,
        updatedAt: now,
      );
    }).toList();
  }

  @override
  Future<List<GeJuAnnotation>> loadBuiltInAnnotations() async {
    final rows = await (_db.select(_db.builtinGeJuRules)
          ..where((t) => t.isActive.equals(true)))
        .get();
    final now = DateTime.now();
    return rows.map((row) {
      return GeJuAnnotation(
        id: 'builtin_ann_${row.id}',
        ruleId: row.patternId,
        schools: [row.schoolId],
        source: GeJuSource(
          bookName: row.schoolId,
          school: row.schoolId,
        ),
        authorType: 'built-in',
        version: row.version,
        description: row.brief ?? row.explanation,
        jiXiong: _toJiXiong(row.jixiong),
        geJuType: _geJuTypeMap[row.geJuType],
        createdAt: now,
        updatedAt: now,
      );
    }).toList();
  }

  @override
  Future<List<GeJuConditionSet>> loadBuiltInConditionSets() async {
    final rows = await (_db.select(_db.builtinGeJuRules)
          ..where((t) => t.isActive.equals(true)))
        .get();
    final now = DateTime.now();
    return rows.map((row) {
      GeJuCondition? conditions;
      if (row.conditions != null && row.conditions!.isNotEmpty) {
        try {
          conditions = GeJuCondition.fromJson(
              jsonDecode(row.conditions!) as Map<String, dynamic>);
        } catch (e) {
          debugPrint('GeJu: failed to parse conditions for rule ${row.patternId} '
              '(builtin_cs_${row.id}): $e');
        }
      }
      return GeJuConditionSet(
        id: 'builtin_cs_${row.id}',
        ruleId: row.patternId,
        label: '${row.schoolId}方案',
        schools: [row.schoolId],
        source: GeJuSource(
          bookName: row.schoolId,
          school: row.schoolId,
        ),
        authorType: 'built-in',
        conditions: conditions,
        createdAt: now,
        updatedAt: now,
      );
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> loadJsonFromAsset(String assetPath) async {
    // 保留兼容接口，不再从 JSON 加载
    try {
      final content = await rootBundle.loadString(assetPath);
      if (content.trim().isNotEmpty) {
        final list = jsonDecode(content) as List<dynamic>;
        return list.cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }
}
