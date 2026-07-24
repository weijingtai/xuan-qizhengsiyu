import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/star_angle_speed.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/engines/calculation_engine_factory.dart';
import 'package:qizhengsiyu/domain/pipeline/qizheng_calculation_context.dart';
import 'package:qizhengsiyu/domain/pipeline/qizheng_chart_calculator.dart';
import 'package:qizhengsiyu/domain/pipeline/qizheng_chart_params.dart';
import 'package:qizhengsiyu/domain/services/shen_sha_service.dart';
import 'package:qizhengsiyu/domain/services/hua_yao_service.dart';
import 'package:qizhengsiyu/domain/entities/models/pan_entity.dart';
import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';

class QizhengPipelineResult {
  final BasePanelModel panelModel;
  final ZhouTianModel zhouTianModel;
  final Map<EnumStars, StarAngleSpeed> starAngleMapper;
  QizhengPipelineResult({
    required this.panelModel,
    required this.zhouTianModel,
    required this.starAngleMapper,
  });
}

class QizhengPipelineExecutor {
  Future<QizhengPipelineResult> execute({
    required ResolvedMoment moment,
    required BasePanelConfig config,
    required ObserverPosition observer,
    required ShenShaService shenShaService,
    required HuaYaoService huaYaoService,
    required String divinationRequestInfoUuid,
    required String divinationDatetimeJson,
    required String uuid,
    required DateTime createdAt,
  }) async {
    final engine = CalculationEngineFactory.create(config);
    final ctx = await QizhengCalculationContext.load(
      config: config,
      engine: engine,
      shenShaService: shenShaService,
      huaYaoService: huaYaoService,
    );
    final params = QizhengChartParams(
      uuid: uuid,
      createdAt: createdAt,
      lastUpdatedAt: createdAt,
      divinationRequestInfoUuid: divinationRequestInfoUuid,
      divinationDatetimeJson: divinationDatetimeJson,
      panelConfig: config,
      observerPosition: observer,
    );
    final calculator = QizhengChartCalculator(context: ctx, engine: engine);
    final contract = calculator.calculate(moment, params);
    final entity = QiZhengSiYuPanEntity.fromContract(contract);
    return QizhengPipelineResult(
      panelModel: entity.panelModel,
      zhouTianModel: ctx.zhouTianModel,
      starAngleMapper: entity.panelModel.starAngleMapper,
    );
  }
}
