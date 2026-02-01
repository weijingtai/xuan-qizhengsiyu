import 'dart:math';

import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart'; // 使用domain层的模型

import '../enums/enum_panel_system_type.dart';
import '../enums/enum_twelve_gong.dart';
import '../domain/managers/zhou_tian_calculator.dart'; // Using domain manager
import '../domain/entities/models/observer_position.dart'; // 使用domain层的ObserverPosition
import '../domain/entities/models/star_enter_info.dart'; // 使用domain层的模型
import '../domain/entities/models/zhou_tian_model.dart'; // 使用domain层的模型
import 'da_xian_constellation_passage_info.dart';
import 'da_xian_palace_info.dart';
import 'gong_constellation_mapping.dart';
import 'star_influence_model.dart';

class DongWeiDaXianCalculator {
  final ZhouTianModel zhouTianModel;
  final List<EnumTwelveGong> daxianPalaceOrder;
  final Map<EnumTwelveGong, YearMonth> daxianPalaceDurations; // 改为YearMonth

  // final Map<EnumTwelveGong, CelestialObject> palacesStaticInfo;
  // final Map<Enum28Constellations, CelestialObject> constellationsStaticInfo;
  final int totalDegreesInt;
  // 判断是否为逆行（这里需要根据实际的逆行判断逻辑）
  bool isRetrograde = true;

  double luoRangeDegree; // 同络，可接受的偏移范围
  double dingRangeDegree; // ‘明’，‘暗’顶可接受的偏移范围
  BasePanelModel basePanel;
  ObserverPosition observerPosition;

  Map<EnumStars, EnteredInfo> get starsEnterInfo => basePanel.enteredGongMapper;
  DateTime get birthTime => observerPosition.dateTime;

  DongWeiDaXianCalculator({
    required this.zhouTianModel,
    required this.basePanel,
    required this.observerPosition,
    required this.daxianPalaceOrder,
    required this.daxianPalaceDurations, // 现在接受YearMonth类型
    this.isRetrograde = true,
    this.luoRangeDegree = 1.0,
    this.dingRangeDegree = 1.0,
  }) : totalDegreesInt =
            (zhouTianModel.totalDegree * ZhouTianCalculator.DEGREE_MULTIPLIER)
                .round();

  Map<EnumTwelveGong, DaXianPalaceInfo> calculate(
      List<ConstellationMappingResult> mapping,
      Map<EnumTwelveGong, CelestialObject> palacesStaticInfo) {
    // 1. 首先调用 calculateDaXian 获取 List<DaXianPalaceInfo>
    List<DaXianPalaceInfo> daXianList =
        calculateDaXian(mapping, palacesStaticInfo, starsEnterInfo);

    // 2. 为每个大限宫位计算星体影响并更新到 List<DaXianPalaceInfo>
    for (int i = 0; i < daXianList.length; i++) {
      DaXianPalaceInfo daXianInfo = daXianList[i];

      // 调用 calculateStarInfluences 计算星体影响
      // 注意：需要准备 starsEnterInfo 参数，这里假设从某处获取
      Map<EnumStars, EnteredInfo> starsEnterInfo = {}; // 需要从适当的地方获取星体入宫信息

      StarGongInfluence? starInfluence = calculateStarInfluences(
        targetPalace: daXianInfo.palace,
        starsEnterInfo: starsEnterInfo,
      );

      // 更新星体影响到大限宫位信息
      daXianList[i] = daXianInfo.copyWith(
        starGongInfluence: starInfluence,
      );
    }

    // 3. 为每个大限宫位计算丁度星体影响并更新到 List<DaXianPalaceInfo>
    for (int i = 0; i < daXianList.length; i++) {
      DaXianPalaceInfo daXianInfo = daXianList[i];

      // 调用 calculateDingStar 计算丁度影响
      Map<EnumInfluenceType, List<DingStarInfluenceModel>>? dingStarMapper =
          calculateDingStar(daXianInfo);

      // 更新丁度影响到大限宫位信息
      daXianList[i] = daXianInfo.copyWith(
        dingStarMapper: dingStarMapper,
      );
    }

    // 4. 最后生成 Map<EnumTwelveGong, DaXianPalaceInfo> 并返回
    Map<EnumTwelveGong, DaXianPalaceInfo> result = {};
    for (DaXianPalaceInfo daXianInfo in daXianList) {
      result[daXianInfo.palace] = daXianInfo;
    }

    return result;
  }

