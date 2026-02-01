import 'dart:math';

import 'package:common/enums.dart';

import '../../enums/enum_twelve_gong.dart';
import '../../xing_xian/gong_constellation_mapping.dart';
import '../entities/models/zhou_tian_model.dart';

import 'package:common/module.dart';

// --- 计算逻辑 ---
class ZhouTianCalculator {
  // --- 工具函数 ---
  static const double EPSILON_RAW = 1e-6; // 用于原始浮点数比较
  static const int DEGREE_MULTIPLIER = 1000; // 用于将度数转为整数计算
  static const double EPSILON_INT = 0.1; // 用于整数比较 (相当于原始的 0.001 度)
  static const double EPSILON_INT_COMPARISON_THRESHOLD =
      0.5; // 用于整数比较时的容错 (0.5 / MULTIPLIER)

  final ZhouTianModel zhouTianModel;
  final int totalDegreesInt;

  ZhouTianCalculator({required this.zhouTianModel})
      : totalDegreesInt =
            (zhouTianModel.totalDegree * ZhouTianCalculator.DEGREE_MULTIPLIER)
                .round();
// 规范化角度到 [0, TOTAL_CELESTIAL_DEGREES_INT)
  static int normalizeAngleInt(int angle, int totalDegreesInt) {
    int normalized = angle % totalDegreesInt;
    return normalized < 0 ? normalized + totalDegreesInt : normalized;
  }

// 规范化角度到 [0, TOTAL_CELESTIAL_DEGREES)
  static double normalizeAngle(double angle, double totalDegrees) {
    double normalized = angle % totalDegrees;
    return normalized < 0 ? normalized + totalDegrees : normalized;
  }

  Map<EnumTwelveGong, CelestialObject<EnumTwelveGong>> calculatePalaceAngles() {
    final List<EnumTwelveGong> palaceOrder = zhouTianModel.gongOrder;
    if (palaceOrder.isEmpty) throw ArgumentError("宫位顺序列表 (gongOrder) 不能为空");

    final Map<EnumTwelveGong, int> palaceWidthsInt = {};
    if (zhouTianModel.gongDegreeSeq.isNotEmpty &&
        zhouTianModel.gongDegreeSeq.length == palaceOrder.length) {
      for (int i = 0; i < palaceOrder.length; i++) {
        palaceWidthsInt[palaceOrder[i]] =
            (zhouTianModel.gongDegreeSeq[i].degree *
                    ZhouTianCalculator.DEGREE_MULTIPLIER)
                .round();
      }
    } else {
      logger.w("警告: gongDegreeSeq 提供不完整或为空，假设为等宫制。");
      int defaultPalaceWidthInt =
          (totalDegreesInt / palaceOrder.length).round();
      for (var gong in palaceOrder) {
        palaceWidthsInt[gong] = defaultPalaceWidthInt;
      }
    }

    final EnumTwelveGong alignmentGongName =
        zhouTianModel.alignmentPointAtGong.gong;
    final int palaceAlignmentOffsetInt =
        (zhouTianModel.alignmentPointAtGong.degree *
                ZhouTianCalculator.DEGREE_MULTIPLIER)
            .round();
    final int celestialZeroPointInt = 0; // 天文0点

    Map<EnumTwelveGong, CelestialObject<EnumTwelveGong>> palaceAngles = {};
    // 起始宫的连续绝对起始点 (可能为负或大于totalDegreesInt)
    int currentPalaceabsStartInt =
        celestialZeroPointInt - palaceAlignmentOffsetInt;

    int alignmentGongIndex = palaceOrder.indexOf(alignmentGongName);
    if (alignmentGongIndex == -1) {
      throw ArgumentError("对齐宫位 ${alignmentGongName.name} 不在 gongOrder 中。");
    }

    for (int i = 0; i < palaceOrder.length; i++) {
      int effectiveIndex = (alignmentGongIndex + i) % palaceOrder.length;
      EnumTwelveGong pName = palaceOrder[effectiveIndex];
      int pWidthInt = palaceWidthsInt[pName]!;

      int pabsEndInt = currentPalaceabsStartInt + pWidthInt;

      palaceAngles[pName] = CelestialObject<EnumTwelveGong>(
          pName, // 直接使用枚举值而不是name
          currentPalaceabsStartInt / ZhouTianCalculator.DEGREE_MULTIPLIER,
          pabsEndInt / ZhouTianCalculator.DEGREE_MULTIPLIER,
          pWidthInt / ZhouTianCalculator.DEGREE_MULTIPLIER);
      currentPalaceabsStartInt = pabsEndInt;
    }
    return palaceAngles;
  }

