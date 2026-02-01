import 'dart:convert';
import 'dart:io';

import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:common/utils.dart';
import 'package:flutter/services.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/utils/star_walking_info_utils.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../enums/enum_panel_system_type.dart';
import '../../enums/enum_qi_zheng.dart';
import '../../enums/enum_settle_life_body.dart';
import '../../utils/star_enter_info_calculator.dart';
import '../entities/models/base_panel_model.dart';
import '../entities/models/body_life_model.dart';
import '../entities/models/hua_yao.dart';
import '../entities/models/naming_degree_pair.dart';
import '../entities/models/observer_position.dart';
import '../entities/models/panel_config.dart';
import '../entities/models/passage_year_panel_model.dart';
import '../entities/models/star_angle_speed.dart';
import '../entities/models/star_enter_info.dart';
import '../entities/models/stars_angle.dart';
import '../entities/models/zhou_tian_model.dart';
import '../managers/hua_yao_manager.dart';
import '../managers/shen_sha_manager.dart';
import '../managers/zhou_tian_model_manager.dart';
import 'an_shen_li_ming_service.dart';
import '../engines/calculation_engine_factory.dart';

class GenerateBasePanelService {
  final BasePanelConfig panelConfig;
  final ObserverPosition observerPosition;

  final ShenShaManager shenShaManager;
  final HuaYaoManager huaYaoManager;

  GenerateBasePanelService(
      {required this.panelConfig,
      required this.observerPosition,
      required this.shenShaManager,
      required this.huaYaoManager});

  // --- Zi Qi (Purple Gas) Calculation Constants & Methods ---

  /// 基准时间: 2013-4-9 02:58 (Shanghai time) -> 2013-4-8 18:58 (UTC)
  static final DateTime referenceDateTimeUtc = DateTime.utc(2013, 4, 8, 18, 58);

  /// 基准位置: 284度
  static const double referencePositionDegrees = 284.0;

  /// 日速率: 0.0352 度/天
  static const double dailyRateDegrees = 0.0352;

  /// 计算紫气位置 (授时历/笨办法)
  static double shouShiLiCalculateZiQiPosition(
    DateTime dateTime, {
    double circleDegrees = 360.0,
  }) {
    final Duration diff = dateTime.difference(referenceDateTimeUtc);
    final double daysDiff = diff.inMinutes / (24 * 60.0);
    final double angleDiff = daysDiff * dailyRateDegrees;

    // Calculate raw position
    double rawPosition = referencePositionDegrees + angleDiff;

    // Normalize to [0, circleDegrees)
    double result = rawPosition % circleDegrees;
    if (result < 0) {
      result += circleDegrees;
    }
    return result;
  }

