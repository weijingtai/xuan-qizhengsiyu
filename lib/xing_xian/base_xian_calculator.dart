import 'dart:math';

import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/xing_xian/base_xian_palace.dart';

import '../domain/entities/models/base_panel_model.dart';
import '../domain/entities/models/observer_position.dart';
import '../domain/entities/models/star_enter_info.dart';
import '../domain/entities/models/zhou_tian_model.dart';
import '../domain/managers/zhou_tian_calculator.dart';
import '../enums/enum_panel_system_type.dart';
import '../enums/enum_twelve_gong.dart';
import 'da_xian_constellation_passage_info.dart';
import 'da_xian_palace_info.dart';
import 'gong_constellation_mapping.dart';
import 'star_influence_model.dart';

/// 行限计算器基类
abstract class BaseXianCalculator {
  final ZhouTianModel zhouTianModel;
  final List<EnumTwelveGong> daxianPalaceOrder;
  final Map<EnumTwelveGong, YearMonth> daxianPalaceDurations;
  final int totalDegreesInt;
  final bool isRetrograde;
  final double luoRangeDegree; // 同络，可接受的偏移范围
  final double dingRangeDegree; // '明'，'暗'顶可接受的偏移范围
  final BasePanelModel basePanel;
  final ObserverPosition observerPosition;

  Map<EnumStars, EnteredInfo> get starsEnterInfo => basePanel.enteredGongMapper;
  DateTime get birthTime => observerPosition.dateTime;

  BaseXianCalculator({
    required this.zhouTianModel,
    required this.basePanel,
    required this.observerPosition,
    required this.daxianPalaceOrder,
    required this.daxianPalaceDurations,
    this.isRetrograde = true,
    this.luoRangeDegree = 1.0,
    this.dingRangeDegree = 1.0,
  }) : totalDegreesInt =
            (zhouTianModel.totalDegree * ZhouTianCalculator.DEGREE_MULTIPLIER)
                .round();

  /// 计算同宫影响
  List<PalaceStarInfluenceModel> calculateSameGongInfluence({
    required EnumTwelveGong targetPalace,
    required Map<EnumStars, EnteredInfo> starsEnterInfo,
  }) {
    List<PalaceStarInfluenceModel> sameGongInfluence = [];

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
    }