  Map<Enum28Constellations, CelestialObject<Enum28Constellations>>
      calculateConstellationAngles() {
    final List<Enum28Constellations> constellationOrder =
        this.zhouTianModel.starInnOrder;
    if (constellationOrder.isEmpty)
      throw ArgumentError("星宿顺序列表 (starInnOrder) 不能为空");

// *** 修正点：从 starInnDegreeSeq 中安全地获取宽度 ***
    final Map<Enum28Constellations, int> constellationWidthsInt = {};
// 1. 先将 starInnDegreeSeq 转换为一个 Map，方便按名称查找
    final Map<Enum28Constellations, double> inputWidthsMap = {
      for (var cd in this.zhouTianModel.starInnDegreeSeq)
        cd.constellation: cd.degree
    };

// 2. 遍历 starInnOrder，从转换后的 Map 中获取宽度
    for (Enum28Constellations cNameKey in constellationOrder) {
      if (inputWidthsMap.containsKey(cNameKey)) {
        constellationWidthsInt[cNameKey] =
            (inputWidthsMap[cNameKey]! * DEGREE_MULTIPLIER).round();
      } else {
        throw ArgumentError(
            "在 starInnDegreeSeq 中未找到星宿 ${cNameKey.name} 的宽度数据。");
      }
    }

    final Enum28Constellations alignmentConstellationName =
        zhouTianModel.alignmentPointAtConstellation.constellation;
    final int constellationAlignmentOffsetInt =
        (zhouTianModel.alignmentPointAtConstellation.degree *
                ZhouTianCalculator.DEGREE_MULTIPLIER)
            .round();
    final int celestialZeroPointInt = 0;

    Map<Enum28Constellations, CelestialObject<Enum28Constellations>>
        constellationAngles = {};
    // 起始星宿的连续绝对起始点
    int currentConstellationabsStartInt =
        celestialZeroPointInt - constellationAlignmentOffsetInt;

    int alignmentConstellationIndex =
        constellationOrder.indexOf(alignmentConstellationName);
    if (alignmentConstellationIndex == -1) {
      throw ArgumentError(
          "对齐星宿 ${alignmentConstellationName.name} 不在 starInnOrder 中。");
    }

    for (int i = 0; i < constellationOrder.length; i++) {
      int effectiveIndex =
          (alignmentConstellationIndex + i) % constellationOrder.length;
      Enum28Constellations cName = constellationOrder[effectiveIndex];
      int cWidthInt = constellationWidthsInt[cName]!;

      int cabsEndInt = currentConstellationabsStartInt + cWidthInt;

      constellationAngles[cName] = CelestialObject<Enum28Constellations>(
          cName, // 直接使用枚举值而不是name
          currentConstellationabsStartInt /
              ZhouTianCalculator.DEGREE_MULTIPLIER,
          cabsEndInt / ZhouTianCalculator.DEGREE_MULTIPLIER,
          cWidthInt / ZhouTianCalculator.DEGREE_MULTIPLIER);
      currentConstellationabsStartInt = cabsEndInt;
    }
    return constellationAngles;
  }

