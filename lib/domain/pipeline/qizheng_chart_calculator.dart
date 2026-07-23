import 'dart:convert';

import 'package:metaphysics_core/enums.dart';
import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';

import '../entities/models/observer_position.dart';
import '../entities/models/star_angle_speed.dart';
import '../../enums/enum_panel_system_type.dart';
import '../entities/models/star_position_raw_data.dart';
import '../services/generate_base_panel_service.dart';
import '../managers/shen_sha_manager.dart';
import '../managers/hua_yao_manager.dart';
import '../engines/i_calculation_engine.dart';
import 'qizheng_calculation_context.dart';
import 'qizheng_chart_params.dart';

final class QizhengChartCalculator
    implements ChartCalculator<QizhengChartParams, QiZhengSiYuPanContract> {
  final QizhengCalculationContext context;
  final ICalculationEngine engine;

  const QizhengChartCalculator({
    required this.context,
    required this.engine,
  });

  @override
  String get module => 'qizhengsiyu';

  @override
  QiZhengSiYuPanContract calculate(ResolvedMoment moment, QizhengChartParams params) {
    final op = ObserverPosition(
      dateTime: moment.nominalTime,
      latitude: params.observerPosition.latitude,
      longitude: params.observerPosition.longitude,
      altitude: params.observerPosition.altitude,
      timezone: params.observerPosition.timezone,
      yearGanZhi: moment.eightChars.year,
      monthGanZhi: moment.eightChars.month,
      dayGanZhi: moment.eightChars.day,
      timeGanZhi: moment.eightChars.time,
      isDayBirth: moment.nominalTime.hour >= 6 && moment.nominalTime.hour < 18,
    );

    final starPositions = engine.calculateStarPositionsSync(
      moment.nominalTime, op, params.panelConfig, context.zhouTianModel,
    );
    final starAngleMapper = _positionsToAngleMapper(
      starPositions,
      panelSystemType: params.panelConfig.panelSystemType,
      coordinateSystem: params.panelConfig.celestialCoordinateSystem,
    );

    final service = GenerateBasePanelService(
      panelConfig: params.panelConfig,
      observerPosition: op,
    );

    final enteredGongMapper = service.getStarEnteredInfoMapper(
      starAngleMapper, context.zhouTianModel,
    );

    final bodyLifeModel = service.calculateLifeBodyAndMaster(
      context.zhouTianModel,
      enteredGongMapper[EnumStars.Sun]!,
      enteredGongMapper[EnumStars.Moon]!,
    );

    final lifeGong = bodyLifeModel.lifeGongInfo.gong;
    final sunGong = enteredGongMapper[EnumStars.Sun]!.enterGongInfo.gong;
    final moonGong = enteredGongMapper[EnumStars.Moon]!.enterGongInfo.gong;

    final shenShaMapper = ShenShaManager.calculateShenShaSync(
      yearJiaZi: op.yearGanZhi,
      monthJiaZi: op.monthGanZhi,
      hourJiaZi: op.timeGanZhi,
      mingGong: lifeGong,
      sunGong: sunGong,
      moonGong: moonGong,
      isDayBirth: op.isDayBirth,
      otherShenSha: context.otherShenSha,
      ganZhiShenSha: context.ganZhiShenSha,
      tianGanShenSha: context.tianGanShenSha,
      yearDiZhiShenSha: context.yearDiZhiShenSha,
      monthDiZhiShenSha: context.monthDiZhiShenSha,
      bundledShenSha: context.bundledShenSha,
    );

    final huaYaoMapper = HuaYaoManager.calculateHuaYaoSync(
      mingGong: lifeGong,
      yearJiaZi: op.yearGanZhi,
      monthJiaZi: op.monthGanZhi,
      tianGanHuaYao: context.tianGanHuaYao,
      diZhiHuaYao: context.diZhiHuaYao,
      othersHuaYao: context.othersHuaYao,
    );

    final panel = service.calculateSync(
      zhouTianModel: context.zhouTianModel,
      starAngleMapper: starAngleMapper,
      shenShaMapper: shenShaMapper,
      huaYaoMapper: huaYaoMapper,
    );

    return QiZhengSiYuPanContract(
      uuid: params.uuid,
      createdAt: params.createdAt,
      lastUpdatedAt: params.lastUpdatedAt,
      deletedAt: null,
      divinationRequestInfoUuid: params.divinationRequestInfoUuid,
      divinationDatetimeJson: params.divinationDatetimeJson,
      panelConfigJson: jsonEncode(params.panelConfig.toJson()),
      panelModelJson: jsonEncode(panel.toJson()),
    );
  }

  static Map<EnumStars, StarAngleSpeed> _positionsToAngleMapper(
    List<StarPositionRawData> positions, {
    PanelSystemType? panelSystemType,
    CelestialCoordinateSystem? coordinateSystem,
  }) {
    final mapper = <EnumStars, StarAngleSpeed>{};
    for (final pos in positions) {
      final filtered = pos.angleRawInfoSet.where(
        (info) =>
            info.panelSystemType == panelSystemType &&
            info.coordinateSystem == coordinateSystem,
      );
      if (filtered.isEmpty) {
        throw ArgumentError(
          'No angle info for ${pos.starType} matching '
          'panelSystemType=$panelSystemType, coordinateSystem=$coordinateSystem',
        );
      }
      final info = filtered.first;
      mapper[pos.starType] = StarAngleSpeed(
        angle: info.angle,
        speed: info.speed,
      );
    }
    return mapper;
  }
}
