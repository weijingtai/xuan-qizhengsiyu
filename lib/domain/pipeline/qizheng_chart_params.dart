import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';

import '../entities/models/panel_config.dart';
import '../entities/models/observer_position.dart';

final class QizhengChartParams implements ModuleParams {
  final String uuid;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final String divinationRequestInfoUuid;
  final BasePanelConfig panelConfig;
  final ObserverPosition observerPosition;

  const QizhengChartParams({
    required this.uuid,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.divinationRequestInfoUuid,
    required this.panelConfig,
    required this.observerPosition,
  });

  @override
  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'createdAt': createdAt.toIso8601String(),
    'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    'divinationRequestInfoUuid': divinationRequestInfoUuid,
    'panelConfig': panelConfig.toJson(),
    'observerPosition': observerPosition.toJson(),
  };
}
