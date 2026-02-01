import 'dart:math';

import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:common/utils.dart';
import 'package:tuple/tuple.dart';

import '../../enums/enum_settle_life_body.dart';
import '../../enums/enum_twelve_gong.dart';
import '../../qi_zheng_si_yu_constant_resources.dart';
import '../../utils/star_degree_inn_gong_helper.dart';
import '../entities/models/body_life_model.dart';
import '../entities/models/naming_degree_pair.dart';
import '../entities/models/star_inn_gong_degree.dart';


@Deprecated("使用 SettleLifeBodyService 代替")
class LifeBodyModelBuilder {
  Tuple4<JiaZi, JiaZi, JiaZi, JiaZi> eightChar;

  JiaZi get yearJiaZi => eightChar.item1;
  JiaZi get monthJiaZi => eightChar.item2;
  JiaZi get dayJiaZi => eightChar.item3;
  JiaZi get timeJiaZi => eightChar.item4;

  double sunAngle;
  double moonAngle;
  DiZhi mannualLiftGongDiZhi;

  EnumSettleLifeType settleLifeType;
  EnumSettleBodyType settleBodyType;

  PanelCelesticalInfo panelCelesticalInfo;

  LifeBodyModelBuilder(
      {required this.eightChar,
      required this.panelCelesticalInfo,
      required this.sunAngle,
      required this.moonAngle,
      required this.settleLifeType,
      required this.settleBodyType,
      this.mannualLiftGongDiZhi = DiZhi.MAO});

  /// 安身立命总方法
  build() {
    Tuple2<EnumTwelveGong, double> sunResult =
        StarDegreeInnGongHelper.calculateStarAngleEnterDiZhiGong(sunAngle);
    EnumTwelveGong sunEnterGong = sunResult.item1;
    double sunEnterGongDegree = sunResult.item2;
    // 命宫
    EnumTwelveGong lifeGongIs = settleLifeGong(sunEnterGong);
    // 命度
    Tuple2<Enum28Constellations, double> lifeTuple =
        settleLifeStarInn(panelCelesticalInfo, lifeGongIs, sunEnterGongDegree);

    // 立命
    // 获取太阳的入宫，以及入宫角度
    Tuple2<EnumTwelveGong, double> moonResult =
        StarDegreeInnGongHelper.calculateStarAngleEnterDiZhiGong(moonAngle);
    EnumTwelveGong moonEnterGong = moonResult.item1;
    double moonEnterGongDegree = moonResult.item2;

    EnumTwelveGong bodyGongIs = settleBodyGong(moonEnterGong);
    // TODO: 提取出到单独的方法进行
    Tuple2<Enum28Constellations, double> bodyStarInnResult =
        StarDegreeInnGongHelper.calculateStarAngleEnterStarInn(
            moonAngle,
            StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
            StarPanelType.getStarXiuMapper(panelCelesticalInfo));

    return BodyLifeModel(
      lifeGongInfo: GongDegree(gong: lifeGongIs, degree: sunEnterGongDegree),
      lifeConstellationInfo: ConstellationDegree(
        constellation: lifeTuple.item1,
        degree: lifeTuple.item2,
      ),
      bodyGongInfo:
          GongDegree(gong: moonEnterGong, degree: moonEnterGongDegree),
      bodyConstellationInfo: ConstellationDegree(
        constellation: bodyStarInnResult.item1,
        degree: bodyStarInnResult.item2,
      ),
    );
  }

  static Tuple2<Enum28Constellations, double> settleLifeStarInn(
      PanelCelesticalInfo panelCelesticalInfo,
      EnumTwelveGong lifeGong,
      double enterGongAngle) {
    // 根据盘制式 使用对应的星宿度数
    Map<Enum28Constellations, ConstellationGongDegreeInfo> innMapper =
        StarPanelType.getStarXiuMapper(panelCelesticalInfo);
    List<ConstellationGongDegreeInfo> xiuTypeList = innMapper.values
        .where((xiu) =>
            xiu.startAtGongDegree.gong == lifeGong ||
            xiu.endAtGongDegree.gong == lifeGong)
        .toList();
    xiuTypeList.sort((x1, x2) => x1.degreeStartAt.compareTo(x2.degreeStartAt));

    ConstellationGongDegreeInfo? xiuType;
    double? enterAngle = 0.0;
    for (var e in xiuTypeList) {
      if (e.startAtGongDegree.gong == lifeGong &&
          e.endAtGongDegree.gong == lifeGong) {
        // 星宿在当前宫位内
        if (e.startAtGongDegree.degree <= enterGongAngle &&
            e.endAtGongDegree.degree >= enterGongAngle) {
          xiuType = e;
          enterAngle = enterGongAngle - e.startAtGongDegree.degree;
        }
      } else {
        if (e.startAtGongDegree.gong != lifeGong &&
            e.endAtGongDegree.gong == lifeGong) {
          int index = EnumTwelveGong.eclipticSeq.indexOf(lifeGong);
          // 得到当前宫位的0°在圆周的度数
          double lifeGongStartAtAngle = (index) * 30;

          // 当前宫位的0度是 这个星宿的第n度
          double gongZeroAtXiuAngle =
              lifeGongStartAtAngle * 100 - e.degreeStartAt * 100;
          xiuType = e;
          enterAngle = (gongZeroAtXiuAngle + enterGongAngle * 100) / 100;
        } else if (e.startAtGongDegree.gong == lifeGong &&
            e.endAtGongDegree.gong != lifeGong) {
          if (e.startAtGongDegree.degree < enterGongAngle) {
            xiuType = e;
            enterAngle =
                (enterGongAngle * 100 - e.startAtGongDegree.degree * 100) / 100;
          }
        }
      }
    }
    if (xiuType == null) {
      throw Exception("定命度时，未找到合适的命度");
    }
    return Tuple2(xiuType!.starXiu, enterAngle!);
  }

