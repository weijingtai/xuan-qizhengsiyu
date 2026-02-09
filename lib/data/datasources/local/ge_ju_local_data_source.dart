import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_annotation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition_set.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_source.dart';
import 'package:qizhengsiyu/domain/errors/ge_ju_errors.dart';
import 'package:qizhengsiyu/domain/managers/ge_ju/ge_ju_rule_parser.dart';

// 条件导入: Web 使用 stub，非 Web 使用真实实现
import 'ge_ju_file_storage_stub.dart'
    if (dart.library.io) 'ge_ju_file_storage_io.dart' as file_storage;

/// 内置格局数据源接口（只读）
abstract class GeJuBuiltInDataSource {
  /// 加载 JSON 资源文件
  Future<List<Map<String, dynamic>>> loadJsonFromAsset(String assetPath);

  /// 从 assets 加载所有内置 Rule（薄锚点）
  Future<List<GeJuRule>> loadBuiltInRules();

  /// 从 assets 加载所有内置 Annotation（从 Variant 文字字段映射）
  Future<List<GeJuAnnotation>> loadBuiltInAnnotations();

  /// 从 assets 加载所有内置 ConditionSet（从 Variant 条件字段映射）
  Future<List<GeJuConditionSet>> loadBuiltInConditionSets();
}

/// Legacy: 格局本地数据源接口（保留用于旧用户文件迁移）
@Deprecated('Use GeJuBuiltInDataSource + GeJuDao instead')
abstract class GeJuLocalDataSource {
  Future<List<GeJuRule>> loadFromAssets(List<String> assetPaths);
  Future<List<Map<String, dynamic>>> loadJsonFromAsset(String assetPath);
  Future<List<GeJuRule>> loadFromUserFile();
  Future<void> saveToUserFile(List<GeJuRule> rules);
  Future<String> getUserRulesFilePath();
  Future<bool> userRulesFileExists();
}

/// 内置格局数据源实现
class GeJuBuiltInDataSourceImpl implements GeJuBuiltInDataSource {
  /// 内置规则资源路径列表
  static const List<String> _ruleAssetPaths = [
    'assets/qizhengsiyu/ge_ju/rules/jin_xing_ge_ju_rules.json',
    'assets/qizhengsiyu/ge_ju/rules/mu_xing_ge_ju_rules.json',
    'assets/qizhengsiyu/ge_ju/rules/shui_xing_ge_ju_rules.json',
    'assets/qizhengsiyu/ge_ju/rules/huo_xing_ge_ju_rules.json',
    'assets/qizhengsiyu/ge_ju/rules/tu_xing_ge_ju_rules.json',
    'assets/qizhengsiyu/ge_ju/rules/common_ge_ju_rules.json',
    'assets/qizhengsiyu/ge_ju/rules/ling_tai_ge_ju_rules.json',
    'assets/qizhengsiyu/ge_ju/rules/shi_san_bu_yi_ge_ju_rules.json',
    'assets/qizhengsiyu/ge_ju/rules/he_ge_ge_ju_rules.json',
    'assets/qizhengsiyu/ge_ju/rules/gui_ge_ge_ju_rules.json',
    'assets/qizhengsiyu/ge_ju/rules/xing_ge_zong_lun_rules.json',
    'assets/qizhengsiyu/ge_ju/rules/ge_ju_zong_lun_rules.json',
  ];

  static const List<String> _contentAssetPaths = [
    'assets/qizhengsiyu/ge_ju/content/jin_xing_ge_ju_content.json',
    'assets/qizhengsiyu/ge_ju/content/mu_xing_ge_ju_content.json',
    'assets/qizhengsiyu/ge_ju/content/shui_xing_ge_ju_content.json',
    'assets/qizhengsiyu/ge_ju/content/huo_xing_ge_ju_content.json',
    'assets/qizhengsiyu/ge_ju/content/tu_xing_ge_ju_content.json',
    'assets/qizhengsiyu/ge_ju/content/common_ge_ju_content.json',
    'assets/qizhengsiyu/ge_ju/content/ling_tai_ge_ju_content.json',
    'assets/qizhengsiyu/ge_ju/content/shi_san_bu_yi_ge_ju_content.json',
    'assets/qizhengsiyu/ge_ju/content/he_ge_ge_ju_content.json',
    'assets/qizhengsiyu/ge_ju/content/gui_ge_ge_ju_content.json',
    'assets/qizhengsiyu/ge_ju/content/xing_ge_zong_lun_content.json',
    'assets/qizhengsiyu/ge_ju/content/ge_ju_zong_lun_content.json',
  ];