  // 在 DongWeiDaXianCalculator 类中添加修正后的方法
  /// 基于已有的宫位星宿映射结果计算大限
  /// [mapping] 来自 ZhouTianCalculator.mapConstellationsToPalaces() 的结果
  List<DaXianPalaceInfo> calculateDaXian(
    List<ConstellationMappingResult> mapping,
    Map<EnumTwelveGong, CelestialObject> palacesStaticInfo,
    Map<EnumStars, EnteredInfo> starsEnterInfo,
  ) {
    List<DaXianPalaceInfo> results = [];
    DateTime currentEventTime = birthTime;
    YearMonth currentEventAge = YearMonth(0, 0);
    int daxianOrder = 0;

    // 创建宫位到星宿段的映射
    Map<EnumTwelveGong, List<ConstellationSegmentForDaXian>> palaceToSegments =
        {};

    // 初始化所有宫位的空列表
    for (EnumTwelveGong palace in daxianPalaceOrder) {
      palaceToSegments[palace] = [];
    }

    // 从映射结果中提取每个宫位的星宿段
    for (ConstellationMappingResult constellationResult in mapping) {
      for (ConstellationSegment segment in constellationResult.segments) {
        if (palaceToSegments.containsKey(segment.palaceName)) {
          palaceToSegments[segment.palaceName]!.add(
            ConstellationSegmentForDaXian(
              constellation: constellationResult.constellationName,
              segmentStartInPalace: segment.startInPalaceDeg,
              segmentEndInPalace: segment.endInPalaceDeg,
              degreeStartInConstellation: segment.startInConstellationDeg,
              degreeEndInConstellation: segment.endInConstellationDeg,
              segmentLengthDeg: segment.segmentLengthDeg,
            ),
          );
        }
      }
    }

    // 对每个宫位的星宿段进行排序
    for (EnumTwelveGong palace in palaceToSegments.keys) {
      List<ConstellationSegmentForDaXian> segments = palaceToSegments[palace]!;
      if (isRetrograde) {
        // 逆行：从高度数到低度数
        segments.sort(
            (a, b) => b.segmentEndInPalace.compareTo(a.segmentEndInPalace));
      } else {
        // 正行：从低度数到高度数
        segments.sort(
            (a, b) => a.segmentStartInPalace.compareTo(b.segmentStartInPalace));
      }
    }

    // 遍历大限宫位顺序
    for (EnumTwelveGong currentPalaceKey in daxianPalaceOrder) {
      daxianOrder++;
      YearMonth palaceDaxianDuration = daxianPalaceDurations[currentPalaceKey]!;

      DateTime daxianStartTime = currentEventTime;
      YearMonth daxianStartAge = currentEventAge;
      DateTime daxianEndTime = TimeUtils.addYearMonthToDateTime(
          daxianStartTime, palaceDaxianDuration);
      YearMonth daxianEndAge = daxianStartAge + palaceDaxianDuration;

      // 获取宫位信息
      CelestialObject palaceStatic = palacesStaticInfo[currentPalaceKey]!;
      double palaceWidthDegrees = palaceStatic.width;

      if (palaceWidthDegrees < ZhouTianCalculator.EPSILON_RAW) {
        if (palaceDaxianDuration.toTotalMonths() == 0) {
          List<DaXianConstellationPassageInfo> passages = [];
          results.add(DaXianPalaceInfo(
            order: daxianOrder,
            palace: currentPalaceKey,
            durationYears: palaceDaxianDuration,
            startTime: daxianStartTime,
            endTime: daxianEndTime,
            startAge: daxianStartAge,
            endAge: daxianEndAge,
            rateYearsPerDegree: YearMonth.zero(),
            constellationPassages: passages,
            totalGongDegreee: palaceWidthDegrees,
          ));
          currentEventTime = daxianEndTime;
          currentEventAge = daxianEndAge;
          continue;
        }
        throw Exception("宫位 ${palaceStatic.name} 宽度为0但大限时长不为0");
      }

      // 计算时间分配
      int totalDays = palaceDaxianDuration.toTotalDays();
      double daysPerDegree = totalDays / palaceWidthDegrees;
      YearMonth rateYearsPerDegree =
          YearMonth.fromTotalDays(daysPerDegree.round());

      List<DaXianConstellationPassageInfo> passages = [];
      int accumulatedDaysInThisDaxian = 0;

      // 处理该宫位中的所有星宿段
      List<ConstellationSegmentForDaXian> segmentsInPalace =
          palaceToSegments[currentPalaceKey]!;

      for (ConstellationSegmentForDaXian segment in segmentsInPalace) {
        double currentSegmentSpanDegrees = segment.segmentLengthDeg;

        // 计算持续时间
        int passageDurationDays =
            (currentSegmentSpanDegrees * daysPerDegree).round();
        YearMonth passageDurationYears =
            YearMonth.fromTotalDays(passageDurationDays);

        DateTime passageEntryTime =
            daxianStartTime.add(Duration(days: accumulatedDaysInThisDaxian));
        YearMonth passageEntryAge = daxianStartAge +
            YearMonth.fromTotalDays(accumulatedDaysInThisDaxian);

        accumulatedDaysInThisDaxian += passageDurationDays;

        // 确保不超过宫位总时长
        if (accumulatedDaysInThisDaxian > totalDays) {
          accumulatedDaysInThisDaxian = totalDays;
        }

        DateTime passageExitTime =
            daxianStartTime.add(Duration(days: accumulatedDaysInThisDaxian));
        YearMonth passageExitAge = daxianStartAge +
            YearMonth.fromTotalDays(accumulatedDaysInThisDaxian);

        // 计算星宿影响
        List<ConstellationStarInfluenceModel>? constellationStarInfluences =
            calculateConstellationStarInfluences(
          targetConstellation: segment.constellation,
          starsEnterInfo: starsEnterInfo,
        );

        passages.add(DaXianConstellationPassageInfo(
          constellation: segment.constellation,
          // 处理逆行时的度数方向
          startDegreeInConstellation: isRetrograde
              ? segment.degreeEndInConstellation
              : segment.degreeStartInConstellation,
          endDegreeInConstellation: isRetrograde
              ? segment.degreeStartInConstellation
              : segment.degreeEndInConstellation,
          segmentAngularSpanDegrees: currentSegmentSpanDegrees,
          passageDurationYears: passageDurationYears,
          entryTime: passageEntryTime,
          exitTime: passageExitTime,
          entryAge: passageEntryAge,
          exitAge: passageExitAge,
          constellationStarInfluences: constellationStarInfluences,
        ));
      }

      results.add(DaXianPalaceInfo(
        order: daxianOrder,
        palace: currentPalaceKey,
        durationYears: palaceDaxianDuration,
        startTime: daxianStartTime,
        endTime: daxianEndTime,
        startAge: daxianStartAge,
        endAge: daxianEndAge,
        rateYearsPerDegree: rateYearsPerDegree,
        constellationPassages: passages,
        totalGongDegreee: palaceWidthDegrees,
      ));

      currentEventTime = daxianEndTime;
      currentEventAge = daxianEndAge;
    }

    return results;
  }

