import 'package:common/enums.dart';

import '../../enums/enum_twelve_gong.dart';
import '../entities/models/gong_star_info.dart';
import '../entities/models/star_enter_info.dart';

class StarPositionManager {
  late final List<EnteredInfo> enteredInfos;
  late final double tongLuoRangeDegree;
  StarPositionManager(
      {required this.enteredInfos, this.tongLuoRangeDegree = 0.5});

  /// 计算同宫星
  List<GongStarInfo>? calculateSameGong() {
    final Map<EnumTwelveGong, List<EnumStars>> mapper = {};
    for (var enteredInfo in enteredInfos) {
      if (!mapper.containsKey(enteredInfo.gong)) {
        mapper[enteredInfo.gong] = [];
      }
      mapper[enteredInfo.gong]!.add(enteredInfo.star);
    }
    final sameGongInfos = mapper.entries.where((e) => e.value.length > 1);
    if (sameGongInfos.isEmpty) {
      return null;
    }
    return sameGongInfos
        .map((e) => GongStarInfo(
              positionType: StarGongPositionType.tongGong,
              mapper: {e.key: e.value},
            ))
        .toList();
  }

  /// 计算对宫
  List<GongStarInfo>? calculateOppositeGong() {
    final oppositeGongMapper = <DiZhiChong, List<EnteredInfo>>{};
    for (var enteredInfo in enteredInfos) {
      final gongZhiChong = DiZhiChong.getFromSingleDiZhi(enteredInfo.gong.zhi)!;

      if (!oppositeGongMapper.containsKey(gongZhiChong)) {
        oppositeGongMapper[gongZhiChong] = [];
      }
      oppositeGongMapper[gongZhiChong]!.add(enteredInfo);
    }
    final iter = oppositeGongMapper.entries.where((entry) {
      if (entry.value.length > 1) {
        // 确保 entery.value 中所有的星体不会全部在同一宫位
        final gongs = entry.value.map((e) => e.gong).toSet();
        if (gongs.length == 1) {
          return false;
        }
        return true;
      }
      return false;
    });

    if (iter.isEmpty) {
      return null;
    }
    List<GongStarInfo> result = [];
    for (var each in iter) {
      final resultMapper = <EnumTwelveGong, List<EnumStars>>{};
      for (var e in each.value) {
        if (!resultMapper.containsKey(e.gong)) {
          resultMapper[e.gong] = [];
        }
        resultMapper[e.gong]!.add(e.star);
      }
      result.add(GongStarInfo(
        positionType: StarGongPositionType.duiGong,
        mapper: resultMapper,
      ));
    }
    return result;
  }

  /// 计算三方
  List<GongStarInfo>? calculateThreeGong() {
    final threeGongMapper = <DiZhiSanHe, List<EnteredInfo>>{};
    for (var enteredInfo in enteredInfos) {
      final gongZhiChong = DiZhiSanHe.getBySingleDiZhi(enteredInfo.gong.zhi)!;
    }
    final iter = threeGongMapper.entries.where((entry) {
      if (entry.value.length > 1) {
        // 确保 entery.value 中所有的星体不会全部在同一宫位
        final gongs = entry.value.map((e) => e.gong).toSet();
        if (gongs.length == 1) {
          return false;
        }
        return true;
      }
      return false;
    });
    if (iter.isEmpty) {
      return null;
    }
    List<GongStarInfo> result = [];
    for (var each in iter) {
      final resultMapper = <EnumTwelveGong, List<EnumStars>>{};
      for (var e in each.value) {
        if (!resultMapper.containsKey(e.gong)) {
          resultMapper[e.gong] = [];
        }
        resultMapper[e.gong]!.add(e.star);
      }
      result.add(GongStarInfo(
        positionType: StarGongPositionType.sanFang,
        mapper: resultMapper,
      ));
    }
    return result;
  }