  @deprecated
  Map<Enum28Constellations, CelestialObject<Enum28Constellations>>
      calculateConstellationAnglesV1() {
    final List<Enum28Constellations> constellationOrder =
        zhouTianModel.starInnOrder;
    if (constellationOrder.isEmpty)
      throw ArgumentError("星宿顺序列表 (starInnOrder) 不能为空");

    final Map<Enum28Constellations, int> constellationWidthsInt = {};
    if (zhouTianModel.starInnDegreeSeq.isNotEmpty &&
        zhouTianModel.starInnDegreeSeq.length == constellationOrder.length) {
      for (int i = 0; i < constellationOrder.length; i++) {
        // 假设starInnDegreeSeq与starInnOrder顺序对应
        constellationWidthsInt[constellationOrder[i]] =
            (zhouTianModel.starInnDegreeSeq[i].degree *
                    ZhouTianCalculator.DEGREE_MULTIPLIER)
                .round();
      }
    } else {
      throw ArgumentError("starInnDegreeSeq 提供不完整或与 starInnOrder 不匹配。");
    }

    final Enum28Constellations alignmentConstellationName =
        zhouTianModel.alignmentPointAtConstellation.constellation;
    final int constellationAlignmentOffsetInt =
        (zhouTianModel.alignmentPointAtConstellation.degree *
                ZhouTianCalculator.DEGREE_MULTIPLIER)
            .round();
    final int celestialZeroPointInt = 0;

    Map<Enum28Constellations, CelestialObject<Enum28Constellations>>
        constellationAngles = {};
    // 起始星宿的连续绝对起始点
    int currentConstellationabsStartInt =
        celestialZeroPointInt - constellationAlignmentOffsetInt;

    int alignmentConstellationIndex =
        constellationOrder.indexOf(alignmentConstellationName);
    if (alignmentConstellationIndex == -1) {
      throw ArgumentError(
          "对齐星宿 ${alignmentConstellationName.name} 不在 starInnOrder 中。");
    }

    for (int i = 0; i < constellationOrder.length; i++) {
      int effectiveIndex =
          (alignmentConstellationIndex + i) % constellationOrder.length;
      Enum28Constellations cName = constellationOrder[effectiveIndex];
      int cWidthInt = constellationWidthsInt[cName]!;

      int cabsEndInt = currentConstellationabsStartInt + cWidthInt;

      constellationAngles[cName] = CelestialObject<Enum28Constellations>(
          cName, // 直接使用枚举值而不是name
          currentConstellationabsStartInt /
              ZhouTianCalculator.DEGREE_MULTIPLIER,
          cabsEndInt / ZhouTianCalculator.DEGREE_MULTIPLIER,
          cWidthInt / ZhouTianCalculator.DEGREE_MULTIPLIER);
      currentConstellationabsStartInt = cabsEndInt;
    }
    return constellationAngles;
  }

