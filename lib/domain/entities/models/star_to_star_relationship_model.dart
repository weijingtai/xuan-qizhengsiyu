import 'package:common/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

import 'eleven_stars_info.dart';

class StarToStarRelationshipModel {
  /// 本类用于存储星体与星体之间的位置关系
  /// 将包含，同宫、同宿、同经、同络、对宫、三方、四正
  ///
  ///
  ///
  late double sameLuoDegreeRange;
  late Set<ElevenStarsInfo> starsSet;
  // 同宫
  late Map<EnumTwelveGong, Set<ElevenStarsInfo>> sameGongMap;

  // 同宿
  late Map<Enum28Constellations, Set<ElevenStarsInfo>> sameStarInnMap;

  // 同经
  // map.key 同经时星宿的七曜属性
  // map.mapEntry.key 星体进入的星宿
  // map.mapEntry.value 进入这个星宿的所有星体
  late Map<EnumStars, Map<Enum28Constellations, Set<ElevenStarsInfo>>>
      sameJingMap;

  // 同络，不同中，相同入宫度数的星体。
  late Set<Set<ElevenStarsInfo>> sameLuoSet;

  // 对宫
  // 外层map.key为所处对宫，如：子午宫，卯酉宫等
  // 内层map.key 所在宫位 map.value 在这个宫位中所有的集合
  late Map<DiZhiChong, Map<EnumTwelveGong, Set<ElevenStarsInfo>>> chongGongSet;

  // 三方
  // 外层map.key为所属三合，如：申子辰宫，亥卯未等
  // 内层map.key 所在宫位 map.value 在这个宫位中所有的集合
  late Map<DiZhiSanHe, Map<EnumTwelveGong, Set<ElevenStarsInfo>>>
      threeHeGongMap;