  Future<BasePanelModel> calculate({
    required ZhouTianModel zhouTianModel,
    required Map<EnumStars, StarAngleSpeed> starAngleMapper,
  }) async {
    // The engine has already provided the zhouTianModel and starAngleMapper.
    // This service is now responsible for the post-processing.

    // 2. 计算星体进入宫位信息
    final Map<EnumStars, EnteredInfo> enteredGongMapper =
        _getStarEnteredInfoMapper(starAngleMapper, zhouTianModel);

    // 3. 计算五星运行状态
    final Map<EnumStars, StarAngleSpeed> fiveStarMapper =
        Map.fromEntries(starAngleMapper.entries.where((t) => t.key.isFiveStar));
    final Map<EnumStars, BaseFiveStarWalkingInfo> fiveStarWalkingTypeMapper =
        calculateFiveStarskWalingStatus(fiveStarMapper);

    // 4. 计算四主（命宫主、身宫主、命度主、身度主）
    final BodyLifeModel bodyLifeModel = calculateLifeBodyAndMaster(
        zhouTianModel,
        enteredGongMapper[EnumStars.Sun]!,
        enteredGongMapper[EnumStars.Moon]!);
    // 5. 根据命宫位置，排序命理十二宫
    final Map<EnumTwelveGong, EnumDestinyTwelveGong> twelveGongMapper =
        orderDestinyTwelveGong(bodyLifeModel);
    // 6. 计算神煞位置
    final Map<EnumTwelveGong, List<ShenSha>> shenShaMapper =
        await shenShaManager.calculate(
            observerPosition.yearGanZhi,
            observerPosition.monthGanZhi,
            observerPosition.timeGanZhi,
            bodyLifeModel.lifeGong,
            enteredGongMapper[EnumStars.Sun]!.enterGongInfo.gong,
            enteredGongMapper[EnumStars.Moon]!.enterGongInfo.gong,
            observerPosition.isDayBirth);

    final Map<EnumTwelveGong, List<ShenSha>> shenShaItemMapper =
        shenShaMapper.map((key, value) {
      return MapEntry(key, value.map((e) => e).toList());
    });

    // 将神煞从ShenSha 处理成 String
    // Map<EnumTwelveGong, List<String>> shenShaStrMapper = {};
    // for (var i = 0; i < shenShaMapper.entries.length; i++) {
    //   final entry = shenShaMapper.entries.elementAt(i);
    //   final gong = entry.key;
    //   final shenShaList = entry.value;
    //   final result = shenShaList.map((e) => e.name).toList();
    //   shenShaStrMapper[gong] = result;
    // }

    // 7. 计算化曜位置
    final Map<HuaYao, EnumStars> huaYaoMapper = await huaYaoManager.calculate(
      mingGong: bodyLifeModel.lifeGong,
      yearJiaZi: observerPosition.yearGanZhi,
      monthJiaZi: observerPosition.monthGanZhi,
    );
    final Map<EnumStars, List<HuaYaoItem>> huaYaoItemMapper = {};
    for (var entry in huaYaoMapper.entries) {
      if (!huaYaoItemMapper.containsKey(entry.value)) {
        huaYaoItemMapper[entry.value] = [];
      }
      huaYaoItemMapper[entry.value]!.add(HuaYaoItem.fromHuaYao(entry.key));
    }
    // 8. 计算十二长生
    final Map<EnumTwelveGong, TwelveZhangSheng> twelveZhangShengGongMapper =
        calculateTwelveLong(observerPosition.yearGanZhi);

    // 8.1. 根据十二长生enum 构建出对应 zhangsheng12ShenSha 并加入在神煞中,
    for (var i = 0; i < twelveZhangShengGongMapper.entries.length; i++) {
      final gong = twelveZhangShengGongMapper.entries.elementAt(i).key;
      shenShaMapper[gong]!.insert(
          0,
          ZhangSheng12ShenSha(
              twelveZhangShengGongMapper.entries.elementAt(i).value.name,
              JiXiongEnum.PING,
              null,
              null));
    }

    return BasePanelModel(
      starAngleMapper: starAngleMapper,
      enteredGongMapper: enteredGongMapper,
      fiveStarWalkingTypeMapper: fiveStarWalkingTypeMapper,
      bodyLifeModel: bodyLifeModel,
      twelveGongMapper: twelveGongMapper,
      shenShaItemMapper: shenShaItemMapper,
      huaYaoItemMapper: huaYaoItemMapper,
      twelveZhangShengGongMapper: twelveZhangShengGongMapper,
    );
  }