  /// 计算丁度星体影响
  /// [daXianPassageGong] 大限宫位信息，包含星体影响数据
  /// 返回丁度星体影响模型列表
  Map<EnumInfluenceType, List<DingStarInfluenceModel>>? calculateDingStar(
      DaXianPalaceInfo daXianPassageGong) {
    Map<EnumInfluenceType, List<DingStarInfluenceModel>> dingStarInfluences =
        {};

    // 检查是否有星体宫位影响数据
    if (daXianPassageGong.starGongInfluence == null) {
      return null;
    }

    StarGongInfluence starGongInfluence = daXianPassageGong.starGongInfluence!;

    // 处理同宫影响（明顶）
    if (starGongInfluence.sameGongInfluence != null) {
      List<DingStarInfluenceModel> sameInfluences = [];
      for (PalaceStarInfluenceModel starInfluence
          in starGongInfluence.sameGongInfluence!) {
        // 检查度数差是否在丁度范围内
        if (starInfluence.degreeDiff.abs() <= dingRangeDegree) {
          sameInfluences.add(_createDingStarInfluence(
            starInfluence,
            daXianPassageGong,
            EnumInfluenceType.same,
          ));
        }
      }
      if (sameInfluences.isNotEmpty) {
        dingStarInfluences[EnumInfluenceType.same] = sameInfluences;
      }
    }

    // 处理对宫影响（暗顶）
    if (starGongInfluence.oppositeGongInfluence != null) {
      List<DingStarInfluenceModel> oppositeInfluences = [];
      for (PalaceStarInfluenceModel starInfluence
          in starGongInfluence.oppositeGongInfluence!) {
        // 检查度数差是否在丁度范围内
        if (starInfluence.degreeDiff.abs() <= dingRangeDegree) {
          oppositeInfluences.add(_createDingStarInfluence(
            starInfluence,
            daXianPassageGong,
            EnumInfluenceType.opposite,
          ));
        }
      }
      if (oppositeInfluences.isNotEmpty) {
        dingStarInfluences[EnumInfluenceType.opposite] = oppositeInfluences;
      }
    }

    // 处理三方影响（暗顶）
    if (starGongInfluence.triangleGongInfluence != null) {
      List<DingStarInfluenceModel> triangleInfluences = [];
      starGongInfluence.triangleGongInfluence!
          .forEach((palace, starInfluences) {
        for (PalaceStarInfluenceModel starInfluence in starInfluences) {
          // 检查度数差是否在丁度范围内
          if (starInfluence.degreeDiff.abs() <= dingRangeDegree) {
            triangleInfluences.add(_createDingStarInfluence(
              starInfluence,
              daXianPassageGong,
              EnumInfluenceType.triangle,
            ));
          }
        }
      });
      if (triangleInfluences.isNotEmpty) {
        dingStarInfluences[EnumInfluenceType.triangle] = triangleInfluences;
      }
    }

    // 处理四正影响（暗顶）
    if (starGongInfluence.squareGongInfluence != null) {
      List<DingStarInfluenceModel> squareInfluences = [];
      starGongInfluence.squareGongInfluence!.forEach((palace, starInfluences) {
        for (PalaceStarInfluenceModel starInfluence in starInfluences) {
          // 检查度数差是否在丁度范围内
          if (starInfluence.degreeDiff.abs() <= dingRangeDegree) {
            squareInfluences.add(_createDingStarInfluence(
              starInfluence,
              daXianPassageGong,
              EnumInfluenceType.square,
            ));
          }
        }
      });
      if (squareInfluences.isNotEmpty) {
        dingStarInfluences[EnumInfluenceType.square] = squareInfluences;
      }
    }

    // 注意：同络影响不参与暗顶计算，所以这里不处理 sameLuoInfluence

    return dingStarInfluences.isEmpty ? null : dingStarInfluences;
  }

