import 'package:flutter/foundation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_school.dart';
import 'package:qizhengsiyu/domain/services/ge_ju_school_service_adapter.dart';

/// 流派列表 ViewModel
class GeJuSchoolListViewModel extends ChangeNotifier {
  final GeJuSchoolServiceAdapter _schoolService;

  GeJuSchoolListViewModel({required GeJuSchoolServiceAdapter schoolService})
      : _schoolService = schoolService;

  List<GeJuSchool> _schools = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<GeJuSchool> get schools => _schools;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool isBuiltIn(String id) => GeJuSchool.builtInIds.contains(id);

  Future<void> loadSchools() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _schoolService.clearCache();
      _schools = await _schoolService.getAllSchools();
    } catch (e) {
      _errorMessage = '加载流派失败: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteSchool(String id) async {
    try {
      await _schoolService.deleteSchool(id);
      await loadSchools();
      return true;
    } catch (e) {
      _errorMessage = '删除失败: $e';
      notifyListeners();
      return false;
    }
  }
}
