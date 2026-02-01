import 'package:common/module.dart';
import 'package:common/utils.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:tuple/tuple.dart';

import 'package:common/models/year_month.dart';
import '../../entities/models/body_life_model.dart';
import '../../entities/models/fate_dong_wei_da_xian.dart';
import '../../entities/models/naming_degree_pair.dart';

// 百六限
// 固定命宫 15岁
class DongWeiHundredSixManager {
  // 十二宫位年限配置
  static const Map<EnumDestinyTwelveGong, double> PALACE_YEARS_Modern = {
    EnumDestinyTwelveGong.Ming: 15.0,
    EnumDestinyTwelveGong.XiangMao: 10.0,
    EnumDestinyTwelveGong.FuDe: 11.0,
    EnumDestinyTwelveGong.GuanLu: 15.0,
    EnumDestinyTwelveGong.QianYi: 8.0,
    EnumDestinyTwelveGong.JiE: 7.0,
    EnumDestinyTwelveGong.FuQi: 11.0,
    EnumDestinyTwelveGong.NuPu: 4.5,
    EnumDestinyTwelveGong.NanNv: 4.5,
    EnumDestinyTwelveGong.TianZhai: 4.5,
    EnumDestinyTwelveGong.XiongDi: 5.0,
    EnumDestinyTwelveGong.CaiBo: 5.0,
  };
  static const Map<EnumDestinyTwelveGong, double> PALACE_YEARS_Ancient = {
    EnumDestinyTwelveGong.Ming: 15.0,
    EnumDestinyTwelveGong.XiangMao: 10.0,
    EnumDestinyTwelveGong.FuDe: 11.0,
    EnumDestinyTwelveGong.GuanLu: 15.0,
    EnumDestinyTwelveGong.QianYi: 8.0,
    EnumDestinyTwelveGong.JiE: 7.0,
    EnumDestinyTwelveGong.FuQi: 11.0,
    EnumDestinyTwelveGong.NuPu: 5,
    EnumDestinyTwelveGong.NanNv: 5,
    EnumDestinyTwelveGong.TianZhai: 5,
    EnumDestinyTwelveGong.XiongDi: 5.0,
    EnumDestinyTwelveGong.CaiBo: 5.0,
  };

  // @return Map.key是对应的命理宫，
  // value是Tuple2<Tuple2<int, int>, Tuple2<int, int>>，
  // 第一个Tuple2<int, int>是开始的年与月，
  // 第二个Tuple2<int, int>是结束的年与月
  DongWeiFate calculate(DongWeiDaXianMingGongCountingType mingCountingType,
      BodyLifeModel bodyLifeModel) {
    // 这里应该从输入参数中获取太阳度数
    // 为了示例，我们假设太阳度数为30度
    final res =
        <EnumDestinyTwelveGong, Tuple2<Tuple2<int, int>, Tuple2<int, int>>>{};
    final YearMonth mingXian;

    mingXian = calculateMingXianWithFixed15(bodyLifeModel.lifeGongInfo);
    // Map<EnumDestinyTwelveGong, Tuple2<YearMonth, YearMonth>> mapper =
    //     {};
    final daXianGongs = <DaXianGong>[];
    YearMonth _tmpEnd = YearMonth.zero();
    final List<EnumTwelveGong> gongSeq =
        CollectUtils.changeSeq(bodyLifeModel.lifeGong, EnumTwelveGong.listAll);
    int order = 0;

    late Map<EnumDestinyTwelveGong, double> gongYears;
    switch (mingCountingType) {
      case DongWeiDaXianMingGongCountingType.HundredSix:
        gongYears = PALACE_YEARS_Modern;
        break;
      case DongWeiDaXianMingGongCountingType.Ancient:
        gongYears = PALACE_YEARS_Ancient;
        break;
      case DongWeiDaXianMingGongCountingType.Modern:
        gongYears = PALACE_YEARS_Modern;
        break;
    }
    for (var entry in gongYears.entries) {
      final palace = entry.key;
      if (entry.key == EnumDestinyTwelveGong.Ming) {
        _tmpEnd = _tmpEnd + mingXian;

        // _tmpEnd = Tuple2(
        // mingXian.item1 + _tmpEnd.item1, mingXian.item2 + _tmpEnd.item2);
        daXianGongs.add(DaXianGong(
            order: order,
            destinyGong: palace,
            gong: gongSeq[order],
            start: YearMonth.zero(),
            end: _tmpEnd,
            totalYears: mingXian));
        // mapper[palace] = Tuple2(YearMonth.zero(), _tmpEnd);
      } else {
        YearMonth _newTmpEnd;
        YearMonth yearMonthCurrentPair;
        if ((entry.value - entry.value.toInt()) != 0) {
          // 有小数
          // _newTmpEnd = Tuple2(_tmp, item2)
          yearMonthCurrentPair = YearMonth(entry.value.toInt(), 6);
          _newTmpEnd = _tmpEnd + yearMonthCurrentPair;
        } else {
          // 没有小数
          yearMonthCurrentPair = YearMonth(entry.value.toInt(), 0);
          _newTmpEnd = _tmpEnd + yearMonthCurrentPair;
        }
        daXianGongs.add(DaXianGong(
            order: order,
            destinyGong: palace,
            gong: gongSeq[order],
            start: _tmpEnd,
            end: _newTmpEnd,
            totalYears: yearMonthCurrentPair));
        _tmpEnd = _newTmpEnd;
      }
      order++;
    }
    return DongWeiFate(type: mingCountingType, daXianGongs: daXianGongs);
  }

  YearMonth calculateMingXianWithFixed15(GongDegree gongDegree) {
    return YearMonth(15, 0);
  }
}
