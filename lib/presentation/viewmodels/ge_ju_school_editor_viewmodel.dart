import 'package:flutter/foundation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_school.dart';
import 'package:qizhengsiyu/domain/services/ge_ju_school_service.dart';

/// 流派编辑器模式
enum SchoolEditorMode { create, edit }

/// 流派编辑器 ViewModel
class GeJuSchoolEditorViewModel extends ChangeNotifier {
  final GeJuSchoolService _schoolService;

  GeJuSchoolEditorViewModel({required GeJuSchoolService schoolService})
      : _schoolService = schoolService;

  SchoolEditorMode _mode = SchoolEditorMode.create;
  GeJuSchool? _originalSchool;
  bool _isReadOnly = false;

  String _name = '';
  String _brief = '';
  List<String> _features = [];

  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  String? _errorMessage;

  // Getters
  SchoolEditorMode get mode => _mode;
  bool get isReadOnly => _isReadOnly;
  String get name => _name;
  String get brief => _brief;
  List<String> get features => _features;
  bool get isSaving => _isSaving;
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  String? get errorMessage => _errorMessage;

  String get pageTitle {
    if (_isReadOnly) return '查看流派';
    return _mode == SchoolEditorMode.create ? '新建流派' : '编辑流派';
  }

  bool get canSave =>
      !_isSaving && !_isReadOnly && _name.trim().isNotEmpty;

  /// 初始化为创建模式
  void initForCreate() {
    _mode = SchoolEditorMode.create;
    _originalSchool = null;
    _isReadOnly = false;
    _name = '';
    _brief = '';
    _features = [];
    _hasUnsavedChanges = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// 初始化为编辑模式
  Future<bool> initForEdit(String schoolId) async {
    try {
      final school = await _schoolService.getSchoolById(schoolId);
      if (school == null) {
        _errorMessage = '流派不存在';
        notifyListeners();
        return false;
      }

      _mode = SchoolEditorMode.edit;
      _originalSchool = school;
      _isReadOnly = school.isBuiltIn;
      _name = school.name;
      _brief = school.brief ?? '';
      _features = List.from(school.features);
      _hasUnsavedChanges = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '加载失败: $e';
      notifyListeners();
      return false;
    }
  }

  // Field updates
  void updateName(String value) {
    if (_name != value) {
      _name = value;
      _hasUnsavedChanges = true;
      notifyListeners();
    }
  }

  void updateBrief(String value) {
    if (_brief != value) {
      _brief = value;
      _hasUnsavedChanges = true;
      notifyListeners();
    }
  }

  void addFeature(String feature) {
    if (feature.trim().isNotEmpty) {
      _features = [..._features, feature.trim()];
      _hasUnsavedChanges = true;
      notifyListeners();
    }
  }

  void removeFeature(int index) {
    if (index >= 0 && index < _features.length) {
      _features = List.from(_features)..removeAt(index);
      _hasUnsavedChanges = true;
      notifyListeners();
    }
  }

  void updateFeature(int index, String value) {
    if (index >= 0 && index < _features.length) {
      _features = List.from(_features)..[index] = value;
      _hasUnsavedChanges = true;
      notifyListeners();
    }
  }

  /// 保存
  Future<bool> save() async {
    if (!canSave) return false;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_mode == SchoolEditorMode.create) {
        await _schoolService.createSchool(
          name: _name.trim(),
          brief: _brief.trim().isNotEmpty ? _brief.trim() : null,
          features: _features,
        );
      } else {
        final updated = GeJuSchool(
          id: _originalSchool!.id,
          name: _name.trim(),
          brief: _brief.trim().isNotEmpty ? _brief.trim() : null,
          features: _features,
        );
        await _schoolService.updateSchool(updated);
        _originalSchool = updated;
      }

      _hasUnsavedChanges = false;
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '保存失败: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
