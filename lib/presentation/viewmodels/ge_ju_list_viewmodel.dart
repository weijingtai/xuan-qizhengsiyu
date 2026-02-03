import 'package:common/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju_model.dart';
import 'package:qizhengsiyu/domain/errors/ge_ju_errors.dart';
import 'package:qizhengsiyu/domain/services/ge_ju_crud_service.dart';

/// 格局排序字段
enum GeJuSortField {
  name,
  className,
  jiXiong,
  geJuType,
}

/// 格局列表 ViewModel
///
/// 管理格局列表的状态，包括加载、搜索、筛选、排序、删除等操作
class GeJuListViewModel extends ChangeNotifier {
  final GeJuCrudService _crudService;

  GeJuListViewModel({required GeJuCrudService crudService})
      : _crudService = crudService;

  // ========== 状态字段 ==========

  /// 全部规则列表
  List<GeJuRule> _allRules = [];

  /// 筛选后的规则列表
  List<GeJuRule> _filteredRules = [];

  /// 加载中状态
  bool _isLoading = false;

  /// 错误信息
  String? _errorMessage;

  /// 搜索关键词
  String _searchKeyword = '';

  /// 分类筛选
  String? _selectedCategory;

  /// 吉凶筛选
  JiXiongEnum? _selectedJiXiong;

  /// 类型筛选
  GeJuType? _selectedType;

  /// 范围筛选
  GeJuScope? _selectedScope;

  /// 来源筛选: null=全部, true=仅内置, false=仅用户
  bool? _sourceFilter;

  /// 排序字段
  GeJuSortField _sortField = GeJuSortField.name;

  /// 排序方向
  bool _sortAscending = true;

  // ========== Getters ==========

  /// 当前显示的规则列表
  List<GeJuRule> get rules => _filteredRules;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 错误信息
  String? get errorMessage => _errorMessage;

  /// 搜索关键词
  String get searchKeyword => _searchKeyword;

  /// 选中的分类
  String? get selectedCategory => _selectedCategory;

  /// 选中的吉凶
  JiXiongEnum? get selectedJiXiong => _selectedJiXiong;

  /// 选中的类型
  GeJuType? get selectedType => _selectedType;

  /// 选中的范围
  GeJuScope? get selectedScope => _selectedScope;

  /// 来源筛选
  bool? get sourceFilter => _sourceFilter;

  /// 排序字段
  GeJuSortField get sortField => _sortField;

  /// 排序方向
  bool get sortAscending => _sortAscending;

  /// 总规则数
  int get totalCount => _allRules.length;

  /// 内置规则数
  int get builtInCount =>
      _allRules.where((r) => _crudService.isBuiltInRule(r.id)).length;

  /// 用户规则数
  int get userCount =>
      _allRules.where((r) => !_crudService.isBuiltInRule(r.id)).length;

  /// 是否有活跃的筛选条件
  bool get hasActiveFilters =>
      _searchKeyword.isNotEmpty ||
      _selectedCategory != null ||
      _selectedJiXiong != null ||
      _selectedType != null ||
      _selectedScope != null ||
      _sourceFilter != null;

  /// 所有分类列表（从数据中提取）
  List<String> get categories {
    final cats = _allRules.map((r) => r.className).toSet().toList();
    cats.sort();
    return cats;
  }

  // ========== 核心方法 ==========

  /// 加载规则
  Future<void> loadRules() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allRules = await _crudService.getAllRules();
      _applyFiltersAndSort();
    } catch (e) {
      _errorMessage = e is GeJuError ? e.message : '加载格局失败: $e';
      _filteredRules = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 强制刷新（清除缓存）
  Future<void> refreshRules() async {
    _crudService.clearCache();
    await loadRules();
  }

  /// 搜索
  void search(String keyword) {
    _searchKeyword = keyword;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// 按分类筛选
  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// 按吉凶筛选
  void filterByJiXiong(JiXiongEnum? jiXiong) {
    _selectedJiXiong = jiXiong;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// 按类型筛选
  void filterByType(GeJuType? type) {
    _selectedType = type;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// 按范围筛选
  void filterByScope(GeJuScope? scope) {
    _selectedScope = scope;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// 按来源筛选
  void filterBySource(bool? isBuiltIn) {
    _sourceFilter = isBuiltIn;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// 清除所有筛选
  void clearFilters() {
    _searchKeyword = '';
    _selectedCategory = null;
    _selectedJiXiong = null;
    _selectedType = null;
    _selectedScope = null;
    _sourceFilter = null;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// 设置排序
  void sortBy(GeJuSortField field, {bool? ascending}) {
    if (_sortField == field && ascending == null) {
      // 同字段切换方向
      _sortAscending = !_sortAscending;
    } else {
      _sortField = field;
      _sortAscending = ascending ?? true;
    }
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// 删除规则
  Future<bool> deleteRule(String ruleId) async {
    try {
      await _crudService.deleteRule(ruleId);
      _allRules.removeWhere((r) => r.id == ruleId);
      _applyFiltersAndSort();
      notifyListeners();
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

  /// 判断规则是否为内置
  bool isBuiltIn(String ruleId) {
    return _crudService.isBuiltInRule(ruleId);
  }

  /// 清除错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ========== 内部方法 ==========

  /// 应用筛选和排序
  void _applyFiltersAndSort() {
    var result = List<GeJuRule>.from(_allRules);

    // 搜索
    if (_searchKeyword.isNotEmpty) {
      final lower = _searchKeyword.toLowerCase();
      result = result.where((rule) {
        return rule.name.toLowerCase().contains(lower) ||
            rule.description.toLowerCase().contains(lower) ||
            rule.className.toLowerCase().contains(lower) ||
            rule.books.toLowerCase().contains(lower) ||
            rule.source.toLowerCase().contains(lower);
      }).toList();
    }

    // 分类筛选
    if (_selectedCategory != null) {
      result = result.where((r) => r.className == _selectedCategory).toList();
    }

    // 吉凶筛选
    if (_selectedJiXiong != null) {
      result = result.where((r) => r.jiXiong == _selectedJiXiong).toList();
    }

    // 类型筛选
    if (_selectedType != null) {
      result = result.where((r) => r.geJuType == _selectedType).toList();
    }

    // 范围筛选
    if (_selectedScope != null) {
      result = result.where((r) => r.scope == _selectedScope).toList();
    }

    // 来源筛选
    if (_sourceFilter != null) {
      if (_sourceFilter!) {
        result = result.where((r) => _crudService.isBuiltInRule(r.id)).toList();
      } else {
        result =
            result.where((r) => !_crudService.isBuiltInRule(r.id)).toList();
      }
    }

    // 排序
    result.sort((a, b) {
      int compare;
      switch (_sortField) {
        case GeJuSortField.name:
          compare = a.name.compareTo(b.name);
          break;
        case GeJuSortField.className:
          compare = a.className.compareTo(b.className);
          break;
        case GeJuSortField.jiXiong:
          compare = a.jiXiong.index.compareTo(b.jiXiong.index);
          break;
        case GeJuSortField.geJuType:
          compare = a.geJuType.index.compareTo(b.geJuType.index);
          break;
      }
      return _sortAscending ? compare : -compare;
    });

    _filteredRules = result;
  }
}
