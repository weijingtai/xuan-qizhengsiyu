import 'package:metaphysics_core/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_alias.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_annotation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition_set.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju_model.dart';
import 'package:qizhengsiyu/domain/errors/ge_ju_errors.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_school.dart';
import 'package:qizhengsiyu/domain/services/ge_ju_crud_service.dart';
import 'package:qizhengsiyu/domain/services/ge_ju_school_service_adapter.dart';
import 'package:qizhengsiyu/domain/services/ge_ju_validation.dart';
import 'package:qizhengsiyu/presentation/models/condition_editor_node.dart';

/// 编辑器模式
enum EditorMode {
  create,
  edit,
  duplicate,
  saveAs,
}

/// 保存结果
class SaveResult {
  final bool success;
  final String? ruleId;
  final String? errorMessage;

  const SaveResult({required this.success, this.ruleId, this.errorMessage});

  factory SaveResult.ok(String ruleId) =>
      SaveResult(success: true, ruleId: ruleId);

  factory SaveResult.error(String message) =>
      SaveResult(success: false, errorMessage: message);
}

/// 格局编辑器 ViewModel（三实体模型）
///
/// 以"格局"为单位操作，内部管理 Rule + Annotation + ConditionSet 三个实体的字段
class GeJuEditorViewModel extends ChangeNotifier {
  final GeJuCrudService _crudService;
  final GeJuSchoolServiceAdapter? _schoolService;

  GeJuEditorViewModel({
    required GeJuCrudService crudService,
    GeJuSchoolServiceAdapter? schoolService,
  })  : _crudService = crudService,
        _schoolService = schoolService;

  // ========== 模式与原始数据 ==========

  EditorMode _mode = EditorMode.create;
  String? _editingRuleId;
  GeJuRule? _originalRule;
  GeJuAnnotation? _originalAnnotation;
  GeJuConditionSet? _originalConditionSet;

  // ═══ Rule 字段 ═══
  String _name = '';
  List<GeJuAlias> _aliases = [];
  String? _disambiguationNote;
  GeJuScope _scope = GeJuScope.both;

  // ═══ Annotation 字段 ═══
  String _description = '';
  JiXiongEnum _jiXiong = JiXiongEnum.PING;
  GeJuType _geJuType = GeJuType.pin;
  String _className = '';
  String _books = '';
  String? _sourceSection;

  // ═══ ConditionSet 字段 ═══
  String _csLabel = '';
  String? _changeNote;
  ConditionEditorNode? _rootConditionNode;
  String? _derivedFrom;

  // ═══ School 字段 ═══
  List<GeJuSchool> _allSchools = [];
  List<String> _annotationSchools = [];
  List<String> _conditionSetSchools = [];

  // ═══ UI 状态 ═══
  ValidationResult? _validationResult;
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;
  String? _saveError;

  // ========== Getters ==========

  EditorMode get mode => _mode;
  String? get editingRuleId => _editingRuleId;
  bool get isBuiltIn =>
      _editingRuleId != null && _crudService.isBuiltInRule(_editingRuleId!);
  bool get isReadOnly => isBuiltIn;

  // Rule fields
  String get name => _name;
  List<GeJuAlias> get aliases => _aliases;
  String? get disambiguationNote => _disambiguationNote;
  GeJuScope get scope => _scope;

  // Annotation fields
  String get description => _description;
  JiXiongEnum get jiXiong => _jiXiong;
  GeJuType get geJuType => _geJuType;
  String get className => _className;
  String get books => _books;
  String? get sourceSection => _sourceSection;

  // ConditionSet fields
  String get csLabel => _csLabel;
  String? get changeNote => _changeNote;
  ConditionEditorNode? get rootConditionNode => _rootConditionNode;
  String? get derivedFrom => _derivedFrom;

  // School fields
  List<GeJuSchool> get allSchools => _allSchools;
  List<String> get annotationSchools => _annotationSchools;
  List<String> get conditionSetSchools => _conditionSetSchools;

