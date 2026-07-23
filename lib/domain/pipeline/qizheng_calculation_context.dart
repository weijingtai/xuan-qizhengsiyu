import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/shen_sha_bundled.dart';
import 'package:metaphysics_core/models/shen_sha_gan_zhi.dart';
import 'package:metaphysics_core/models/shen_sha_di_zhi.dart';
import 'package:metaphysics_core/models/shen_sha_tian_gan.dart';
import 'package:qizhengsiyu/domain/entities/models/hua_yao.dart';
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/star_angle_raw_info.dart';
import 'package:qizhengsiyu/domain/entities/models/star_position_raw_data.dart';
import 'package:qizhengsiyu/domain/entities/models/star_angle_speed.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/engines/i_calculation_engine.dart';
import 'package:qizhengsiyu/domain/services/hua_yao_service.dart';
import 'package:qizhengsiyu/domain/services/shen_sha_service.dart';

class QizhengCalculationContext {
  final ZhouTianModel zhouTianModel;
  final Map<EnumStars, StarAngleSpeed> starAngleMapper;

  final List<OtherShenSha> otherShenSha;
  final List<GanZhiShenSha> ganZhiShenSha;
  final List<TianGanShenSha> tianGanShenSha;
  final List<DiZhiShenSha> yearDiZhiShenSha;
  final List<DiZhiShenSha> monthDiZhiShenSha;
  final List<BundledShenSha> bundledShenSha;

  final List<TianGanHuaYao> tianGanHuaYao;
  final List<DiZhiHuaYao> diZhiHuaYao;
  final List<OthersHuaYao> othersHuaYao;

  const QizhengCalculationContext({
    required this.zhouTianModel,
    required this.starAngleMapper,
    required this.otherShenSha,
    required this.ganZhiShenSha,
    required this.tianGanShenSha,
    required this.yearDiZhiShenSha,
    required this.monthDiZhiShenSha,
    required this.bundledShenSha,
    required this.tianGanHuaYao,
    required this.diZhiHuaYao,
    required this.othersHuaYao,
  });

  static Future<QizhengCalculationContext> load({
    required BasePanelConfig config,
    required ObserverPosition observerPosition,
    required ICalculationEngine engine,
    required ShenShaService shenShaService,
    required HuaYaoService huaYaoService,
  }) async {
    final zhouTianModel = await engine.getSystemDefinition(config);
    final starPositions = await engine.calculateStarPositions(
      observerPosition.dateTime, observerPosition, config,
    );
    final starAngleMapper = _positionsToAngleMapper(
      starPositions,
      panelSystemType: config.panelSystemType,
      coordinateSystem: config.celestialCoordinateSystem,
    );

    return QizhengCalculationContext(
      zhouTianModel: zhouTianModel,
      starAngleMapper: starAngleMapper,
      otherShenSha: await shenShaService.getOtherShenSha(),
      ganZhiShenSha: await shenShaService.getGanZhiShenSha(),
      tianGanShenSha: await shenShaService.getTianGanShenSha(),
      yearDiZhiShenSha: await shenShaService.getYearDiZhiShenSha(),
      monthDiZhiShenSha: await shenShaService.getMonthDiZhiShenSha(),
      bundledShenSha: await shenShaService.getBundledShenSha(),
      tianGanHuaYao: await huaYaoService.getTianGanHuaYao(),
      diZhiHuaYao: await huaYaoService.getDiZhiHuaYao(),
      othersHuaYao: await huaYaoService.getOthersHuaYao(),
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
      final info = filtered.isNotEmpty ? filtered.first : pos.angleRawInfoSet.first;
      mapper[pos.starType] = StarAngleSpeed(
        angle: info.angle,
        speed: info.speed,
      );
    }
    return mapper;
  }
}
