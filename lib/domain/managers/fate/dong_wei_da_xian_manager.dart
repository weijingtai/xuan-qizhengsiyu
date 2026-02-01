import 'package:common/models/year_month.dart';
import 'package:common/module.dart';
import 'package:common/utils.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:tuple/tuple.dart';

import '../../entities/models/body_life_model.dart';
import '../../entities/models/fate_dong_wei_da_xian.dart';
import '../../entities/models/naming_degree_pair.dart';

class DongWeiDaXianManager {
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

    switch (mingCountingType) {
      case DongWeiDaXianMingGongCountingType.Ancient:
        mingXian = calculateMingXianAncient(bodyLifeModel.lifeGongInfo);
        break;
      case DongWeiDaXianMingGongCountingType.Modern:
        mingXian = calculateMingXianModern(bodyLifeModel.lifeGongInfo);
        break;
      default:
        mingXian = calculateMingXianModern(bodyLifeModel.lifeGongInfo);
        break;
    }
    // Map<EnumDestinyTwelveGong, Tuple2<YearMonth, YearMonth>> mapper =
    //     {};
    final daXianGongs = <DaXianGong>[];
    YearMonth _tmpEnd = YearMonth.zero();
    final List<EnumTwelveGong> gongSeq =
        CollectUtils.changeSeq(bodyLifeModel.lifeGong, EnumTwelveGong.listAll);
    int order = 0;

    late Map<EnumDestinyTwelveGong, double> gongYears;
    switch (mingCountingType) {
      // case DongWeiDaXianMingGongCountingType.Ancient:
      // gongYears = PALACE_YEARS_Ancient;
      // break;
      case DongWeiDaXianMingGongCountingType.Modern:
        gongYears = PALACE_YEARS_Modern;
        break;
      default:
        gongYears = PALACE_YEARS_Ancient;
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
            totalYears: mingXian,
            end: _tmpEnd));
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

  // 古代方式计算命限
  // 0~3 度 11年
  // 3~6 度 12年
  // 6~9 度 13年
  // 9~12 度 14年
  // 12~15 度 15年
  // 15~18 度 16年
  // 18~21 度 17年
  // 21~24 度 18年
  // 24~27 度 19年
  // 27~30 度 20年
  YearMonth calculateMingXianAncient(GongDegree gongDegree) {
    double enteredGong = gongDegree.degree;
    double addedYears = 0;

    if (enteredGong >= 0 && enteredGong < 3) {
      addedYears = 0;
    } else if (enteredGong >= 3 && enteredGong < 6) {
      addedYears = 1;
    } else if (enteredGong >= 6 && enteredGong < 9) {
      addedYears = 2;
    } else if (enteredGong >= 9 && enteredGong < 12) {
      addedYears = 3;
    } else if (enteredGong >= 12 && enteredGong < 15) {
      addedYears = 4;
    } else if (enteredGong >= 15 && enteredGong < 18) {
      addedYears = 5;
    } else if (enteredGong >= 18 && enteredGong < 21) {
      addedYears = 6;
    } else if (enteredGong >= 21 && enteredGong < 24) {
      addedYears = 7;
    } else if (enteredGong >= 24 && enteredGong < 27) {
      addedYears = 8;
    } else if (enteredGong >= 27 && enteredGong < 30) {
      addedYears = 9;
    }
    return YearMonth(10 + addedYears.toInt(), 0);
  }

  // 现代方式计算命限
  // @return Tuple2<int,int> 第一个int是年，第二个int是月
  YearMonth calculateMingXianModern(GongDegree gongDegree) {
    // 以10年为基础 加太阳入宫度数转换为年
    // 每算3度增加1年(12月)，每1度对应4个月 = 0.25年
    // 从命宫0度开始计算
    final totalAdded = getMingXianAddYears(gongDegree.degree);
    final totalYears = 10 + totalAdded.year;
    final totalMonths = totalAdded.month;
    return YearMonth(totalYears, totalMonths);
  }

  // @return Tuple2<int,int> 第一个int是年，第二个int是月
  static YearMonth getMingXianAddYears(double atGongDegree) {
    // 每算3度增加1年(12月)，每1度对应4个月 = 0.25年
    double addYears = atGongDegree / 3;
    int years = addYears.toInt();
    int months = ((addYears - years) * 12).toInt();
    return YearMonth(years, months);
  }

  String _judgePalace(String palace, double startAge, double endAge) {
    // 这里应该实现具体的吉凶判断逻辑
    // 为了示例，我们返回一个简单的判断
    return '吉凶待定';
  }
}