  // 四正
  late Map<DiZhiFourZheng, Map<EnumTwelveGong, Set<ElevenStarsInfo>>>
      fourZhengMap;
  StarToStarRelationshipModel._({
    required this.starsSet,
    required this.sameGongMap,
    required this.sameJingMap,
    required this.sameStarInnMap,
    required this.sameLuoSet,
    required this.chongGongSet,
    required this.threeHeGongMap,
    required this.fourZhengMap,
    required this.sameLuoDegreeRange,
  });
  factory StarToStarRelationshipModel.create(Set<ElevenStarsInfo> starsSet,
      {double sameLuoDegreeRange = 2}) {
    // 验证星体数量
    Set<EnumStars> verifyStarEnum = starsSet.map((s) => s.star).toSet();
    // if (verifyStarEnum.length != 11) {
    // throw ArgumentError('星体集合必须包含11颗星体，当前包含 ${starsSet.length} 颗');
    // }
    // // 验证是否为全部星体
    // if (setEquals(verifyStarEnum, EnumStars.values.toSet())) {
    //   throw ArgumentError('星体集合必须包含所有11颗星体');
    // }
    // 进行排序，确保顺序为 日、月、五星、四余
    List<ElevenStarsInfo> orderedStars = starsSet.toList()
      ..sort((a, b) => b.priority.compareTo(b.priority));

    // 初始化所有关系映射
    Map<EnumTwelveGong, Set<ElevenStarsInfo>> sameGongMap = {};
    Map<Enum28Constellations, Set<ElevenStarsInfo>> sameStarInnMap = {};
    Map<EnumStars, Map<Enum28Constellations, Set<ElevenStarsInfo>>>
        sameJingMap = {};
    Set<Set<ElevenStarsInfo>> sameLuoSet = {};
    Map<DiZhiChong, Map<EnumTwelveGong, Set<ElevenStarsInfo>>> chongGongSet =
        {};
    Map<DiZhiSanHe, Map<EnumTwelveGong, Set<ElevenStarsInfo>>> threeHeGongMap =
        {};
    Map<DiZhiFourZheng, Map<EnumTwelveGong, Set<ElevenStarsInfo>>>
        fourZhengMap = {};

    // 预处理：为每个星体创建关系映射
    Map<EnumTwelveGong, Set<ElevenStarsInfo>> gongToStarsMap = {};
    Map<Enum28Constellations, Set<ElevenStarsInfo>> innToStarsMap = {};
    Map<EnumStars, Set<ElevenStarsInfo>> jingToStarsMap = {};
    // 初始化三方和四正的映射结构
    for (var sanHe in DiZhiSanHe.values) {
      threeHeGongMap[sanHe] = {};
    }

    for (var fourZheng in DiZhiFourZheng.values) {
      fourZhengMap[fourZheng] = {};
    }

    for (var sevenZhengStar in EnumStars.values) {
      sameJingMap[sevenZhengStar] = {};
    }

    // 第一次遍历：收集所有星体的宫位和星宿信息
    for (var star in orderedStars) {
      // 收集同宫信息
      if (!gongToStarsMap.containsKey(star.enteredGong)) {
        gongToStarsMap[star.enteredGong] = {};
      }
      gongToStarsMap[star.enteredGong]!.add(star);

      // 收集同宿信息
      if (!innToStarsMap.containsKey(star.enteredStarInn)) {
        innToStarsMap[star.enteredStarInn] = {};
      }
      innToStarsMap[star.enteredStarInn]!.add(star);

      // 收集同经信息
      EnumStars innMasterStar = star.enteredStarInn.sevenZheng;
      if (!jingToStarsMap.containsKey(innMasterStar)) {
        jingToStarsMap[innMasterStar] = {};
      }
      jingToStarsMap[innMasterStar]!.add(star);
    }

    // 第二次遍历：构建所有关系
    for (var star in orderedStars) {
      // 同宫关系
      if (gongToStarsMap[star.enteredGong]!.length > 1 &&
          !sameGongMap.containsKey(star.enteredGong)) {
        sameGongMap[star.enteredGong] =
            Set.from(gongToStarsMap[star.enteredGong]!);
      }

      // 同宿关系
      if (innToStarsMap[star.enteredStarInn]!.length > 1 &&
          !sameStarInnMap.containsKey(star.enteredStarInn)) {
        sameStarInnMap[star.enteredStarInn] =
            Set.from(innToStarsMap[star.enteredStarInn]!);
      }

      // 同经关系
      EnumStars innMasterStar = star.enteredStarInn.sevenZheng;
      if (!sameJingMap[innMasterStar]!.containsKey(star.enteredStarInn)) {
        sameJingMap[innMasterStar]![star.enteredStarInn] = {};
      }
      sameJingMap[innMasterStar]![star.enteredStarInn]!.add(star);

      // 同络关系
      if (!sameLuoSet.any((set) => set.contains(star))) {
        double minDegree = star.enteredGongDegree - sameLuoDegreeRange;
        double maxDegree = star.enteredGongDegree + sameLuoDegreeRange;
        minDegree = minDegree < 0 ? 0 : minDegree;
        maxDegree = maxDegree > 30 ? 30 : maxDegree;

        Set<ElevenStarsInfo> luoStars = orderedStars
            .where((s) =>
                s.star != star.star &&
                s.enteredGongDegree >= minDegree &&
                s.enteredGongDegree <= maxDegree)
            .toSet();

        if (luoStars.isNotEmpty) {
          Set<ElevenStarsInfo> luoSet = {star}..addAll(luoStars);
          sameLuoSet.add(luoSet);
        }
      }

      // 对宫关系
      DiZhiChong chong = DiZhiChong.getFromSingleDiZhi(star.enteredGong.zhi)!;
      if (!chongGongSet.containsKey(chong)) {
        _processRelationship(
            orderedStars,
            star,
            (s) => DiZhiChong.getFromSingleDiZhi(s.enteredGong.zhi) == chong,
            chong,
            chongGongSet);
      }

      // 三方关系
      DiZhiSanHe he = DiZhiSanHe.getBySingleDiZhi(star.enteredGong.zhi)!;

      if (!threeHeGongMap[he]!.containsKey(star.enteredGong)) {
        threeHeGongMap[he]![star.enteredGong] = {};
      }
      threeHeGongMap[he]![star.enteredGong]!.add(star);

      // 四正关系
      DiZhiFourZheng fourZheng =
          DiZhiFourZheng.getBySingleDiZhi(star.enteredGong.zhi);

      if (!fourZhengMap[fourZheng]!.containsKey(star.enteredGong)) {
        fourZhengMap[fourZheng]![star.enteredGong] = {};
      }
      fourZhengMap[fourZheng]![star.enteredGong]!.add(star);
    }
    // 去除 _threeHeGongMap 和 _fourZhengMap 中值为空的项
    // 以及只有一个宫的项（此种情况说明为多星同宫，而不是三方宫有多星）

    sameJingMap
        .removeWhere((key, value) => value.isEmpty || value.keys.length == 1);
    threeHeGongMap
        .removeWhere((key, value) => value.isEmpty || value.keys.length == 1);
    fourZhengMap
        .removeWhere((key, value) => value.isEmpty || value.keys.length == 1);

    // _sameJingMap.forEach((key, value) {
    //   print("");
    //   print('${key.singleName}');
    //   value.forEach((k, v) =>
    //       print("${k.fullname} - ${v.map((e) => e.star.singleName).toSet()}"));
    // });
    return StarToStarRelationshipModel._(
      starsSet: starsSet,
      sameGongMap: sameGongMap,
      sameJingMap: sameJingMap,
      sameStarInnMap: sameStarInnMap,
      sameLuoSet: sameLuoSet,
      chongGongSet: chongGongSet,
      threeHeGongMap: threeHeGongMap,
      fourZhengMap: fourZhengMap,
      sameLuoDegreeRange: sameLuoDegreeRange,
    );
  }