  Future<PassageYearPanelModel> calculateDaXia(
    BasePanelModel basePanel,
    ObserverPosition daXianObserver, {
    required ZhouTianModel zhouTianModel,
    required Map<EnumStars, StarAngleSpeed> starAngleMapper,
  }) async {
    // 大限与 计算星命基础命盘一样，但是不计算 四主 与 命理十二宫的位置。
    // 在计算神煞时则是借用原局的命宫等位置进行计算

    // 2. 计算星体进入宫位信息
    final Map<EnumStars, EnteredInfo> enteredGongMapper =
        _getStarEnteredInfoMapper(starAngleMapper, zhouTianModel);

    // 3. 计算五星运行状态
    final Map<EnumStars, StarAngleSpeed> fiveStarMapper =
        Map.fromEntries(starAngleMapper.entries.where((t) => t.key.isFiveStar));
    final Map<EnumStars, BaseFiveStarWalkingInfo> fiveStarWalkingTypeMapper =
        calculateFiveStarskWalingStatus(fiveStarMapper);

    // 6. 计算神煞位置
    final Map<EnumTwelveGong, List<ShenSha>> shenShaMapper =
        await shenShaManager.calculate(
            daXianObserver.yearGanZhi,
            daXianObserver.monthGanZhi,
            daXianObserver.timeGanZhi,
            basePanel.bodyLifeModel.lifeGong,
            enteredGongMapper[EnumStars.Sun]!.enterGongInfo.gong,
            enteredGongMapper[EnumStars.Moon]!.enterGongInfo.gong,
            daXianObserver.isDayBirth);
    final Map<EnumTwelveGong, List<ShenSha>> shenShaItemMapper =
        shenShaMapper.map((key, value) {
      return MapEntry(key, value.map((e) => e).toList());
    });
    // 7. 计算化曜位置
    final Map<HuaYao, EnumStars> huaYaoMapper = await huaYaoManager.calculate(
      mingGong: basePanel.bodyLifeModel.lifeGong,
      yearJiaZi: daXianObserver.yearGanZhi,
      monthJiaZi: daXianObserver.monthGanZhi,
    );
    // final List<HuaYaoStarPair> huaYaoStarPairList = huaYaoMapper.entries
    //     .map((e) => HuaYaoStarPair(e.key, e.value))
    //     .toList();

    final Map<EnumStars, List<HuaYaoItem>> huaYaoItemMapper = {};
    for (var entry in huaYaoMapper.entries) {
      if (!huaYaoItemMapper.containsKey(entry.value)) {
        huaYaoItemMapper[entry.value] = [];
      }
      // huaYaoStarPairList[entry.value]!.add(entry.key);

      huaYaoItemMapper[entry.value]!.add(HuaYaoItem.fromHuaYao(entry.key));
    }
    // 8. 计算十二长生
    final Map<EnumTwelveGong, TwelveZhangSheng> twelveZhangShengGongMapper =
        calculateTwelveLong(daXianObserver.yearGanZhi);
    // 8.1. 根据十二长生enum 构建出对应 zhangsheng12ShenSha 并加入在神煞中,
    for (var i = 0; i < twelveZhangShengGongMapper.entries.length; i++) {
      final entry = twelveZhangShengGongMapper.entries.elementAt(i);
      final gong = entry.key;
      // 插入到第一个
      shenShaMapper[gong]!.insert(0,
          ZhangSheng12ShenSha(entry.value.name, JiXiongEnum.PING, null, null));
    }
    return PassageYearPanelModel(
      starAngleMapper: starAngleMapper,
      enteredGongMapper: enteredGongMapper,
      fiveStarWalkingTypeMapper: fiveStarWalkingTypeMapper,
      shenShaItemMapper: shenShaItemMapper,
      huaYaoItemMapper: huaYaoItemMapper,
      twelveZhangShengGongMapper: twelveZhangShengGongMapper,
    );
  }

  Map<EnumTwelveGong, TwelveZhangSheng> calculateTwelveLong(JiaZi yearJiaZi) {
    // 年纳音五行 计算长生十二宫
    final yearNaYinFiveXing = yearJiaZi.naYin.fiveXing;
    final yearNaYinZhangSheng =
        TwelveZhangSheng.fiveXingZhangShengMapper[yearNaYinFiveXing]!;
    final result = <EnumTwelveGong, TwelveZhangSheng>{};
    for (var i = 0; i < yearNaYinZhangSheng.length; i++) {
      final zhangShengGong =
          EnumTwelveGong.getEnumTwelveGongByZhi(yearNaYinZhangSheng[i]);
      final zhangSheng = TwelveZhangSheng.values[i];
      result[zhangShengGong] = zhangSheng;
    }

    return result;
  }