    return sameGongInfluence;
  }

  /// 计算对宫影响
  List<PalaceStarInfluenceModel> calculateOppositeGongInfluence({
    required EnumTwelveGong targetPalace,
    required Map<EnumStars, EnteredInfo> starsEnterInfo,
  }) {
    List<PalaceStarInfluenceModel> oppositeGongInfluence = [];
    EnumTwelveGong oppositePalace = targetPalace.opposite;

    for (MapEntry<EnumStars, EnteredInfo> entry in starsEnterInfo.entries) {
      EnumStars star = entry.key;
      EnteredInfo starInfo = entry.value;

      // 对宫影响
      if (starInfo.gong == oppositePalace) {
        oppositeGongInfluence.add(PalaceStarInfluenceModel(
          influenceType: EnumInfluenceType.opposite,
          star: star,
          location: starInfo.gong,
          entryDegree: starInfo.atGongDegree,
        ));
      }
    }

    return oppositeGongInfluence;
  }

  /// 计算三方影响
  Map<EnumTwelveGong, List<PalaceStarInfluenceModel>>
      calculateTriangleGongInfluence({
    required EnumTwelveGong targetPalace,
    required Map<EnumStars, EnteredInfo> starsEnterInfo,
  }) {
    Map<EnumTwelveGong, List<PalaceStarInfluenceModel>> triangleGongInfluence =
        {};
    List<EnumTwelveGong> trianglePalaces = targetPalace.otherTringleGongList;

    for (MapEntry<EnumStars, EnteredInfo> entry in starsEnterInfo.entries) {
      EnumStars star = entry.key;
      EnteredInfo starInfo = entry.value;

      // 三方影响
      if (trianglePalaces.contains(starInfo.gong)) {
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
    }

    return triangleGongInfluence;
  }

  /// 计算四正影响
  Map<EnumTwelveGong, List<PalaceStarInfluenceModel>>
      calculateSquareGongInfluence({
    required EnumTwelveGong targetPalace,
    required Map<EnumStars, EnteredInfo> starsEnterInfo,
  }) {
    Map<EnumTwelveGong, List<PalaceStarInfluenceModel>> squareGongInfluence =
        {};
    List<EnumTwelveGong> squarePalaces = targetPalace.otherSquareGongList;

    for (MapEntry<EnumStars, EnteredInfo> entry in starsEnterInfo.entries) {
      EnumStars star = entry.key;
      EnteredInfo starInfo = entry.value;

      // 四正影响
      if (squarePalaces.contains(starInfo.gong)) {
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
    }

    return squareGongInfluence;
  }

  /// 计算同络影响
  void calculateSameLuoInfluence({
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

  /// 计算星体宫位影响
  StarGongInfluence? calculateStarInfluences({
    required EnumTwelveGong targetPalace,
    required Map<EnumStars, EnteredInfo> starsEnterInfo,
  }) {
    // 使用基类方法计算各种影响
    List<PalaceStarInfluenceModel> sameGongInfluence =
        calculateSameGongInfluence(
      targetPalace: targetPalace,
      starsEnterInfo: starsEnterInfo,
    );

    List<PalaceStarInfluenceModel> oppositeGongInfluence =
        calculateOppositeGongInfluence(
      targetPalace: targetPalace,
      starsEnterInfo: starsEnterInfo,
    );

    Map<EnumTwelveGong, List<PalaceStarInfluenceModel>> triangleGongInfluence =
        calculateTriangleGongInfluence(
      targetPalace: targetPalace,
      starsEnterInfo: starsEnterInfo,
    );

    Map<EnumTwelveGong, List<PalaceStarInfluenceModel>> squareGongInfluence =
        calculateSquareGongInfluence(
      targetPalace: targetPalace,
      starsEnterInfo: starsEnterInfo,
    );

    // 计算同络影响
    Map<EnumTwelveGong, List<PalaceStarInfluenceModel>> sameLuoInfluence = {};
    for (MapEntry<EnumStars, EnteredInfo> entry in starsEnterInfo.entries) {
      EnumStars star = entry.key;
      EnteredInfo starInfo = entry.value;

      calculateSameLuoInfluence(
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

  DingStarInfluenceModel createDingStarInfluence(
    PalaceStarInfluenceModel starInfluence,
    BaseXianPalace daXianPassageGong,
    EnumInfluenceType influenceType,
  );

  /// 计算顶度星体影响
  /// [daXianPassageGong] 大限宫位信息，包含星体影响数据
  /// 返回顶度星体影响模型列表
  Map<EnumInfluenceType, List<DingStarInfluenceModel>>? calculateDingStar(
      BaseXianPalace daXianPassageGong) {
    throw UnimplementedError();
  }

  /// 计算行限星宿信息
  /// [targetPalaceMapping] 目标宫位的星宿映射结果
  /// [daxianDuration] 大限持续时间
  /// [daxianStartTime] 大限开始时间
  /// [daxianStartAge] 大限开始年龄
  /// [isRetrograde] 是否逆行
  List<DaXianConstellationPassageInfo> calculateXingXianStarPassages({
    required PalaceMappingResult targetPalaceMapping,
    required YearMonth daxianDuration,
    required DateTime daxianStartTime,
    required YearMonth daxianStartAge,
    required bool isRetrograde,
  }) {
    List<DaXianConstellationPassageInfo> passages = [];

    // 创建宫位到星宿段的映射
    Map<EnumTwelveGong, List<ConstellationSegmentForDaXian>> palaceToSegments =
        {};
    palaceToSegments[targetPalaceMapping.palaceName] = [];

    // 从目标宫位映射结果中提取星宿段
    for (PalaceConstellationSegment segment in targetPalaceMapping.segments) {
      palaceToSegments[targetPalaceMapping.palaceName]!.add(
        ConstellationSegmentForDaXian(
          constellation: segment.constellationName,
          segmentStartInPalace: segment.startInPalaceDeg,
          segmentEndInPalace: segment.endInPalaceDeg,
          degreeStartInConstellation: segment.startInConstellationDeg,
          degreeEndInConstellation: segment.endInConstellationDeg,
          segmentLengthDeg: segment.segmentLengthDeg,
        ),
      );
    }

    // 对星宿段进行排序
    List<ConstellationSegmentForDaXian> segments =
        palaceToSegments[targetPalaceMapping.palaceName]!;
    if (isRetrograde) {
      // 逆行：从高度数到低度数
      segments
          .sort((a, b) => b.segmentEndInPalace.compareTo(a.segmentEndInPalace));
    } else {
      // 正行：从低度数到高度数
      segments.sort(
          (a, b) => a.segmentStartInPalace.compareTo(b.segmentStartInPalace));
    }

    // 计算时间分配 - 从 PalaceMappingResult 中获取宫位总度数
    double palaceWidthDegrees = targetPalaceMapping.totalWidthDeg;
    int totalDays = daxianDuration.toTotalDays();
    double daysPerDegree = totalDays / palaceWidthDegrees;
    int accumulatedDaysInThisDaxian = 0;

    // 处理该宫位中的所有星宿段
    for (ConstellationSegmentForDaXian segment in segments) {
      double currentSegmentSpanDegrees = segment.segmentLengthDeg;

      // 计算持续时间
      int passageDurationDays =
          (currentSegmentSpanDegrees * daysPerDegree).round();
      YearMonth passageDurationYears =
          YearMonth.fromTotalDays(passageDurationDays);

      DateTime passageEntryTime =
          daxianStartTime.add(Duration(days: accumulatedDaysInThisDaxian));
      YearMonth passageEntryAge =
          daxianStartAge + YearMonth.fromTotalDays(accumulatedDaysInThisDaxian);

      accumulatedDaysInThisDaxian += passageDurationDays;

      // 确保不超过宫位总时长
      if (accumulatedDaysInThisDaxian > totalDays) {
        accumulatedDaysInThisDaxian = totalDays;
      }

      DateTime passageExitTime =
          daxianStartTime.add(Duration(days: accumulatedDaysInThisDaxian));
      YearMonth passageExitAge =
          daxianStartAge + YearMonth.fromTotalDays(accumulatedDaysInThisDaxian);

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
      ));
    }

    return passages;
  }

  // Map<EnumInfluenceType, List<DingStarInfluenceModel>>? calculateDingStar(
  //     BaseXianPalace daXianPassageGong) {
  //   Map<EnumInfluenceType, List<DingStarInfluenceModel>> dingStarInfluences =
  //       {};

  //   // 检查是否有星体宫位影响数据
  //   if (daXianPassageGong.starGongInfluence == null) {
  //     return null;
  //   }

  //   StarGongInfluence starGongInfluence = daXianPassageGong.starGongInfluence!;

  //   // 处理同宫影响（明顶）
  //   if (starGongInfluence.sameGongInfluence != null) {
  //     List<DingStarInfluenceModel> sameInfluences = [];
  //     for (PalaceStarInfluenceModel starInfluence
  //         in starGongInfluence.sameGongInfluence!) {
  //       // 检查度数差是否在丁度范围内
  //       if ((starInfluence.degreeDiff).abs() <= dingRangeDegree) {
  //         sameInfluences.add(createDingStarInfluence(
  //           starInfluence,
  //           daXianPassageGong,
  //           EnumInfluenceType.same,
  //         ));
  //       }
  //     }
  //     if (sameInfluences.isNotEmpty) {
  //       dingStarInfluences[EnumInfluenceType.same] = sameInfluences;
  //     }
  //   }

  //   // 处理对宫影响（暗顶）
  //   if (starGongInfluence.oppositeGongInfluence != null) {
  //     List<DingStarInfluenceModel> oppositeInfluences = [];
  //     for (PalaceStarInfluenceModel starInfluence
  //         in starGongInfluence.oppositeGongInfluence!) {
  //       // 检查度数差是否在丁度范围内
  //       if ((starInfluence.degreeDiff).abs() <= dingRangeDegree) {
  //         oppositeInfluences.add(createDingStarInfluence(
  //           starInfluence,
  //           daXianPassageGong,
  //           EnumInfluenceType.opposite,
  //         ));
  //       }
  //     }
  //     if (oppositeInfluences.isNotEmpty) {
  //       dingStarInfluences[EnumInfluenceType.opposite] = oppositeInfluences;
  //     }
  //   }

  //   // 处理三方影响（暗顶）
  //   if (starGongInfluence.triangleGongInfluence != null) {
  //     List<DingStarInfluenceModel> triangleInfluences = [];
  //     starGongInfluence.triangleGongInfluence!
  //         .forEach((palace, starInfluences) {
  //       for (PalaceStarInfluenceModel starInfluence in starInfluences) {
  //         // 检查度数差是否在丁度范围内
  //         if ((starInfluence.degreeDiff).abs() <= dingRangeDegree) {
  //           triangleInfluences.add(createDingStarInfluence(
  //             starInfluence,
  //             daXianPassageGong,
  //             EnumInfluenceType.triangle,
  //           ));
  //         }
  //       }
  //     });
  //     if (triangleInfluences.isNotEmpty) {
  //       dingStarInfluences[EnumInfluenceType.triangle] = triangleInfluences;
  //     }
  //   }

  //   // 处理四正影响（暗顶）
  //   if (starGongInfluence.squareGongInfluence != null) {
  //     List<DingStarInfluenceModel> squareInfluences = [];
  //     starGongInfluence.squareGongInfluence!.forEach((palace, starInfluences) {
  //       for (PalaceStarInfluenceModel starInfluence in starInfluences) {
  //         // 检查度数差是否在丁度范围内
  //         if ((starInfluence.degreeDiff).abs() <= dingRangeDegree) {
  //           squareInfluences.add(createDingStarInfluence(
  //             starInfluence,
  //             daXianPassageGong,
  //             EnumInfluenceType.square,
  //           ));
  //         }
  //       }
  //     });
  //     if (squareInfluences.isNotEmpty) {
  //       dingStarInfluences[EnumInfluenceType.square] = squareInfluences;
  //     }
  //   }

  //   // 注意：同络影响不参与暗顶计算，所以这里不处理 sameLuoInfluence

  //   return dingStarInfluences.isEmpty ? null : dingStarInfluences;
  // }
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
