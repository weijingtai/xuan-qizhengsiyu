import 'dart:convert';

import 'package:qizhengsiyu/data/datasources/local/ge_ju_local_data_source.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/errors/ge_ju_errors.dart';
import 'package:qizhengsiyu/domain/managers/ge_ju/ge_ju_rule_parser.dart';
import 'package:qizhengsiyu/domain/repositories/ge_ju_repository.dart';
import 'package:uuid/uuid.dart';

/// 格局仓库实现
class GeJuRepositoryImpl implements IGeJuRepository {
  final GeJuLocalDataSource _localDataSource;

  /// 内置规则资源路径列表
  static const List<String> _builtInAssetPaths = [
    'assets/qizhengsiyu/ge_ju/mu_xing_ge_ju.json',
    'assets/qizhengsiyu/ge_ju/huo_xing_ge_ju.json',
    'assets/qizhengsiyu/ge_ju/tu_xing_ge_ju.json',
    'assets/qizhengsiyu/ge_ju/jin_xing_ge_ju.json',
    'assets/qizhengsiyu/ge_ju/shui_xing_ge_ju.json',
    'assets/qizhengsiyu/ge_ju/common_ge_ju.json',
  ];

  /// 内置规则缓存
  List<GeJuRule>? _builtInRulesCache;

  /// 用户规则缓存
  List<GeJuRule>? _userRulesCache;

  /// 内置规则 ID 集合
  final Set<String> _builtInRuleIds = {};

  static const _uuid = Uuid();

  GeJuRepositoryImpl({required GeJuLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<List<GeJuRule>> loadBuiltInRules() async {
    if (_builtInRulesCache != null) {
      return _builtInRulesCache!;
    }

    final rules = await _localDataSource.loadFromAssets(_builtInAssetPaths);

    // 记录所有内置规则的 ID
    _builtInRuleIds.clear();
    for (final rule in rules) {
      _builtInRuleIds.add(rule.id);
    }

    _builtInRulesCache = rules;
    return rules;
  }

  @override
  Future<List<GeJuRule>> loadUserRules() async {
    if (_userRulesCache != null) {
      return _userRulesCache!;
    }

    final rules = await _localDataSource.loadFromUserFile();
    _userRulesCache = rules;
    return rules;
  }

  @override
  Future<List<GeJuRule>> loadAllRules() async {
    final builtIn = await loadBuiltInRules();
    final user = await loadUserRules();
    return [...builtIn, ...user];
  }

  @override
  Future<void> saveUserRule(GeJuRule rule) async {
    if (isBuiltInRule(rule.id)) {
      throw BuiltInRuleModificationError(rule.id);
    }

    // 加载现有用户规则
    final existingRules = List<GeJuRule>.from(await loadUserRules());

    // 查找是否已存在，存在则替换
    final index = existingRules.indexWhere((r) => r.id == rule.id);
    if (index >= 0) {
      existingRules[index] = rule;
    } else {
      existingRules.add(rule);
    }

    // 保存并更新缓存
    await _localDataSource.saveToUserFile(existingRules);
    _userRulesCache = existingRules;
  }

  @override
  Future<void> saveUserRules(List<GeJuRule> rules) async {
    // 检查是否有内置规则
    for (final rule in rules) {
      if (isBuiltInRule(rule.id)) {
        throw BuiltInRuleModificationError(rule.id);
      }
    }

    await _localDataSource.saveToUserFile(rules);
    _userRulesCache = rules;
  }

  @override
  Future<void> deleteUserRule(String ruleId) async {
    if (isBuiltInRule(ruleId)) {
      throw BuiltInRuleModificationError(ruleId);
    }

    final existingRules = List<GeJuRule>.from(await loadUserRules());
    existingRules.removeWhere((r) => r.id == ruleId);

    // 如果规则不存在（包括已被删除的情况），不需要抛异常
    await _localDataSource.saveToUserFile(existingRules);
    _userRulesCache = existingRules;
  }

  @override
  Future<String> exportRules(List<GeJuRule> rules) async {
    final jsonList = rules.map((rule) => rule.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(jsonList);
  }

  @override
  Future<List<GeJuRule>> importRules(String jsonContent) async {
    try {
      final parsed = GeJuRuleParser.parseRules(jsonContent);

      // 为每条导入的规则生成新 UUID，避免 ID 冲突
      final importedRules = parsed.map((rule) {
        return GeJuRule(
          id: 'user_${_uuid.v4()}',
          name: rule.name,
          className: rule.className,
          books: rule.books,
          description: rule.description,
          source: rule.source,
          jiXiong: rule.jiXiong,
          geJuType: rule.geJuType,
          scope: rule.scope,
          conditions: rule.conditions,
          coordinateSystem: rule.coordinateSystem,
        );
      }).toList();

      return importedRules;
    } on FormatException catch (e) {
      throw RuleImportError('JSON 格式错误', details: e.message);
    } catch (e) {
      if (e is GeJuError) rethrow;
      throw RuleImportError('导入失败', details: e.toString());
    }
  }

  @override
  bool isBuiltInRule(String ruleId) {
    return _builtInRuleIds.contains(ruleId);
  }

  @override
  Future<GeJuRule?> getRuleById(String ruleId) async {
    final allRules = await loadAllRules();
    try {
      return allRules.firstWhere((r) => r.id == ruleId);
    } catch (_) {
      return null;
    }
  }

  @override
  void clearCache() {
    _builtInRulesCache = null;
    _userRulesCache = null;
  }

  @override
  Set<String> get builtInRuleIds => Set.unmodifiable(_builtInRuleIds);
}
