import 'package:common/enums.dart';
import 'package:common/utils.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

import 'fate_manager.dart';

// 洞微小限
class DongWeiXiaoXianManager {
  static EnumTwelveGong calculate(
      JiaZi yearGanZhi, EnumTwelveGong mingGong, DiZhi taiSui) {
    // 实现洞微小限的具体计算逻辑

    final gongSeq =
        CollectUtils.changeSeq(mingGong, EnumTwelveGong.listAll.toList());
    var diZhiSeq = CollectUtils.changeSeq(
        yearGanZhi.diZhi, DiZhi.listAll.reversed.toList());
    final yearTaiSuiIndex = diZhiSeq.indexWhere((t) => t == taiSui);
    return gongSeq[yearTaiSuiIndex];
  }
}
