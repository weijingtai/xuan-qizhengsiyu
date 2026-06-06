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
  
  // Collect stage records for all three stages.
  final stageRecordsList = <List<ZhuLuoYearResult>>[];
  var nextStageStartAge = 1;

  for (var stageIdx = 0; stageIdx < 3; stageIdx++) {
    final ruler = rulers[stageIdx];
    final stage = LimitStage.values[stageIdx];
    final startPalace = input.rulerPalaces[ruler];
    if (startPalace == null) {
      // If the ruler's palace is not provided, we cannot calculate this stage.
      break;
    }
    final dur = rulerDuration(ruler);
    final N = rulerNumber(ruler);
    final startAge = stageIdx == 0 ? 1 : nextStageStartAge;
    
    // Safety check: if startAge has exceeded maxAge, no need to calculate this stage.
    if (startAge > input.maxAge) {
      break;
    }

    final stageRecords = <ZhuLuoYearResult>[];

    if (input.config.usesInverseSections) {
      // A 法: 起宫停星数年、逆节 10 年、再逆节 10 年、零年顺行，遇下一限主交限，未交则延行
      for (var t = 1; ; t++) {
        final age = startAge + t - 1;
        if (age > input.maxAge) break;

        EnumTwelveGong palace;
        String phase;

        if (t <= N) {
          palace = startPalace;
          phase = "hold";
        } else if (t <= N + 10) {
          palace = movePalace(startPalace, -2);
          phase = "inverse";
        } else if (t <= N + 20) {
          palace = movePalace(startPalace, -4);
          phase = "inverse";
        } else {
          palace = movePalace(startPalace, -4 + (t - N - 20) * input.config.annualDirection);
          phase = "direct";
        }

        stageRecords.add(ZhuLuoYearResult(
          age: age,
          stage: stage,
          ruler: ruler,
          palace: palace,
          algorithmId: input.config.id,
          phase: phase,
          isTransitionYear: t == 1,
          usedBridge: false,
        ));

        // Check for transition to next stage (stageIdx < 2)
        if (stageIdx < 2) {
          final nextRuler = rulers[stageIdx + 1];
          final nextRulerPalace = input.rulerPalaces[nextRuler];
          if (nextRulerPalace != null) {
            if (t >= dur && palace == nextRulerPalace) {
              nextStageStartAge = age;
              break;
            }
          } else {
            if (t >= dur) {
              nextStageStartAge = age + 1;
              break;
            }
          }
        } else {
          // Last stage
          if (t >= dur && age >= input.maxAge) {
            break;
          }
        }
      }
    } else {
      // B 法: 起宫停星数年，顺排行年，交限，补桥
      var bridgeTriggered = false;
      var bridgeStartT = 0;
      var bridgePalaces = <EnumTwelveGong>[];

      for (var t = 1; ; t++) {
        final age = startAge + t - 1;
        if (age > input.maxAge) break;

        EnumTwelveGong palace;
        String phase;
        var usedBridge = false;

        if (bridgeTriggered) {
          final nextRuler = stageIdx < 2 ? rulers[stageIdx + 1] : null;
          final m = nextRuler != null ? rulerNumber(nextRuler) : 1;
          final bridgePalaceIndex = (t - bridgeStartT) ~/ m;
          
          if (bridgePalaceIndex < bridgePalaces.length) {
            palace = bridgePalaces[bridgePalaceIndex];
          } else {
            palace = bridgePalaces.last;
          }
          phase = "bridge";
          usedBridge = true;
        } else {
          if (t <= N) {
            palace = startPalace;
            phase = "hold";
          } else {
            palace = movePalace(startPalace, (t - N) * input.config.annualDirection);
            phase = "direct";
          }
        }

        // Check if we should trigger bridge for subsequent years
        if (!bridgeTriggered && input.config.bridgeMode == BridgeMode.nextRulerNumberBridge && stageIdx < 2) {
          final nextRuler = rulers[stageIdx + 1];
          final nextRulerPalace = input.rulerPalaces[nextRuler];
          if (nextRulerPalace != null) {
            final m = rulerNumber(nextRuler);
            final d = forwardDistance(palace, nextRulerPalace);
            final R = dur - t;
            if (d > 0 && R == d * m) {
              bridgeTriggered = true;
              bridgeStartT = t + 1;
              bridgePalaces = List.generate(
                d,
                (idx) => movePalace(palace, (idx + 1) * input.config.annualDirection),
              );
            }
          }
        }

        stageRecords.add(ZhuLuoYearResult(
          age: age,
          stage: stage,
          ruler: ruler,
          palace: palace,
          algorithmId: input.config.id,
          phase: phase,
          isTransitionYear: t == 1,
          usedBridge: usedBridge,
        ));

        // Check for transition to next stage (stageIdx < 2)
        if (stageIdx < 2) {
          final nextRuler = rulers[stageIdx + 1];
          final nextRulerPalace = input.rulerPalaces[nextRuler];
          if (nextRulerPalace != null) {
            if (bridgeTriggered) {
              if (t == dur) {
                final d = bridgePalaces.length;
                final m = rulerNumber(nextRuler);
                final targetT = bridgeStartT + (d - 1) * m;
                nextStageStartAge = startAge + targetT - 1;
                break;
              }
            } else {
              if (t >= dur && palace == nextRulerPalace) {
                nextStageStartAge = age;
                break;
              }
            }
          } else {
            if (t >= dur) {
              nextStageStartAge = age + 1;
              break;
            }
          }
        } else {
          // Last stage
          if (t >= dur && age >= input.maxAge) {
            break;
          }
        }
      }
    }

    stageRecordsList.add(stageRecords);
  }

  // Merge/deduplicate records by age
  final allRecords = <ZhuLuoYearResult>[];
  final recordsByAge = <int, List<ZhuLuoYearResult>>{};
  
  for (final stageRecords in stageRecordsList) {
    for (final rec in stageRecords) {
      recordsByAge.putIfAbsent(rec.age, () => []).add(rec);
    }
  }

  for (var age = 1; age <= input.maxAge; age++) {
    final recs = recordsByAge[age];
    if (recs == null || recs.isEmpty) {
      continue;
    }
    if (recs.length == 1) {
      allRecords.add(recs.first);
    } else {
      recs.sort((a, b) => a.stage.index.compareTo(b.stage.index));
      final base = recs.last;
      
      final usedBridge = recs.any((r) => r.usedBridge);
      final isTransitionYear = true;

      allRecords.add(ZhuLuoYearResult(
        age: base.age,
        stage: base.stage,
        ruler: base.ruler,
        palace: base.palace,
        algorithmId: base.algorithmId,
        phase: base.phase,
        isTransitionYear: isTransitionYear,
        usedBridge: usedBridge,
      ));
    }
  }

  return allRecords;
}
