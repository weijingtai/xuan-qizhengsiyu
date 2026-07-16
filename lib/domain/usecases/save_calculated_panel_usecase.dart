import 'package:metaphysics_core/datamodel/divination_request_info_datamodel.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:uuid/uuid.dart';

import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import '../entities/models/base_panel_model.dart';
import '../entities/models/pan_entity.dart';
import '../entities/models/panel_config.dart';

class SaveCalculatedPanelUseCase {
  final Uuid _uuid = const Uuid();
  IQiZhengSiYuPanRepository qiZhengSiYuPanRepository;
  QiZhengRecordRepository recordRepository;

  SaveCalculatedPanelUseCase({
    required this.qiZhengSiYuPanRepository,
    required this.recordRepository,
  });

  /// 保存计算得到的基础面板模型到本地数据库
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
      await qiZhengSiYuPanRepository.save(entity.toContract());
      await recordRepository.saveRecord(entity.toContract());
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
      QiZhengSiYuPanContract? oldContract =
          await qiZhengSiYuPanRepository.findByUuid(uuid);
      if (oldContract == null) {
        return false;
      }
      final oldEntity = QiZhengSiYuPanEntity.fromContract(oldContract);
      final updatedEntity = oldEntity.copyWith(
        panelModel: basicPanelModel,
        panelConfig: panelConfig,
        divinationDatetimeModel: divinationDatetimeModel,
        lastUpdatedAt: now,
      );
      await qiZhengSiYuPanRepository.update(updatedEntity.toContract());
      return true;
    } catch (e) {
      throw SavePanelException('更新面板数据失败: $e');
    }
  }

  /// 根据UUID获取面板数据
  Future<QiZhengSiYuPanEntity?> getByUuid(String uuid) async {
    try {
      final contract = await qiZhengSiYuPanRepository.findByUuid(uuid);
      if (contract == null) return null;
      return QiZhengSiYuPanEntity.fromContract(contract);
    } catch (e) {
      throw SavePanelException('获取面板数据失败: $e');
    }
  }

  /// 根据占卜UUID获取面板数据
  Future<List<QiZhengSiYuPanEntity>> getByDivinationUuid(
      String divinationUuid) async {
    try {
      final contracts =
          await qiZhengSiYuPanRepository.findByDivinationUuid(divinationUuid);
      return contracts.map(QiZhengSiYuPanEntity.fromContract).toList();
    } catch (e) {
      throw SavePanelException('根据占卜UUID获取面板数据失败: $e');
    }
  }

  /// 删除面板数据
  Future<int> delete(String uuid) async {
    try {
      final isExist = await qiZhengSiYuPanRepository.existsByUuid(uuid);
      if (!isExist) {
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
