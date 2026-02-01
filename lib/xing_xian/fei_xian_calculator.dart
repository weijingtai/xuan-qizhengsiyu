import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/enum_twelve_gong.dart';
import '../enums/enum_xing_xian_type.dart';
import 'package:common/models/year_month.dart';
import '../domain/entities/models/zhou_tian_model.dart'; // 使用domain层的模型
import 'da_xian_palace_info.dart';
import 'da_xian_constellation_passage_info.dart';
import 'fei_xian_detail_palace.dart';

enum FeiXianGongType {
  @JsonValue("本宫")
  current,
  @JsonValue("对宫")
  opposite,
  @JsonValue("阳三合")
  yang_triangle,
  @JsonValue("阴三合")
  yin_triangle,
}

class FeiXianPalace {
  int order;

  YearMonth durationYears;
  EnumTwelveGong palace;
  EnumDestinyTwelveGong destinyPalace;
  List<FeiXianDetailPalace> orderedPalaces;

  FeiXianPalace({
    required this.order,
    required this.durationYears,
    required this.palace,
    required this.destinyPalace,
    required this.orderedPalaces,
  });
}

/// 洞微飞限计算器
class FeiXianCalculator {
  final ZhouTianModel zhouTianModel;
  final List<EnumTwelveGong> daxianPalaceOrder;
  final Map<EnumTwelveGong, YearMonth> daxianPalaceDurations; // 改为YearMonth

  FeiXianCalculator({
    required this.zhouTianModel,
    required this.daxianPalaceOrder,
    required this.daxianPalaceDurations,
  });

  List<FeiXianDetailPalace> calculateEach(DaXianPalaceInfo daXianPalace) {
    EnumTwelveGong currentGong = daXianPalace.palace;
    bool isYangGong = _isYangGong(currentGong); // 阳宫顺取三合，阴宫逆取三合
    List<DiZhi> sanHeDiZhiList = isYangGong
        ? DiZhiSanHe.getBySingleDiZhi(currentGong.zhi)!.getOrderedSeq()
        : DiZhiSanHe.getBySingleDiZhi(currentGong.zhi)!.getReversedSeq();
    // remove currentGong
    sanHeDiZhiList.remove(currentGong.zhi);
    // 取前两个
    FeiXianGongType triangleType = isYangGong
        ? FeiXianGongType.yang_triangle
        : FeiXianGongType.yin_triangle;

    DateTime startTime = daXianPalace.startTime;
    YearMonth startAge = daXianPalace.startAge;

    // 本宫2年
    YearMonth currentDuration = YearMonth.fromYear(2);
    YearMonth oppositeDuration = YearMonth.fromYear(2);
    YearMonth triangleDuration = YearMonth.oneYear();

    int pointer = 0; // 0为本宫，1为对宫，2为三合宫第一，3为三合宫第二
    YearMonth _tmp = daXianPalace.durationYears;
    List<FeiXianDetailPalace> result = [];
    YearMonth _tmpDuration = oppositeDuration;
    while (_tmp.year > 0 || _tmp.month > 0) {
      var feiGongPalace;
      var _tmpFeiGongPointer = pointer % 4;
      if (_tmpFeiGongPointer == 0) {
        _tmpDuration = currentDuration;
        if (_tmp.toTotalMonths() < currentDuration.toTotalMonths()) {
          _tmpDuration = YearMonth.fromMonths(_tmp.toTotalMonths());
        }
        feiGongPalace = FeiXianDetailPalace(
          order: pointer,
          palace: currentGong,
          startAge: startAge,
          endAge: startAge + _tmpDuration,
          startTime: startTime,
          durationYears: _tmpDuration,
          feiXianGongType: FeiXianGongType.current,
          endTime: startTime.add(Duration(hours: _tmpDuration.toDaysInHour())),
        );
      } else if (_tmpFeiGongPointer == 1) {
        _tmpDuration = oppositeDuration;
        if (_tmp.toTotalMonths() < oppositeDuration.toTotalMonths()) {
          _tmpDuration = YearMonth.fromMonths(_tmp.toTotalMonths());
        }
        feiGongPalace = FeiXianDetailPalace(
          order: pointer,
          palace: currentGong.opposite,
          startAge: startAge,
          endAge: startAge + _tmpDuration,
          startTime: startTime,
          durationYears: _tmpDuration,
          feiXianGongType: FeiXianGongType.opposite,
          endTime: startTime.add(Duration(hours: _tmpDuration.toDaysInHour())),
        );
      } else if (_tmpFeiGongPointer == 2) {
        _tmpDuration = triangleDuration;
        if (_tmp.year < 1 && _tmp.month > 0) {
          _tmpDuration = YearMonth.fromMonths(_tmp.month);
        }
        feiGongPalace = FeiXianDetailPalace(
          order: pointer,
          palace: EnumTwelveGong.getEnumTwelveGongByZhi(sanHeDiZhiList.first),
          startAge: startAge,
          endAge: startAge + _tmpDuration,
          startTime: startTime,
          durationYears: _tmpDuration,
          feiXianGongType: triangleType,
          triangleIndex: 0,
          endTime: startTime.add(Duration(hours: _tmpDuration.toDaysInHour())),
        );
      } else {
        _tmpDuration = triangleDuration;
        if (_tmp.year < 1 && _tmp.month > 0) {
          _tmpDuration = YearMonth.fromMonths(_tmp.month);
        }
        feiGongPalace = FeiXianDetailPalace(
          order: pointer,
          palace: EnumTwelveGong.getEnumTwelveGongByZhi(sanHeDiZhiList.last),
          startAge: startAge,
          endAge: startAge + _tmpDuration,
          startTime: startTime,
          durationYears: _tmpDuration,
          feiXianGongType: triangleType,
          triangleIndex: 1,
          endTime: startTime.add(Duration(hours: _tmpDuration.toDaysInHour())),
        );
      }
      startTime = feiGongPalace.endTime;
      startAge = feiGongPalace.endAge;
      result.add(feiGongPalace);
      _tmp = _tmp - feiGongPalace.durationYears;
      pointer++;
    }

    return result;
  }