  List<ConstellationMappingResult> mapConstellationsToPalaces() {
    final Map<EnumTwelveGong, CelestialObject<EnumTwelveGong>> palacesData =
        calculatePalaceAngles();
    final Map<Enum28Constellations, CelestialObject<Enum28Constellations>>
        constellationsData = calculateConstellationAngles();

    List<ConstellationMappingResult> results = [];

    List<CelestialObject<EnumTwelveGong>> sortedPalaces =
        palacesData.values.toList();
    // 排序时使用规范化后的起始点，以确保正确的查找顺序
    sortedPalaces.sort((a, b) => normalizeAngle(
            a.absStartContinuous, zhouTianModel.totalDegree)
        .compareTo(
            normalizeAngle(b.absStartContinuous, zhouTianModel.totalDegree)));

    for (Enum28Constellations cName in zhouTianModel.starInnOrder) {
      CelestialObject<Enum28Constellations> constellation =
          constellationsData[cName]!;

      // 将星宿的原始double值转为整数进行计算
      int constellationStartContInt = (constellation.absStartContinuous *
              ZhouTianCalculator.DEGREE_MULTIPLIER)
          .round();
      int constellationWidthInt =
          (constellation.width * ZhouTianCalculator.DEGREE_MULTIPLIER).round();
      int constellationEndContInt =
          constellationStartContInt + constellationWidthInt;

      List<ConstellationSegment> segments = [];
      int constellationProcessedDegreesInt = 0; // 这是相对于星宿自身0度的已处理部分
      int currentAbsPosOverallInt = constellationStartContInt; // 当前处理的连续绝对位置

      while (constellationProcessedDegreesInt <
          constellationWidthInt - EPSILON_INT_COMPARISON_THRESHOLD.round()) {
        int currentAbsPosInCycleInt =
            normalizeAngleInt(currentAbsPosOverallInt, totalDegreesInt);

        CelestialObject? currentPalaceFound;
        for (CelestialObject p in sortedPalaces) {
          int pStartContInt =
              (p.absStartContinuous * ZhouTianCalculator.DEGREE_MULTIPLIER)
                  .round();
          int pEndContInt =
              (p.absEndContinuous * ZhouTianCalculator.DEGREE_MULTIPLIER)
                  .round(); // p.absStart + p.width

          // 关键：我们需要找到一个宫位 P，使得 currentAbsPosOverallInt 落在 P 的 [P_start_cont, P_end_cont) 区间内
          // 为了正确处理跨越多个周天的情况，我们需要找到宫位在 currentAbsPosOverallInt 附近的那个“实例”
          int pStartEffective = pStartContInt;
          while (pStartEffective +
                  (p.width * ZhouTianCalculator.DEGREE_MULTIPLIER).round() <=
              currentAbsPosOverallInt -
                  EPSILON_INT_COMPARISON_THRESHOLD.round()) {
            pStartEffective += totalDegreesInt;
          }
          while (pStartEffective >
              currentAbsPosOverallInt +
                  EPSILON_INT_COMPARISON_THRESHOLD.round()) {
            pStartEffective -= totalDegreesInt;
          }
          int pEndEffective = pStartEffective +
              (p.width * ZhouTianCalculator.DEGREE_MULTIPLIER).round();

          if (currentAbsPosOverallInt >=
                  pStartEffective - EPSILON_INT_COMPARISON_THRESHOLD.round() &&
              currentAbsPosOverallInt <
                  pEndEffective - EPSILON_INT_COMPARISON_THRESHOLD.round()) {
            currentPalaceFound = p; // p 存储的是原始的double值对象
            break;
          }
        }

        if (currentPalaceFound == null) {
          throw Exception(
              '宫位未找到! 星宿: ${constellation.name}, 当前绝对位置(int): $currentAbsPosOverallInt, 规范化后: $currentAbsPosInCycleInt');
        }
        CelestialObject currentPalace = currentPalaceFound;
        int palaceStartContInt = (currentPalace.absStartContinuous *
                ZhouTianCalculator.DEGREE_MULTIPLIER)
            .round();
        int palaceWidthInt =
            (currentPalace.width * ZhouTianCalculator.DEGREE_MULTIPLIER)
                .round();
        int palaceEndContInt = palaceStartContInt + palaceWidthInt;

        // 找到宫位在当前绝对位置附近的那个“实例”的起始点
        int palaceStartEffectiveInt = palaceStartContInt;
        while (palaceStartEffectiveInt + palaceWidthInt <=
            currentAbsPosOverallInt -
                EPSILON_INT_COMPARISON_THRESHOLD.round()) {
          palaceStartEffectiveInt += totalDegreesInt;
        }
        while (palaceStartEffectiveInt >
            currentAbsPosOverallInt +
                EPSILON_INT_COMPARISON_THRESHOLD.round()) {
          palaceStartEffectiveInt -= totalDegreesInt;
        }
        int palaceEndEffectiveInt = palaceStartEffectiveInt + palaceWidthInt;

        // 段在宫内的起始度数 = 当前绝对位置 - 宫位有效实例的起始位置
        int segmentStartInPalaceInt =
            currentAbsPosOverallInt - palaceStartEffectiveInt;

        int remainingInConstellationInt =
            constellationWidthInt - constellationProcessedDegreesInt;
        int remainingInPalaceInt =
            palaceEndEffectiveInt - currentAbsPosOverallInt;

        int segmentLengthInt =
            min(remainingInConstellationInt, remainingInPalaceInt);

        if (segmentLengthInt < 1 && remainingInConstellationInt > 0) {
          // 避免长度为0卡死
          logger.w(
              "警告: segmentLengthInt 为0或负 ($segmentLengthInt), 但星宿 ${constellation.name} 尚余 $remainingInConstellationInt. 强制推进1单位.");
          segmentLengthInt = 1; // 推进最小单位
          if (segmentLengthInt > remainingInConstellationInt)
            segmentLengthInt = remainingInConstellationInt;
          if (segmentLengthInt > remainingInPalaceInt)
            segmentLengthInt = remainingInPalaceInt;
        }
        if (segmentLengthInt <= 0 &&
            constellationProcessedDegreesInt >=
                constellationWidthInt -
                    EPSILON_INT_COMPARISON_THRESHOLD.round()) {
          break;
        }
        if (segmentLengthInt <= 0) {
          throw Exception(
              "错误: segmentLengthInt <= 0 ($segmentLengthInt) 在星宿 ${constellation.name} 未完成时。");
        }

        int segmentEndInConstellationInt =
            constellationProcessedDegreesInt + segmentLengthInt;
        // 段在宫内的结束度数 = 段在宫内起始 + 段长
        int segmentEndInPalaceInt = segmentStartInPalaceInt + segmentLengthInt;

        double? crossPoint = null;
        if ((palaceEndEffectiveInt - currentAbsPosOverallInt - segmentLengthInt)
                    .abs() <
                EPSILON_INT_COMPARISON_THRESHOLD.round() &&
            remainingInConstellationInt >
                segmentLengthInt + EPSILON_INT_COMPARISON_THRESHOLD.round()) {
          crossPoint = segmentEndInConstellationInt /
              ZhouTianCalculator.DEGREE_MULTIPLIER;
        }

        // 在创建ConstellationSegment时使用枚举值
        segments.add(ConstellationSegment(
          palaceName: currentPalace.name, // 现在是EnumTwelveGong类型
          startInPalaceDeg:
              segmentStartInPalaceInt / ZhouTianCalculator.DEGREE_MULTIPLIER,
          endInPalaceDeg:
              segmentEndInPalaceInt / ZhouTianCalculator.DEGREE_MULTIPLIER,
          startInConstellationDeg: constellationProcessedDegreesInt /
              ZhouTianCalculator.DEGREE_MULTIPLIER,
          endInConstellationDeg: segmentEndInConstellationInt /
              ZhouTianCalculator.DEGREE_MULTIPLIER,
          segmentLengthDeg:
              segmentLengthInt / ZhouTianCalculator.DEGREE_MULTIPLIER,
          crossesPalaceAtConstellationDeg: crossPoint,
        ));

        constellationProcessedDegreesInt +=
            segmentLengthInt; // 正确累加相对于星宿自身的已处理度数
        currentAbsPosOverallInt += segmentLengthInt;
      }
      results.add(ConstellationMappingResult(
        constellationName: constellation.name, // 现在是Enum28Constellations类型
        absStartDeg: normalizeAngle(
            constellation.absStartContinuous, zhouTianModel.totalDegree),
        absEndDeg: normalizeAngle(
            constellation.absEndContinuous, zhouTianModel.totalDegree),
        totalWidthDeg: constellation.width,
        segments: segments,
      ));
    }
    return results;
  }

