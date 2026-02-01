import 'package:common/enums.dart';
import 'package:common/utils.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

import 'fate_manager.dart';

// 洞微月限
class DongWeiMonthXianManager {
  static EnumTwelveGong calculate(EnumTwelveGong xiaoXian,
      JiaZi birthMonthGanZhi, JiaZi currentMonthGanZhi) {
    List<EnumTwelveGong> baseCountingGongSeq =
        CollectUtils.changeSeq(xiaoXian, EnumTwelveGong.listAll);
    // print(baseCountingGongSeq.map((e) => e.name));
    List<DiZhi> countingDiZhiSeq = CollectUtils.changeSeq(
        birthMonthGanZhi.diZhi, DiZhi.listAll.reversed.toList());
    // print(countingDiZhiSeq.map((e) => e.name));
    int currentMonthIndex = countingDiZhiSeq.indexOf(currentMonthGanZhi.zhi);
    return baseCountingGongSeq[currentMonthIndex];

    // 实现洞微月限的计算
    // final gongSeq =
    //     CollectUtils.changeSeq(xiaoXian, EnumTwelveGong.listAll.toList());
    // final diZhiCountingSeq =
    //     CollectUtils.changeSeq(birthMonthGanZhi.diZhi, DiZhi.listAll);
    // final currentMonthIndex = diZhiCountingSeq.indexOf(currentMonthGanZhi.zhi);
    // return gongSeq[currentMonthIndex];
  }
}