  /// 已解析的内置规则缓存（旧 GeJuRule 含 variants，用于映射）
  List<GeJuRule>? _parsedRulesCache;

  /// 加载并合并 rules + content 为旧格式 GeJuRule（含 variants）
  Future<List<GeJuRule>> _loadMergedRules() async {
    if (_parsedRulesCache != null) return _parsedRulesCache!;

    // 1. Load Rules (logic) and Content (display)
    final ruleMapsList = await Future.wait(
        _ruleAssetPaths.map((path) => loadJsonFromAsset(path)));
    final contentMapsList = await Future.wait(
        _contentAssetPaths.map((path) => loadJsonFromAsset(path)));

    // 2. Index Rules by ID
    final rulesMap = <String, Map<String, dynamic>>{};
    for (final fileRules in ruleMapsList) {
      for (final rule in fileRules) {
        final id = rule['id'] as String?;
        if (id != null) rulesMap[id] = rule;
      }
    }

    // 3. Merge Content with Rules
    final allRules = <GeJuRule>[];
    for (final fileContent in contentMapsList) {
      for (final content in fileContent) {
        final id = content['id'] as String?;
        if (id == null) continue;

        final merged = Map<String, dynamic>.from(content);
        final ruleLogic = rulesMap[id];
        if (ruleLogic != null) {
          if (ruleLogic.containsKey('variants') &&
              merged.containsKey('variants')) {
            final contentVariants = merged['variants'] as List;
            final ruleVariants = ruleLogic['variants'] as List;
            for (int i = 0;
                i < contentVariants.length && i < ruleVariants.length;
                i++) {
              final cVariant = contentVariants[i] as Map<String, dynamic>;
              final rVariant = ruleVariants[i] as Map<String, dynamic>;
              if (rVariant.containsKey('conditions')) {
                cVariant['conditions'] = rVariant['conditions'];
              }
            }
          } else if (ruleLogic.containsKey('conditions') &&
              merged.containsKey('variants')) {
            final contentVariants = merged['variants'] as List;
            if (contentVariants.isNotEmpty) {
              (contentVariants[0] as Map<String, dynamic>)['conditions'] =
                  ruleLogic['conditions'];
            }
          } else if (ruleLogic.containsKey('conditions')) {
            merged['conditions'] = ruleLogic['conditions'];
          }
        }

        try {
          allRules.add(GeJuRule.fromJson(merged));
        } catch (e) {
          print('Error parsing rule $id: $e');
        }
      }
    }

    _parsedRulesCache = allRules;
    return allRules;
  }

