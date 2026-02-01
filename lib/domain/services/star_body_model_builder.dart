import 'package:common/enums.dart';
import 'package:qizhengsiyu/enums/enum_moon_phases.dart';
import 'package:tuple/tuple.dart';

import '../../enums/enum_qi_zheng.dart';
import '../../enums/enum_twelve_gong.dart';
import '../../qi_zheng_si_yu_constant_resources.dart';
import '../../utils/star_degree_inn_gong_helper.dart';
import '../../utils/star_walking_info_utils.dart';
import '../entities/models/eleven_stars_info.dart';
import '../entities/models/naming_degree_pair.dart';
import '../entities/models/observer_position.dart';
import '../entities/models/panel_stars_info.dart';
import '../entities/models/star_enter_info.dart';
import '../entities/models/stars_angle.dart';
import 'star_angle_strategy.dart';

class StarBodyModelBuilder {
  PanelCelesticalInfo panelCelesticalInfo;
  ObserverPosition observerPosition;
  StarBodyModelBuilder(
      {required this.panelCelesticalInfo, required this.observerPosition});

  createFiveStar(
      EnumStars star, double starAngle, double starSpeed, bool isHidden) {
    EnteredInfo starInfo = calculateStarEnterInfo(star, starAngle);
    return FiveStarsInfo(
      star: star,
      angle: starAngle,
      enterInfo: starInfo,
      fiveStarWalkingType: getWalkingType(star, starSpeed),
      walkingSpeed: starSpeed,
      // isHidden: isHidden
    );
  }

  createSunStar(EnumStars star, double sunAngle) {
    EnteredInfo starInfo = calculateStarEnterInfo(star, sunAngle);
    return SunInfo(angle: sunAngle, enterInfo: starInfo);
  }

  createMoonStar(EnumStars star, double moonAngle, bool isHidden) {
    // TODO: 需要添加月亮 月象的部分
    EnteredInfo starInfo = calculateStarEnterInfo(star, moonAngle);
    return MoonInfo(
        angle: moonAngle,
        enterInfo: starInfo,
        // isHidden: isHidden,
        moonPhase: EnumMoonPhases.Can_Yue);
  }

  createFuYu(EnumStars star, double starAngle, bool isHidden) {
    EnteredInfo starInfo = calculateStarEnterInfo(star, starAngle);
    if (star == EnumStars.Bei) {
      return FourSlaveStarInfo.bei(angle: starAngle, enterInfo: starInfo);
    } else if (star == EnumStars.Qi) {
      return FourSlaveStarInfo.qi(angle: starAngle, enterInfo: starInfo);
    } else {
      return LouJiStarsInfo(star: star, angle: starAngle, enterInfo: starInfo);
    }
  }

  FiveStarWalkingType getWalkingType(
    EnumStars star,
    double starSpeed,
  ) {
    final tuple = StarsAngle.moirasFiveStartsMapper[star]!;

    // 优先判断留行状态（接近静止）
    if (starSpeed.abs() <= tuple.item4) {
      return FiveStarWalkingType.Stay;
    }

    // 判断逆行状态
    if (starSpeed < 0) {
      return FiveStarWalkingType.Retrograde;
    }

    // 顺行状态判断
    if (tuple.item5 != null && starSpeed >= tuple.item5!) {
      return FiveStarWalkingType.Fast;
    }

    if (tuple.item6 != null) {
      return starSpeed >= tuple.item6!
          ? FiveStarWalkingType.Normal
          : FiveStarWalkingType.Slow;
    }

    // 默认常态（当疾行/迟行阈值未定义时）
    return FiveStarWalkingType.Normal;
  }

  Map<EnumStars, FiveStarWalkingInfo> calculateFiveStarskWalingStatus(
      EnumStars star) {
    Map<EnumStars, FiveStarWalkingInfo> result = {};
    StarWalkingInfoUtils.calculateStarWalkingInfo(
        star, observerPosition, StarsAngle.moirasFiveStartsMapper);
    return result;
  }

  EnteredInfo calculateStarEnterInfo(EnumStars star, double starAngle) {
    Tuple2<EnumTwelveGong, double> sunResult =
        StarDegreeInnGongHelper.calculateStarAngleEnterDiZhiGong(starAngle);
    EnumTwelveGong starEnterGong = sunResult.item1;
    double starEnterGongDegree = sunResult.item2;
    // 命宫
    Tuple2<Enum28Constellations, double> innTuple =
        StarDegreeInnGongHelper.calculateStarAngleEnterStarInn(
            starEnterGongDegree,
            StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
            StarPanelType.getStarXiuMapper(panelCelesticalInfo));

    return EnteredInfo(
        originalStar: StarDegree(star: star, degree: starAngle),
        enterGongInfo:
            GongDegree(gong: starEnterGong, degree: starEnterGongDegree),
        enterInnInfo: ConstellationDegree(
            constellation: innTuple.item1, degree: innTuple.item2));
  }

}
