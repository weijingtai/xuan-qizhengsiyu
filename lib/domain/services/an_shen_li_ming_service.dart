import 'package:common/enums.dart';
import 'package:common/utils.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';

import 'package:tuple/tuple.dart';

import '../../enums/enum_twelve_gong.dart';
import '../entities/models/body_life_model.dart';
import '../entities/models/eleven_stars_info.dart';
import '../entities/models/naming_degree_pair.dart';
import '../entities/models/star_enter_info.dart';
import '../entities/models/star_inn_gong_degree.dart';


class SettleLifeBodyService {
  // 地支在黄道的顺序，逆时针 戌->酉...->子->亥
  // tatic const List<DiZhi> diZhiAtEclipticGong = [DiZhi.XU,DiZhi.YOU,DiZhi.SHEN,DiZhi.WEI,DiZhi.WU,DiZhi.SI,DiZhi.CHEN,DiZhi.MAO,DiZhi.YIN,DiZhi.CHOU,DiZhi.ZI,DiZhi.HAI];
  static const Map<MonthToken, DiZhi> sunMonthlyAtGongOrderMapper = {
    MonthToken.ZI: DiZhi.YIN,
    MonthToken.CHOU: DiZhi.CHOU,
    MonthToken.YIN: DiZhi.ZI,
    MonthToken.MAO: DiZhi.HAI,
    MonthToken.CHEN: DiZhi.XU,
    MonthToken.SI: DiZhi.YOU,
    MonthToken.WU: DiZhi.SHEN,
    MonthToken.WEI: DiZhi.WEI,
    MonthToken.SHEN: DiZhi.WU,
    MonthToken.YOU: DiZhi.SI,
    MonthToken.XU: DiZhi.CHEN,
    MonthToken.HAI: DiZhi.MAO,
  };

  /// 立命宫
  /// 以太阳在真太阳时为基准，确定太阳所在宫位
  /// @param bySunRealTimeLocation 是否以太阳的真实位置计算命宫
  ///        true 以真太阳时计算
  ///        false 根据月令的不同，确定太阳所在宫位。如：“子月在寅，丑月在丑，寅月在亥。。。。”
  /// @param lifeGong 立命宫
  ///        countingTo 计算宫位是的基准宫位，如“逆数至卯”
  static EnumTwelveGong settleLifeGong(
    EnteredInfo sunEnteredInfo,
    EnumTwelveGong countingTo,
    JiaZi monthGanZhi,
    JiaZi timeGanZhi,
    bool bySunRealTimeLocation,
  ) {
    final EnumTwelveGong sunAtGong;
    if (bySunRealTimeLocation) {
      sunAtGong = sunEnteredInfo.gong;
    } else {
      sunAtGong = sunEnterGongByMonthTokenOnly(monthGanZhi.zhi.asMonthToken);
    }
    return countingToGong(timeGanZhi, sunAtGong, countingTo);
    // List<DiZhi> lists = [
    //   ...DiZhi.listAll.sublist(timeGanZhi.zhi.index - 1),
    //   ...DiZhi.listAll.sublist(0, timeGanZhi.zhi.index - 1)
    // ];
    // final liMingIndex = lists.indexOf(countingTo.zhi);

    // int countingTimes = lists.sublist(0, liMingIndex).length;
    // List<DiZhi> lists0 = [
    //   ...DiZhi.listAll.sublist(sunAtGong.index),
    //   ...DiZhi.listAll.sublist(0, sunAtGong.index)
    // ];
    // return EnumTwelveGong.getEnumTwelveGongByZhi(lists0[countingTimes - 1]);
  }

  static EnumTwelveGong settleBodyGong(
    EnteredInfo moonEnteredInfo,
    EnumTwelveGong countingTo,
    JiaZi? timeGanZhi,
  ) {
    if (timeGanZhi == null) {
      return moonEnteredInfo.gong;
    }
    return countingToGong(timeGanZhi, moonEnteredInfo.gong, countingTo);
  }