  // 辅助方法：处理对宫、三方、四正等关系
  static void _processRelationship<T>(
      List<ElevenStarsInfo> orderedStars,
      ElevenStarsInfo star,
      bool Function(ElevenStarsInfo) condition,
      T key,
      Map<T, Map<EnumTwelveGong, Set<ElevenStarsInfo>>> resultMap) {
    Set<ElevenStarsInfo> relatedStars =
        orderedStars.where((s) => s.star != star.star && condition(s)).toSet();

    // print(relatedStars);
    if (relatedStars.isNotEmpty) {
      Set<ElevenStarsInfo> allStars = {star}..addAll(relatedStars);
      Map<EnumTwelveGong, Set<ElevenStarsInfo>> gongMap = {};

      for (var s in allStars) {
        if (!gongMap.containsKey(s.enteredGong)) {
          gongMap[s.enteredGong] = {};
        }
        gongMap[s.enteredGong]!.add(s);
      }

      resultMap[key] = gongMap;
    }
  }

  @deprecated
  factory StarToStarRelationshipModel.createDeprecated(
      Set<ElevenStarsInfo> starsSet,
      {double sameLuoDegreeRange = 2}) {
    // 验证星体数量
    Set<EnumStars> verifyStarEnum = starsSet.map((s) => s.star).toSet();
    if (verifyStarEnum.length != 11) {
      throw ArgumentError('星体集合必须包含11颗星体，当前包含 ${starsSet.length} 颗');
    }
    // 验证是否为全部星体
    if (setEquals(verifyStarEnum, EnumStars.values.toSet())) {
      throw ArgumentError('星体集合必须包含所有11颗星体');
    }
    // 进行排序，确保顺序为 日、月、五星、四余
    List<ElevenStarsInfo> orderedStars = starsSet.toList()
      ..sort((a, b) => b.priority.compareTo(b.priority));

    Map<EnumTwelveGong, Set<ElevenStarsInfo>> sameGongMap = {};

    Map<Enum28Constellations, Set<ElevenStarsInfo>> sameStarInnMap = {};
    Map<EnumStars, Map<Enum28Constellations, Set<ElevenStarsInfo>>>
        sameJingMap = {};
    Map<DiZhiChong, Map<EnumTwelveGong, Set<ElevenStarsInfo>>> chongGongSet =
        {};
    Map<DiZhiSanHe, Map<EnumTwelveGong, Set<ElevenStarsInfo>>> threeHeGongMap =
        {};
    Set<Set<ElevenStarsInfo>> sameLuoSet = {};
    Map<DiZhiFourZheng, Map<EnumTwelveGong, Set<ElevenStarsInfo>>>
        fourZhengMap = {};
    for (var s in orderedStars) {
      // 同宫
      if (!sameGongMap.containsKey(s.enteredGong)) {
        Set<ElevenStarsInfo> sameGonSet = orderedStars
            .where((os) => os.star != s.star && os.enteredGong == s.enteredGong)
            .toSet();
        if (sameGonSet.isNotEmpty) {
          sameGongMap[s.enteredGong] = {s}..addAll(sameGonSet);
        }
      }
      // 同宿
      if (!sameStarInnMap.containsKey(s.enteredStarInn)) {
        Set<ElevenStarsInfo> enteredStarInn = orderedStars
            .where((os) =>
                os.star != s.star && os.enteredStarInn == s.enteredStarInn)
            .toSet();
        if (enteredStarInn.isNotEmpty) {
          sameStarInnMap[s.enteredStarInn] = {s}..addAll(enteredStarInn);
        }
      }
      // 同经
      EnumStars innMasterStar = s.enteredStarInn.sevenZheng;
      if (!sameJingMap.containsKey(innMasterStar)) {
        Set<ElevenStarsInfo> enteredStarInn = orderedStars
            .where((os) =>
                os.star != s.star &&
                os.enteredStarInn.sevenZheng == innMasterStar)
            .toSet();
        if (enteredStarInn.isNotEmpty) {
          Map<Enum28Constellations, Set<ElevenStarsInfo>> res = {};
          Set<ElevenStarsInfo> added = {s};
          added.addAll(enteredStarInn);
          for (var s in added) {
            if (res.containsKey(s.enteredStarInn)) {
              res[s.enteredStarInn]!.add(s);
            } else {
              res[s.enteredStarInn] = {s};
            }
          }
          sameJingMap[innMasterStar] = res;
        }
      }

      // 同络
      if (!sameLuoSet.any((l) => l.contains(s))) {
        double miniLuoDegree = s.enteredGongDegree - sameLuoDegreeRange;
        if (miniLuoDegree < 0) {
          miniLuoDegree = 0;
        }
        double maxLuoDegree = s.enteredGongDegree + sameLuoDegreeRange;
        if (maxLuoDegree > 30) {
          maxLuoDegree = 30;
        }
        Set<ElevenStarsInfo> isSameLuoSet = orderedStars
            .where((os) =>
                os.star != s.star &&
                os.enteredGongDegree >= miniLuoDegree &&
                os.enteredGongDegree < maxLuoDegree)
            .toSet();

        if (isSameLuoSet.isNotEmpty) {
          Set<ElevenStarsInfo> added = {s};
          added.addAll(isSameLuoSet);

          sameLuoSet.add(added);
        }
      }

      // 对宫

      DiZhiChong chong = DiZhiChong.getFromSingleDiZhi(s.enteredGong.zhi)!;
      if (!chongGongSet.containsKey(chong)) {
        // Map<EnumTwelveGong, Set<ElevenStarsInfo>> res = {};
        Set<ElevenStarsInfo> isChongGongSet = orderedStars
            .where((os) =>
                os.star != s.star &&
                DiZhiChong.getFromSingleDiZhi(os.enteredGong.zhi) == chong)
            .toSet();
        if (isChongGongSet.isNotEmpty) {
          Set<ElevenStarsInfo> added = {s};
          added.addAll(isChongGongSet);
          Map<EnumTwelveGong, Set<ElevenStarsInfo>> res = {};
          for (var s in added) {
            if (res.containsKey(s.enteredGong)) {
              res[s.enteredGong]!.add(s);
            } else {
              res[s.enteredGong] = {s};
            }
          }
          chongGongSet[chong] = res;
        }
      }
      // 三方
      DiZhiSanHe he = DiZhiSanHe.getBySingleDiZhi(s.enteredGong.zhi)!;
      if (!threeHeGongMap.containsKey(he)) {
        // Map<EnumTwelveGong, Set<ElevenStarsInfo>> res = {};
        Set<ElevenStarsInfo> isHeGongSet = orderedStars
            .where((os) =>
                os.star != s.star &&
                DiZhiSanHe.getBySingleDiZhi(os.enteredGong.zhi) == he)
            .toSet();
        if (isHeGongSet.isNotEmpty) {
          Set<ElevenStarsInfo> added = {s};
          added.addAll(isHeGongSet);
          Map<EnumTwelveGong, Set<ElevenStarsInfo>> res = {};
          for (var s in added) {
            if (res.containsKey(s.enteredGong)) {
              res[s.enteredGong]!.add(s);
            } else {
              res[s.enteredGong] = {s};
            }
          }
          threeHeGongMap[he] = res;
        }
      }
      // 四正

      Set<DiZhi> fourZhengZhiSet =
          DiZhiFourZheng.getOtherDiZhid(s.enteredGong.zhi);
      DiZhiFourZheng fourZheng =
          DiZhiFourZheng.getBySingleDiZhi(s.enteredGong.zhi);
      if (!fourZhengMap.containsKey(fourZheng)) {
        // Map<EnumTwelveGong, Set<ElevenStarsInfo>> res = {};
        Set<ElevenStarsInfo> isFourZhengSet = orderedStars
            .where((os) =>
                os.star != s.star &&
                fourZhengZhiSet.contains(os.enteredGong.zhi))
            .toSet();
        if (isFourZhengSet.isNotEmpty) {
          Set<ElevenStarsInfo> added = {s};
          added.addAll(isFourZhengSet);
          Map<EnumTwelveGong, Set<ElevenStarsInfo>> res = {};
          for (var s in added) {
            if (res.containsKey(s.enteredGong)) {
              res[s.enteredGong]!.add(s);
            } else {
              res[s.enteredGong] = {s};
            }
          }
          fourZhengMap[fourZheng] = res;
        }
      }
    }

    return StarToStarRelationshipModel._(
      starsSet: starsSet,
      sameGongMap: sameGongMap,
      sameJingMap: sameJingMap,
      sameStarInnMap: sameStarInnMap,
      sameLuoSet: sameLuoSet,
      chongGongSet: chongGongSet,
      threeHeGongMap: threeHeGongMap,
      fourZhengMap: fourZhengMap,
      sameLuoDegreeRange: sameLuoDegreeRange,
    );
  }
}