  /// 将宫位映射到星宿的结果
  /// 基于 mapConstellationsToPalaces() 的返回结果，创建以宫位为主体的映射
  List<PalaceMappingResult> mapPalacesToConstellations(
      List<ConstellationMappingResult> constellationMappings,
      Map<EnumTwelveGong, CelestialObject<EnumTwelveGong>> palacesData) {
    // // 首先获取星宿到宫位的映射结果
    // List<ConstellationMappingResult> constellationMappings =
    //     mapConstellationsToPalaces();

    // // 获取宫位数据
    // final Map<EnumTwelveGong, CelestialObject<EnumTwelveGong>> palacesData =
    //     calculatePalaceAngles();

    // 创建宫位到星宿分段的映射
    Map<EnumTwelveGong, List<PalaceConstellationSegment>> palaceToSegments = {};

    // 初始化所有宫位的分段列表
    for (EnumTwelveGong palace in palacesData.keys) {
      palaceToSegments[palace] = [];
    }

    // 遍历所有星宿映射结果，将分段信息重新组织到对应的宫位中
    for (ConstellationMappingResult constellationResult
        in constellationMappings) {
      for (ConstellationSegment segment in constellationResult.segments) {
        EnumTwelveGong palaceName = segment.palaceName;

        // 创建宫位中的星宿分段信息
        PalaceConstellationSegment palaceSegment = PalaceConstellationSegment(
          constellationName: constellationResult.constellationName,
          // totalDeg: zhouTianModel.starInnDegreeSeq
          //     .firstWhere((t) =>
          //         t.constellation == constellationResult.constellationName)
          //     .degree,
          startInConstellationDeg: segment.startInConstellationDeg,
          endInConstellationDeg: segment.endInConstellationDeg,
          startInPalaceDeg: segment.startInPalaceDeg,
          endInPalaceDeg: segment.endInPalaceDeg,
          segmentLengthDeg: segment.segmentLengthDeg,
        );

        palaceToSegments[palaceName]!.add(palaceSegment);
      }
    }

    // 创建最终的宫位映射结果列表
    List<PalaceMappingResult> results = [];

    for (EnumTwelveGong palace in palacesData.keys) {
      CelestialObject<EnumTwelveGong> palaceData = palacesData[palace]!;
      List<PalaceConstellationSegment> segments = palaceToSegments[palace]!;

      // 按照在宫位中的起始度数排序
      segments.sort((a, b) => a.startInPalaceDeg.compareTo(b.startInPalaceDeg));

      PalaceMappingResult palaceResult = PalaceMappingResult(
        palaceName: palace,
        totalWidthDeg: palaceData.width,
        absStartDeg: normalizeAngle(
            palaceData.absStartContinuous, zhouTianModel.totalDegree),
        absEndDeg: normalizeAngle(
            palaceData.absEndContinuous, zhouTianModel.totalDegree),
        segments: segments,
      );

      results.add(palaceResult);
    }

    // 按照宫位顺序排序（可选）
    results.sort((a, b) {
      int indexA = zhouTianModel.gongOrder.indexOf(a.palaceName);
      int indexB = zhouTianModel.gongOrder.indexOf(b.palaceName);
      return indexA.compareTo(indexB);
    });

    return results;
  }
}

