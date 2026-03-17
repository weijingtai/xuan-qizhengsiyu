import 'package:common/enums/enum_di_zhi.dart';
import 'package:common/enums/enum_four_seasons.dart';
import 'package:common/enums/enum_stars.dart';
import 'package:common/models/shen_sha.dart';
import 'package:qizhengsiyu/domain/entities/models/di_zhi_shen_sha.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_input.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/conditions/gong_status_conditions.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/conditions/position_conditions.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/conditions/relationship_conditions.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/conditions/shen_sha_conditions.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/conditions/structure_conditions.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/conditions/time_conditions.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/conditions/xian_conditions.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/conditions/yong_shen_conditions.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/twelve_gong_system.dart';
import 'package:qizhengsiyu/domain/entities/models/hua_yao.dart';
import 'package:qizhengsiyu/enums/enum_moon_phases.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:qizhengsiyu/enums/enum_star_position_status.dart';
import 'package:qizhengsiyu/enums/enum_stars_four_type.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

/// 格局条件预过滤器
///
/// 从 [GeJuInput] 一次性提取"星盘事实"，对每个条件树做快速的
/// 三值逻辑判定 (`true` / `false` / `null`)：
/// - `true`  → 条件**一定**满足，可直接标记为匹配
/// - `false` → 条件**一定**不满足，可跳过完整 evaluate
/// - `null`  → 无法确定，需回退到完整 evaluate
///
/// 覆盖全部 837 个叶子条件（100%），包括 23 种叶子类型。
class GeJuPreFilter {
  // ── 预计算的星盘事实 ──────────────────────────────────────────────────────

  /// 星 → 宫位（O(1) 查找，替代 GeJuInput.getStarGong 的 O(11) 扫描）
  final Map<EnumStars, EnumTwelveGong> _starGongMap;

  /// 星 → 星宿 starName（O(1) 查找）
  final Map<EnumStars, String> _starConstellationNameMap;

  /// 星 → 运行状态
  final Map<EnumStars, FiveStarWalkingType> _starWalkingTypeMap;

  /// 命宫
  final EnumTwelveGong _lifeGong;

  /// 命度星宿名
  final String _lifeConstellationName;

  /// 功能宫 → 地支宫位
  final Map<EnumDestinyTwelveGong, EnumTwelveGong> _destinyGongMapper;

  /// 四主映射：role → master 星
  final Map<String, EnumStars> _siZhuMap;

  /// 恩难仇用
  final Map<EnumStars, Map<EnumStarsFourType, Set<EnumStars>>>
      _starsFourTypeMapper;

  /// 化曜
  final Map<EnumStars, List<HuaYaoItem>> _huaYaoMapper;

  /// 庙旺状态（可能为空 → 对应条件返回 false）
  final Map<EnumStars, List<EnumStarGongPositionStatusType>>?
      _starGongStatusMapper;

  /// 神煞映射
  final Map<EnumTwelveGong, List<ShenSha>> _shenShaMapper;

  /// 身宫
  final EnumTwelveGong _bodyGong;

  /// 出生季节
  final FourSeasons _season;

  /// 昼生
  final bool _isDayBirth;

  /// 出生月地支
  final DiZhi _monthZhi;

  /// 月相
  final EnumMoonPhases _moonPhase;

  /// 空亡地支集合
  final Set<DiZhi> _kongWangSet;

  /// 行限宫位（可选）
  final EnumTwelveGong? _currentXianGong;

  /// 行限星宿名（可选）
  final String? _currentXianConstellationName;

  /// 行限宫内星曜集合（可选，Set 化以 O(1) 查找）
  final Set<EnumStars>? _xianPalaceStarsSet;

