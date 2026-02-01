import 'package:common/module.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

import 'fate_manager.dart';

// 洞微飞限
class DongWeiChildXianManager {
  static const List<EnumDestinyTwelveGong> childXianGongSeq = [
    EnumDestinyTwelveGong.Ming,
    EnumDestinyTwelveGong.CaiBo,
    EnumDestinyTwelveGong.JiE,
    EnumDestinyTwelveGong.FuQi,
    EnumDestinyTwelveGong.FuDe,
    EnumDestinyTwelveGong.GuanLu,
    EnumDestinyTwelveGong.QianYi,
    EnumDestinyTwelveGong.JiE,
    EnumDestinyTwelveGong.FuQi,
    EnumDestinyTwelveGong.NuPu,
    EnumDestinyTwelveGong.NanNv,
    EnumDestinyTwelveGong.TianZhai,
    EnumDestinyTwelveGong.XiongDi,
    EnumDestinyTwelveGong.CaiBo,
  ];
  List<EnumDestinyTwelveGong> calculate(YearMonth mingXianPair) {
    final allGongSeq = [...childXianGongSeq, ...childXianGongSeq];
    if (mingXianPair.month != 0) {
      return allGongSeq.sublist(0, mingXianPair.year);
    } else {
      return allGongSeq.sublist(0, mingXianPair.year - 1);
    }
  }
}