  /// 立命
  /// 卯时立命 或者为 辰时 寅时 需要根据真太阳时确定
  /// @return 黄道十二地支宫
  @Deprecated('use settleLifeGong instead')
  static EnumTwelveGong settleDownLifeGong(
    JiaZi monthGanZhi,
    JiaZi timeGanZhi,
    double sunAngle, [
    bool bySunRealTimeLocation = true,
    DiZhi liMingDiZhi = DiZhi.MAO,
  ]) {
    // 获取当前太阳所在宫位
    final EnumTwelveGong sunMonthlyAtGong;
    if (bySunRealTimeLocation) {
      sunMonthlyAtGong = sunEnterGongBySunsAngle(sunAngle);
    } else {
      sunMonthlyAtGong =
          sunEnterGongByMonthTokenOnly(monthGanZhi.zhi.asMonthToken);
    }
    return countingToGong(timeGanZhi, sunMonthlyAtGong,
        EnumTwelveGong.getEnumTwelveGongByZhi(liMingDiZhi));
    // 以当前时辰为开始，从当前太阳所在宫顺时针数到 liMingDiZhi 停止的宫位为命宫的序号
    // 将 timeGanZhi.zhi 作为 DiZhi.listAll 第一个元素
    List<DiZhi> lists = [
      ...DiZhi.listAll.sublist(timeGanZhi.zhi.index - 1),
      ...DiZhi.listAll.sublist(0, timeGanZhi.zhi.index - 1)
    ];
    final liMingIndex = lists.indexOf(liMingDiZhi);

    int countingTimes = lists.sublist(0, liMingIndex).length;
    List<DiZhi> lists0 = [
      ...DiZhi.listAll.sublist(sunMonthlyAtGong.index),
      ...DiZhi.listAll.sublist(0, sunMonthlyAtGong.index)
    ];
    return EnumTwelveGong.getEnumTwelveGongByZhi(lists0[countingTimes - 1]);
  }

  /// 安身
  /// 一为太阴为身，太阴所在宫位为身宫，如太阴在酉，酉就是身宫，太阴在辰，辰就是身宫。
  /// 二为太阴起生时逆数至酉，数法与计算命宫的方法大同小异，即太阴所在宫位加生时逆时针逆数至酉，最后定出的宫位为身宫。
  /// timeGanZhi 为null时 默认使用“一”
  /// @param liBodyDiZhi 立身宫
  static EnumTwelveGong settleDownBodyGong(ElevenStarsInfo lunarInfo,
      [JiaZi? timeGanZhi, DiZhi liBodyDiZhi = DiZhi.YOU]) {
    if (timeGanZhi == null) {
      return lunarInfo.enteredGong;
    }
    return countingToGong(timeGanZhi, lunarInfo.enteredGong,
        EnumTwelveGong.getEnumTwelveGongByZhi(liBodyDiZhi));
    // // 获取当前太阳所在宫位
    // // 以当前时辰为开始，从当前太阳所在宫顺时针数到 liMingDiZhi 停止的宫位为命宫的序号
    // // 将 timeGanZhi.zhi 作为 DiZhi.listAll 第一个元素
    // List<DiZhi> lists = [
    //   ...DiZhi.listAll.sublist(timeGanZhi.zhi.index - 1),
    //   ...DiZhi.listAll.sublist(0, timeGanZhi.zhi.index - 1)
    // ];
    // final liMingIndex = lists.indexOf(liBodyDiZhi);

    // int countingTimes = lists.sublist(0, liBodyDiZhi).length;
    // List<DiZhi> lists0 = [
    //   ...DiZhi.listAll.sublist(lunarInfo.enteredGong.index),
    //   ...DiZhi.listAll.sublist(0, lunarInfo.enteredGong.index)
    // ];
    // return EnumTwelveGong.getEnumTwelveGongByZhi(lists0[countingTimes - 1]);
  }