  /// 判断宫位是否为阳宫
  bool _isYangGong(EnumTwelveGong gong) {
    return gong.yinYangGong == YinYang.YANG;
    // 阳宫：子、寅、辰、午、申、戌
  }

  /// 获取对宫
  EnumTwelveGong _getOppositeGong(EnumTwelveGong gong) {
    return gong.opposite;
  }

  /// 获取三合宫位
  List<EnumTwelveGong> _getTriangleGongs(EnumTwelveGong gong) {
    // 获取三合宫位（不包括本宫）
    List<EnumTwelveGong> triangleGongs = gong.otherTringleGongList;
    return triangleGongs;
  }

  /// 根据阴阳宫位规则获取流转顺序
  List<EnumTwelveGong> _getFlowOrder(EnumTwelveGong mingGong) {
    bool isYang = _isYangGong(mingGong);
    EnumTwelveGong oppositeGong = _getOppositeGong(mingGong);
    List<EnumTwelveGong> triangleGongs = _getTriangleGongs(mingGong);

    List<EnumTwelveGong> flowOrder = [];

    if (isYang) {
      // 阳宫：逆取三合宫位，但顺行流转
      // 命宫 -> 对宫 -> 三合宫（按顺行顺序）
      flowOrder.add(mingGong); // 命宫
      flowOrder.add(oppositeGong); // 对宫

      // 三合宫按顺行顺序添加
      // 需要根据命宫位置确定三合宫的顺行顺序
      List<EnumTwelveGong> sortedTriangleGongs =
          _sortTriangleGongsForYang(mingGong, triangleGongs);
      flowOrder.addAll(sortedTriangleGongs);
    } else {
      // 阴宫：顺取三合宫位，但逆行流转
      // 命宫 -> 对宫 -> 三合宫（按逆行顺序）
      flowOrder.add(mingGong); // 命宫
      flowOrder.add(oppositeGong); // 对宫

      // 三合宫按逆行顺序添加
      List<EnumTwelveGong> sortedTriangleGongs =
          _sortTriangleGongsForYin(mingGong, triangleGongs);
      flowOrder.addAll(sortedTriangleGongs);
    }

    return flowOrder;
  }

  /// 为阳宫排序三合宫（顺行）
  List<EnumTwelveGong> _sortTriangleGongsForYang(
      EnumTwelveGong mingGong, List<EnumTwelveGong> triangleGongs) {
    // 按照地支顺序排序，然后按顺行方向
    List<EnumTwelveGong> sorted = List.from(triangleGongs);
    sorted.sort((a, b) => a.index.compareTo(b.index));

    // 找到命宫在三合中的位置，然后按顺行顺序排列
    int mingIndex = mingGong.index;
    List<EnumTwelveGong> result = [];

    // 从命宫的下一个三合宫开始，按顺行顺序
    for (EnumTwelveGong gong in sorted) {
      if (gong.index > mingIndex) {
        result.add(gong);
      }
    }
    for (EnumTwelveGong gong in sorted) {
      if (gong.index < mingIndex) {
        result.add(gong);
      }
    }

    return result;
  }

  /// 为阴宫排序三合宫（逆行）
  List<EnumTwelveGong> _sortTriangleGongsForYin(
      EnumTwelveGong mingGong, List<EnumTwelveGong> triangleGongs) {
    // 按照地支顺序排序，然后按逆行方向
    List<EnumTwelveGong> sorted = List.from(triangleGongs);
    sorted.sort((a, b) => b.index.compareTo(a.index)); // 逆序

    // 找到命宫在三合中的位置，然后按逆行顺序排列
    int mingIndex = mingGong.index;
    List<EnumTwelveGong> result = [];

    // 从命宫的上一个三合宫开始，按逆行顺序
    for (EnumTwelveGong gong in sorted) {
      if (gong.index < mingIndex) {
        result.add(gong);
      }
    }
    for (EnumTwelveGong gong in sorted) {
      if (gong.index > mingIndex) {
        result.add(gong);
      }
    }

    return result;
  }
}
