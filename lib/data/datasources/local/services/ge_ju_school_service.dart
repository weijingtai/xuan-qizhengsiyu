import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import 'package:qizhengsiyu/data/datasources/local/daos/ge_ju_dao.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_school.dart';
import 'package:qizhengsiyu/domain/services/ge_ju_school_service_adapter.dart';
import 'package:uuid/uuid.dart';

class GeJuSchoolService implements GeJuSchoolServicePort {
  final GeJuDao _dao;
  static const _uuid = Uuid();

  List<GeJuSchoolContract>? _cache;

  GeJuSchoolService({required GeJuDao dao}) : _dao = dao;

  /// 获取所有流派（内置 + 用户自定义）
  @override
  Future<List<GeJuSchoolContract>> getAllSchools() async {
    if (_cache != null) return _cache!;
    final userSchools = await _dao.getAllSchools();
    final allSchools = [...GeJuSchool.builtInSchools, ...userSchools];
    _cache = allSchools.map(geJuSchoolToContract).toList();
    return _cache!;
  }

  /// 根据 ID 获取流派
  @override
  Future<GeJuSchoolContract?> getSchoolById(String id) async {
    // 先查内置
    final builtIn = GeJuSchool.builtInSchools.where((s) => s.id == id);
    if (builtIn.isNotEmpty) {
      return geJuSchoolToContract(builtIn.first);
    }
    // 再查用户
    final school = await _dao.getSchoolById(id);
    return school != null ? geJuSchoolToContract(school) : null;
  }

  /// 创建用户自定义流派
  @override
  Future<GeJuSchoolContract> createSchool({
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
    return geJuSchoolToContract(school);
  }

  /// 更新用户自定义流派（内置流派不可修改）
  @override
  Future<void> updateSchool(GeJuSchoolContract contract) async {
    if (GeJuSchool.builtInIds.contains(contract.id)) {
      throw StateError('不能修改内置流派: ${contract.id}');
    }
    final school = geJuSchoolFromContract(contract);
    await _dao.updateSchool(school);
    _clearCache();
  }

  /// 删除用户自定义流派（内置流派不可删除）
  @override
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

  @override
  void clearCache() => _clearCache();
}
