import 'package:flutter/foundation.dart' hide Category;
import 'package:companion_system/database/drift_database.dart';
import 'package:drift/drift.dart';

class PatternProvider extends ChangeNotifier {
  final AppDatabase db;

  List<Pattern> _patterns = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchKeyword = '';
  String? _selectedCategoryId;

  PatternProvider(this.db) {
    loadData();
  }

  List<Pattern> get patterns => _filteredPatterns;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchKeyword => _searchKeyword;
  String? get selectedCategoryId => _selectedCategoryId;

  List<Pattern> get _filteredPatterns {
    var filtered = _patterns.toList();

    if (_searchKeyword.isNotEmpty) {
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
            (p.pinyin?.toLowerCase().contains(_searchKeyword.toLowerCase()) ?? false) ||
            (p.englishName?.toLowerCase().contains(_searchKeyword.toLowerCase()) ?? false) ||
            (p.keywords?.toLowerCase().contains(_searchKeyword.toLowerCase()) ?? false);
      }).toList();
    }

    if (_selectedCategoryId != null) {
      filtered = filtered.where((p) => p.categoryId == _selectedCategoryId).toList();
    }

    return filtered;
  }

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _patterns = await db.select(db.geJuPatterns).get();
      _categories = await db.select(db.geJuCategories).get();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = '加载数据失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPatterns() async {
    _isLoading = true;
    notifyListeners();

    try {
      _patterns = await db.select(db.geJuPatterns).get();
    } catch (e) {
      _errorMessage = '加载格局失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      _categories = await db.select(db.geJuCategories).get();
      notifyListeners();
    } catch (e) {
      print('加载分类失败: $e');
    }
  }

  void setSearchKeyword(String keyword) {
    _searchKeyword = keyword;
    notifyListeners();
  }

  void setSelectedCategoryId(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void clearFilters() {
    _searchKeyword = '';
    _selectedCategoryId = null;
    notifyListeners();
  }

  Future<Pattern?> getPatternById(String id) async {
    try {
      return await (db.select(db.geJuPatterns)..where((p) => p.id.equals(id))).getSingleOrNull();
    } catch (e) {
      print('获取格局失败: $e');
      return null;
    }
  }

  Future<void> insertPattern(GeJuPatternsCompanion companion) async {
    try {
      await db.into(db.geJuPatterns).insert(companion);
      await loadPatterns();
      await _updateCategoryPatternCount(companion.categoryId.value);
    } catch (e) {
      _errorMessage = '插入格局失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updatePattern(String id, GeJuPatternsCompanion companion) async {
    try {
      await (db.update(db.geJuPatterns)..where((p) => p.id.equals(id))).write(companion);
      await loadPatterns();
      await _updateCategoryPatternCount(companion.categoryId.value);
    } catch (e) {
      _errorMessage = '更新格局失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deletePattern(String id) async {
    try {
      final pattern = await getPatternById(id);
      if (pattern != null) {
        await (db.delete(db.geJuPatterns)..where((p) => p.id.equals(id))).go();
        await loadPatterns();
        await _updateCategoryPatternCount(pattern.categoryId);
      }
    } catch (e) {
      _errorMessage = '删除格局失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _updateCategoryPatternCount(String categoryId) async {
    try {
      final count = _patterns.where((p) => p.categoryId == categoryId).length;
      await (db.update(db.geJuCategories)..where((c) => c.id.equals(categoryId)))
          .write(GeJuCategoriesCompanion(patternCount: Value(count)));
      await loadCategories();
    } catch (e) {
      print('更新分类计数失败: $e');
    }
  }

  Future<List<Pattern>> searchPatterns(String query) async {
    if (query.isEmpty) return [];
    return _patterns.where((p) {
      return p.name.contains(query) ||
          (p.pinyin?.contains(query) ?? false) ||
          (p.englishName?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }
}