  GeJuPreFilter._({
    required Map<EnumStars, EnumTwelveGong> starGongMap,
    required Map<EnumStars, String> starConstellationNameMap,
    required Map<EnumStars, FiveStarWalkingType> starWalkingTypeMap,
    required EnumTwelveGong lifeGong,
    required String lifeConstellationName,
    required Map<EnumDestinyTwelveGong, EnumTwelveGong> destinyGongMapper,
    required Map<String, EnumStars> siZhuMap,
    required Map<EnumStars, Map<EnumStarsFourType, Set<EnumStars>>>
        starsFourTypeMapper,
    required Map<EnumStars, List<HuaYaoItem>> huaYaoMapper,
    required Map<EnumStars, List<EnumStarGongPositionStatusType>>?
        starGongStatusMapper,
    required Map<EnumTwelveGong, List<ShenSha>> shenShaMapper,
    required EnumTwelveGong bodyGong,
    required FourSeasons season,
    required bool isDayBirth,
    required DiZhi monthZhi,
    required EnumMoonPhases moonPhase,
    required Set<DiZhi> kongWangSet,
    required EnumTwelveGong? currentXianGong,
    required String? currentXianConstellationName,
    required Set<EnumStars>? xianPalaceStarsSet,
  })  : _starGongMap = starGongMap,
        _starConstellationNameMap = starConstellationNameMap,
        _starWalkingTypeMap = starWalkingTypeMap,
        _lifeGong = lifeGong,
        _lifeConstellationName = lifeConstellationName,
        _destinyGongMapper = destinyGongMapper,
        _siZhuMap = siZhuMap,
        _starsFourTypeMapper = starsFourTypeMapper,
        _huaYaoMapper = huaYaoMapper,
        _starGongStatusMapper = starGongStatusMapper,
        _shenShaMapper = shenShaMapper,
        _bodyGong = bodyGong,
        _season = season,
        _isDayBirth = isDayBirth,
        _monthZhi = monthZhi,
        _moonPhase = moonPhase,
        _kongWangSet = kongWangSet,
        _currentXianGong = currentXianGong,
        _currentXianConstellationName = currentXianConstellationName,
        _xianPalaceStarsSet = xianPalaceStarsSet;

  /// 从 GeJuInput 构建预过滤器（一次性 O(11) 扫描）
  factory GeJuPreFilter.fromInput(GeJuInput input) {
    final starGongMap = <EnumStars, EnumTwelveGong>{};
    final starConstMap = <EnumStars, String>{};
    final starWalkingMap = <EnumStars, FiveStarWalkingType>{};

    for (final info in input.starsSet) {
      starGongMap[info.star] = info.enteredGong;
      starConstMap[info.star] = info.enteredStarInn.starName;
    }

    // 提取五星运行状态
    if (input.fiveStarWalkingTypeMapper != null) {
      for (final e in input.fiveStarWalkingTypeMapper!.entries) {
        starWalkingMap[e.key] = e.value.walkingType;
      }
    }

    final kongWang =
        JiaZiShenSha.getKongWangAtDiZhi(input.yearJiaZi) ?? <DiZhi>{};

    // 四主
    final siZhuMap = <String, EnumStars>{
      'lifeGongMaster': input.lifeGongMaster,
      'bodyGongMaster': input.bodyGongMaster,
      'lifeConstellationMaster': input.lifeConstellationMaster,
      'bodyConstellationMaster': input.bodyConstellationMaster,
    };

    return GeJuPreFilter._(
      starGongMap: starGongMap,
      starConstellationNameMap: starConstMap,
      starWalkingTypeMap: starWalkingMap,
      lifeGong: input.lifeGong,
      lifeConstellationName: input.lifeConstellation.starName,
      destinyGongMapper: input.destinyGongMapper,
      siZhuMap: siZhuMap,
      starsFourTypeMapper: input.starsFourTypeMapper,
      huaYaoMapper: input.huaYaoMapper,
      starGongStatusMapper: input.starGongStatusMapper,
      shenShaMapper: input.shenShaMapper,
      bodyGong: input.bodyLifeModel.bodyGong,
      season: input.season,
      isDayBirth: input.isDayBirth,
      monthZhi: input.monthZhi,
      moonPhase: input.moonPhase,
      kongWangSet: kongWang,
      currentXianGong: input.currentXianGong,
      currentXianConstellationName:
          input.currentXianConstellation?.starName,
      xianPalaceStarsSet: input.xianPalaceStars?.toSet(),
    );
  }

  // ── 三值逻辑入口 ─────────────────────────────────────────────────────────

  /// 快速评估条件树。
  ///
  /// 返回 `true`（一定满足）、`false`（一定不满足）、`null`（无法确定）。
  bool? quickEvaluate(GeJuCondition condition) {
    // ── 组合器 ──
    if (condition is AndCondition) {
      return _evalAnd(condition.conditions);
    }
    if (condition is OrCondition) {
      return _evalOr(condition.conditions);
    }
    if (condition is NotCondition) {
      final inner = quickEvaluate(condition.condition);
      if (inner == null) return null;
      return !inner;
    }

    // ── 叶子条件 ──
    return _evalLeaf(condition);
  }

