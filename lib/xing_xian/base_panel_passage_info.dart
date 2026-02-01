import 'package:common/enums.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/xing_xian/fei_xian_detail_palace.dart';
import 'package:qizhengsiyu/xing_xian/xiao_xian_detail_palace.dart';

import 'star_influence_model.dart';
import 'da_xian_palace_info.dart';

class BasePanelStarInfluenceModel {
  /// 星宫影响
  Map<Enum28Constellations, ConstellationStarInfluenceModel>
      starConstellationInfluenceMapper;

  /// 星宫影响
  Map<EnumTwelveGong, StarGongInfluence> starGongInfluenceMapper;

  Map<EnumTwelveGong, DaXianPalaceInfo> daXianPalaceInfoMapper;
  Map<EnumTwelveGong, DaXianPalaceInfo> xian106PalaceInfoMapper;

  /// 飞限宫位，顺地支十二宫，key为飞限宫（命、相貌的地支宫，飞限年限长度不同，）。Value 为具体的“飞宫”（本宫2连，对宫2年，三方宫阳顺阴逆各1年）
  Map<EnumTwelveGong, List<FeiXianDetailPalace>> feiXianPalaceInfoMapper;

  /// 小限，key为限宫，List为行限每宫的信息，因为小限为生时换宫，且十二宫循环，所以每个地支宫都会重复
  /// 当前使用120年作为小限最大行限年份
  Map<EnumTwelveGong, List<XiaoXianDetailPalace>> xiaoXianPalaceInfoMapper;

  BasePanelStarInfluenceModel({
    required this.starConstellationInfluenceMapper,
    required this.starGongInfluenceMapper,
    required this.daXianPalaceInfoMapper,
    required this.xian106PalaceInfoMapper,
    required this.feiXianPalaceInfoMapper,
    required this.xiaoXianPalaceInfoMapper,
  });
}
