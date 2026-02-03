import 'package:common/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju_model.dart';
import 'package:qizhengsiyu/domain/errors/ge_ju_errors.dart';
import 'package:qizhengsiyu/domain/services/ge_ju_crud_service.dart';
import 'package:qizhengsiyu/domain/services/ge_ju_validation.dart';
import 'package:qizhengsiyu/presentation/models/condition_editor_node.dart';

/// 格局编辑器 ViewModel
///
/// 管理格局编辑器的状态，包括表单字段、条件树、验证等
class GeJuEditorViewModel extends ChangeNotifier {
  final GeJuCrudService _crudService;

  GeJuEditorViewModel({required GeJuCrudService crudService})
      : _crudService = crudService;

  // ========== 模式与原始数据 ==========

  /// 是否为创建模式（否则为编辑模式）
  bool _isCreateMode = true;

  /// 正在编辑的规则 ID（编辑模式时有值）
  String? _editingRuleId;

  /// 原始规则（编辑模式时保存原始数据，用于检测变更）
  GeJuRule? _originalRule;

  // ========== 表单状态 ==========

  String _name = '';
  String _className = '自定义';
  String _books = '';
  String _description = '';
  String _source = '';
  JiXiongEnum _jiXiong = JiXiongEnum.PING;
  GeJuType _geJuType = GeJuType.pin;
  GeJuScope _scope = GeJuScope.natal;

  /// 条件树根节点
  ConditionEditorNode? _rootConditionNode;

  // ========== UI 状态 ==========

  /// 验证结果
  ValidationResult? _validationResult;

  /// 是否有未保存的修改
  bool _hasUnsavedChanges = false;

  /// 保存中状态
  bool _isSaving = false;

  /// 保存错误信息
  String? _saveError;

  // ========== Getters ==========

  bool get isCreateMode => _isCreateMode;
  String? get editingRuleId => _editingRuleId;
  bool get isBuiltIn =>
      _editingRuleId != null && _crudService.isBuiltInRule(_editingRuleId!);

  String get name => _name;
  String get className => _className;
  String get books => _books;
  String get description => _description;
  String get source => _source;
  JiXiongEnum get jiXiong => _jiXiong;
  GeJuType get geJuType => _geJuType;
  GeJuScope get scope => _scope;
  ConditionEditorNode? get rootConditionNode => _rootConditionNode;

  ValidationResult? get validationResult => _validationResult;
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  bool get isSaving => _isSaving;
  String? get saveError => _saveError;

  /// 是否可以保存
  bool get canSave {
    if (_isSaving) return false;
    if (isBuiltIn) return false; // 内置规则不可编辑
    final validation = validate();
    return validation.isValid;
  }

  /// 页面标题
  String get pageTitle {
    if (_isCreateMode) return '新建格局';
    if (isBuiltIn) return '查看格局';
    return '编辑格局';
  }

  // ========== 初始化方法 ==========

  /// 初始化为创建模式
  void initForCreate() {
    _isCreateMode = true;
    _editingRuleId = null;
    _originalRule = null;
    _resetForm();
    notifyListeners();
  }

  /// 初始化为编辑模式
  Future<bool> initForEdit(String ruleId) async {
    try {
      final rule = await _crudService.getRule(ruleId);
      if (rule == null) {
        _saveError = '格局不存在';
        notifyListeners();
        return false;
      }

      _isCreateMode = false;
      _editingRuleId = ruleId;
      _originalRule = rule;
      _loadFromRule(rule);
      _hasUnsavedChanges = false;
      _validationResult = null;
      _saveError = null;
      notifyListeners();
      return true;
    } catch (e) {
      _saveError = '加载格局失败: $e';
      notifyListeners();
      return false;
    }
  }

  /// 基于现有规则初始化为创建模式（复制）
  Future<bool> initFromDuplicate(String ruleId) async {
    try {
      final rule = await _crudService.getRule(ruleId);
      if (rule == null) {
        _saveError = '格局不存在';
        notifyListeners();
        return false;
      }

      _isCreateMode = true;
      _editingRuleId = null;
      _originalRule = null;
      _loadFromRule(rule);
      _name = '${rule.name} (副本)';
      _hasUnsavedChanges = true;
      _validationResult = null;
      _saveError = null;
      notifyListeners();
      return true;
    } catch (e) {
      _saveError = '加载格局失败: $e';
      notifyListeners();
      return false;
    }
  }