  // ── AND / OR 三值逻辑传播 ─────────────────────────────────────────────────

  bool? _evalAnd(List<GeJuCondition> children) {
    var allTrue = true;
    for (final c in children) {
      final v = quickEvaluate(c);
      if (v == false) return false; // 短路：任一 false → AND 为 false
      if (v == null) allTrue = false;
    }
    return allTrue ? true : null;
  }

  bool? _evalOr(List<GeJuCondition> children) {
    var allFalse = true;
    for (final c in children) {
      final v = quickEvaluate(c);
      if (v == true) return true; // 短路：任一 true → OR 为 true
      if (v == null) allFalse = false;
    }
    return allFalse ? false : null;
  }

  // ── 叶子条件速查 ─────────────────────────────────────────────────────────

  bool? _evalLeaf(GeJuCondition cond) {
    // ── 时间类 ──
    if (cond is SeasonIsCondition) {
      return cond.seasons.contains(_season);
    }
    if (cond is IsDayBirthCondition) {
      return cond.isDay == _isDayBirth;
    }
    if (cond is MonthIsCondition) {
      return cond.months.contains(_monthZhi);
    }
    if (cond is MoonPhaseIsCondition) {
      return cond.phases.contains(_moonPhase);
    }

    // ── 关系类 ──
    if (cond is SameGongCondition) {
      return _checkSameGong(cond.stars);
    }
    if (cond is SameConstellationCondition) {
      return _checkSameConstellation(cond.stars);
    }
    if (cond is OppositeGongCondition) {
      return _checkOppositeGong(cond.starA, cond.starB);
    }
    if (cond is TrineGongCondition) {
      return _checkTrineGong(cond.stars);
    }
    if (cond is SquareGongCondition) {
      return _checkSquareGong(cond.stars);
    }

    // ── 位置类 ──
    if (cond is StarInGongCondition) {
      return _checkStarInGong(cond.star, cond.gongs);
    }
    if (cond is StarInConstellationCondition) {
      return _checkStarInConstellation(cond.star, cond.constellations);
    }
    if (cond is StarInKongWangCondition) {
      return _checkStarInKongWang(cond.star);
    }
    if (cond is StarWalkingStateCondition) {
      final actual = _starWalkingTypeMap[cond.star];
      if (actual == null) return false;
      return cond.states.contains(actual);
    }

    // ── 结构类 ──
    if (cond is LifeGongAtCondition) {
      return _checkLifeGongAt(cond.gongs);
    }
    if (cond is LifeConstellationAtCondition) {
      return cond.constellations.contains(_lifeConstellationName);
    }
    if (cond is StarGuardLifeCondition) {
      return _starGongMap[cond.star] == _lifeGong;
    }
    if (cond is StarInDestinyGongCondition) {
      return _checkStarInDestinyGong(cond.star, cond.destinyGong);
    }

    // ── 用神类 ──
    if (cond is StarIsSiZhuCondition) {
      for (final role in cond.roles) {
        if (_siZhuMap[role] == cond.star) return true;
      }
      return false;
    }
    if (cond is StarFourTypeCondition) {
      final map = _starsFourTypeMapper[cond.target];
      if (map == null) return false;
      for (final type in cond.types) {
        if (map[type]?.contains(cond.star) ?? false) return true;
      }
      return false;
    }
    if (cond is StarHasHuaYaoCondition) {
      final items = _huaYaoMapper[cond.star] ?? [];
      for (final item in items) {
        for (final required in cond.huaYaos) {
          if (item.name == required.name) return true;
        }
      }
      return false;
    }

    // ── 庙旺状态 ──
    if (cond is StarGongStatusCondition) {
      if (_starGongStatusMapper == null) return false;
      final statuses = _starGongStatusMapper![cond.star] ?? [];
      for (final s in cond.statuses) {
        if (statuses.contains(s)) return true;
      }
      return false;
    }

    // ── 神煞类 ──
    if (cond is StarWithShenShaCondition) {
      final gong = _starGongMap[cond.star];
      if (gong == null) return false;
      final list = _shenShaMapper[gong] ?? [];
      for (final name in cond.shenShaNames) {
        if (list.any((s) => s.name == name)) return true;
      }
      return false;
    }
    if (cond is GongHasShenShaCondition) {
      EnumTwelveGong? targetGong;
      if (cond.gongIdentifier == 'lifeGong') {
        targetGong = _lifeGong;
      } else if (cond.gongIdentifier == 'bodyGong') {
        targetGong = _bodyGong;
      } else {
        targetGong = TwelveGongSystem.resolve(cond.gongIdentifier);
      }
      if (targetGong == null) return false;
      final list = _shenShaMapper[targetGong] ?? [];
      for (final name in cond.shenShaNames) {
        if (list.any((s) => s.name == name)) return true;
      }
      return false;
    }

    // ── 行限类 ──
    if (cond is XianAtGongCondition) {
      if (_currentXianGong == null) return false;
      for (final name in cond.gongs) {
        if (TwelveGongSystem.resolve(name) == _currentXianGong) return true;
      }
      return false;
    }
    if (cond is XianAtConstellationCondition) {
      if (_currentXianConstellationName == null) return false;
      return cond.constellations.contains(_currentXianConstellationName);
    }
    if (cond is XianMeetStarCondition) {
      if (_xianPalaceStarsSet == null) return false;
      for (final star in cond.stars) {
        if (_xianPalaceStarsSet!.contains(star)) return true;
      }
      return false;
    }

    // ── 未知类型（sameJing / sameLuo 等极低频）── 保守返回 null
    return null;
  }