  static EnumTwelveGong countingToGong(
      JiaZi timeGanZhi, EnumTwelveGong atGong, EnumTwelveGong countingTo) {
    // 获取当前太阳所在宫位
    // 以当前时辰为开始，从当前太阳所在宫顺时针数到 liMingDiZhi 停止的宫位为命宫的序号
    // 将 timeGanZhi.zhi 作为 DiZhi.listAll 第一个元素

    // print(timeGanZhi.zhi.name);
    // print(timeGanZhi.zhi.index);

    List<DiZhi> lists = DiZhi.listAll.map((e) => e).toList();
    if (timeGanZhi.zhi.index != 0) {
      lists = [
        ...DiZhi.listAll.sublist(timeGanZhi.zhi.index - 1),
        ...DiZhi.listAll.sublist(0, timeGanZhi.zhi.index - 1)
      ];
    }
    final liMingIndex = lists.indexOf(countingTo.zhi);

    int countingTimes = lists.sublist(0, liMingIndex).length;
    List<DiZhi> lists0 = [
      ...DiZhi.listAll.sublist(atGong.zhi.index),
      ...DiZhi.listAll.sublist(0, atGong.zhi.index)
    ];
    return EnumTwelveGong.getEnumTwelveGongByZhi(lists0[countingTimes - 1]);
  }

  static EnumTwelveGong sunEnterGongBySunsAngle(double starAngle) {
    /// 如果给定太阳角度，则根据太阳角度计算太阳所在宫位
    /// 戌0°为黄道0，星盘上所有方向为逆时针
    if (starAngle % 30 == 0) {
      int passingGongTotal = (starAngle / 30).toInt();
      return EnumTwelveGong.eclipticSeq[passingGongTotal];
    } else {
      int passingGongTotal = (starAngle ~/ 30).toInt();
      return EnumTwelveGong.eclipticSeq[passingGongTotal];
    }
  }

  static EnumTwelveGong sunEnterGongByMonthTokenOnly(MonthToken monthToken) {
    // 每月太阳所在宫位
    // 子月在寅，丑月在丑
    // 寅月在子，卯月在亥
    // 辰月在戌，巳月在酉
    // 午月在申，未月在未
    // 申月在午，酉月在巳
    // 戌月在辰，亥月在卯
    return EnumTwelveGong.getEnumTwelveGongByZhi(
        sunMonthlyAtGongOrderMapper[monthToken]!);
  }

  /// @params lunarIsBody: true时 太阴落宫为身宫，false时，太阴落宫逆数至酉为申宫
  static BodyLifeModel settleDownBodyAndLife(
    JiaZi monthGanZhi,
    JiaZi timeGanZhi,
    ElevenStarsInfo sunInfo,
    ElevenStarsInfo lunarInfo,
    Map<Enum28Constellations, ConstellationGongDegreeInfo> mapper, {
    DiZhi settleLifeBy = DiZhi.MAO,
    bool lunarIsBody = false,
  }) {
    //安身立命
    // 1. 立命
    // 1.1. 确定命宫
    EnumTwelveGong lifeGong = settleDownLifeGong(
      monthGanZhi,
      timeGanZhi,
      sunInfo.angle,
      true,
      settleLifeBy,
    );
    // 1.2. 确定命度
    Tuple2<Enum28Constellations, double> lifeInn =
        settleDownLifeInn(sunInfo, lifeGong, mapper);
    // 2. 安身
    // 2.1 确立身宫
    EnumTwelveGong bodyGong =
        settleDownBodyGong(lunarInfo, lunarIsBody ? null : timeGanZhi);
    // 2.2. 确立身度主
    Tuple2<Enum28Constellations, double> bodyInn = settleDownBodyInn(lunarInfo);
    return BodyLifeModel(
      lifeGongInfo:
          GongDegree(gong: lifeGong, degree: sunInfo.enteredGongDegree),
      lifeConstellationInfo: ConstellationDegree(
        constellation: lifeInn.item1,
        degree: lifeInn.item2,
      ),
      bodyGongInfo:
          GongDegree(gong: bodyGong, degree: lunarInfo.enteredGongDegree),
      bodyConstellationInfo: ConstellationDegree(
        constellation: bodyInn.item1,
        degree: bodyInn.item2,
      ),
      // lunarLocationIsBody: lunarIsBody
    );
  }

