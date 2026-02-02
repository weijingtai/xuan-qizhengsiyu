import 'package:common/enums.dart';
import 'package:flutter/services.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/eleven_stars_info.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_input.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_result.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/managers/ge_ju/ge_ju_evaluator.dart';
import 'package:qizhengsiyu/domain/managers/ge_ju/ge_ju_input_builder.dart';
import 'package:qizhengsiyu/domain/managers/ge_ju/ge_ju_rule_parser.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

/// 格局管理器
/// 提供格局判断系统的统一入口
class GeJuManager {
  /// 已加载的规则缓存
  static List<GeJuRule>? _cachedRules;

  /// 规则文件路径列表
  static const List<String> _defaultRulePaths = [
    'assets/qizhengsiyu/ge_ju/mu_xing_ge_ju.json',
    'assets/qizhengsiyu/ge_ju/huo_xing_ge_ju.json',
    'assets/qizhengsiyu/ge_ju/tu_xing_ge_ju.json',
    'assets/qizhengsiyu/ge_ju/jin_xing_ge_ju.json',
    'assets/qizhengsiyu/ge_ju/shui_xing_ge_ju.json',
    'assets/qizhengsiyu/ge_ju/common_ge_ju.json',
  ];

  /// 加载所有规则文件
  ///
  /// [assetPaths] 规则文件路径列表，默认使用内置路径
  /// [forceReload] 是否强制重新加载（忽略缓存）
  static Future<List<GeJuRule>> loadRules({
    List<String>? assetPaths,
    bool forceReload = false,
  }) async {
    if (_cachedRules != null && !forceReload) {
      return _cachedRules!;
    }

    final paths = assetPaths ?? _defaultRulePaths;
    final allRules = <GeJuRule>[];

    for (var path in paths) {
      try {
        final content = await rootBundle.loadString(path);
        final rules = GeJuRuleParser.parseRules(content);
        allRules.addAll(rules);
      } catch (e) {
        // 文件不存在或解析错误时跳过，继续加载其他文件
        print('Warning: Failed to load ge_ju rules from $path: $e');
      }
    }

    _cachedRules = allRules;
    return allRules;
  }

  /// 从 JSON 字符串直接加载规则
  static List<GeJuRule> loadRulesFromJson(String jsonContent) {
    return GeJuRuleParser.parseRules(jsonContent);
  }

  /// 加载单个规则文件
  static Future<List<GeJuRule>> loadRulesFromAsset(String assetPath) async {
    final content = await rootBundle.loadString(assetPath);
    return GeJuRuleParser.parseRules(content);
  }

  /// 清除缓存的规则
  static void clearCache() {
    _cachedRules = null;
  }

  /// 评估命盘格局（核心方法）
  ///
  /// [panelModel] 基础命盘模型
  /// [starsSet] 十一颗星体信息
  /// [monthZhi] 出生月地支
  /// [yearJiaZi] 出生年甲子
  /// [coordinateSystem] 坐标系统
  /// [rules] 可选，自定义规则列表；如果不提供则使用已加载的规则
  static Future<GeJuEvaluationSummary> evaluateNatalChart({
    required BasePanelModel panelModel,
    required Set<ElevenStarsInfo> starsSet,
    required DiZhi monthZhi,
    required JiaZi yearJiaZi,
    CelestialCoordinateSystem coordinateSystem = CelestialCoordinateSystem.ecliptic,
    List<GeJuRule>? rules,
  }) async {
    // 1. 获取规则
    final ruleList = rules ?? await loadRules();

    // 2. 构建输入
    final input = GeJuInputBuilder.buildFromPanel(
      panelModel: panelModel,
      starsSet: starsSet,
      monthZhi: monthZhi,
      yearJiaZi: yearJiaZi,
      coordinateSystem: coordinateSystem,
    );

    // 3. 评估
    return GeJuEvaluator.evaluate(input: input, rules: ruleList);
  }

  /// 评估行限格局
  ///
  /// [panelModel] 基础命盘模型
  /// [starsSet] 十一颗星体信息
  /// [monthZhi] 出生月地支
  /// [yearJiaZi] 出生年甲子
  /// [xianGong] 当前行限所在宫位
  /// [xianConstellation] 当前行限所在星宿
  /// [coordinateSystem] 坐标系统
  /// [rules] 可选，自定义规则列表
  static Future<GeJuEvaluationSummary> evaluateXingXianChart({
    required BasePanelModel panelModel,
    required Set<ElevenStarsInfo> starsSet,
    required DiZhi monthZhi,
    required JiaZi yearJiaZi,
    required EnumTwelveGong xianGong,
    required Enum28Constellations xianConstellation,
    CelestialCoordinateSystem coordinateSystem = CelestialCoordinateSystem.ecliptic,
    List<GeJuRule>? rules,
  }) async {
    // 1. 获取规则
    final ruleList = rules ?? await loadRules();

    // 2. 构建输入（包含行限数据）
    final input = GeJuInputBuilder.buildForXingXian(
      panelModel: panelModel,
      starsSet: starsSet,
      monthZhi: monthZhi,
      yearJiaZi: yearJiaZi,
      xianGong: xianGong,
      xianConstellation: xianConstellation,
      coordinateSystem: coordinateSystem,
    );

    // 3. 评估（仅评估 xingxian 和 both scope 的规则）
    return GeJuEvaluator.evaluate(input: input, rules: ruleList);
  }

  /// 快速获取匹配的格局列表
  static Future<List<GeJuResult>> getMatchedPatterns({
    required BasePanelModel panelModel,
    required Set<ElevenStarsInfo> starsSet,
    required DiZhi monthZhi,
    required JiaZi yearJiaZi,
    CelestialCoordinateSystem coordinateSystem = CelestialCoordinateSystem.ecliptic,
  }) async {
    final summary = await evaluateNatalChart(
      panelModel: panelModel,
      starsSet: starsSet,
      monthZhi: monthZhi,
      yearJiaZi: yearJiaZi,
      coordinateSystem: coordinateSystem,
    );
    return summary.matchedPatterns;
  }

  /// 使用已构建的 GeJuInput 直接评估（高级用法）
  static Future<GeJuEvaluationSummary> evaluateWithInput({
    required GeJuInput input,
    List<GeJuRule>? rules,
  }) async {
    final ruleList = rules ?? await loadRules();
    return GeJuEvaluator.evaluate(input: input, rules: ruleList);
  }

  /// 获取规则统计信息
  static Future<Map<String, dynamic>> getRuleStatistics() async {
    final rules = await loadRules();

    final byScope = <String, int>{};
    final byJiXiong = <String, int>{};
    final byType = <String, int>{};

    for (var rule in rules) {
      byScope[rule.scope.name] = (byScope[rule.scope.name] ?? 0) + 1;
      byJiXiong[rule.jiXiong.name] = (byJiXiong[rule.jiXiong.name] ?? 0) + 1;
      byType[rule.geJuType.name] = (byType[rule.geJuType.name] ?? 0) + 1;
    }

    return {
      'totalRules': rules.length,
      'byScope': byScope,
      'byJiXiong': byJiXiong,
      'byType': byType,
    };
  }
}