  EnumTwelveGong settleLifeGong(EnumTwelveGong sunEnterGong) {
    EnumTwelveGong lifeGongSettledAt;
    // 根据立命的策略类型
    switch (settleLifeType) {
      case EnumSettleLifeType.Mao:
        lifeGongSettledAt = calculateLifeGong(sunEnterGong, DiZhi.MAO);
        break;
      case EnumSettleLifeType.YinMaoChen:
        lifeGongSettledAt =
            calculateLifeGong(sunEnterGong, mannualLiftGongDiZhi);
        break;
      default:
        lifeGongSettledAt =
            EnumTwelveGong.getEnumTwelveGongByZhi(mannualLiftGongDiZhi);
        break;
    }
    return lifeGongSettledAt;
  }

  EnumTwelveGong settleBodyGong(EnumTwelveGong monEnterGong) {
    EnumTwelveGong bodyGongSettledAt;
    // 根据立命的策略类型
    switch (settleBodyGong) {
      case EnumSettleBodyType.you:
        bodyGongSettledAt = calculateBodyGong(monEnterGong, DiZhi.YOU);
        break;
      default:
        bodyGongSettledAt = monEnterGong;
        break;
    }
    return bodyGongSettledAt;
  }

  EnumTwelveGong calculateLifeGong(
      EnumTwelveGong sunEnterGong, DiZhi toLifeZhi) {
    return calculateLife(timeJiaZi.diZhi, sunEnterGong, toLifeZhi);
  }

  EnumTwelveGong calculateBodyGong(
      EnumTwelveGong sunEnterGong, DiZhi toLifeZhi) {
    return calculateBody(timeJiaZi.diZhi, sunEnterGong, toLifeZhi);
  }

  // 安身宫计算逻辑（逆数至酉）
  static EnumTwelveGong calculateBody(
      DiZhi shengShiDiZhi, EnumTwelveGong moonEnterGong, DiZhi toLifeZhi) {
    // 获取地支列表（逆时针顺序）
    final reversedDiZhi = DiZhi.listAll.reversed.toList();

    // 1. 确定太阴起始宫位
    final moonStartIndex = reversedDiZhi.indexOf(moonEnterGong.zhi);

    // 2. 生时地支的索引（逆时针序）
    final hourIndex = reversedDiZhi.indexOf(shengShiDiZhi);

    // 3. 计算总步数（从太阴宫逆数到酉）
    final totalSteps = (moonStartIndex + hourIndex) % 12;

    // 4. 获取酉的索引位置
    final youIndex = reversedDiZhi.indexOf(toLifeZhi);

    // 5. 计算最终身宫位置
    final bodyIndex = (youIndex - totalSteps + 12) % 12;

    return EnumTwelveGong.getEnumTwelveGongByZhi(reversedDiZhi[bodyIndex]);
  }

  static EnumTwelveGong calculateLife(
      DiZhi shengShiDiZhi, EnumTwelveGong sunEnterGong, DiZhi toLifeZhi) {
    // 生时地支
    // DiZhi shengShiDiZhi = timeJiaZi.diZhi;

    int shengShiIndex = DiZhi.listAll.indexWhere((t) => t == shengShiDiZhi);

    List<DiZhi> tmpList = CollectUtils.changeSeq(
        shengShiDiZhi, DiZhi.listAll.map((e) => e).toList());
    // 将 _tmpList 截断 只保留 toLifeZhi 以及其之前的部分
    int tmpIndex = tmpList.indexWhere((e) => e == toLifeZhi);
    List<DiZhi> diZhiList = tmpList.sublist(0, tmpIndex + 1);

    List<DiZhi> sunEnterGongAsFirstList = CollectUtils.changeSeq(
        sunEnterGong.zhi, DiZhi.listAll.map((e) => e).toList());

    // print(diZhiList.map((e) => e.name));
    // 从_sunEnterGongAsFirstList列表中截断 diZhiList.lenght 个 地支

    List<DiZhi> resultList =
        sunEnterGongAsFirstList.sublist(0, diZhiList.length);
    // print(resultList.map((e) => e.name));
    return EnumTwelveGong.getEnumTwelveGongByZhi(resultList.last);
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
