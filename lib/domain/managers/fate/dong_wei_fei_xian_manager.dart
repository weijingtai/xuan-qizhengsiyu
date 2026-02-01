import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:common/utils.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

import '../../entities/models/fate_dong_wei_da_xian.dart';

// 洞微飞限
class DongWeiFeiXianManager {
  List<List<DaXianFeiXianGong>> calculate(DongWeiFate dongWeiFate) {
    final res = dongWeiFate.daXianGongs.map((e) => doCalculate(e)).toList();
    return res;
  }

  static const List<FeiGongType> feiGongTypeList = [
    FeiGongType.benGong,
    FeiGongType.benGong,
    FeiGongType.duiGong,
    FeiGongType.duiGong,
    FeiGongType.sanHeGong,
    FeiGongType.sanHeGong,
  ];

  List<DaXianFeiXianGong> doCalculate(DaXianGong daXianGong) {
    final totalYears = daXianGong.totalYears;
    final YinYang gongYinYang = daXianGong.gong.yinYangGong;

    final diZhiSanHe = DiZhiSanHe.getBySingleDiZhi(daXianGong.gong.zhi)!;

    var sanHeDiZhiList = diZhiSanHe.content.toList();

    if (gongYinYang.isYang) {
      sanHeDiZhiList =
          CollectUtils.changeSeq(daXianGong.gong.zhi, sanHeDiZhiList);
    } else {
      sanHeDiZhiList = CollectUtils.changeSeq(
        daXianGong.gong.zhi,
        sanHeDiZhiList.reversed.toList(),
      );
    }

    // 核心规则解析
    // ​宫位阴阳划分​：
    // ​阳宫​（子、寅、辰、午、申、戌）：逆地支顺行（例：午宫三合为寅、戌）。
    // ​阴宫​（丑、卯、巳、未、酉、亥）：顺地支逆行（例：未宫三合为亥、卯）。
    // ​飞限循环周期​：
    // ​本宫​：前两年在本宫。
    // ​对宫​：第三、四年在对宫。
    // ​三合宫​：第五、六年按阴阳规则顺/逆取三合宫。
    // ​循环模式​：每6年重复一次本宫-对宫-三合宫的逻辑

    bool withMonth = daXianGong.totalYears.month != 0;
    var totalYear = daXianGong.totalYears.year;
    if (withMonth) {
      totalYear += 1;
    }

    List<DaXianFeiXianGong> daXianFeiXianGongs = [];

    YearMonth YearMonthCountiner = daXianGong.start;
    YearMonth _counter = YearMonthCountiner;
    // print("current ${_counter.toJson().toString()}");
    for (var i = 0; i < totalYear; i++) {
      final feiGongType = feiGongTypeList[i % 6];
      // final isFirst = i % 2 == 0;
      var _newCounter = _counter;
      var _shouldAddYearMonth;
      if (i == totalYear - 1 && withMonth) {
        _shouldAddYearMonth = YearMonth(0, daXianGong.totalYears.month);
      } else {
        _shouldAddYearMonth = YearMonth(1, 0);
      }
      _newCounter = _newCounter + _shouldAddYearMonth;
      late EnumTwelveGong _atGong;
      switch (feiGongType) {
        case FeiGongType.benGong:
          _atGong = daXianGong.gong;
          break;
        case FeiGongType.duiGong:
          _atGong = daXianGong.gong.opposite;
          break;
        case FeiGongType.sanHeGong:
          // 飞限 三合宫 第五、六年按阴阳规则顺/逆取三合宫。，第五年取第一个，第六年取第二个
          final int sanHeIndex = (i % 2 == 0) ? 1 : 2;
          _atGong =
              EnumTwelveGong.getEnumTwelveGongByZhi(sanHeDiZhiList[sanHeIndex]);
          break;
      }
      daXianFeiXianGongs.add(DaXianFeiXianGong(
        order: i,
        gong: _atGong,
        start: _counter,
        end: _newCounter,
        totalYears: _shouldAddYearMonth,
      ));
      // 更新 _counter
      _counter = _newCounter;
    }

    return daXianFeiXianGongs;
  }
}

enum FeiGongType {
  benGong,
  duiGong,
  sanHeGong;
}
