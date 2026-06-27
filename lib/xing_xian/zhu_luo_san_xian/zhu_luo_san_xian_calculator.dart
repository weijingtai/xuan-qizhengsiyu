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
  
  final stageRecordsList = <List<ZhuLuoYearResult>>[];
  var nextStageStartAge = 1;

  for (var stageIdx = 0; stageIdx < 3; stageIdx++) {
    final ruler = rulers[stageIdx];
    final stage = LimitStage.values[stageIdx];
    final startPalace = input.rulerPalaces[ruler];
    if (startPalace == null) {
      break;
    }
    final dur = rulerDuration(ruler);
    final N = rulerNumber(ruler);
    final startAge = stageIdx == 0 ? 1 : nextStageStartAge;
    
    if (startAge > input.maxAge) {
      break;
    }

    final stageRecords = <ZhuLuoYearResult>[];
    
    // 标准段：本宫静守 N 年 + 顺行充满 T 年
    // 所有方案的标准段完全一致 (Doc B §3)
    for (var t = 1; t <= dur; t++) {
      final age = startAge + t - 1;
      if (age > input.maxAge) break;

      EnumTwelveGong palace;
      String phase;

      if (t <= N) {
        // 本宫静守：等分本宫为 N 段
        palace = startPalace;
        phase = "hold";
      } else {
        // 顺行充满标准年限：每年顺行一宫
        palace = movePalace(startPalace, t - N);
        phase = "direct";
      }

      stageRecords.add(ZhuLuoYearResult(
        age: age,
        stage: stage,
        ruler: ruler,
        palace: palace,
        algorithmId: input.config.id,
        phase: phase,
        isTransitionYear: false,
        usedBridge: false,
      ));
    }

    // 交限段（age >= startAge + T 起，四套方案分歧，见 Doc B §4）
    if (stageIdx < 2) {
      final nextRuler = rulers[stageIdx + 1];
      final nextRulerPalace = input.rulerPalaces[nextRuler];
      if (nextRulerPalace == null) {
        stageRecordsList.add(stageRecords);
        nextStageStartAge = startAge + dur;
        continue;
      }

      final pEnd = movePalace(startPalace, dur - N);
      final ageEnd = startAge + dur - 1;

      // 根据方案执行不同的交限策略
      final transitionResult = _planTransition(
        config: input.config,
        p0: startPalace,
        N: N,
        T: dur,
        startAge: startAge,
        pEnd: pEnd,
        ageEnd: ageEnd,
        pNext: nextRulerPalace,
        nextRuler: nextRuler,
        stage: stage,
        ruler: ruler,
        maxAge: input.maxAge,
      );

      stageRecords.addAll(transitionResult.segments);
      nextStageStartAge = transitionResult.nextStageStartAge;
    } else {
      // 最后一限
      nextStageStartAge = startAge + dur;
    }

    stageRecordsList.add(stageRecords);
  }

  // 合并/去重记录
  return _mergeRecords(stageRecordsList);
}

class _TransitionResult {
  final List<ZhuLuoYearResult> segments;
  final int nextStageStartAge;

  const _TransitionResult({
    required this.segments,
    required this.nextStageStartAge,
  });
}

/// 根据方案执行交限策略 (Doc B §4)
_TransitionResult _planTransition({
  required ZhuLuoAlgorithmConfig config,
  required EnumTwelveGong p0,
  required int N,
  required int T,
  required int startAge,
  required EnumTwelveGong pEnd,
  required int ageEnd,
  required EnumTwelveGong pNext,
  required ZhuLuoRuler nextRuler,
  required LimitStage stage,
  required ZhuLuoRuler ruler,
  required int maxAge,
}) {
  switch (config.id) {
    case ZhuLuoAlgorithmId.classicForwardUntilTarget:
      return _planClassicForward(
        p0: p0, N: N, T: T, startAge: startAge,
        pEnd: pEnd, ageEnd: ageEnd, pNext: pNext,
        nextRuler: nextRuler, stage: stage, ruler: ruler, maxAge: maxAge,
      );
    case ZhuLuoAlgorithmId.forceCut:
      return _planForceCut(
        p0: p0, N: N, T: T, startAge: startAge,
        pEnd: pEnd, ageEnd: ageEnd, pNext: pNext,
        nextRuler: nextRuler, stage: stage, ruler: ruler, maxAge: maxAge,
      );
    case ZhuLuoAlgorithmId.retrace:
      return _planRetrace(
        p0: p0, N: N, T: T, startAge: startAge,
        pEnd: pEnd, ageEnd: ageEnd, pNext: pNext,
        nextRuler: nextRuler, stage: stage, ruler: ruler, maxAge: maxAge,
      );
    case ZhuLuoAlgorithmId.bridgeWithFallback:
      return _planBridgeWithFallback(
        p0: p0, N: N, T: T, startAge: startAge,
        pEnd: pEnd, ageEnd: ageEnd, pNext: pNext,
        nextRuler: nextRuler, stage: stage, ruler: ruler, maxAge: maxAge,
      );
  }
}

