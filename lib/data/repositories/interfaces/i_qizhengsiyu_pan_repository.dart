import '../../../domain/entities/models/pan_entity.dart';
import '../qizhengsiyu_pan_repository.dart';

abstract class IQiZhengSiYuPanRepository {
  // 基础CRUD操作
  /// 保存一个新的七政四遇盘实体
  /// [entity] 要保存的七政四遇盘实体
  Future<void> save(QiZhengSiYuPanEntity entity);

  /// 根据UUID查找七政四遇盘实体
  /// [uuid] 要查找的七政四遇盘UUID
  /// 返回找到的实体，如果不存在则返回null
  Future<QiZhengSiYuPanEntity?> findByUuid(String uuid);

  /// 更新现有的七政四遇盘实体
  /// [entity] 要更新的七政四遇盘实体
  Future<void> update(QiZhengSiYuPanEntity entity);

  /// 软删除指定UUID的七政四遇盘
  /// [uuid] 要删除的七政四遇盘UUID
  Future<void> delete(String uuid);

  /// 永久删除指定UUID的七政四遇盘
  /// [uuid] 要永久删除的七政四遇盘UUID
  Future<void> permanentlyDelete(String uuid);

  // 查询和搜索功能
  /// 查找所有未被删除的七政四遇盘
  /// 返回活跃状态的七政四遇盘列表
  Future<List<QiZhengSiYuPanEntity>> findAllActive();

  /// 根据占卜UUID查找相关的七政四遇盘
  /// [divinationUuid] 占卜的UUID
  /// 返回与该占卜相关的所有七政四遇盘
  Future<List<QiZhengSiYuPanEntity>> findByDivinationUuid(
      String divinationUuid);

  /// 查找指定日期范围内的七政四遇盘
  /// [startDate] 开始日期
  /// [endDate] 结束日期
  /// 返回日期范围内的所有七政四遇盘
  Future<List<QiZhengSiYuPanEntity>> findByDateRange(
      DateTime startDate, DateTime endDate);

  /// 分页查询七政四遇盘
  /// [page] 页码，默认为1
  /// [pageSize] 每页数量，默认为20
  /// 返回分页后的七政四遇盘结果
  Future<PaginatedResult<QiZhengSiYuPanEntity>> findWithPagination(
      {int page = 1, int pageSize = 20});

  /// 按条件搜索七政四遇盘
  /// [divinationUuid] 可选的占卜UUID
  /// [startDate] 可选的开始日期
  /// [endDate] 可选的结束日期
  /// [limit] 可选的结果数量限制
  /// 返回符合搜索条件的七政四遇盘列表
  Future<List<QiZhengSiYuPanEntity>> search({
    String? divinationUuid,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  // 统计功能
  /// 获取七政四遇盘总数
  /// 返回系统中所有七政四遇盘的数量
  Future<int> getTotalCount();

  /// 获取今日七政四遇盘数量
  /// 返回今天创建的七政四遇盘数量
  Future<int> getTodayCount();

  /// 获取最近的七政四遇盘
  /// [limit] 返回结果的数量限制，默认为10
  /// 返回最近创建的七政四遇盘列表
  Future<List<QiZhengSiYuPanEntity>> getRecent({int limit = 10});

  // 业务逻辑方法
  /// 检查指定UUID的七政四遇盘是否存在
  /// [uuid] 要检查的七政四遇盘UUID
  /// 返回true表示存在，false表示不存在
  Future<bool> existsByUuid(String uuid);

  /// 批量保存七政四遇盘实体
  /// [entities] 要批量保存的七政四遇盘实体列表
  Future<void> saveBatch(List<QiZhengSiYuPanEntity> entities);

  /// 清理过期数据
  /// [daysOld] 指定多少天前的数据视为过期，默认30天
  /// 返回被清理的记录数量
  Future<int> cleanupExpiredData({int daysOld = 30});
}