// 假设的 ZhouTianCalculator 内部方法，用于计算静态周天信息
// 你需要将上一版回复中的 _calculatePalaceAngles 和 calculateConstellationAngles 逻辑
// 提取出来，或者使它们可以被 DongWeiDaXianCalculator 调用。
// 为了简洁，这里仅示意。
extension ZhouTianCalculatorStaticHelpers on ZhouTianCalculator {
  // 之前的 _calculatePalaceAngles 逻辑
  Map<EnumTwelveGong, CelestialObject> calculatePalaceAngles() {
    // ... (复制并粘贴上一版回复中的 _calculatePalaceAngles 实现)
    // ... (确保 CelestialObject.name 是 EnumName.toString().split('.').last)
    // ... (确保返回的 CelestialObject 的 absStartContinuous 和 absEndContinuous 是正确的连续度数)
    //  return {}; // 占位符
    final List<EnumTwelveGong> palaceOrder = this.zhouTianModel.gongOrder;
    if (palaceOrder.isEmpty) throw ArgumentError("宫位顺序列表 (gongOrder) 不能为空");

    final Map<EnumTwelveGong, int> palaceWidthsInt = {};
    if (this.zhouTianModel.gongDegreeSeq.isNotEmpty &&
        this.zhouTianModel.gongDegreeSeq.length == palaceOrder.length) {
      final Map<EnumTwelveGong, double> inputPalaceWidths = {
        for (var gd in this.zhouTianModel.gongDegreeSeq) gd.gong: gd.degree
      };
      for (EnumTwelveGong pNameKey in palaceOrder) {
        if (inputPalaceWidths.containsKey(pNameKey)) {
          palaceWidthsInt[pNameKey] = (inputPalaceWidths[pNameKey]! *
                  ZhouTianCalculator.DEGREE_MULTIPLIER)
              .round();
        } else {
          logger
              .w("警告: 未在 gongDegreeSeq 中通过名称找到宫位 ${pNameKey.name} 的宽度，将使用默认值。");
          int fallbackWidth =
              (this.totalDegreesInt / palaceOrder.length).round();
          palaceWidthsInt[pNameKey] = fallbackWidth;
        }
      }
    } else {
      logger.w("警告: gongDegreeSeq 提供不完整或为空，假设为等宫制。");
      int defaultPalaceWidthInt =
          (this.totalDegreesInt / palaceOrder.length).round();
      for (var gong in palaceOrder) {
        palaceWidthsInt[gong] = defaultPalaceWidthInt;
      }
    }

    final EnumTwelveGong alignmentGongName =
        this.zhouTianModel.alignmentPointAtGong.gong;
    final int palaceAlignmentOffsetInt =
        (this.zhouTianModel.alignmentPointAtGong.degree *
                ZhouTianCalculator.DEGREE_MULTIPLIER)
            .round();
    final int celestialZeroPointInt = 0;

    Map<EnumTwelveGong, CelestialObject> palaceAngles = {};
    int currentPalaceAbsStartContinuousInt =
        celestialZeroPointInt - palaceAlignmentOffsetInt;

    int alignmentGongIndex = palaceOrder.indexOf(alignmentGongName);
    if (alignmentGongIndex == -1) {
      throw ArgumentError("对齐宫位 ${alignmentGongName.name} 不在 gongOrder 中。");
    }

    for (int i = 0; i < palaceOrder.length; i++) {
      int effectiveIndex = (alignmentGongIndex + i) % palaceOrder.length;
      EnumTwelveGong pName = palaceOrder[effectiveIndex];
      int pWidthInt = palaceWidthsInt[pName]!;

      int pAbsEndContinuousInt = currentPalaceAbsStartContinuousInt + pWidthInt;

      palaceAngles[pName] = CelestialObject(
          pName.name,
          currentPalaceAbsStartContinuousInt /
              ZhouTianCalculator.DEGREE_MULTIPLIER,
          pAbsEndContinuousInt / ZhouTianCalculator.DEGREE_MULTIPLIER,
          pWidthInt / ZhouTianCalculator.DEGREE_MULTIPLIER);
      currentPalaceAbsStartContinuousInt = pAbsEndContinuousInt;
    }
    return palaceAngles;
  }