  // ========== 表单更新方法 ==========

  void updateName(String value) {
    if (_name != value) {
      _name = value;
      _markChanged();
    }
  }

  void updateClassName(String value) {
    if (_className != value) {
      _className = value;
      _markChanged();
    }
  }

  void updateBooks(String value) {
    if (_books != value) {
      _books = value;
      _markChanged();
    }
  }

  void updateDescription(String value) {
    if (_description != value) {
      _description = value;
      _markChanged();
    }
  }

  void updateSource(String value) {
    if (_source != value) {
      _source = value;
      _markChanged();
    }
  }

  void updateJiXiong(JiXiongEnum value) {
    if (_jiXiong != value) {
      _jiXiong = value;
      _markChanged();
    }
  }

  void updateGeJuType(GeJuType value) {
    if (_geJuType != value) {
      _geJuType = value;
      _markChanged();
    }
  }

  void updateScope(GeJuScope value) {
    if (_scope != value) {
      _scope = value;
      _markChanged();
    }
  }

  // ========== 条件树操作方法 ==========

  /// 设置根条件
  void setRootCondition(ConditionEditorNode? node) {
    _rootConditionNode = node;
    _markChanged();
  }

  /// 向逻辑组添加子条件
  void addConditionToGroup(String groupId, ConditionEditorNode child) {
    final group = _rootConditionNode?.findChild(groupId);
    if (group != null && group.isLogic) {
      group.addChild(child);
      _markChanged();
    }
  }

  /// 移除条件节点
  void removeConditionNode(String nodeId) {
    if (_rootConditionNode == null) return;

    if (_rootConditionNode!.id == nodeId) {
      _rootConditionNode = null;
      _markChanged();
      return;
    }

    // 递归查找并移除
    _removeNodeRecursive(_rootConditionNode!, nodeId);
    _markChanged();
  }

  void _removeNodeRecursive(ConditionEditorNode parent, String nodeId) {
    parent.removeChild(nodeId);
    for (var child in parent.children) {
      _removeNodeRecursive(child, nodeId);
    }
  }

  /// 更新条件节点
  void updateConditionNode(String nodeId, ConditionEditorNode updated) {
    if (_rootConditionNode == null) return;

    if (_rootConditionNode!.id == nodeId) {
      _rootConditionNode = updated;
      _markChanged();
      return;
    }

    _rootConditionNode!.replaceChild(nodeId, updated);
    _markChanged();
  }

  /// 将节点包装为逻辑组
  void wrapInLogicGroup(String nodeId, String logicType) {
    if (_rootConditionNode == null) return;

    if (_rootConditionNode!.id == nodeId) {
      final original = _rootConditionNode!;
      _rootConditionNode = ConditionEditorNode.logic(logicType, children: [original]);
      _markChanged();
      return;
    }

    // 查找父节点并替换
    _wrapNodeRecursive(_rootConditionNode!, nodeId, logicType);
    _markChanged();
  }

  void _wrapNodeRecursive(
      ConditionEditorNode parent, String nodeId, String logicType) {
    for (int i = 0; i < parent.children.length; i++) {
      if (parent.children[i].id == nodeId) {
        final original = parent.children[i];
        parent.children[i] =
            ConditionEditorNode.logic(logicType, children: [original]);
        return;
      }
      _wrapNodeRecursive(parent.children[i], nodeId, logicType);
    }
  }

  // ========== 验证与保存 ==========

  /// 验证所有字段
  ValidationResult validate() {
    final errors = <String>[];
    final warnings = <String>[];

    // 名称不为空
    if (_name.trim().isEmpty) {
      errors.add('格局名称不能为空');
    }

    // 分类不为空
    if (_className.trim().isEmpty) {
      errors.add('格局分类不能为空');
    }

    // 描述建议
    if (_description.trim().isEmpty) {
      warnings.add('建议填写格局描述');
    }

    // 条件树验证
    if (_rootConditionNode == null) {
      warnings.add('未设置判断条件，该格局将无法进行匹配');
    } else {
      final conditionValidation = _validateConditionNode(_rootConditionNode!);
      errors.addAll(conditionValidation.errors);
      warnings.addAll(conditionValidation.warnings);
    }

    _validationResult = errors.isEmpty
        ? ValidationResult.valid(warnings: warnings)
        : ValidationResult.invalid(errors: errors, warnings: warnings);

    return _validationResult!;
  }