  static Tuple2<Enum28Constellations, double> settleDownLifeInn(
      ElevenStarsInfo sunInf,
      EnumTwelveGong lifeGong,
      Map<Enum28Constellations, ConstellationGongDegreeInfo> mapper) {
    // 如太阳在卯15度，立命在申，则找申宫15度所在星宿度数，申宫15度约在参水4度，参水4度即为命度。
    // 又例如太阳在戌10度，立命在亥，找亥宫10度所在星宿度数，约在室火7度，室火7度即为命度。

    double atGongDegree = sunInf.enteredGongDegree;
    Iterable<MapEntry<Enum28Constellations, ConstellationGongDegreeInfo>> iter =
        mapper.entries.where((entry) {
      return entry.value.startAtGongDegree.gong == lifeGong;
    });
    MapEntry<Enum28Constellations, ConstellationGongDegreeInfo> result =
        iter.firstWhere((e) {
      return e.value.startAtGongDegree.degree <= atGongDegree &&
          e.value.endAtGongDegree.degree > atGongDegree;
    });
    return Tuple2(
        result.key, atGongDegree - result.value.startAtGongDegree.degree);
  }

  /// 安身 身度主
  /// 人出生在世间，有命亦有身体，命主是因为太阳而定，身主是因为月亮而产生，所以， 就以月亮所在的星宿度的度主为身度主。
  /// 我们身体的生长要得到身度主星的元气，所 以，刚刚出生时月亮所在星宿度最关紧要。
  static Tuple2<Enum28Constellations, double> settleDownBodyInn(
      ElevenStarsInfo lunarInfo) {
    return Tuple2(lunarInfo.enteredStarInn, lunarInfo.enteredStarInnDegree);
  }

  /// item1 inter gong
  /// item2 enter degree
  static Tuple2<EnumTwelveGong, double> starEnterGong(double starAngle) {
    /// 如果给定太阳角度，则根据太阳角度计算太阳所在宫位
    /// 戌0°为黄道0，星盘上所有方向为逆时针
    // List<DiZhi> diZhiAtEclipticGong = [DiZhi.XU,DiZhi.YOU,DiZhi.SHEN,DiZhi.WEI,DiZhi.WU,DiZhi.SI,DiZhi.CHEN,DiZhi.MAO,DiZhi.YIN,DiZhi.CHOU,DiZhi.ZI,DiZhi.HAI];
    if (starAngle % 30 == 0) {
      int passingGongTotal = (starAngle / 30).toInt();
      return Tuple2(EnumTwelveGong.eclipticSeq[passingGongTotal], 0);
    } else {
      int passingGongTotal = (starAngle ~/ 30).toInt();
      double enterGongDegree = starAngle - passingGongTotal * 30;
      return Tuple2(
          EnumTwelveGong.eclipticSeq[passingGongTotal], enterGongDegree);
    }
  }

  static Tuple2<Enum28Constellations, double> starEnterStarInn(double starAngle,
      Map<Enum28Constellations, ConstellationGongDegreeInfo> mapper) {
    if (mapper.entries.first.value.degreeStartAt > starAngle) {
      return Tuple2(mapper.entries.last.key,
          360 - mapper.entries.last.value.degreeStartAt + starAngle);
    } else if (mapper.entries.last.value.degreeStartAt < starAngle) {
      return Tuple2(mapper.entries.last.key,
          starAngle - mapper.entries.last.value.degreeStartAt);
    }
    MapEntry<Enum28Constellations, ConstellationGongDegreeInfo> result =
        mapper.entries.firstWhere(
            (e) => e.value.degreeStartAt + e.value.totalDegree >= starAngle);

    return Tuple2(result.key, starAngle - result.value.degreeStartAt);
  }

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
}