  /// 创建丁度星体影响模型的辅助方法
  DingStarInfluenceModel _createDingStarInfluence(
    PalaceStarInfluenceModel starInfluence,
    DaXianPalaceInfo daXianPassageGong,
    EnumInfluenceType influenceType,
  ) {
    // 根据星体入宫度数和大限时间信息计算丁度的起止时间
    double entryDegree = starInfluence.entryDegree;
    YearMonth ratePerDegree = daXianPassageGong.rateYearsPerDegree;

    // 计算星体影响的时间范围（基于度数差和丁度范围）
    double startDegree = entryDegree - dingRangeDegree;
    double endDegree = entryDegree + dingRangeDegree;

    // 确保度数在宫位范围内
    startDegree = startDegree.clamp(0.0, 30.0);
    endDegree = endDegree.clamp(0.0, 30.0);

    // 计算相对于大限开始的时间偏移
    int startDaysOffset = (startDegree * ratePerDegree.toTotalDays()).round();
    int endDaysOffset = (endDegree * ratePerDegree.toTotalDays()).round();

    DateTime startTime =
        daXianPassageGong.startTime.add(Duration(days: startDaysOffset));
    DateTime endTime =
        daXianPassageGong.startTime.add(Duration(days: endDaysOffset));

    YearMonth startAge =
        daXianPassageGong.startAge + YearMonth.fromTotalDays(startDaysOffset);
    YearMonth endAge =
        daXianPassageGong.startAge + YearMonth.fromTotalDays(endDaysOffset);

    return DingStarInfluenceModel(
      influenceType: influenceType,
      star: starInfluence.star,
      location: starInfluence.location,
      entryDegree: starInfluence.entryDegree,
      degreeDiff: starInfluence.degreeDiff,
      defaultRangeDegree: dingRangeDegree,
      startTime: startTime,
      endTime: endTime,
      startAge: startAge,
      endAge: endAge,
    );
  }