/// 方案1: 候星逐宫延交法 (A法·古籍正统)
/// 触发条件：行限落宫 == pNext
/// 三场景：
/// 1. pEnd == pNext：当年交限
/// 2. 未到 pNext：继续顺行一年一宫，逐年候至落宫==pNext
/// 3. 已过 pNext：不折返，继续顺行循环十二宫，下一圈重逢 pNext
_TransitionResult _planClassicForward({
  required EnumTwelveGong p0,
  required int N,
  required int T,
  required int startAge,
  required EnumTwelveGong pEnd,
  required int ageEnd,
  required EnumTwelveGong pNext,
  required ZhuLuoRuler nextRuler,
  required LimitStage stage,
  required ZhuLuoRuler ruler,
  required int maxAge,
}) {
  final segments = <ZhuLuoYearResult>[];
  
  // 场景1: pEnd == pNext，当年交限
  if (pEnd == pNext) {
    // 交限发生，不需要尾段
    return _TransitionResult(
      segments: segments,
      nextStageStartAge: ageEnd,
    );
  }

  // 场景2/3: 继续顺行一年一宫，直到落宫==pNext
  var currentPalace = pEnd;
  var age = ageEnd + 1;
  
  while (age <= maxAge) {
    currentPalace = movePalace(currentPalace, 1);
    
    segments.add(ZhuLuoYearResult(
      age: age,
      stage: stage,
      ruler: ruler,
      palace: currentPalace,
      algorithmId: ZhuLuoAlgorithmId.classicForwardUntilTarget,
      phase: "yanJiao",
      isTransitionYear: currentPalace == pNext,
      usedBridge: false,
    ));

    if (currentPalace == pNext) {
      return _TransitionResult(
        segments: segments,
        nextStageStartAge: age,
      );
    }
    
    age++;
  }

  // 未找到交限点，返回当前状态
  return _TransitionResult(
    segments: segments,
    nextStageStartAge: age,
  );
}

/// 方案2: 年限强制切换法 (商用简化)
///
/// 特点：标准年限一到，不管有没有走到、有没有错过下一限主星本宫，立刻强制切换。
///
/// 行为：
/// - 土星初限满26年，到达26岁
/// - 不看当年落在未宫、去年已经路过午宫这件事，不等待、不回头
/// - 26岁直接作废土星初限，强制切换为月亮中限
/// - 25岁午宫错过的交限窗口直接作废，不再处理
/// - 全程只顺行、不等待
_TransitionResult _planForceCut({
  required EnumTwelveGong p0,
  required int N,
  required int T,
  required int startAge,
  required EnumTwelveGong pEnd,
  required int ageEnd,
  required EnumTwelveGong pNext,
  required ZhuLuoRuler nextRuler,
  required LimitStage stage,
  required ZhuLuoRuler ruler,
  required int maxAge,
}) {
  // 强制截断：在 ageEnd 处给一个 forced 截断标记
  // 26岁直接作废初限，强制切换为中限
  final segments = <ZhuLuoYearResult>[];
  
  segments.add(ZhuLuoYearResult(
    age: ageEnd,
    stage: stage,
    ruler: ruler,
    palace: pEnd,
    algorithmId: ZhuLuoAlgorithmId.forceCut,
    phase: "forcedCut",
    isTransitionYear: true,
    usedBridge: false,
  ));

  return _TransitionResult(
    segments: segments,
    nextStageStartAge: ageEnd,
  );
}

