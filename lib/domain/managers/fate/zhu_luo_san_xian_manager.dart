import 'package:xuan_logger/xuan_logger.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_config.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_input_builder.dart';
import 'fate_manager.dart';

// 竹罗三限
class ZhuLuoSanXianManager extends FateManager {
  List<ZhuLuoYearResult> calculateFromRulerPalaces({
    required EnumTwelveGong lifePalace,
    required BirthSect birthSect,
    required Map<ZhuLuoRuler, EnumTwelveGong> rulerPalaces,
    required int maxAge,
    required ZhuLuoAlgorithmConfig config,
  }) {
    return calculateZhuLuoSanXian(
      ZhuLuoInput(
        lifePalace: lifePalace,
        birthSect: birthSect,
        rulerPalaces: rulerPalaces,
        maxAge: maxAge,
        config: config,
      ),
    );
  }

  List<ZhuLuoYearResult> calculateFromStarPalaces({
    required EnumTwelveGong lifePalace,
    required BirthSect birthSect,
    required Map<EnumStars, EnumTwelveGong> starPalaces,
    required int maxAge,
    required ZhuLuoAlgorithmConfig config,
  }) {
    return calculateZhuLuoSanXian(
      buildZhuLuoInputFromStarPalaces(
        lifePalace: lifePalace,
        birthSect: birthSect,
        starPalaces: starPalaces,
        maxAge: maxAge,
        config: config,
      ),
    );
  }

  List<ZhuLuoYearResult> calculateFromPanel({
    required BasePanelModel panel,
    required BirthSect birthSect,
    required int maxAge,
    required ZhuLuoAlgorithmConfig config,
  }) {
    return calculateZhuLuoSanXian(
      buildZhuLuoInputFromPanel(
        panel: panel,
        birthSect: birthSect,
        maxAge: maxAge,
        config: config,
      ),
    );
  }

  @override
  void calculate(DateTime date) {
    logger.i('计算竹罗三限...');
    passToNext(date);
  }
}
