import 'package:drift/drift.dart';
import '../../../../domain/entities/models/pan_entity.dart';
import '../app_database.dart';
import '../tables/qizhengsiyu_pan_table.dart';

part 'qizhengsiyu_pan_dao.g.dart';

@DriftAccessor(tables: [QizhengsiyuPanTable])
class QiZhengSiYuPanDao extends DatabaseAccessor<AppDatabase>
    with _$QiZhengSiYuPanDaoMixin {
  QiZhengSiYuPanDao(AppDatabase db) : super(db);

  // 插入新的盘数据
  Future<void> insertPan(QiZhengSiYuPanEntity entity) async {
    await into(qizhengsiyuPanTable).insert(QizhengsiyuPanTableCompanion.insert(
      uuid: entity.uuid,
      divinationRequestInfoUuid: entity.divinationRequestInfoUuid,
      createdAt: entity.createdAt,
      lastUpdatedAt: entity.lastUpdatedAt,
      deletedAt: Value(entity.deletedAt),
      panelModel: entity.panelModel,
      panelConfig: entity.panelConfig,
      divinationDatetimeModel: entity.divinationDatetimeModel,
    ));
  }

  // 根据UUID获取盘数据
  Future<QiZhengSiYuPanEntity?> getPanByUuid(String uuid) async {
    final query = select(qizhengsiyuPanTable)
      ..where((tbl) => tbl.uuid.equals(uuid));

    return await query.getSingleOrNull();
  }

  // 获取所有未删除的盘数据
  Future<List<QiZhengSiYuPanEntity>> getAllActivePans() async {
    final query = select(qizhengsiyuPanTable)
      ..where((tbl) => tbl.deletedAt.isNull())
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    return await query.get();
  }

  // 根据占卜请求UUID获取盘数据
  Future<List<QiZhengSiYuPanEntity>> getPansByDivinationUuid(
      String divinationUuid) async {
    final query = select(qizhengsiyuPanTable)
      ..where((tbl) =>
          tbl.divinationRequestInfoUuid.equals(divinationUuid) &
          tbl.deletedAt.isNull())
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    return await query.get();
  }

  // 更新盘数据
  Future<void> updatePan(QiZhengSiYuPanEntity entity) async {
    await (update(qizhengsiyuPanTable)
          ..where((tbl) => tbl.uuid.equals(entity.uuid)))
        .write(QizhengsiyuPanTableCompanion(
      panelModel: Value(entity.panelModel),
      panelConfig: Value(entity.panelConfig),
      divinationDatetimeModel: Value(entity.divinationDatetimeModel),
      lastUpdatedAt: Value(DateTime.now()),
    ));
  }

  // 软删除盘数据
  Future<void> softDeletePan(String uuid) async {
    await (update(qizhengsiyuPanTable)..where((tbl) => tbl.uuid.equals(uuid)))
        .write(QizhengsiyuPanTableCompanion(
      deletedAt: Value(DateTime.now()),
      lastUpdatedAt: Value(DateTime.now()),
    ));
  }

  // 硬删除盘数据
  Future<void> deletePan(String uuid) async {
    await (delete(qizhengsiyuPanTable)..where((tbl) => tbl.uuid.equals(uuid)))
        .go();
  }

  // 分页获取盘数据
  Future<List<QiZhengSiYuPanEntity>> getPansWithPagination({
    int limit = 20,
    int offset = 0,
  }) async {
    final query = select(qizhengsiyuPanTable)
      ..where((tbl) => tbl.deletedAt.isNull())
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
      ..limit(limit, offset: offset);

    return await query.get();
  }

  // 获取盘数据总数
  Future<int> getPansCount() async {
    final query = selectOnly(qizhengsiyuPanTable)
      ..addColumns([qizhengsiyuPanTable.uuid.count()])
      ..where(qizhengsiyuPanTable.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(qizhengsiyuPanTable.uuid.count()) ?? 0;
  }

  // 按时间范围查询
  Future<List<QiZhengSiYuPanEntity>> getPansByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final query = select(qizhengsiyuPanTable)
      ..where((tbl) =>
          tbl.createdAt.isBetweenValues(startDate, endDate) &
          tbl.deletedAt.isNull())
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    return await query.get();
  }
}
