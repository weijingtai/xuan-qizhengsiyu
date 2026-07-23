import 'package:metaphysics_core/models/shen_sha_bundled.dart';
import 'package:metaphysics_core/models/shen_sha_gan_zhi.dart';
import 'package:metaphysics_core/models/shen_sha_di_zhi.dart';
import 'package:metaphysics_core/models/shen_sha_tian_gan.dart';
import 'package:qizhengsiyu/domain/entities/models/hua_yao.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/engines/i_calculation_engine.dart';
import 'package:qizhengsiyu/domain/services/hua_yao_service.dart';
import 'package:qizhengsiyu/domain/services/shen_sha_service.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';

class QizhengCalculationContext {
  final ZhouTianModel zhouTianModel;

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
    required ICalculationEngine engine,
    required ShenShaService shenShaService,
    required HuaYaoService huaYaoService,
  }) async {
    final zhouTianModel = await engine.getSystemDefinition(config);

    return QizhengCalculationContext(
      zhouTianModel: zhouTianModel,
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
}