  // 之前的 calculateConstellationAngles 逻辑
  Map<Enum28Constellations, CelestialObject> calculateConstellationAngles() {
    // ... (复制并粘贴上一版回复中的 calculateConstellationAngles 实现)
    // ... (确保 CelestialObject.name 是 EnumName.toString().split('.').last)
    // ... (确保返回的 CelestialObject 的 absStartContinuous 和 absEndContinuous 是正确的连续度数)
    // return {}; // 占位符
    final List<Enum28Constellations> constellationOrder =
        this.zhouTianModel.starInnOrder;
    if (constellationOrder.isEmpty)
      throw ArgumentError("星宿顺序列表 (starInnOrder) 不能为空");

    final Map<Enum28Constellations, int> constellationWidthsInt = {};
    if (this.zhouTianModel.starInnDegreeSeq.isNotEmpty &&
        this.zhouTianModel.starInnDegreeSeq.length ==
            constellationOrder.length) {
      for (int i = 0; i < constellationOrder.length; i++) {
        constellationWidthsInt[constellationOrder[i]] =
            (this.zhouTianModel.starInnDegreeSeq[i].degree *
                    ZhouTianCalculator.DEGREE_MULTIPLIER)
                .round();
      }
    } else {
      throw ArgumentError("starInnDegreeSeq 提供不完整或与 starInnOrder 不匹配。");
    }

    final Enum28Constellations alignmentConstellationName =
        this.zhouTianModel.alignmentPointAtConstellation.constellation;
    final int constellationAlignmentOffsetInt =
        (this.zhouTianModel.alignmentPointAtConstellation.degree *
                ZhouTianCalculator.DEGREE_MULTIPLIER)
            .round();
    final int celestialZeroPointInt = 0;

    Map<Enum28Constellations, CelestialObject> constellationAngles = {};
    int currentConstellationAbsStartContinuousInt =
        celestialZeroPointInt - constellationAlignmentOffsetInt;

    int alignmentConstellationIndex =
        constellationOrder.indexOf(alignmentConstellationName);
    if (alignmentConstellationIndex == -1) {
      throw ArgumentError(
          "对齐星宿 ${alignmentConstellationName.name} 不在 starInnOrder 中。");
    }

    for (int i = 0; i < constellationOrder.length; i++) {
      int effectiveIndex =
          (alignmentConstellationIndex + i) % constellationOrder.length;
      Enum28Constellations cName = constellationOrder[effectiveIndex];
      int cWidthInt = constellationWidthsInt[cName]!;

      int cAbsEndContinuousInt =
          currentConstellationAbsStartContinuousInt + cWidthInt;

      constellationAngles[cName] = CelestialObject(
          cName.name,
          currentConstellationAbsStartContinuousInt /
              ZhouTianCalculator.DEGREE_MULTIPLIER,
          cAbsEndContinuousInt / ZhouTianCalculator.DEGREE_MULTIPLIER,
          cWidthInt / ZhouTianCalculator.DEGREE_MULTIPLIER);
      currentConstellationAbsStartContinuousInt = cAbsEndContinuousInt;
    }
    return constellationAngles;
  }
}
