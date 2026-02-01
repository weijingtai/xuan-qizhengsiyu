import 'package:common/datamodel/divination_request_info_datamodel.dart';
import 'package:common/models/divination_datetime.dart';
import 'package:flutter/rendering.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/interfaces/i_qizhengsiyu_pan_repository.dart';
import '../entities/models/base_panel_model.dart';
import '../entities/models/pan_entity.dart';
import '../entities/models/panel_config.dart';

class SaveCalculatedPanelUseCase {
  // final BasePanelDao _basePanelDao;
  final Uuid _uuid = const Uuid();
  IQiZhengSiYuPanRepository qiZhengSiYuPanRepository;

  SaveCalculatedPanelUseCase({
    required this.qiZhengSiYuPanRepository,
  });

  /// 保存计算得到的基础面板模型到本地数据库
  ///
  /// [basicPanelModel] 计算得到的基础面板模型
  /// [panelConfig] 面板配置信息
  /// [observerPosition] 观测者位置信息
  /// [divinationUuid] 可选的占卜UUID
  /// [seekerUuid] 可选的求测人UUID
  ///
  /// 返回保存的记录UUID
  Future<QiZhengSiYuPanEntity> execute({
    required BasePanelModel basicPanelModel,
    required BasePanelConfig panelConfig,
    required DivinationDatetimeModel divinationDatetimeModel,
    required DivinationRequestInfoDataModel requestInfo,
  }) async {
    try {
      final uuid = _uuid.v4();
      final now = DateTime.now();
      QiZhengSiYuPanEntity entity = QiZhengSiYuPanEntity(
        uuid: uuid,
        createdAt: now,
        lastUpdatedAt: now,
        deletedAt: null,
        divinationRequestInfoUuid: requestInfo.uuid,
        panelConfig: panelConfig,
        panelModel: basicPanelModel,
        divinationDatetimeModel: divinationDatetimeModel,
      );
      await qiZhengSiYuPanRepository.save(entity);
      // TODO: Dev only
      List<QiZhengSiYuPanEntity> all =
          await qiZhengSiYuPanRepository.findAllActive();
      debugPrint("all: ${all.length}");
      return entity;
    } catch (e) {
      throw SavePanelException('保存面板数据失败: $e');
    }
  }

  /// 更新已存在的面板记录
  Future<bool> update({
    required String uuid,
    required BasePanelModel basicPanelModel,
    required BasePanelConfig panelConfig,
    required DivinationDatetimeModel divinationDatetimeModel,
    required DivinationRequestInfoDataModel requestInfo,
  }) async {
    try {
      final now = DateTime.now();
      QiZhengSiYuPanEntity? oldEntity =
          await qiZhengSiYuPanRepository.findByUuid(uuid);
      if (oldEntity == null) {
        debugPrint("this is not entity with {uuid: $uuid} in db");
        return false;
      }
      oldEntity.copyWith(
        panelModel: basicPanelModel,
        panelConfig: panelConfig,
        divinationDatetimeModel: divinationDatetimeModel,
        lastUpdatedAt: now,
      );
      await qiZhengSiYuPanRepository.update(oldEntity);
      return false;
    } catch (e) {
      throw SavePanelException('更新面板数据失败: $e');
    }
  }

  /// 根据UUID获取面板数据
  Future<QiZhengSiYuPanEntity?> getByUuid(String uuid) async {
    try {
      final record = await qiZhengSiYuPanRepository.findByUuid(uuid);
      if (record == null) return null;
      return record;
    } catch (e) {
      throw SavePanelException('获取面板数据失败: $e');
    }
  }

  /// 根据占卜UUID获取面板数据
  Future<List<QiZhengSiYuPanEntity>> getByDivinationUuid(
      String divinationUuid) async {
    try {
      List<QiZhengSiYuPanEntity> resultList =
          await qiZhengSiYuPanRepository.findByDivinationUuid(divinationUuid);
      return resultList;
    } catch (e) {
      throw SavePanelException('根据占卜UUID获取面板数据失败: $e');
    }
  }

  /// 删除面板数据
  Future<int> delete(String uuid) async {
    try {
      final isExist = await qiZhengSiYuPanRepository.existsByUuid(uuid);
      if (!isExist) {
        debugPrint("this is not entity with {uuid: $uuid} in db");
        return 0;
      }
      await qiZhengSiYuPanRepository.delete(uuid);
      return 1;
    } catch (e) {
      throw SavePanelException('删除面板数据失败: $e');
    }
  }
}

/// 保存面板异常
class SavePanelException implements Exception {
  final String message;
  SavePanelException(this.message);

  @override
  String toString() => 'SavePanelException: $message';
}