/// 方案3: 折返补救交限法 (小众私传，考据否定)
///
/// 特点：年限到期没到下星宫会顺行等候，一旦走过下星宫就逆行倒退回到星宫再交限。
///
/// 行为：
/// - 土星初限满26年，当年落在未宫，发现已经走过月亮本宫午
/// - 打破行限只能顺行的规则，流年宫位逆行倒退一格，从未倒回午
/// - 认定26岁行限实质落在午宫，在当年完成初限转中限
/// - 交限完成后，往后年份继续恢复顺行流转
///
/// 注意：违背古籍"零年顺转逐宫移"单向规定，主流考据派不认可。
_TransitionResult _planRetrace({
  required EnumTwelveGong p0,
  required int N,
  required int T,
  required int startAge,
  required EnumTwelveGong pEnd,
  required int ageEnd,
  required EnumTwelveGong pNext,
  required ZhuLuoRuler nextRuler,
  required LimitStage stage,
  required ZhuLuoRuler ruler,
  required int maxAge,
}) {
  final segments = <ZhuLuoYearResult>[];
  
  // 场景1: pEnd == pNext，当年交限
  if (pEnd == pNext) {
    return _TransitionResult(
      segments: segments,
      nextStageStartAge: ageEnd,
    );
  }

  // 计算 pEnd 到 pNext 的顺行距离
  final forwardDist = forwardDistance(pEnd, pNext);
  
  // 如果 forwardDist > 0 且 <= 6，说明还没到 pNext，需要顺行延交（同方案1）
  if (forwardDist > 0 && forwardDist <= 6) {
    // 场景2: 未到 pNext，继续顺行
    return _planClassicForward(
      p0: p0, N: N, T: T, startAge: startAge,
      pEnd: pEnd, ageEnd: ageEnd, pNext: pNext,
      nextRuler: nextRuler, stage: stage, ruler: ruler, maxAge: maxAge,
    );
  }

  // 场景3: 已过 pNext，逆行折返
  // 关键：折返发生在 ageEnd 当年，不是 ageEnd+1
  // 例如：26岁在未宫，已过午宫，折返一格到午宫，认定26岁行限实质落在午宫
  
  // 计算需要折返的距离
  final retraceDist = (12 - forwardDist) % 12;
  
  // 在 ageEnd 当年进行折返
  // 从 pEnd 开始，逆行 retraceDist 步到 pNext
  var currentPalace = pEnd;
  
  for (var i = 0; i < retraceDist; i++) {
    currentPalace = movePalace(currentPalace, -1);
  }
  
  // 折返完成后，ageEnd 当年认定落在 pNext
  segments.add(ZhuLuoYearResult(
    age: ageEnd,
    stage: stage,
    ruler: ruler,
    palace: currentPalace,
    algorithmId: ZhuLuoAlgorithmId.retrace,
    phase: "zheFan",
    isTransitionYear: true,
    usedBridge: false,
  ));

  // 交限完成后，往后年份继续恢复顺行流转
  // nextStageStartAge = ageEnd，中限从 ageEnd 开始
  return _TransitionResult(
    segments: segments,
    nextStageStartAge: ageEnd,
  );
}

/// 方案4: 补桥年限双轨交限法 (B法·西洋改良)
/// 优先触发（补桥）：若满足补桥公式，走完补桥段刚好抵达 pNext
/// 兜底触发：不满足补桥条件 → 年限到期强制切换
_TransitionResult _planBridgeWithFallback({
  required EnumTwelveGong p0,
  required int N,
  required int T,
  required int startAge,
  required EnumTwelveGong pEnd,
  required int ageEnd,
  required EnumTwelveGong pNext,
  required ZhuLuoRuler nextRuler,
  required LimitStage stage,
  required ZhuLuoRuler ruler,
  required int maxAge,
}) {
  final segments = <ZhuLuoYearResult>[];
  
  // 检查补桥条件：剩余年限 = 宫数 × nextStarYears
  final d = forwardDistance(pEnd, pNext);
  final m = rulerNumber(nextRuler);
  final R = T - (T - N);  // 剩余年限 = T - (已走年限)
  
  // 补桥条件：d * m == R
  if (d > 0 && d * m == R) {
    // 补桥段：跨 d 个宫，每年 m 个年龄
    var currentPalace = pEnd;
    var age = ageEnd + 1;
    
    for (var i = 0; i < d; i++) {
      currentPalace = movePalace(currentPalace, 1);
      
      for (var j = 0; j < m; j++) {
        if (age > maxAge) break;
        
        segments.add(ZhuLuoYearResult(
          age: age,
          stage: stage,
          ruler: ruler,
          palace: currentPalace,
          algorithmId: ZhuLuoAlgorithmId.bridgeWithFallback,
          phase: "buQiao",
          isTransitionYear: i == d - 1 && j == m - 1,
          usedBridge: true,
        ));
        
        age++;
      }
    }

    return _TransitionResult(
      segments: segments,
      nextStageStartAge: ageEnd + d * m,
    );
  }

  // 兜底：强制切换（同方案2）
  return _planForceCut(
    p0: p0, N: N, T: T, startAge: startAge,
    pEnd: pEnd, ageEnd: ageEnd, pNext: pNext,
    nextRuler: nextRuler, stage: stage, ruler: ruler, maxAge: maxAge,
  );
}

/// 合并/去重记录 (Doc B §5 三限串接)
List<ZhuLuoYearResult> _mergeRecords(List<List<ZhuLuoYearResult>> stageRecordsList) {
  final allRecords = <ZhuLuoYearResult>[];
  final recordsByAge = <int, List<ZhuLuoYearResult>>{};
  
  for (final stageRecords in stageRecordsList) {
    for (final rec in stageRecords) {
      recordsByAge.putIfAbsent(rec.age, () => []).add(rec);
    }
  }

  for (var age = 1; age <= (recordsByAge.keys.isEmpty ? 0 : recordsByAge.keys.last); age++) {
    final recs = recordsByAge[age];
    if (recs == null || recs.isEmpty) {
      continue;
    }
    if (recs.length == 1) {
      allRecords.add(recs.first);
    } else {
      // 多个记录（交限年），取最新限的记录
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
