import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'zhu_luo_san_xian_tables.dart';
import 'zhu_luo_san_xian_palace_math.dart';
import 'zhu_luo_san_xian_config.dart';

class ZhuLuoInput {
  final EnumTwelveGong lifePalace;
  final BirthSect birthSect;
  final Map<ZhuLuoRuler, EnumTwelveGong> rulerPalaces;
  final int maxAge;
  final ZhuLuoAlgorithmConfig config;

  const ZhuLuoInput({
    required this.lifePalace,
    required this.birthSect,
    required this.rulerPalaces,
    required this.maxAge,
    required this.config,
  });
}

class ZhuLuoYearResult {
  final int age;
  final LimitStage stage;
  final ZhuLuoRuler ruler;
  final EnumTwelveGong palace;
  final ZhuLuoAlgorithmId algorithmId;
  final String phase;
  final bool isTransitionYear;
  final bool usedBridge;

  const ZhuLuoYearResult({
    required this.age,
    required this.stage,
    required this.ruler,
    required this.palace,
    required this.algorithmId,
    required this.phase,
    required this.isTransitionYear,
    required this.usedBridge,
  });
}

List<ZhuLuoYearResult> calculateZhuLuoSanXian(ZhuLuoInput input) {
  final rulers = zhuLuoLimitRulers(input.lifePalace, input.birthSect);
  final results = <ZhuLuoYearResult>[];
  var currentAge = 1;

  for (var stageIdx = 0; stageIdx < 3 && currentAge <= input.maxAge; stageIdx++) {
    final ruler = rulers[stageIdx];
    final stage = LimitStage.values[stageIdx];
    final startPalace = input.rulerPalaces[ruler]!;
    final dur = rulerDuration(ruler);

    for (var y = 0; y < dur && currentAge <= input.maxAge; y++, currentAge++) {
      EnumTwelveGong palace;
      String phase;

      if (stageIdx == 0 && input.config.usesInverseSections && y < input.config.sectionLength) {
        palace = movePalace(startPalace, y * input.config.inverseSectionOffset);
        phase = "inverse";
      } else {
        final directStart = stageIdx == 0 && input.config.usesInverseSections
            ? movePalace(startPalace, input.config.sectionLength * input.config.inverseSectionOffset)
            : startPalace;
        final directY = stageIdx == 0 && input.config.usesInverseSections
            ? y - input.config.sectionLength
            : y;
        palace = movePalace(directStart, directY * input.config.annualDirection);
        phase = "direct";
      }

      results.add(ZhuLuoYearResult(
        age: currentAge,
        stage: stage,
        ruler: ruler,
        palace: palace,
        algorithmId: input.config.id,
        phase: phase,
        isTransitionYear: y == 0,
        usedBridge: false,
      ));
    }
  }

  return results;
}
