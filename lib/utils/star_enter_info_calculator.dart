import 'package:common/enums/enum_di_zhi.dart';
import 'package:decimal/decimal.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart'; // 使用domain层的模型
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart'; // 使用domain层的模型

import '../domain/entities/models/star_enter_info.dart'; // 使用domain层的模型
import 'package:common/module.dart';

// 计算每个星体的进入宫位和星宿
class StarEnterInfoCalculator {
  final ZhouTianModel zhouTianModel;
  final int scale; // 保留小数位数

  StarEnterInfoCalculator({required this.zhouTianModel, this.scale = 3}) {
    // 根据十二地支 逆向进行排序
    List<DiZhi> reversedList = DiZhi.values.reversed.toList();
    final newGongDegreeSeq = <GongDegree>[];
    Map<EnumTwelveGong, GongDegree> gongDegreeMap = Map.fromEntries(
        zhouTianModel.gongDegreeSeq.map((e) => MapEntry(e.gong, e)));
    reversedList.forEach((element) {
      newGongDegreeSeq
          .add(gongDegreeMap[EnumTwelveGong.getEnumTwelveGongByZhi(element)]!);
    });
  }

  List<EnteredInfo> calculate(List<StarDegree> starDegreeSeq) {
    List<ConstellationPosition> adjuestedStarInnSeq =
        generateConstellationSequence(
            zhouTianModel.alignmentPointAtConstellation,
            zhouTianModel.starInnDegreeSeq);
    List<GongPosition> adjustedGongSeq = generateGongSequence(
        zhouTianModel.alignmentPointAtGong, zhouTianModel.gongDegreeSeq);
    // 计算每个星体的进入宫位和星宿
    final result = <EnteredInfo>[];
    for (final star in starDegreeSeq) {
      logger.d("${star.toJson()}");
      final starInn = doFindConstellation(
        star.degree,
        adjuestedStarInnSeq,
        scale: scale,
      );
      final gong = doFindGong(
        star.degree,
        adjustedGongSeq,
        scale: scale,
      );
      result.add(EnteredInfo(
          originalStar: star, enterGongInfo: gong, enterInnInfo: starInn));
    }

    return result;
  }

  static List<ConstellationPosition> generateConstellationSequence(
      ConstellationDegree dynamicStart,
      List<ConstellationDegree> baseSequence) {
    final tmpAppendToTail = <ConstellationDegree>[];
    final newSequence = <ConstellationDegree>[];

    for (final constellation in baseSequence) {
      if (constellation.constellation != dynamicStart.constellation) {
        if (newSequence.isEmpty) {
          tmpAppendToTail.add(ConstellationDegree(
            constellation: constellation.constellation,
            degree: constellation.degree,
          ));
        } else {
          newSequence.add(ConstellationDegree(
            constellation: constellation.constellation,
            degree: constellation.degree,
          ));
        }
      } else {
        if (dynamicStart.degree > constellation.degree) {
          // // print(
          //     '警告：${dynamicStart.name}宿偏移量${dynamicStart.degree}超过该宿总度数${constellation.degree}');
        } else {
          tmpAppendToTail.add(ConstellationDegree(
            constellation: constellation.constellation,
            degree: dynamicStart.degree,
          ));
          newSequence.add(ConstellationDegree(
            constellation: dynamicStart.constellation,
            degree: constellation.degree - dynamicStart.degree,
          ));
        }
      }
    }

    newSequence.addAll(tmpAppendToTail);

    double currentAngle = 0;
    final newSequenceWithStartEnd = <ConstellationPosition>[];

    for (final item in newSequence) {
      newSequenceWithStartEnd.add(ConstellationPosition(
        constellation: item.constellation,
        degree: item.degree,
        startAtDegree: currentAngle,
        endAtDegree: currentAngle + item.degree,
      ));
      currentAngle += item.degree;
    }

    return newSequenceWithStartEnd;
  }

  static List<GongPosition> generateGongSequence(
      GongDegree dynamicStart, List<GongDegree> baseSequence) {
    final tmpAppendToTail = <GongDegree>[];
    final newSequence = <GongDegree>[];

    for (final gong in baseSequence) {
      if (gong.gong != dynamicStart.gong) {
        if (newSequence.isEmpty) {
          tmpAppendToTail.add(GongDegree(
            gong: gong.gong,
            degree: gong.degree,
          ));
        } else {
          newSequence.add(GongDegree(
            gong: gong.gong,
            degree: gong.degree,
          ));
        }
      } else {
        if (dynamicStart.degree > gong.degree) {
          // // print(
          //     '警告：${dynamicStart.name}宿偏移量${dynamicStart.degree}超过该宿总度数${constellation.degree}');
        } else {
          // NOTE: 每宫30°时会添加一个为0°的宫位 在末尾（戌宫）所以删除
          // tmpAppendToTail.add(GongDegree(
          //   gong: gong.gong,
          //   degree: dynamicStart.degree,
          // ));
          newSequence.add(GongDegree(
            gong: gong.gong,
            degree: gong.degree - dynamicStart.degree,
          ));
        }
      }
    }

    newSequence.addAll(tmpAppendToTail);

    double currentAngle = 0;
    final newSequenceWithStartEnd = <GongPosition>[];

    for (final item in newSequence) {
      newSequenceWithStartEnd.add(GongPosition(
        gong: item.gong,
        degree: item.degree,
        startAtDegree: currentAngle,
        endAtDegree: currentAngle + item.degree,
      ));
      currentAngle += item.degree;
    }

    return newSequenceWithStartEnd;
  }

