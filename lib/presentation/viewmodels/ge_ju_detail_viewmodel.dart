import 'package:flutter/foundation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_annotation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition_set.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/errors/ge_ju_errors.dart';
import 'package:qizhengsiyu/domain/services/ge_ju_crud_service.dart';

/// 格局详情 ViewModel
///
/// 管理单个格局的详情展示，包括 Rule + Annotations + ConditionSets
class GeJuDetailViewModel extends ChangeNotifier {
  final GeJuCrudService _crudService;

  GeJuDetailViewModel({required GeJuCrudService crudService})
      : _crudService = crudService;

  // ========== 状态字段 ==========

  GeJuRule? _rule;
  List<GeJuAnnotation> _annotations = [];
  List<GeJuConditionSet> _conditionSets = [];

  bool _isLoading = false;
  String? _errorMessage;

  // ========== Getters ==========

  GeJuRule? get rule => _rule;
  List<GeJuAnnotation> get annotations => _annotations;
  List<GeJuConditionSet> get conditionSets => _conditionSets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 首个 Annotation（用于展示摘要信息）
  GeJuAnnotation? get primaryAnnotation =>
      _annotations.isNotEmpty ? _annotations.first : null;

  /// 是否为内置格局
  bool get isBuiltIn => _rule?.isBuiltIn ?? false;

  /// 是否可编辑（仅用户规则可编辑）
  bool get canEdit => _rule != null && !isBuiltIn;

  /// 内置注解列表
  List<GeJuAnnotation> get builtInAnnotations =>
      _annotations.where((a) => a.isBuiltIn).toList();

  /// 用户注解列表
  List<GeJuAnnotation> get userAnnotations =>
      _annotations.where((a) => a.isUser).toList();

  /// 内置判断方案列表
  List<GeJuConditionSet> get builtInConditionSets =>
      _conditionSets.where((cs) => cs.isBuiltIn).toList();

  /// 用户判断方案列表
  List<GeJuConditionSet> get userConditionSets =>
      _conditionSets.where((cs) => cs.isUser).toList();

  // ========== 核心方法 ==========

  /// 加载格局详情
  Future<bool> load(String ruleId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _rule = await _crudService.getRule(ruleId);
      if (_rule == null) {
        _errorMessage = '格局不存在';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _annotations = await _crudService.getAnnotationsForRule(ruleId);
      _conditionSets = await _crudService.getConditionSetsForRule(ruleId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e is GeJuError ? e.message : '加载格局详情失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Fork 判断方案（创建基于某内置/用户方案的用户副本）
  Future<GeJuConditionSet?> forkConditionSet(String csId) async {
    try {
      final forked = await _crudService.forkConditionSet(csId);
      _conditionSets.add(forked);
      notifyListeners();
      return forked;
    } catch (e) {
      _errorMessage = e is GeJuError ? e.message : 'Fork 失败: $e';
      notifyListeners();
      return null;
    }
  }

  /// 复制整个格局
  Future<GeJuRule?> duplicateRule() async {
    if (_rule == null) return null;
    try {
      final newRule = await _crudService.duplicateRule(_rule!.id);
      return newRule;
    } catch (e) {
      _errorMessage = e is GeJuError ? e.message : '复制失败: $e';
      notifyListeners();
      return null;
    }
  }

  /// 删除格局
  Future<bool> deleteRule() async {
    if (_rule == null) return false;
    try {
      await _crudService.deleteRule(_rule!.id);
      return true;
    } on BuiltInRuleModificationError {
      _errorMessage = '内置格局不可删除';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = '删除失败: $e';
      notifyListeners();
      return false;
    }
  }

  /// 删除用户判断方案
  Future<bool> deleteConditionSet(String csId) async {
    try {
      await _crudService.deleteConditionSet(csId);
      _conditionSets.removeWhere((cs) => cs.id == csId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '删除失败: $e';
      notifyListeners();
      return false;
    }
  }

  /// 删除用户注解
  Future<bool> deleteAnnotation(String annId) async {
    try {
      await _crudService.deleteAnnotation(annId);
      _annotations.removeWhere((a) => a.id == annId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '删除失败: $e';
      notifyListeners();
      return false;
    }
  }

  /// 清除错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