  // 计算指定宫位的星体影响信息
  /// [targetPalace] 目标宫位
  /// [starsEnterInfo] 所有星体的入宫入宿信息
  /// [daxianStartTime] 大限开始时间
  /// [daxianEndTime] 大限结束时间
  /// [daxianStartAge] 大限开始年龄
  /// [rateYearsPerDegree] 每度对应的年月数
  /// 计算指定宫位的星体影响信息（简化版）
  StarGongInfluence? calculateStarInfluences({
    required EnumTwelveGong targetPalace,
    required Map<EnumStars, EnteredInfo> starsEnterInfo,
  }) {
    List<PalaceStarInfluenceModel> sameGongInfluence = [];
    List<PalaceStarInfluenceModel> oppositeGongInfluence = [];
    Map<EnumTwelveGong, List<PalaceStarInfluenceModel>> triangleGongInfluence =
        {};
    Map<EnumTwelveGong, List<PalaceStarInfluenceModel>> squareGongInfluence =
        {};
    Map<EnumTwelveGong, List<PalaceStarInfluenceModel>> sameLuoInfluence = {};

    // 获取目标宫位的关系宫位
    EnumTwelveGong oppositePalace = targetPalace.opposite;
    List<EnumTwelveGong> trianglePalaces = targetPalace.otherTringleGongList;
    List<EnumTwelveGong> squarePalaces = targetPalace.otherSquareGongList;

    for (MapEntry<EnumStars, EnteredInfo> entry in starsEnterInfo.entries) {
      EnumStars star = entry.key;
      EnteredInfo starInfo = entry.value;

      // 同宫影响
      if (starInfo.gong == targetPalace) {
        sameGongInfluence.add(PalaceStarInfluenceModel(
          influenceType: EnumInfluenceType.same,
          star: star,
          location: starInfo.gong,
          entryDegree: starInfo.atGongDegree,
        ));
      }

      // 对宫影响
      else if (starInfo.gong == oppositePalace) {
        oppositeGongInfluence.add(PalaceStarInfluenceModel(
          influenceType: EnumInfluenceType.opposite,
          star: star,
          location: starInfo.gong,
          entryDegree: starInfo.atGongDegree,
        ));
      }

      // 三方影响
      else if (trianglePalaces.contains(starInfo.gong)) {
        if (!triangleGongInfluence.containsKey(starInfo.gong)) {
          triangleGongInfluence[starInfo.gong] = [];
        }
        triangleGongInfluence[starInfo.gong]!.add(PalaceStarInfluenceModel(
          influenceType: EnumInfluenceType.triangle,
          star: star,
          location: starInfo.gong,
          entryDegree: starInfo.atGongDegree,
        ));
      }

      // 四正影响
      else if (squarePalaces.contains(starInfo.gong)) {
        if (!squareGongInfluence.containsKey(starInfo.gong)) {
          squareGongInfluence[starInfo.gong] = [];
        }
        squareGongInfluence[starInfo.gong]!.add(PalaceStarInfluenceModel(
          influenceType: EnumInfluenceType.square,
          star: star,
          location: starInfo.gong,
          entryDegree: starInfo.atGongDegree,
        ));
      }

      // 同络影响（需要检查度数差异）
      _calculateSameLuoInfluence(
        targetPalace: targetPalace,
        star: star,
        starInfo: starInfo,
        starsEnterInfo: starsEnterInfo,
        sameLuoInfluence: sameLuoInfluence,
      );
    }

    // 检查是否所有影响列表都为空
    if (sameGongInfluence.isEmpty &&
        oppositeGongInfluence.isEmpty &&
        triangleGongInfluence.isEmpty &&
        squareGongInfluence.isEmpty &&
        sameLuoInfluence.isEmpty) {
      return null;
    }

    return StarGongInfluence(
      sameGongInfluence: sameGongInfluence.isEmpty ? null : sameGongInfluence,
      oppositeGongInfluence:
          oppositeGongInfluence.isEmpty ? null : oppositeGongInfluence,
      triangleGongInfluence:
          triangleGongInfluence.isEmpty ? null : triangleGongInfluence,
      squareGongInfluence:
          squareGongInfluence.isEmpty ? null : squareGongInfluence,
      sameLuoInfluence: sameLuoInfluence.isEmpty ? null : sameLuoInfluence,
    );
  }