  static ConstellationDegree doFindConstellation(
      double targetDegree, List<ConstellationPosition> starInnSeq,
      {int scale = 3}) {
    for (int index = 0; index < starInnSeq.length; index++) {
      final ConstellationPosition item = starInnSeq[index];
      if (item.startAtDegree <= targetDegree &&
          item.endAtDegree >= targetDegree) {
        if (index == 0 &&
            item.constellation == starInnSeq.first.constellation &&
            item.constellation == starInnSeq.last.constellation) {
          return ConstellationDegree(
            constellation: item.constellation,
            degree: toDecimal(targetDegree + starInnSeq.last.degree, scale),
          );
        } else {
          return ConstellationDegree(
            constellation: item.constellation,
            degree: toDecimal(targetDegree - item.startAtDegree, scale),
          );
        }
      }
    }

    logger.e("starInnSeq: ${starInnSeq.map((e) => e).toList()}");
    throw Exception('${targetDegree} 未找到对应的星座');
  }

  static GongDegree doFindGong(double targetDegree, List<GongPosition> gongSeq,
      {int scale = 3}) {
    for (int index = 0; index < gongSeq.length; index++) {
      final item = gongSeq[index];
      // print(
      // "-------_${item.gong} ${item.startAtDegree} ${item.endAtDegree} --- $targetDegree --- ${targetDegree >= item.startAtDegree && targetDegree <= item.endAtDegree}");
      if (targetDegree >= item.startAtDegree &&
          targetDegree <= item.endAtDegree) {
        if (index == 0 &&
            item.gong == gongSeq.first.gong &&
            item.gong == gongSeq.last.gong) {
          // print("-------_${targetDegree + gongSeq.last.degree}");
          // print(
          // "-------_${toDecimal(targetDegree + gongSeq.last.degree, scale)}");
          return GongDegree(
            gong: item.gong,
            degree: toDecimal(targetDegree + gongSeq.last.degree, scale),
          );
        } else {
          return GongDegree(
              gong: item.gong,
              degree: toDecimal(targetDegree - item.startAtDegree, scale));
        }
      }
    }

    throw Exception('未找到对应的宫位');
  }

  static double toDecimal(double value, int scale) {
    return Decimal.parse(value.toString()).round(scale: scale).toDouble();
  }

  @Deprecated('使用 _doFindConstellation 替代')
  ConstellationDegree _findSingleStarAtConstellation(
      double targetDegree,
      ConstellationDegree dynamicStart,
      List<ConstellationDegree> baseSequence) {
    final adjustedSequence =
        generateConstellationSequence(dynamicStart, baseSequence);

    for (int index = 0; index < adjustedSequence.length; index++) {
      final ConstellationPosition item = adjustedSequence[index];
      if (item.startAtDegree <= targetDegree &&
          item.endAtDegree >= targetDegree) {
        if (index == 0 &&
            item.constellation == adjustedSequence.first.constellation &&
            item.constellation == adjustedSequence.last.constellation) {
          return ConstellationDegree(
            constellation: item.constellation,
            degree: targetDegree + adjustedSequence.last.degree,
          );
        } else {
          return ConstellationDegree(
            constellation: item.constellation,
            degree: targetDegree - item.startAtDegree,
          );
        }
      }
    }

    throw Exception('未找到对应的星座');
  }

  @Deprecated('使用 _doFindGong 替代')
  GongDegree _findSingleStarAtGong(double targetDegree, GongDegree dynamicStart,
      List<GongDegree> gongSequence) {
    final adjustedSequence = generateGongSequence(
      dynamicStart,
      gongSequence,
    );

    for (int index = 0; index < adjustedSequence.length; index++) {
      final item = adjustedSequence[index];
      if (item.startAtDegree <= targetDegree &&
          item.endAtDegree >= targetDegree) {
        if (index == 0 &&
            item.gong == adjustedSequence.first.gong &&
            item.gong == adjustedSequence.last.gong) {
          return GongDegree(
            gong: item.gong,
            degree: targetDegree -
                item.startAtDegree +
                adjustedSequence.last.degree,
          );
        } else {
          return GongDegree(
              gong: item.gong, degree: targetDegree - item.startAtDegree);
        }
      }
    }

    throw Exception('未找到对应的宫位');
  }
}