  ValidationResult _validateConditionNode(ConditionEditorNode node) {
    final errors = <String>[];
    final warnings = <String>[];

    if (node.isLogic) {
      if (node.isAnd || node.isOr) {
        if (node.children.isEmpty) {
          errors.add('${node.displayName} 条件组至少需要一个子条件');
        }
        if (node.isOr && node.children.length == 1) {
          warnings.add('OR 条件组只有一个子条件，可以简化');
        }
      } else if (node.isNot) {
        if (node.children.isEmpty) {
          errors.add('NOT 条件需要一个子条件');
        } else if (node.children.length > 1) {
          errors.add('NOT 条件只能有一个子条件');
        }
      }

      for (var child in node.children) {
        final childResult = _validateConditionNode(child);
        errors.addAll(childResult.errors);
        warnings.addAll(childResult.warnings);
      }
    }

    return errors.isEmpty
        ? ValidationResult.valid(warnings: warnings)
        : ValidationResult.invalid(errors: errors, warnings: warnings);
  }

  /// 保存规则
  Future<bool> save() async {
    if (!canSave) return false;

    _isSaving = true;
    _saveError = null;
    notifyListeners();

    try {
      GeJuCondition? condition;
      if (_rootConditionNode != null) {
        condition = _rootConditionNode!.toCondition();
      }

      if (_isCreateMode) {
        final params = GeJuRuleCreateParams(
          name: _name.trim(),
          className: _className.trim(),
          books: _books.trim(),
          description: _description.trim(),
          source: _source.trim(),
          jiXiong: _jiXiong,
          geJuType: _geJuType,
          scope: _scope,
          conditions: condition,
        );
        final newRule = await _crudService.createRule(params);
        _editingRuleId = newRule.id;
        _originalRule = newRule;
        _isCreateMode = false;
      } else {
        final updatedRule = GeJuRule(
          id: _editingRuleId!,
          name: _name.trim(),
          className: _className.trim(),
          books: _books.trim(),
          description: _description.trim(),
          source: _source.trim(),
          jiXiong: _jiXiong,
          geJuType: _geJuType,
          scope: _scope,
          conditions: condition,
        );
        await _crudService.updateRule(updatedRule);
        _originalRule = updatedRule;
      }

      _hasUnsavedChanges = false;
      _isSaving = false;
      notifyListeners();
      return true;
    } on RuleValidationError catch (e) {
      _saveError = e.errors.join('\n');
      _isSaving = false;
      notifyListeners();
      return false;
    } catch (e) {
      _saveError = '保存失败: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  /// 重置表单到初始状态
  void reset() {
    if (_originalRule != null) {
      _loadFromRule(_originalRule!);
    } else {
      _resetForm();
    }
    _hasUnsavedChanges = false;
    _validationResult = null;
    _saveError = null;
    notifyListeners();
  }

  /// 清除错误信息
  void clearError() {
    _saveError = null;
    notifyListeners();
  }

  // ========== 内部方法 ==========

  void _resetForm() {
    _name = '';
    _className = '自定义';
    _books = '';
    _description = '';
    _source = '';
    _jiXiong = JiXiongEnum.PING;
    _geJuType = GeJuType.pin;
    _scope = GeJuScope.natal;
    _rootConditionNode = null;
    _hasUnsavedChanges = false;
    _validationResult = null;
    _saveError = null;
  }

  void _loadFromRule(GeJuRule rule) {
    _name = rule.name;
    _className = rule.className;
    _books = rule.books;
    _description = rule.description;
    _source = rule.source;
    _jiXiong = rule.jiXiong;
    _geJuType = rule.geJuType;
    _scope = rule.scope;
    _rootConditionNode = rule.conditions != null
        ? ConditionEditorNode.fromCondition(rule.conditions!)
        : null;
  }

  void _markChanged() {
    _hasUnsavedChanges = true;
    _validationResult = null; // 清除之前的验证结果
    notifyListeners();
  }
}
