import 'package:common/enums.dart';
import 'package:tuple/tuple.dart';

import '../enums/enum_twelve_gong.dart';
import '../domain/entities/models/star_inn_gong_degree.dart'; // 使用domain层的模型
import '../qi_zheng_si_yu_constant_resources.dart';

class StarDegreeInnGongHelper {
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
}
