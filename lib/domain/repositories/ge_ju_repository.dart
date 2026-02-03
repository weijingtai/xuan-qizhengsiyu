import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';

/// 格局仓库接口
/// 定义格局规则的数据访问操作
abstract class IGeJuRepository {
  /// 加载所有内置格局（只读）
  ///
  /// 从 assets 目录加载预置的格局规则，这些规则不可修改
  Future<List<GeJuRule>> loadBuiltInRules();

  /// 加载所有用户自定义格局
  ///
  /// 从用户文档目录加载用户创建的格局规则
  Future<List<GeJuRule>> loadUserRules();

  /// 加载全部格局（内置 + 用户）
  ///
  /// 合并内置规则和用户规则，内置规则在前
  Future<List<GeJuRule>> loadAllRules();

  /// 保存用户格局（新增或更新）
  ///
  /// [rule] 要保存的规则
  /// 如果规则 ID 已存在则更新，否则新增
  /// 对于内置规则会抛出 [BuiltInRuleModificationError]
  Future<void> saveUserRule(GeJuRule rule);

  /// 批量保存用户格局
  ///
  /// [rules] 要保存的规则列表
  Future<void> saveUserRules(List<GeJuRule> rules);

  /// 删除用户格局
  ///
  /// [ruleId] 要删除的规则 ID
  /// 对于内置规则会抛出 [BuiltInRuleModificationError]
  Future<void> deleteUserRule(String ruleId);

  /// 导出格局为 JSON 字符串
  ///
  /// [rules] 要导出的规则列表
  /// 返回格式化的 JSON 字符串
  Future<String> exportRules(List<GeJuRule> rules);

  /// 从 JSON 字符串导入格局
  ///
  /// [jsonContent] JSON 格式的规则数据
  /// 返回解析出的规则列表（会生成新的 ID 避免冲突）
  Future<List<GeJuRule>> importRules(String jsonContent);

  /// 判断规则是否为内置（不可编辑）
  ///
  /// [ruleId] 规则 ID
  bool isBuiltInRule(String ruleId);

  /// 获取指定 ID 的规则
  ///
  /// [ruleId] 规则 ID
  /// 如果规则不存在返回 null
  Future<GeJuRule?> getRuleById(String ruleId);

  /// 清除缓存
  ///
  /// 强制下次加载时重新读取文件
  void clearCache();

  /// 获取内置规则 ID 集合
  Set<String> get builtInRuleIds;
}