  // UI state
  ValidationResult? get validationResult => _validationResult;
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  bool get isSaving => _isSaving;
  String? get saveError => _saveError;

  bool get canSave {
    if (_isSaving) return false;
    if (isReadOnly) return false;
    final validation = validate();
    return validation.isValid;
  }

  String get pageTitle {
    switch (_mode) {
      case EditorMode.create:
        return '新建格局';
      case EditorMode.edit:
        return isBuiltIn ? '查看格局' : '编辑格局';
      case EditorMode.duplicate:
        return '复制格局';
      case EditorMode.saveAs:
        return '另存为';
    }
  }

  // ========== 初始化方法 ==========

  /// 初始化为创建模式
  Future<bool> initForCreate() async {
    _mode = EditorMode.create;
    _editingRuleId = null;
    _originalRule = null;
    _originalAnnotation = null;
    _originalConditionSet = null;
    _resetForm();
    await reloadSchools();
    notifyListeners();
    return true;
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

      _mode = EditorMode.edit;
      _editingRuleId = ruleId;
      _originalRule = rule;

      // Load associated annotation and condition set
      final annotations = await _crudService.getAnnotationsForRule(ruleId);
      final conditionSets = await _crudService.getConditionSetsForRule(ruleId);

      _originalAnnotation = annotations.isNotEmpty ? annotations.first : null;
      _originalConditionSet = conditionSets.isNotEmpty ? conditionSets.first : null;

      _loadFromEntities(rule, _originalAnnotation, _originalConditionSet);
      _hasUnsavedChanges = false;
      _validationResult = null;
      _saveError = null;
      await reloadSchools();
      notifyListeners();
      return true;
    } catch (e) {
      _saveError = '加载格局失败: $e';
      notifyListeners();
      return false;
    }
  }

  /// 基于现有规则初始化为复制模式
  Future<bool> initFromDuplicate(String ruleId) async {
    try {
      final rule = await _crudService.getRule(ruleId);
      if (rule == null) {
        _saveError = '格局不存在';
        notifyListeners();
        return false;
      }

      _mode = EditorMode.duplicate;
      _editingRuleId = null;
      _originalRule = null;
      _originalAnnotation = null;
      _originalConditionSet = null;

      final annotations = await _crudService.getAnnotationsForRule(ruleId);
      final conditionSets = await _crudService.getConditionSetsForRule(ruleId);

      _loadFromEntities(
        rule,
        annotations.isNotEmpty ? annotations.first : null,
        conditionSets.isNotEmpty ? conditionSets.first : null,
      );
      _name = '${rule.name} (副本)';
      _hasUnsavedChanges = true;
      _validationResult = null;
      _saveError = null;
      await reloadSchools();
      notifyListeners();
      return true;
    } catch (e) {
      _saveError = '加载格局失败: $e';
      notifyListeners();
      return false;
    }
  }

  /// 基于当前编辑状态初始化为另存为模式
  Future<bool> initForSaveAs(String ruleId) async {
    try {
      final rule = await _crudService.getRule(ruleId);
      if (rule == null) {
        _saveError = '格局不存在';
        notifyListeners();
        return false;
      }

      _mode = EditorMode.saveAs;
      _editingRuleId = null;
      _originalRule = null;
      _originalAnnotation = null;
      _originalConditionSet = null;

      final annotations = await _crudService.getAnnotationsForRule(ruleId);
      final conditionSets = await _crudService.getConditionSetsForRule(ruleId);

      _loadFromEntities(
        rule,
        annotations.isNotEmpty ? annotations.first : null,
        conditionSets.isNotEmpty ? conditionSets.first : null,
      );
      _hasUnsavedChanges = true;
      _validationResult = null;
      _saveError = null;
      await reloadSchools();
      notifyListeners();
      return true;
    } catch (e) {
      _saveError = '加载格局失败: $e';
      notifyListeners();
      return false;
    }
  }

  // ========== Rule 字段更新 ==========

  void updateName(String value) {
    if (_name != value) {
      _name = value;
      _markChanged();
    }
  }

  void updateScope(GeJuScope value) {
    if (_scope != value) {
      _scope = value;
      _markChanged();
    }
  }

  void updateDisambiguationNote(String? value) {
    if (_disambiguationNote != value) {
      _disambiguationNote = value;
      _markChanged();
    }
  }

  void updateAliases(List<GeJuAlias> value) {
    _aliases = value;
    _markChanged();
  }

  void addAlias(GeJuAlias alias) {
    _aliases = [..._aliases, alias];
    _markChanged();
  }

  void removeAlias(int index) {
    if (index >= 0 && index < _aliases.length) {
      _aliases = List.from(_aliases)..removeAt(index);
      _markChanged();
    }
  }

  // ========== Annotation 字段更新 ==========

  void updateDescription(String value) {
    if (_description != value) {
      _description = value;
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

  void updateSourceSection(String? value) {
    if (_sourceSection != value) {
      _sourceSection = value;
      _markChanged();
    }
  }

  // ========== School 字段更新 ==========

  void updateAnnotationSchools(List<String> schools) {
    _annotationSchools = schools;
    _markChanged();
  }

  void updateConditionSetSchools(List<String> schools) {
    _conditionSetSchools = schools;
    _markChanged();
  }

  /// 重新加载可选流派列表
  Future<void> reloadSchools() async {
    if (_schoolService != null) {
      _schoolService.clearCache();
      _allSchools = await _schoolService.getAllSchools();
      notifyListeners();
    }
  }

  // ========== ConditionSet 字段更新 ==========

  void updateCsLabel(String value) {
    if (_csLabel != value) {
      _csLabel = value;
      _markChanged();
    }
  }

  void updateChangeNote(String? value) {
    if (_changeNote != value) {
      _changeNote = value;
      _markChanged();
    }
  }

  // ========== 条件树操作（只读展示，保留接口以备未来编辑） ==========

  void setRootCondition(ConditionEditorNode? node) {
    _rootConditionNode = node;
    _markChanged();
  }

  void addConditionToGroup(String groupId, ConditionEditorNode child) {
    final group = _rootConditionNode?.findChild(groupId);
    if (group != null && group.isLogic) {
      group.addChild(child);
      _markChanged();
    }
  }

  void removeConditionNode(String nodeId) {
    if (_rootConditionNode == null) return;
    if (_rootConditionNode!.id == nodeId) {
      _rootConditionNode = null;
      _markChanged();
      return;
    }
    _removeNodeRecursive(_rootConditionNode!, nodeId);
    _markChanged();
  }

  void _removeNodeRecursive(ConditionEditorNode parent, String nodeId) {
    parent.removeChild(nodeId);
    for (var child in parent.children) {
      _removeNodeRecursive(child, nodeId);
    }
  }

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

  void wrapInLogicGroup(String nodeId, String logicType) {
    if (_rootConditionNode == null) return;
    if (_rootConditionNode!.id == nodeId) {
      final original = _rootConditionNode!;
      _rootConditionNode =
          ConditionEditorNode.logic(logicType, children: [original]);
      _markChanged();
      return;
    }
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

  ValidationResult validate() {
    final errors = <String>[];
    final warnings = <String>[];

    if (_name.trim().isEmpty) {
      errors.add('格局名称不能为空');
    }

    if (_description.trim().isEmpty) {
      warnings.add('建议填写格局描述');
    }

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

  /// 保存
  Future<SaveResult> save() async {
    if (!canSave) {
      return SaveResult.error('无法保存');
    }

    _isSaving = true;
    _saveError = null;
    notifyListeners();

    try {
      GeJuCondition? condition;
      if (_rootConditionNode != null) {
        condition = _rootConditionNode!.toCondition();
      }

      String resultRuleId;

      switch (_mode) {
        case EditorMode.create:
        case EditorMode.duplicate:
          // 使用 saveRuleAs 一次创建三个实体
          final rule = await _crudService.saveRuleAs(GeJuRuleSaveAsParams(
            name: _name.trim(),
            scope: _scope,
            disambiguationNote: _disambiguationNote,
            description: _description.trim(),
            jiXiong: _jiXiong,
            geJuType: _geJuType,
            className: _className.trim(),
            books: _books.trim().isNotEmpty ? _books.trim() : null,
            sourceSection: _sourceSection,
            annotationSchools: _annotationSchools.isNotEmpty ? _annotationSchools : null,
            csLabel: _csLabel.trim().isNotEmpty ? _csLabel.trim() : _name.trim(),
            conditions: condition,
            changeNote: _changeNote,
            derivedFrom: _derivedFrom,
            conditionSetSchools: _conditionSetSchools.isNotEmpty ? _conditionSetSchools : null,
          ));
          resultRuleId = rule.id;
          _editingRuleId = rule.id;
          _originalRule = rule;
          _mode = EditorMode.edit;
          break;

        case EditorMode.edit:
          // Update existing entities
          final updatedRule = _originalRule!.copyWith(
            name: _name.trim(),
            scope: _scope,
            disambiguationNote: _disambiguationNote,
            updatedAt: DateTime.now(),
          );
          await _crudService.updateRule(updatedRule);
          _originalRule = updatedRule;

          // Update annotation if exists
          if (_originalAnnotation != null && _originalAnnotation!.isUser) {
            final updatedAnn = _originalAnnotation!.copyWith(
              description: _description.trim(),
              jiXiong: _jiXiong,
              geJuType: _geJuType,
              className: _className.trim(),
              schools: _annotationSchools.isNotEmpty ? _annotationSchools : null,
              updatedAt: DateTime.now(),
            );
            await _crudService.updateAnnotation(updatedAnn);
            _originalAnnotation = updatedAnn;
          } else if (_originalAnnotation == null) {
            // Create new annotation for user rule
            final ann = await _crudService.createAnnotation(
              AnnotationCreateParams(
                ruleId: _editingRuleId!,
                description: _description.trim(),
                jiXiong: _jiXiong,
                geJuType: _geJuType,
                className: _className.trim(),
                books: _books.trim().isNotEmpty ? _books.trim() : null,
                sourceSection: _sourceSection,
                schools: _annotationSchools.isNotEmpty ? _annotationSchools : null,
              ),
            );
            _originalAnnotation = ann;
          }

          // Update condition set if exists
          if (_originalConditionSet != null && _originalConditionSet!.isUser) {
            final updatedCs = _originalConditionSet!.copyWith(
              label: _csLabel.trim().isNotEmpty ? _csLabel.trim() : _name.trim(),
              conditions: condition,
              changeNote: _changeNote,
              schools: _conditionSetSchools.isNotEmpty ? _conditionSetSchools : null,
              updatedAt: DateTime.now(),
            );
            await _crudService.updateConditionSet(updatedCs);
            _originalConditionSet = updatedCs;
          } else if (_originalConditionSet == null && condition != null) {
            // Create new condition set for user rule
            final cs = await _crudService.createConditionSet(
              ConditionSetCreateParams(
                ruleId: _editingRuleId!,
                label: _csLabel.trim().isNotEmpty ? _csLabel.trim() : _name.trim(),
                conditions: condition,
                changeNote: _changeNote,
                schools: _conditionSetSchools.isNotEmpty ? _conditionSetSchools : null,
              ),
            );
            _originalConditionSet = cs;
          }

          resultRuleId = _editingRuleId!;
          break;

        case EditorMode.saveAs:
          final rule = await _crudService.saveRuleAs(GeJuRuleSaveAsParams(
            name: _name.trim(),
            scope: _scope,
            disambiguationNote: _disambiguationNote,
            description: _description.trim(),
            jiXiong: _jiXiong,
            geJuType: _geJuType,
            className: _className.trim(),
            books: _books.trim().isNotEmpty ? _books.trim() : null,
            sourceSection: _sourceSection,
            annotationSchools: _annotationSchools.isNotEmpty ? _annotationSchools : null,
            csLabel: _csLabel.trim().isNotEmpty ? _csLabel.trim() : _name.trim(),
            conditions: condition,
            changeNote: _changeNote,
            derivedFrom: _derivedFrom,
            conditionSetSchools: _conditionSetSchools.isNotEmpty ? _conditionSetSchools : null,
          ));
          resultRuleId = rule.id;
          _editingRuleId = rule.id;
          _originalRule = rule;
          _mode = EditorMode.edit;
          break;
      }

      _hasUnsavedChanges = false;
      _isSaving = false;
      notifyListeners();
      return SaveResult.ok(resultRuleId);
    } on RuleValidationError catch (e) {
      _saveError = e.errors.join('\n');
      _isSaving = false;
      notifyListeners();
      return SaveResult.error(_saveError!);
    } catch (e) {
      _saveError = '保存失败: $e';
      _isSaving = false;
      notifyListeners();
      return SaveResult.error(_saveError!);
    }
  }

  /// 重置表单到初始状态
  void reset() {
    if (_originalRule != null) {
      _loadFromEntities(_originalRule!, _originalAnnotation, _originalConditionSet);
    } else {
      _resetForm();
    }
    _hasUnsavedChanges = false;
    _validationResult = null;
    _saveError = null;
    notifyListeners();
  }

  void clearError() {
    _saveError = null;
    notifyListeners();
  }

  // ========== 内部方法 ==========

  void _resetForm() {
    _name = '';
    _aliases = [];
    _disambiguationNote = null;
    _scope = GeJuScope.both;
    _description = '';
    _jiXiong = JiXiongEnum.PING;
    _geJuType = GeJuType.pin;
    _className = '';
    _books = '';
    _sourceSection = null;
    _csLabel = '';
    _changeNote = null;
    _rootConditionNode = null;
    _derivedFrom = null;
    _annotationSchools = [];
    _conditionSetSchools = [];
    _hasUnsavedChanges = false;
    _validationResult = null;
    _saveError = null;
  }

  void _loadFromEntities(
    GeJuRule rule,
    GeJuAnnotation? annotation,
    GeJuConditionSet? conditionSet,
  ) {
    // Rule fields
    _name = rule.name;
    _aliases = List.from(rule.aliases);
    _disambiguationNote = rule.disambiguationNote;
    _scope = rule.scope;

    // Annotation fields
    _description = annotation?.description ?? '';
    _jiXiong = annotation?.jiXiong ?? JiXiongEnum.PING;
    _geJuType = annotation?.geJuType ?? GeJuType.pin;
    _className = annotation?.className ?? '';
    _books = annotation?.source?.bookName ?? '';
    _sourceSection = annotation?.source?.section;

    // ConditionSet fields
    _csLabel = conditionSet?.label ?? '';
    _changeNote = conditionSet?.changeNote;
    _derivedFrom = conditionSet?.derivedFrom;
    _rootConditionNode = conditionSet?.conditions != null
        ? ConditionEditorNode.fromCondition(conditionSet!.conditions!)
        : null;

    // School fields
    _annotationSchools = annotation?.schools != null
        ? List<String>.from(annotation!.schools!)
        : [];
    _conditionSetSchools = conditionSet?.schools != null
        ? List<String>.from(conditionSet!.schools!)
        : [];
  }

  void _markChanged() {
    _hasUnsavedChanges = true;
    _validationResult = null;
    notifyListeners();
  }
}
