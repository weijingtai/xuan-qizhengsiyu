import 'dart:convert';

import 'package:metaphysics_core/enums.dart';
import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';

import '../services/generate_base_panel_service.dart';
import '../managers/shen_sha_manager.dart';
import '../managers/hua_yao_manager.dart';
import 'qizheng_calculation_context.dart';
import 'qizheng_chart_params.dart';

import 'package:qizhengsiyu/domain/repositories/shen_sha_repository.dart';
import 'package:qizhengsiyu/domain/repositories/hua_yao_repository.dart';
import 'package:qizhengsiyu/domain/services/shen_sha_service.dart';
import 'package:qizhengsiyu/domain/services/hua_yao_service.dart';

final class QizhengChartCalculator
    implements ChartCalculator<QizhengChartParams, QiZhengSiYuPanContract> {
  final QizhengCalculationContext context;

  const QizhengChartCalculator({required this.context});

  @override
  String get module => 'qizhengsiyu';

  @override
  QiZhengSiYuPanContract calculate(ResolvedMoment moment, QizhengChartParams params) {
    final service = GenerateBasePanelService(
      panelConfig: params.panelConfig,
      observerPosition: params.observerPosition,
      shenShaManager: ShenShaManager(shenShaService: _stubShenShaService),
      huaYaoManager: HuaYaoManager(huaYaoService: _stubHuaYaoService),
    );

    final enteredGongMapper = service.getStarEnteredInfoMapper(
      context.starAngleMapper, context.zhouTianModel,
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
      yearJiaZi: params.observerPosition.yearGanZhi,
      monthJiaZi: params.observerPosition.monthGanZhi,
      hourJiaZi: params.observerPosition.timeGanZhi,
      mingGong: lifeGong,
      sunGong: sunGong,
      moonGong: moonGong,
      isDayBirth: params.observerPosition.isDayBirth,
      otherShenSha: context.otherShenSha,
      ganZhiShenSha: context.ganZhiShenSha,
      tianGanShenSha: context.tianGanShenSha,
      yearDiZhiShenSha: context.yearDiZhiShenSha,
      monthDiZhiShenSha: context.monthDiZhiShenSha,
      bundledShenSha: context.bundledShenSha,
    );

    final huaYaoMapper = HuaYaoManager.calculateHuaYaoSync(
      mingGong: lifeGong,
      yearJiaZi: params.observerPosition.yearGanZhi,
      monthJiaZi: params.observerPosition.monthGanZhi,
      tianGanHuaYao: context.tianGanHuaYao,
      diZhiHuaYao: context.diZhiHuaYao,
      othersHuaYao: context.othersHuaYao,
    );

    final panel = service.calculateSync(
      zhouTianModel: context.zhouTianModel,
      starAngleMapper: context.starAngleMapper,
      shenShaMapper: shenShaMapper,
      huaYaoMapper: huaYaoMapper,
    );

    return QiZhengSiYuPanContract(
      uuid: params.uuid,
      createdAt: params.createdAt,
      lastUpdatedAt: params.lastUpdatedAt,
      deletedAt: null,
      divinationRequestInfoUuid: params.divinationRequestInfoUuid,
      divinationDatetimeJson: jsonEncode({
        'instantUtc': moment.source.instantUtc.toIso8601String(),
        'place': {'longitude': moment.source.place.longitude, 'latitude': moment.source.place.latitude},
        'reckoning': moment.source.reckoning.name,
      }),
      panelConfigJson: jsonEncode(params.panelConfig.toJson()),
      panelModelJson: jsonEncode(panel.toJson()),
    );
  }
}

final _stubShenShaService = _StubShenShaService();
final _stubHuaYaoService = _StubHuaYaoService();

class _StubShenShaRepository extends Object implements ShenShaRepository {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _StubHuaYaoRepository extends Object implements HuaYaoRepository {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _StubShenShaService extends ShenShaService {
  _StubShenShaService() : super(repository: _StubShenShaRepository());
}

class _StubHuaYaoService extends HuaYaoService {
  _StubHuaYaoService() : super(repository: _StubHuaYaoRepository());
}
