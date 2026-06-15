import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/entities/models/star_position_raw_data.dart';
import 'package:qizhengsiyu/domain/entities/models/star_angle_speed.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/engines/calculation_engine_factory.dart';
import 'package:qizhengsiyu/domain/services/generate_base_panel_service.dart';
import 'package:qizhengsiyu/domain/managers/shen_sha_manager.dart';
import 'package:qizhengsiyu/domain/managers/hua_yao_manager.dart';

class CalculateQiZhengBasePanelResult {
  final BasePanelModel basicLifePanel;
  final ZhouTianModel zhouTianModel;
  final Map<EnumStars, StarAngleSpeed> starAngleMapper;

  CalculateQiZhengBasePanelResult({
    required this.basicLifePanel,
    required this.zhouTianModel,
    required this.starAngleMapper,
  });
}

class CalculateQiZhengBasePanelUseCase {
  final ShenShaManager shenShaManager;
  final HuaYaoManager huaYaoManager;

  CalculateQiZhengBasePanelUseCase({
    required this.shenShaManager,
    required this.huaYaoManager,
  });

  Future<CalculateQiZhengBasePanelResult> execute({
    required BasePanelConfig config,
    required ObserverPosition observer,
  }) async {
    final engine = CalculationEngineFactory.create(config);
    final zhouTianModel = await engine.getSystemDefinition(config);
    final starPositions = await engine.calculateStarPositions(
        observer.dateTime, observer, config);
    final starAngleMapper = _transformStarPositions(starPositions, config);

    final panelService = GenerateBasePanelService(
      panelConfig: config,
      observerPosition: observer,
      shenShaManager: shenShaManager,
      huaYaoManager: huaYaoManager,
    );

    final basicLifePanel = await panelService.calculate(
      zhouTianModel: zhouTianModel,
      starAngleMapper: starAngleMapper,
    );

    return CalculateQiZhengBasePanelResult(
      basicLifePanel: basicLifePanel,
      zhouTianModel: zhouTianModel,
      starAngleMapper: starAngleMapper,
    );
  }

  Map<EnumStars, StarAngleSpeed> _transformStarPositions(
      List<StarPositionRawData> starPositions, BasePanelConfig config) {
    final Map<EnumStars, StarAngleSpeed> mapper = {};
    for (final pos in starPositions) {
      final matchingInfo = pos.angleRawInfoSet.firstWhere(
        (info) =>
            info.panelSystemType == config.panelSystemType &&
            info.coordinateSystem == config.celestialCoordinateSystem,
        orElse: () => pos.angleRawInfoSet.first,
      );
      mapper[pos.starType] = StarAngleSpeed(
        angle: matchingInfo.angle,
        speed: matchingInfo.speed,
      );
    }
    return mapper;
  }
}