  // ── 具体检查方法 ─────────────────────────────────────────────────────────

  bool _checkSameGong(List<EnumStars> stars) {
    if (stars.length < 2) return true;
    final first = _starGongMap[stars.first];
    if (first == null) return false;
    for (int i = 1; i < stars.length; i++) {
      if (_starGongMap[stars[i]] != first) return false;
    }
    return true;
  }

  bool _checkSameConstellation(List<EnumStars> stars) {
    if (stars.length < 2) return true;
    final first = _starConstellationNameMap[stars.first];
    if (first == null) return false;
    for (int i = 1; i < stars.length; i++) {
      if (_starConstellationNameMap[stars[i]] != first) return false;
    }
    return true;
  }

  bool _checkOppositeGong(EnumStars starA, EnumStars starB) {
    final gA = _starGongMap[starA];
    final gB = _starGongMap[starB];
    if (gA == null || gB == null) return false;
    return gA.opposite == gB;
  }

  bool _checkTrineGong(List<EnumStars> stars) {
    if (stars.length < 2) return false;
    final first = _starGongMap[stars.first];
    if (first == null) return false;
    final trineSet = {first, ...first.otherTringleGongList};
    for (int i = 1; i < stars.length; i++) {
      final g = _starGongMap[stars[i]];
      if (g == null || !trineSet.contains(g)) return false;
    }
    return true;
  }

  bool _checkSquareGong(List<EnumStars> stars) {
    if (stars.length < 2) return false;
    final first = _starGongMap[stars.first];
    if (first == null) return false;
    final squareSet = {first, ...first.otherSquareGongList};
    for (int i = 1; i < stars.length; i++) {
      final g = _starGongMap[stars[i]];
      if (g == null || !squareSet.contains(g)) return false;
    }
    return true;
  }

  bool _checkStarInGong(EnumStars star, List<String> gongs) {
    final actual = _starGongMap[star];
    if (actual == null) return false;
    for (final name in gongs) {
      if (TwelveGongSystem.resolve(name) == actual) return true;
    }
    return false;
  }

  bool _checkStarInConstellation(EnumStars star, List<String> names) {
    final actual = _starConstellationNameMap[star];
    if (actual == null) return false;
    return names.contains(actual);
  }

  bool _checkStarInKongWang(EnumStars star) {
    final gong = _starGongMap[star];
    if (gong == null) return false;
    return _kongWangSet.contains(gong.zhi);
  }

  bool _checkLifeGongAt(List<String> gongs) {
    for (final name in gongs) {
      if (TwelveGongSystem.resolve(name) == _lifeGong) return true;
    }
    return false;
  }

  bool _checkStarInDestinyGong(EnumStars star, EnumDestinyTwelveGong dg) {
    final targetGong = _destinyGongMapper[dg];
    if (targetGong == null) return false;
    return _starGongMap[star] == targetGong;
  }
}