  // 计算四正
  List<GongStarInfo>? calculateFourZheng() {
    final fourZhengMapper = <DiZhiFourZheng, List<EnteredInfo>>{};
    for (var enteredInfo in enteredInfos) {
      final gongZhiChong =
          DiZhiFourZheng.getBySingleDiZhi(enteredInfo.gong.zhi)!;
      if (!fourZhengMapper.containsKey(gongZhiChong)) {
        fourZhengMapper[gongZhiChong] = [];
      }
      fourZhengMapper[gongZhiChong]!.add(enteredInfo);
    }
    final iter = fourZhengMapper.entries.where((entry) {
      if (entry.value.length > 1) {
        // 确保 entery.value 中所有的星体不会全部在同一宫位
        final gongs = entry.value.map((e) => e.gong).toSet();
        if (gongs.length == 1) {
          return false;
        }
        return true;
      }
      return false;
    });
    if (iter.isEmpty) {
      return null;
    }
    List<GongStarInfo> result = [];
    for (var each in iter) {
      final resultMapper = <EnumTwelveGong, List<EnumStars>>{};
      for (var e in each.value) {
        if (!resultMapper.containsKey(e.gong)) {
          resultMapper[e.gong] = [];
        }
        resultMapper[e.gong]!.add(e.star);
      }
      result.add(GongStarInfo(
        positionType: StarGongPositionType.siZheng,
        mapper: resultMapper,
      ));
    }
    return result;
  }

  // 计算同经
  List<ConstellationStarInfo>? calculateSameJing() {
    final sameConstellatioStarnMapper = <EnumStars, List<EnteredInfo>>{};
    for (var enteredInfo in enteredInfos) {
      final star = enteredInfo.star;
      if (!sameConstellatioStarnMapper.containsKey(star)) {
        sameConstellatioStarnMapper[star] = [];
      }
      sameConstellatioStarnMapper[star]!.add(enteredInfo);
    }
    final iter = sameConstellatioStarnMapper.entries.where((entry) {
      if (entry.value.length > 1) {
        // 确保 entery.value 中所有的星体不会全部在同一星宿中
        final inn = entry.value.map((e) => e.inn).toSet();
        if (inn.length == 1) {
          return false;
        }
        return true;
      }
      return false;
    });
    if (iter.isEmpty) {
      return null;
    }
    List<ConstellationStarInfo> result = [];
    for (var each in iter) {
      final resultMapper = <Enum28Constellations, List<EnumStars>>{};
      for (var e in each.value) {
        if (!resultMapper.containsKey(e.gong)) {
          resultMapper[e.inn] = [];
        }
        resultMapper[e.inn]!.add(e.star);
      }
      result.add(ConstellationStarInfo(
        positionType: StarConstellationPositionType.tongJing,
        constellationStar: each.key,
        mapper: resultMapper,
      ));
    }
    return result;
  }

  // 计算同络
  List<SameLuoStarInfo>? calculateSameLuo(double tongLuoRangeDegree) {
    final result = <SameLuoStarInfo>[];
    for (var enteredInfo in enteredInfos) {
      final sameLuo = calculateSameLuoForStar(
          enteredInfo, enteredInfos, tongLuoRangeDegree);
      if (sameLuo.isEmpty) {
        continue;
      }
      result.add(SameLuoStarInfo(
          star: enteredInfo.star,
          sameLuoStars: sameLuo.map((e) => e.star).toList()));
    }
    return result.isEmpty ? null : result;
  }

  List<EnteredInfo> calculateSameLuoForStar(EnteredInfo star,
      List<EnteredInfo> otherStarEnteredInfo, double tongLuoRangeDegree) {
    // 移除 otherStarEnteredInfo 中与 star 同宫的星体，（为确保不会重复计算，这里需要移除star）
    final otherStarEnteredInfoWithoutSameGong = otherStarEnteredInfo
        .where((e) => e.star != star.star)
        .where((e) => e.gong != star.gong)
        .toList();
    if (otherStarEnteredInfoWithoutSameGong.isEmpty) {
      return [];
    }
    final result = <EnteredInfo>[];
    for (var e in otherStarEnteredInfoWithoutSameGong) {
      if (isInSameDegree(star.atInnDegree, e.atInnDegree, tongLuoRangeDegree)) {
        result.add(e);
      }
    }
    return result;
  }

  bool isInSameDegree(
      double degree1, double degree2, double tongLuoRangeDegree) {
    final diff = (degree1 - degree2).abs();
    return diff <= tongLuoRangeDegree;
  }
}