  List<ConstellationStarInfluenceModel>? calculateConstellationStarInfluences(
      {required Enum28Constellations targetConstellation,
      required Map<EnumStars, EnteredInfo> starsEnterInfo,
      EnumStars? starToExclude}) {
    List<ConstellationStarInfluenceModel> influences = [];

    List<MapEntry<EnumStars, EnteredInfo>> sameJingConstell = starsEnterInfo
        .entries
        .where(
            (en) => en.value.inn.sevenZheng == targetConstellation.sevenZheng)
        .toList();

    if (sameJingConstell.isEmpty) {
      return null;
    }
    if (starToExclude != null) {
      sameJingConstell.removeWhere((en) => en.key == starToExclude);
    }
    if (sameJingConstell.isEmpty) {
      return null;
    }

    for (MapEntry<EnumStars, EnteredInfo> entry in starsEnterInfo.entries) {
      EnumStars star = entry.key;
      EnteredInfo starInfo = entry.value;

      // 同经影响（同一星宿）
      if (starInfo.enterInnInfo.constellation == targetConstellation) {
        influences.add(ConstellationStarInfluenceModel(
          influenceType: EnumInfluenceType.jing,
          star: star,
          location: starInfo.enterInnInfo.constellation,
          entryDegree: starInfo.enterInnInfo.degree,
          inSameConstellation: true,
        ));
      } else {
        influences.add(ConstellationStarInfluenceModel(
          influenceType: EnumInfluenceType.jing,
          star: star,
          location: starInfo.enterInnInfo.constellation,
          entryDegree: starInfo.enterInnInfo.degree,
          inSameConstellation: true,
        ));
      }
    }

    return influences;
  }