  @override
  Future<List<Map<String, dynamic>>> loadJsonFromAsset(String assetPath) async {
    try {
      final content = await rootBundle.loadString(assetPath);
      if (content.trim().isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(content);
        return jsonList.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Warning: Failed to load json from $assetPath: $e');
    }
    return [];
  }

  @override
  Future<List<GeJuRule>> loadBuiltInRules() async {
    final mergedRules = await _loadMergedRules();
    // 返回规则本身（保留 variants 用于兼容，但 Rule 是薄锚点）
    return mergedRules;
  }

  @override
  Future<List<GeJuAnnotation>> loadBuiltInAnnotations() async {
    final mergedRules = await _loadMergedRules();
    final annotations = <GeJuAnnotation>[];
    final now = DateTime.now();

    for (final rule in mergedRules) {
      // ignore: deprecated_member_use_from_same_package
      final variants = rule.variants;
      for (int i = 0; i < variants.length; i++) {
        final variant = variants[i];
        annotations.add(GeJuAnnotation(
          id: '${rule.id}_ann_$i',
          ruleId: rule.id,
          schools: variant.schools.isNotEmpty ? variant.schools : null,
          source: variant.books.isNotEmpty
              ? GeJuSource(
                  bookName: variant.books,
                  school: variant.schools.isNotEmpty ? variant.schools.first : 'guolao',
                  section: variant.source.isNotEmpty ? variant.source : null,
                )
              : null,
          authorType: 'built-in',
          version: '1.0',
          description: variant.description,
          jiXiong: variant.jiXiong,
          geJuType: variant.geJuType,
          className: variant.className,
          createdAt: now,
          updatedAt: now,
        ));
      }
    }

    return annotations;
  }

  @override
  Future<List<GeJuConditionSet>> loadBuiltInConditionSets() async {
    final mergedRules = await _loadMergedRules();
    final conditionSets = <GeJuConditionSet>[];
    final now = DateTime.now();

    for (final rule in mergedRules) {
      // ignore: deprecated_member_use_from_same_package
      final variants = rule.variants;
      for (int i = 0; i < variants.length; i++) {
        final variant = variants[i];
        final schoolLabel = variant.schools.isNotEmpty
            ? variant.schools.first
            : 'guolao';
        conditionSets.add(GeJuConditionSet(
          id: '${rule.id}_cs_$i',
          ruleId: rule.id,
          label: '${schoolLabel}方案',
          schools: variant.schools.isNotEmpty ? variant.schools : null,
          source: variant.books.isNotEmpty
              ? GeJuSource(
                  bookName: variant.books,
                  school: schoolLabel,
                  section: variant.source.isNotEmpty ? variant.source : null,
                )
              : null,
          authorType: 'built-in',
          conditions: variant.conditions,
          createdAt: now,
          updatedAt: now,
        ));
      }
    }

    return conditionSets;
  }

  /// 清除缓存
  void clearCache() {
    _parsedRulesCache = null;
  }
}

/// Legacy: 格局本地数据源实现（保留用于旧用户文件迁移）
@Deprecated('Use GeJuBuiltInDataSourceImpl + GeJuDao instead')
class GeJuLocalDataSourceImpl implements GeJuLocalDataSource {
  List<GeJuRule>? _webUserRulesCache;

  @override
  Future<List<GeJuRule>> loadFromAssets(List<String> assetPaths) async {
    final allRules = <GeJuRule>[];
    for (final path in assetPaths) {
      try {
        final content = await rootBundle.loadString(path);
        if (content.trim().isNotEmpty) {
          final rules = GeJuRuleParser.parseRules(content);
          allRules.addAll(rules);
        }
      } catch (e) {
        print('Warning: Failed to load ge_ju rules from $path: $e');
      }
    }
    return allRules;
  }

  @override
  Future<List<Map<String, dynamic>>> loadJsonFromAsset(String assetPath) async {
    try {
      final content = await rootBundle.loadString(assetPath);
      if (content.trim().isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(content);
        return jsonList.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Warning: Failed to load json from $assetPath: $e');
    }
    return [];
  }

  @override
  Future<List<GeJuRule>> loadFromUserFile() async {
    if (kIsWeb) return _webUserRulesCache ?? [];
    try {
      final content = await file_storage.readUserRulesFile();
      if (content == null || content.trim().isEmpty) return [];
      return GeJuRuleParser.parseRules(content);
    } on FormatException catch (e) {
      throw RuleParseError('用户规则文件格式错误', details: e.message);
    } catch (e) {
      if (e is GeJuError) rethrow;
      throw RuleStorageError('无法读取用户规则文件', details: e.toString());
    }
  }

  @override
  Future<void> saveToUserFile(List<GeJuRule> rules) async {
    if (kIsWeb) {
      _webUserRulesCache = List.from(rules);
      return;
    }
    try {
      final jsonList = rules.map((rule) => rule.toJson()).toList();
      final content = const JsonEncoder.withIndent('  ').convert(jsonList);
      await file_storage.writeUserRulesFile(content);
    } catch (e) {
      if (e is GeJuError) rethrow;
      throw RuleStorageError('无法保存用户规则文件', details: e.toString());
    }
  }

  @override
  Future<String> getUserRulesFilePath() async {
    if (kIsWeb) return '';
    return file_storage.getUserRulesFilePath();
  }

  @override
  Future<bool> userRulesFileExists() async {
    if (kIsWeb) return _webUserRulesCache != null;
    return file_storage.userRulesFileExists();
  }
}
