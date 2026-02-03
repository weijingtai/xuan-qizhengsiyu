import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/managers/ge_ju/ge_ju_rule_parser.dart';
import 'package:qizhengsiyu/domain/errors/ge_ju_errors.dart';

// 条件导入: Web 使用 stub，非 Web 使用真实实现
import 'ge_ju_file_storage_stub.dart'
    if (dart.library.io) 'ge_ju_file_storage_io.dart' as file_storage;

/// 格局本地数据源接口
abstract class GeJuLocalDataSource {
  Future<List<GeJuRule>> loadFromAssets(List<String> assetPaths);
  Future<List<GeJuRule>> loadFromUserFile();
  Future<void> saveToUserFile(List<GeJuRule> rules);
  Future<String> getUserRulesFilePath();
  Future<bool> userRulesFileExists();
}

/// 格局本地数据源实现
class GeJuLocalDataSourceImpl implements GeJuLocalDataSource {
  /// Web 平台内存缓存
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
  Future<List<GeJuRule>> loadFromUserFile() async {
    if (kIsWeb) {
      return _webUserRulesCache ?? [];
    }

    try {
      final content = await file_storage.readUserRulesFile();
      if (content == null || content.trim().isEmpty) {
        return [];
      }
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
