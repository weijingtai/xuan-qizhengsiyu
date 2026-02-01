import 'package:common/datamodel/basic_person_info.dart';
import 'package:common/enums.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_constant_resources.dart';
import 'package:tuple/tuple.dart';

import '../../../presentation/models/ui_star_model.dart';
import 'star_hidden_type.dart';
import 'star_inn_gong_degree.dart';

class QiZhengsSiYuPanelModel {
  BasicPersonInfo basicInfo;
  PanelCelesticalInfo panelInfo;

  // 是否为真太阳时
  bool isApparentSolarTime;
  // 是否为夏令时
  bool isDayLightSavingTime;

  // 以下是一些关于盘面中细节的阈值设定，如：星体于太阳的角度小于少时被视为“伏藏”
  StarHiddenType hiddenType; // 星体在太阳周围伏藏的角度，一般为“8”，也有认为“15”

  // 身命

  // 星曜

  // 十二地支宫

  // 化曜 - 科名、科甲之类

  QiZhengsSiYuPanelModel({
    required this.basicInfo,
    required this.panelInfo,
    required this.hiddenType,
    required this.isApparentSolarTime,
    required this.isDayLightSavingTime,
  });

  /// @return
  /// tuple.item1 角度 入宫 0°为戌宫0° 逆时针
  /// tuple.item2 入宫度数
  static Tuple2<EnumTwelveGong, double> calculateStarAngleEnterDiZhiGong(
      double starAngle) {
    double enterGongAngle = starAngle.floorToDouble();
    if (enterGongAngle == 0) {
      return Tuple2(EnumTwelveGong.Xu, starAngle);
    }
    int totalPassedGong = enterGongAngle ~/ 30;
    double leftAngle = starAngle - 30 * totalPassedGong;
    return Tuple2(EnumTwelveGong.eclipticSeq[totalPassedGong], leftAngle);
  }

  /// @return
  /// tuple.item1 角度 入星宿 入宫 0°为戌宫0° 逆时针
  /// tuple.item2 入星宿度数
  static Tuple2<Enum28Constellations, double> calculateStarAngleEnterStarInn(
      double starAngle,
      StarPanelType type,
      Map<Enum28Constellations, ConstellationGongDegreeInfo> mapper) {
    int tmpStarAngle = ((starAngle + type.firstAtZeroDegree) * 100).round();

    int previousAngle = tmpStarAngle;
    for (int i = 0; i < 28; i++) {
      Enum28Constellations starInn = type.starInnOrder[i];
      ConstellationGongDegreeInfo starXiuType = mapper[starInn]!;
      int angle = previousAngle - (starXiuType.totalDegree * 100).round();
      if (angle <= 0) {
        return Tuple2(starInn, (previousAngle * 0.01));
      }
      if (i == 27) {
        if (angle == 0) {
          return Tuple2(type.starInnOrder.first, 0);
        }
        if (angle > 0) {
          return Tuple2(type.starInnOrder.first, (angle * 0.01));
        }
      }
      previousAngle = angle;
    }

    return Tuple2(type.starInnOrder.first, 0);
  }

  /// @return
  /// tuple.item1 入宫
  /// tuple.item2 入宫度数
  static Tuple2<EnumTwelveGong, double> calculateEnterDiZhiGong(
      UIStarModel star) {
    double starAngle = star.angle;
    double enterGongAngle = starAngle.floorToDouble();
    if (enterGongAngle == 0) {
      return Tuple2(EnumTwelveGong.Xu, starAngle);
    }
    int totalPassedGong = enterGongAngle ~/ 30;
    double leftAngle = starAngle - 30 * totalPassedGong;
    return Tuple2(EnumTwelveGong.eclipticSeq[totalPassedGong], leftAngle);
  }

  /// @return
  /// tuple.item1 入星宿
  /// tuple.item2 入星宿度数
  static Tuple2<Enum28Constellations, double> calculateEnterStarInn(
      UIStarModel star,
      StarPanelType type,
      Map<Enum28Constellations, ConstellationGongDegreeInfo> mapper) {
    //
    double starAngle = star.angle;
    // double enterGongAngle = starAngle.floorToDouble();
    int enterGongAngle = starAngle.round();
    // if (starAngle <= type.firstAtZeroDegree) {
    // return Tuple2(type.starInnOrder.first, 0);
    // }

    int tmpStarAngle = ((star.angle + type.firstAtZeroDegree) * 100).round();

    int previousAngle = tmpStarAngle;
    for (int i = 0; i < 28; i++) {
      Enum28Constellations starInn = type.starInnOrder[i];
      ConstellationGongDegreeInfo starXiuType = mapper[starInn]!;
      int angle = previousAngle - (starXiuType.totalDegree * 100).round();
      if (angle <= 0) {
        return Tuple2(starInn, (previousAngle * 0.01));
      }
      if (i == 27) {
        if (angle == 0) {
          return Tuple2(type.starInnOrder.first, 0);
        }
        if (angle > 0) {
          return Tuple2(type.starInnOrder.first, (angle * 0.01));
        }
      }
      previousAngle = angle;
    }

    return Tuple2(type.starInnOrder.first, 0);
  }
}