  /// 计算同络影响（简化版）
  void _calculateSameLuoInfluence({
    required EnumTwelveGong targetPalace,
    required EnumStars star,
    required EnteredInfo starInfo,
    required Map<EnumStars, EnteredInfo> starsEnterInfo,
    required Map<EnumTwelveGong, List<PalaceStarInfluenceModel>>
        sameLuoInfluence,
  }) {
    // 查找目标宫位中的星体
    EnteredInfo? targetPalaceStarInfo;
    for (MapEntry<EnumStars, EnteredInfo> entry in starsEnterInfo.entries) {
      if (entry.value.gong == targetPalace) {
        targetPalaceStarInfo = entry.value;
        break;
      }
    }

    if (targetPalaceStarInfo == null) return;

    // 检查度数差异（同络的判断标准，通常在0.5-1度内）
    double degreeDiff =
        (starInfo.atGongDegree - targetPalaceStarInfo.atGongDegree).abs();
    if (degreeDiff <= luoRangeDegree && starInfo.gong != targetPalace) {
      if (!sameLuoInfluence.containsKey(starInfo.gong)) {
        sameLuoInfluence[starInfo.gong] = [];
      }
      sameLuoInfluence[starInfo.gong]!.add(PalaceStarInfluenceModel(
          influenceType: EnumInfluenceType.luo,
          star: star,
          location: starInfo.gong,
          entryDegree: starInfo.atGongDegree,
          degreeDiff: degreeDiff,
          defaultRangeDegree: luoRangeDegree));
    }
  }
}

// 辅助类
class ConstellationSegmentInPalace {
  final CelestialObject constellation;
  final double segmentStartInPalace;
  final double segmentEndInPalace;
  final double degreeStartInConstellation;
  final double degreeEndInConstellation;

  ConstellationSegmentInPalace({
    required this.constellation,
    required this.segmentStartInPalace,
    required this.segmentEndInPalace,
    required this.degreeStartInConstellation,
    required this.degreeEndInConstellation,
  });

  @override
  String toString() {
    return 'ConstellationSegmentInPalace{constellation: $constellation, segmentStartInPalace: $segmentStartInPalace, segmentEndInPalace: $segmentEndInPalace, degreeStartInConstellation: $degreeStartInConstellation, degreeEndInConstellation: $degreeEndInConstellation}';
  }
}

class TimeUtils {
  static DateTime addYearMonthToDateTime(DateTime start, YearMonth duration) {
    // 最准确的方式是转换为总天数再加
    int daysToAdd = duration.toTotalDays();
    return start.add(Duration(days: daysToAdd));
  }

  static DateTime addDecimalYearsToDateTime(DateTime start, double years) {
    int daysToAdd = (years * YearMonth.avgDaysInYear).round();
    return start.add(Duration(days: daysToAdd));
  }

  static YearMonth addDecimalYearsToYearMonth(YearMonth start, double years) {
    int daysToAdd = (years * YearMonth.avgDaysInYear).round();
    return start.addDays(daysToAdd);
  }
}

// 用于大限计算的星宿段信息
class ConstellationSegmentForDaXian {
  final Enum28Constellations constellation;
  final double segmentStartInPalace;
  final double segmentEndInPalace;
  final double degreeStartInConstellation;
  final double degreeEndInConstellation;
  final double segmentLengthDeg;

  ConstellationSegmentForDaXian({
    required this.constellation,
    required this.segmentStartInPalace,
    required this.segmentEndInPalace,
    required this.degreeStartInConstellation,
    required this.degreeEndInConstellation,
    required this.segmentLengthDeg,
  });

  @override
  String toString() {
    return 'ConstellationSegmentForDaXian{constellation: $constellation, segmentStartInPalace: $segmentStartInPalace, segmentEndInPalace: $segmentEndInPalace, degreeStartInConstellation: $degreeStartInConstellation, degreeEndInConstellation: $degreeEndInConstellation, segmentLengthDeg: $segmentLengthDeg}';
  }
}

/// 星体影响计算结果
