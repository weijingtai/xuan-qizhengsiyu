import 'package:qizhengsiyu/data/datasources/local/daos/ge_ju_dao.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_school.dart';
import 'package:uuid/uuid.dart';

/// 流派管理服务
///
/// 合并内置流派与用户自定义流派，提供 CRUD 接口
class GeJuSchoolService {
  final GeJuDao _dao;
  static const _uuid = Uuid();

  List<GeJuSchool>? _cache;

  GeJuSchoolService({required GeJuDao dao}) : _dao = dao;

  /// 获取所有流派（内置 + 用户自定义）
  Future<List<GeJuSchool>> getAllSchools() async {
    if (_cache != null) return _cache!;
    final userSchools = await _dao.getAllSchools();
    _cache = [...GeJuSchool.builtInSchools, ...userSchools];
    return _cache!;
  }

  /// 根据 ID 获取流派
  Future<GeJuSchool?> getSchoolById(String id) async {
    // 先查内置
    final builtIn = GeJuSchool.builtInSchools.where((s) => s.id == id);
    if (builtIn.isNotEmpty) return builtIn.first;
    // 再查用户
    return await _dao.getSchoolById(id);
  }

  /// 创建用户自定义流派
  Future<GeJuSchool> createSchool({
    required String name,
    String? brief,
    List<String> features = const [],
  }) async {
    final school = GeJuSchool(
      id: 'user_school_${_uuid.v4()}',
      name: name,
      brief: brief,
      features: features,
    );
    await _dao.insertSchool(school);
    _clearCache();
    return school;
  }

  /// 更新用户自定义流派（内置流派不可修改）
  Future<void> updateSchool(GeJuSchool school) async {
    if (school.isBuiltIn) {
      throw StateError('不能修改内置流派: ${school.id}');
    }
    await _dao.updateSchool(school);
    _clearCache();
  }

  /// 删除用户自定义流派（内置流派不可删除）
  Future<void> deleteSchool(String id) async {
    if (GeJuSchool.builtInIds.contains(id)) {
      throw StateError('不能删除内置流派: $id');
    }
    await _dao.deleteSchool(id);
    _clearCache();
  }

  void _clearCache() {
    _cache = null;
  }

  void clearCache() => _clearCache();
}