  Map<EnumTwelveGong, EnumDestinyTwelveGong> orderDestinyTwelveGong(
      BodyLifeModel bodyLifeModel) {
    final lifeGong = bodyLifeModel.lifeGong;
    final revservedDiZhiList = DiZhi.values.reversed
        .map((dz) => EnumTwelveGong.getEnumTwelveGongByZhi(dz))
        .toList();
    final twelveGongStartWithLifGong =
        CollectUtils.changeSeq(lifeGong, revservedDiZhiList);
    final result = <EnumTwelveGong, EnumDestinyTwelveGong>{};
    final orderedDestinyGong =
        EnumDestinyTwelveGong.getOrderedDestinyTwelveGongList();
    for (var i = 0; i < twelveGongStartWithLifGong.length; i++) {
      final gong = twelveGongStartWithLifGong[i];
      final destinyGong = orderedDestinyGong[i];
      result[gong] = destinyGong;
    }

    return result;
  }

  /// 计算四主（命宫主、身宫主、命度主、身度主）
  BodyLifeModel calculateLifeBodyAndMaster(ZhouTianModel zhouTianModel,
      EnteredInfo sunEnteredInfo, EnteredInfo moonEnteredInfo) {
    JiaZi monthGanZhi = observerPosition.monthGanZhi;
    JiaZi timeGanZhi = observerPosition.timeGanZhi;

    final EnumTwelveGong lifeCountingToGong;
    switch (panelConfig.settleLifeType) {
      case EnumSettleLifeType.Mao:
        lifeCountingToGong = EnumTwelveGong.Mao;
        break;
      case EnumSettleLifeType.YinMaoChen:
        lifeCountingToGong = panelConfig.lifeCountingToGong;
      case EnumSettleLifeType.Mannual:
        throw UnimplementedError('不支持的立命方式:${panelConfig.settleLifeType}');
      case EnumSettleLifeType.Ascendant:
        throw UnimplementedError('不支持的立命方式:${panelConfig.settleLifeType}');
    }
    final EnumTwelveGong bodyCountingToGong;

    // 计算命宫
    final lifeGong = SettleLifeBodyService.settleLifeGong(
      sunEnteredInfo,
      lifeCountingToGong,
      observerPosition.monthGanZhi,
      observerPosition.timeGanZhi,
      panelConfig.islifeGongBySunRealTimeLocation,
    );

    // 计算身宫
    final bodyBody = SettleLifeBodyService.settleBodyGong(
      moonEnteredInfo,
      panelConfig.bodyCountingToGong,
      panelConfig.settleBodyType == EnumSettleBodyType.moon ? null : timeGanZhi,
    );
    // 根据太阳入宫的度数，以及命宫，确定命度
    // 太阳入宫度数，放在命宫中对应的度数就为命度
    // final lifeDegreeAtGong = sunEnteredInfo.atGongDegree;
    final gongPositionSeq = StarEnterInfoCalculator.generateGongSequence(
        zhouTianModel.zeroPointAtGong, zhouTianModel.gongDegreeSeq);
    final constellationPositionSeq =
        StarEnterInfoCalculator.generateConstellationSequence(
            zhouTianModel.zeroPointAtConstellation,
            zhouTianModel.starInnDegreeSeq);

    final lifeConstellationMaster = calculateLifeBodyConstellation(
        sunEnteredInfo.enterGongInfo,
        constellationPositionSeq,
        gongPositionSeq);
    final bodyConstellation = calculateLifeBodyConstellation(
        moonEnteredInfo.enterGongInfo,
        constellationPositionSeq,
        gongPositionSeq);
    return BodyLifeModel(
        lifeGongInfo:
            GongDegree(gong: lifeGong, degree: sunEnteredInfo.atGongDegree),
        lifeConstellationInfo: lifeConstellationMaster,
        bodyGongInfo:
            GongDegree(gong: bodyBody, degree: moonEnteredInfo.atGongDegree),
        bodyConstellationInfo: bodyConstellation);
  }

