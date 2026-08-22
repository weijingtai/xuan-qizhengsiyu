import 'package:metaphysics_core/datamodel/divination_request_info_datamodel.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:uuid/uuid.dart';

import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import '../entities/models/base_panel_model.dart';
import '../entities/models/pan_entity.dart';
import '../entities/models/panel_config.dart';

class SaveCalculatedPanelUseCase {
  final Uuid _uuid = const Uuid();
  final RequestContext _ctx = RequestContext(scopeUid: 'local-anonymous');
  IQiZhengSiYuPanRepository qiZhengSiYuPanRepository;
  QiZhengRecordRepository recordRepository;

  SaveCalculatedPanelUseCase({
    required this.qiZhengSiYuPanRepository,
    required this.recordRepository,
  });

  /// 保存计算得到的基础面板模型到本地数据库
  ///
  /// [uuid] 可选：传入则用该值作为 Record uuid（与 Pipeline 排盘 uuid 同源）；
  /// 不传则内部生成 v4。
  Future<QiZhengSiYuPanEntity> execute({
    required BasePanelModel basicPanelModel,
    required BasePanelConfig panelConfig,
    required DivinationDatetimeModel divinationDatetimeModel,
    required DivinationRequestInfoDataModel requestInfo,
    String? uuid,
  }) async {
    try {
      final recordUuid = uuid ?? _uuid.v4();
      final now = DateTime.now();
      QiZhengSiYuPanEntity entity = QiZhengSiYuPanEntity(
        uuid: recordUuid,
        createdAt: now,
        lastUpdatedAt: now,
        deletedAt: null,
        divinationRequestInfoUuid: requestInfo.uuid,
        panelConfig: panelConfig,
        panelModel: basicPanelModel,
        divinationDatetimeModel: divinationDatetimeModel,
      );
      final panResult = await qiZhengSiYuPanRepository.put(entity.toContract(), _ctx);
      switch (panResult) {
        case Ok(): break;
        case Err(:final error): throw error;
      }
      final recResult = await recordRepository.put(entity.toContract(), _ctx);
      switch (recResult) {
        case Ok(): break;
        case Err(:final error): throw error;
      }
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
      final getResult = await qiZhengSiYuPanRepository.get(uuid, _ctx);
      final oldContract = switch (getResult) {
        Ok(:final value) => value,
        Err(:final error) => throw error,
      };
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
      final putResult = await qiZhengSiYuPanRepository.put(updatedEntity.toContract(), _ctx);
      switch (putResult) {
        case Ok(): break;
        case Err(:final error): throw error;
      }
      return true;
    } catch (e) {
      throw SavePanelException('更新面板数据失败: $e');
    }
  }

  /// 根据UUID获取面板数据
  Future<QiZhengSiYuPanEntity?> getByUuid(String uuid) async {
    try {
      final getResult = await qiZhengSiYuPanRepository.get(uuid, _ctx);
      final contract = switch (getResult) {
        Ok(:final value) => value,
        Err(:final error) => throw error,
      };
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
      final queryResult = await qiZhengSiYuPanRepository.query(
          {'divination_uuid': divinationUuid},
          PageRequest(limit: 100),
          _ctx);
      final contracts = switch (queryResult) {
        Ok(:final value) => value.items,
        Err(:final error) => throw error,
      };
      return contracts.map(QiZhengSiYuPanEntity.fromContract).toList();
    } catch (e) {
      throw SavePanelException('根据占卜UUID获取面板数据失败: $e');
    }
  }

  /// 删除面板数据
  Future<int> delete(String uuid) async {
    try {
      final existResult = await qiZhengSiYuPanRepository.exists(uuid, _ctx);
      final isExist = switch (existResult) {
        Ok(:final value) => value,
        Err(:final error) => throw error,
      };
      if (!isExist) {
        return 0;
      }
      final delResult = await qiZhengSiYuPanRepository.softDelete(uuid, _ctx);
      switch (delResult) {
        case Ok(): break;
        case Err(:final error): throw error;
      }
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
