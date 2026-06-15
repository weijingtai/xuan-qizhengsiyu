import 'dart:convert';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';

import 'base_panel_model.dart';

class QiZhengSiYuPanEntity {
  String uuid;
  DateTime createdAt;
  DateTime lastUpdatedAt;
  DateTime? deletedAt;

  String divinationRequestInfoUuid;

  DivinationDatetimeModel divinationDatetimeModel;
  BasePanelConfig panelConfig;
  BasePanelModel panelModel;
  QiZhengSiYuPanEntity({
    required this.uuid,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.deletedAt,
    required this.divinationRequestInfoUuid,
    required this.panelConfig,
    required this.panelModel,
    required this.divinationDatetimeModel,
  });

  QiZhengSiYuPanEntity copyWith({
    String? uuid,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    DateTime? deletedAt,
    String? divinationRequestInfoUuid,
    DivinationDatetimeModel? divinationDatetimeModel,
    BasePanelConfig? panelConfig,
    BasePanelModel? panelModel,
  }) {
    return QiZhengSiYuPanEntity(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      divinationRequestInfoUuid:
          divinationRequestInfoUuid ?? this.divinationRequestInfoUuid,
      divinationDatetimeModel:
          divinationDatetimeModel ?? this.divinationDatetimeModel,
      panelConfig: panelConfig ?? this.panelConfig,
      panelModel: panelModel ?? this.panelModel,
    );
  }

  QiZhengSiYuPanContract toContract() {
    return QiZhengSiYuPanContract(
      uuid: uuid,
      createdAt: createdAt,
      lastUpdatedAt: lastUpdatedAt,
      deletedAt: deletedAt,
      divinationRequestInfoUuid: divinationRequestInfoUuid,
      divinationDatetimeJson: jsonEncode(divinationDatetimeModel.toJson()),
      panelConfigJson: jsonEncode(panelConfig.toJson()),
      panelModelJson: jsonEncode(panelModel.toJson()),
    );
  }

  factory QiZhengSiYuPanEntity.fromContract(QiZhengSiYuPanContract contract) {
    return QiZhengSiYuPanEntity(
      uuid: contract.uuid,
      createdAt: contract.createdAt,
      lastUpdatedAt: contract.lastUpdatedAt,
      deletedAt: contract.deletedAt,
      divinationRequestInfoUuid: contract.divinationRequestInfoUuid,
      divinationDatetimeModel: DivinationDatetimeModel.fromJson(
          jsonDecode(contract.divinationDatetimeJson) as Map<String, dynamic>),
      panelConfig: BasePanelConfig.fromJson(
          jsonDecode(contract.panelConfigJson) as Map<String, dynamic>),
      panelModel: BasePanelModel.fromJson(
          jsonDecode(contract.panelModelJson) as Map<String, dynamic>),
    );
  }
}