  ConstellationDegree calculateLifeBodyConstellation(
      GongDegree atGongDegree,
      List<ConstellationPosition> constellationPositionSeq,
      List<GongPosition> gongPositionSeq) {
    final lifeDegreeAtGongIndex =
        gongPositionSeq.indexWhere((t) => t.gong == atGongDegree.gong);
    double targetDegree = 0;
    if (gongPositionSeq.length == 12) {
      // 周天起始的位置为某个宫的0度，无需考虑是否“截断”
      targetDegree = gongPositionSeq[lifeDegreeAtGongIndex].startAtDegree +
          atGongDegree.degree;
    } else {
      // 周天起始的位置为某个宫位中的刻度，需要考虑“截断”
      if (lifeDegreeAtGongIndex == 0 || lifeDegreeAtGongIndex == 12) {
        // “截断”
        // lifeDegree = lifeDegreeAtGong;
        // 宫位截断段后，在seq头不得部分
        double gongSplitedLastPart = gongPositionSeq.first.endAtDegree -
            gongPositionSeq.first.startAtDegree;
        // 宫位截断后，在seq最后的部分
        double gongSplitedFirstPart = gongPositionSeq.last.degree;
        if (targetDegree <= gongSplitedFirstPart) {
          targetDegree = 330 + gongSplitedLastPart + atGongDegree.degree;
        } else {
          // 说明命度落点在宫位截断后的后半部分，也就是周天0度到宫位截断段
          // 需要将命度减去宫位截断段后的前段的长度
          targetDegree = atGongDegree.degree - gongSplitedFirstPart;
        }
      } else {
        targetDegree = gongPositionSeq[lifeDegreeAtGongIndex].startAtDegree +
            atGongDegree.degree;
      }
    }

    // 根据命度在周天的角度，确定命度所在的星宿
    final ConstellationDegree targetConstellation =
        StarEnterInfoCalculator.doFindConstellation(
            targetDegree, constellationPositionSeq);
    return targetConstellation;
  }

  Map<EnumStars, BaseFiveStarWalkingInfo> calculateFiveStarskWalingStatus(
      Map<EnumStars, StarAngleSpeed> starAngleMapper) {
    Map<EnumStars, BaseFiveStarWalkingInfo> result = {};
    for (var starAngle in starAngleMapper.entries) {
      final EnumStars star = starAngle.key;
      final double speed = starAngle.value.speed;

      final walkingTypeThreshold =
          StarWalkingTypeThreshold.moirasFiveStarsThresholdMapper[star]!;
      final walkingType = StarWalkingInfoUtils.getWalkingTypeByThreshold(
          speed, walkingTypeThreshold);
      result[star] = BaseFiveStarWalkingInfo(
        star: star,
        speed: speed,
        walkingType: walkingType,
        threshold: walkingTypeThreshold,
      );
    }
    return result;
  }

  Map<EnumStars, EnteredInfo> _getStarEnteredInfoMapper(
      Map<EnumStars, StarAngleSpeed> starAngleMapper,
      ZhouTianModel zhouTianModel) {
    final starEnterInfoCalculator =
        StarEnterInfoCalculator(zhouTianModel: zhouTianModel);
    final starDegreeSeq = starAngleMapper.entries
        .map((e) => StarDegree(star: e.key, degree: e.value.angle))
        .toList();
    final enteredInfoList = starEnterInfoCalculator.calculate(starDegreeSeq);
    return Map.fromEntries(
        enteredInfoList.map((e) => MapEntry(e.originalStar.star, e)));
  }
}
