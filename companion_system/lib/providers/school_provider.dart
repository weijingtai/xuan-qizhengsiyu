import 'package:flutter/foundation.dart';
import 'package:companion_system/database/drift_database.dart';
import 'package:drift/drift.dart';

class SchoolProvider extends ChangeNotifier {
  final AppDatabase db;

  List<School> _schools = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchKeyword = '';
  String? _selectedType;

  SchoolProvider(this.db) {
    loadSchools();
  }

  List<School> get schools => _filteredSchools;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchKeyword => _searchKeyword;
  String? get selectedType => _selectedType;

  List<String> get availableTypes {
    final types = _schools.map((s) => s.type).toSet().toList();
    return types..sort();
  }

  List<School> get _filteredSchools {
    var filtered = _schools.where((s) => s.isActive).toList();

    if (_searchKeyword.isNotEmpty) {
      filtered = filtered.where((s) {
        return s.name.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
            (s.founder?.toLowerCase().contains(_searchKeyword.toLowerCase()) ?? false);
      }).toList();
    }

    if (_selectedType != null) {
      filtered = filtered.where((s) => s.type == _selectedType).toList();
    }

    return filtered;
  }

  Future<void> loadSchools() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _schools = await db.select(db.geJuSchools).get();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = '加载流派失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchKeyword(String keyword) {
    _searchKeyword = keyword;
    notifyListeners();
  }

  void setSelectedType(String? type) {
    _selectedType = type;
    notifyListeners();
  }

  void clearFilters() {
    _searchKeyword = '';
    _selectedType = null;
    notifyListeners();
  }

  Future<School?> getSchoolById(String id) async {
    try {
      return await (db.select(db.geJuSchools)..where((s) => s.id.equals(id))).getSingleOrNull();
    } catch (e) {
      print('获取流派失败: $e');
      return null;
    }
  }

  Future<void> insertSchool(GeJuSchoolsCompanion companion) async {
    try {
      await db.into(db.geJuSchools).insert(companion);
      await loadSchools();
    } catch (e) {
      _errorMessage = '插入流派失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateSchool(String id, GeJuSchoolsCompanion companion) async {
    try {
      await (db.update(db.geJuSchools)..where((s) => s.id.equals(id))).write(companion);
      await loadSchools();
    } catch (e) {
      _errorMessage = '更新流派失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteSchool(String id) async {
    try {
      await (db.update(db.geJuSchools)..where((s) => s.id.equals(id)))
          .write(const GeJuSchoolsCompanion(isActive: Value(false)));
      await loadSchools();
    } catch (e) {
      _errorMessage = '删除流派失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> permanentDeleteSchool(String id) async {
    try {
      await (db.delete(db.geJuSchools)..where((s) => s.id.equals(id))).go();
      await loadSchools();
    } catch (e) {
      _errorMessage = '删除流派失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateRuleCount(String schoolId) async {
    try {
      final rules = await (db.select(db.geJuRules)..where((r) => r.schoolId.equals(schoolId))).get();
      final count = rules.length;
      await (db.update(db.geJuSchools)..where((s) => s.id.equals(schoolId)))
          .write(GeJuSchoolsCompanion(ruleCount: Value(count)));
      await loadSchools();
    } catch (e) {
      print('更新规则计数失败: $e');
    }
  }
}
