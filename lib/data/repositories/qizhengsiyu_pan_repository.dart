
import '../../domain/entities/models/pan_entity.dart';
import '../datasources/local/app_database.dart';
import '../datasources/local/daos/qizhengsiyu_pan_dao.dart';
import 'interfaces/i_qizhengsiyu_pan_repository.dart';

class QiZhengSiYuPanRepository extends IQiZhengSiYuPanRepository {
  QiZhengSiYuPanDao get _localStorage => _appDatabase.qiZhengSiYuPanDao;
  late final AppDatabase _appDatabase;
  QiZhengSiYuPanRepository({required AppDatabase appDatabase}) {
    _appDatabase = appDatabase;
  }

  // 基础CRUD操作

  /// 保存盘数据
  Future<void> save(QiZhengSiYuPanEntity entity) async {
    try {
      await _localStorage.insertPan(entity);
    } catch (e) {
      throw RepositoryException('保存盘数据失败: $e');
    }
  }

  /// 根据UUID获取盘数据
  Future<QiZhengSiYuPanEntity?> findByUuid(String uuid) async {
    try {
      return await _localStorage.getPanByUuid(uuid);
    } catch (e) {
      throw RepositoryException('获取盘数据失败: $e');
    }
  }

  /// 更新盘数据
  Future<void> update(QiZhengSiYuPanEntity entity) async {
    try {
      await _localStorage.updatePan(entity);
    } catch (e) {
      throw RepositoryException('更新盘数据失败: $e');
    }
  }

  /// 删除盘数据（软删除）
  Future<void> delete(String uuid) async {
    try {
      await _localStorage.softDeletePan(uuid);
    } catch (e) {
      throw RepositoryException('删除盘数据失败: $e');
    }
  }

  /// 永久删除盘数据
  Future<void> permanentlyDelete(String uuid) async {
    try {
      await _localStorage.deletePan(uuid);
    } catch (e) {
      throw RepositoryException('永久删除盘数据失败: $e');
    }
  }

  // 查询和搜索功能

  /// 获取所有活跃的盘数据
  Future<List<QiZhengSiYuPanEntity>> findAllActive() async {
    try {
      return await _localStorage.getAllActivePans();
    } catch (e) {
      throw RepositoryException('获取活跃盘数据失败: $e');
    }
  }

  /// 根据占卜请求UUID查找盘数据
  Future<List<QiZhengSiYuPanEntity>> findByDivinationUuid(
      String divinationUuid) async {
    try {
      return await _localStorage.getPansByDivinationUuid(divinationUuid);
    } catch (e) {
      throw RepositoryException('根据占卜UUID查找盘数据失败: $e');
    }
  }

  /// 按时间范围搜索盘数据
  Future<List<QiZhengSiYuPanEntity>> findByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      return await _localStorage.getPansByDateRange(startDate, endDate);
    } catch (e) {
      throw RepositoryException('按时间范围搜索失败: $e');
    }
  }

  /// 分页获取盘数据
  Future<PaginatedResult<QiZhengSiYuPanEntity>> findWithPagination({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final items = await _localStorage.getPansWithPagination(
        limit: pageSize,
        offset: offset,
      );
      final totalCount = await _localStorage.getPansCount();

      return PaginatedResult<QiZhengSiYuPanEntity>(
        items: items,
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
        totalPages: (totalCount / pageSize).ceil(),
      );
    } catch (e) {
      throw RepositoryException('分页查询失败: $e');
    }
  }

  /// 搜索功能 - 根据多个条件搜索
  Future<List<QiZhengSiYuPanEntity>> search({
    String? divinationUuid,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      List<QiZhengSiYuPanEntity> results;

      if (divinationUuid != null) {
        results = await findByDivinationUuid(divinationUuid);
      } else if (startDate != null && endDate != null) {
        results = await findByDateRange(startDate, endDate);
      } else {
        results = await findAllActive();
      }

      if (limit != null && results.length > limit) {
        results = results.take(limit).toList();
      }

      return results;
    } catch (e) {
      throw RepositoryException('搜索失败: $e');
    }
  }

  // 统计功能

  /// 获取盘数据总数
  Future<int> getTotalCount() async {
    try {
      return await _localStorage.getPansCount();
    } catch (e) {
      throw RepositoryException('获取总数失败: $e');
    }
  }

  /// 获取今日创建的盘数据数量
  Future<int> getTodayCount() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final todayPans = await findByDateRange(startOfDay, endOfDay);
      return todayPans.length;
    } catch (e) {
      throw RepositoryException('获取今日数量失败: $e');
    }
  }

  /// 获取最近的盘数据
  Future<List<QiZhengSiYuPanEntity>> getRecent({int limit = 10}) async {
    try {
      return await _localStorage.getPansWithPagination(limit: limit, offset: 0);
    } catch (e) {
      throw RepositoryException('获取最近数据失败: $e');
    }
  }

  // 业务逻辑方法

  /// 检查UUID是否存在
  Future<bool> existsByUuid(String uuid) async {
    try {
      final entity = await findByUuid(uuid);
      return entity != null;
    } catch (e) {
      return false;
    }
  }

  /// 批量保存
  Future<void> saveBatch(List<QiZhengSiYuPanEntity> entities) async {
    try {
      for (final entity in entities) {
        await _localStorage.insertPan(entity);
      }
    } catch (e) {
      throw RepositoryException('批量保存失败: $e');
    }
  }

  /// 清理过期数据（删除指定天数前的软删除数据）
  Future<int> cleanupExpiredData({int daysOld = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final expiredPans = await _localStorage.getPansByDateRange(
        DateTime(2000), // 很早的日期
        cutoffDate,
      );

      int deletedCount = 0;
      for (final pan in expiredPans) {
        if (pan.deletedAt != null && pan.deletedAt!.isBefore(cutoffDate)) {
          await _localStorage.deletePan(pan.uuid);
          deletedCount++;
        }
      }

      return deletedCount;
    } catch (e) {
      throw RepositoryException('清理过期数据失败: $e');
    }
  }
}

/// 分页结果类
class PaginatedResult<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  const PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}

/// Repository异常类
class RepositoryException implements Exception {
  final String message;

  const RepositoryException(this.message);

  @override
  String toString() => 'RepositoryException: $message';
}
