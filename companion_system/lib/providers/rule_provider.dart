/// 规则数据Provider

import 'package:flutter/foundation.dart';
import 'package:companion_system/database/drift_database.dart';
import 'package:companion_system/models/enums.dart';
import 'package:drift/drift.dart';

class RuleProvider extends ChangeNotifier {
  final AppDatabase db;

  List<Rule> _rules = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchKeyword = '';
  String? _selectedSchoolId;
  Jixiong? _selectedJixiong;
  Level? _selectedLevel;
  Scope? _selectedScope;

  RuleProvider(this.db) {
    loadRules();
  }

  List<Rule> get rules => _filteredRules;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchKeyword => _searchKeyword;
  String? get selectedSchoolId => _selectedSchoolId;
  Jixiong? get selectedJixiong => _selectedJixiong;
  Level? get selectedLevel => _selectedLevel;
  Scope? get selectedScope => _selectedScope;

  List<Rule> get _filteredRules {
    var filtered = _rules;

    // 搜索过滤
    if (_searchKeyword.isNotEmpty) {
      filtered = filtered.where((rule) {
        // 注意：需要从关联的Pattern获取名称
        return rule.conditions?.toLowerCase().contains(_searchKeyword.toLowerCase()) ??
            false;
      }).toList();
    }

    // 流派过滤
    if (_selectedSchoolId != null) {
      filtered = filtered.where((rule) => rule.schoolId == _selectedSchoolId).toList();
    }

    // 吉凶过滤
    if (_selectedJixiong != null) {
      filtered = filtered.where((rule) {
        final jixiong = _jixiongFromString(rule.jixiong);
        return jixiong == _selectedJixiong;
      }).toList();
    }

    // 层级过滤
    if (_selectedLevel != null) {
      filtered = filtered.where((rule) {
        final level = _levelFromString(rule.level);
        return level == _selectedLevel;
      }).toList();
    }

    // 范围过滤
    if (_selectedScope != null) {
      filtered = filtered.where((rule) {
        final scope = _scopeFromString(rule.scope);
        return scope == _selectedScope;
      }).toList();
    }

    return filtered;
  }

  Future<void> loadRules() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final allRules = await db.select(db.geJuRules).get();
      _rules = allRules;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = '加载规则失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchKeyword(String keyword) {
    _searchKeyword = keyword;
    notifyListeners();
  }

  void setSelectedSchoolId(String? schoolId) {
    _selectedSchoolId = schoolId;
    notifyListeners();
  }

  void setSelectedJixiong(Jixiong? jixiong) {
    _selectedJixiong = jixiong;
    notifyListeners();
  }

  void setSelectedLevel(Level? level) {
    _selectedLevel = level;
    notifyListeners();
  }

  void setSelectedScope(Scope? scope) {
    _selectedScope = scope;
    notifyListeners();
  }

  void clearFilters() {
    _searchKeyword = '';
    _selectedSchoolId = null;
    _selectedJixiong = null;
    _selectedLevel = null;
    _selectedScope = null;
    notifyListeners();
  }

  Future<void> deleteRule(int ruleId) async {
    await (db.delete(db.geJuRules)..where((tbl) => tbl.id.equals(ruleId))).go();
    await loadRules();
  }

  Future<void> saveRule(GeJuRulesCompanion companion) async {
    await db.into(db.geJuRules).insert(companion);
    await loadRules();
  }

  Future<void> updateRule(int ruleId, GeJuRulesCompanion companion) async {
    await (db.update(db.geJuRules)..where((t) => t.id.equals(ruleId)))
        .write(companion);
    await loadRules();
  }

  Future<void> updatePatternDescription(
      String patternId, String? description) async {
    await (db.update(db.geJuPatterns)..where((t) => t.id.equals(patternId)))
        .write(GeJuPatternsCompanion(description: Value(description)));
    notifyListeners();
  }

  Jixiong _jixiongFromString(String value) {
    switch (value) {
      case '吉':
        return Jixiong.ji;
      case '平':
        return Jixiong.ping;
      case '凶':
        return Jixiong.xiong;
      default:
        return Jixiong.ping;
    }
  }

  Level _levelFromString(String value) {
    switch (value) {
      case '小':
        return Level.xiao;
      case '中':
        return Level.zhong;
      case '大':
        return Level.da;
      default:
        return Level.zhong;
    }
  }

  Scope _scopeFromString(String value) {
    switch (value) {
      case 'natal':
        return Scope.natal;
      case 'xingxian':
        return Scope.xingxian;
      case 'both':
        return Scope.both;
      default:
        return Scope.natal;
    }
  }
}
