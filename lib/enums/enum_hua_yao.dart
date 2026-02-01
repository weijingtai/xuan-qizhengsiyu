import 'package:common/enums.dart';
import 'package:common/utils/collections_utils.dart';
import 'package:flutter/material.dart';

enum EnumGuoLaoHuaYao {
  Lu("禄", EnumTenGods.BiJian),
  An("暗", EnumTenGods.JieCai),
  Fu("福", EnumTenGods.ShiShen),
  Hao("耗", EnumTenGods.ShangGuan),
  YinBi("荫", EnumTenGods.PanCai),
  Gui("贵", EnumTenGods.ZhenCai),
  Xing("刑", EnumTenGods.PanGuan),
  Yin("印", EnumTenGods.ZhengGuan),
  Qiu("囚", EnumTenGods.PanYin),
  Quan("权", EnumTenGods.ZhengYin);

  final String name;
  final EnumTenGods tenGods;
  const EnumGuoLaoHuaYao(this.name, this.tenGods);

  static List<EnumGuoLaoHuaYao> get originalSeq =>
      [Lu, An, Fu, Hao, YinBi, Gui, Xing, Yin, Qiu, Quan];

  EnumGuoLaoHuaYao tianGuanStar(JiaZi jiaZi) {
    /// 天官星，甲丙戊庚壬[阳干]，天印为天官星；乙丁己辛癸[阴干]，天贵(天嗣)为天官星。
    return jiaZi.tianGan.isYang ? Yin : Gui;
  }

  // 火孛木金土，月水气计罗。
  static final List<EnumStars> _defaultStarsSeq = [
    EnumStars.Mars,
    EnumStars.Bei,
    EnumStars.Jupiter,
    EnumStars.Venus,
    EnumStars.Saturn,
    EnumStars.Moon,
    EnumStars.Mercury,
    EnumStars.Qi,
    EnumStars.Ji,
    EnumStars.Luo
  ];
  static final List<TianGan> _defaultTianGanSeq = [
    TianGan.JIA,
    TianGan.YI,
    TianGan.BING,
    TianGan.DING,
    TianGan.WU,
    TianGan.JI,
    TianGan.GENG,
    TianGan.XIN,
    TianGan.REN,
    TianGan.GUI,
  ];

  // 甲火乙孛丙属木，丁是金星戊土求。己人太阴庚是水，辛气壬计癸罗。
  static Map<TianGan, EnumStars> tianGanStarsMapper = {
    TianGan.JIA: EnumStars.Mars,
    TianGan.YI: EnumStars.Bei,
    TianGan.BING: EnumStars.Jupiter,
    TianGan.DING: EnumStars.Venus,
    TianGan.WU: EnumStars.Saturn,
    TianGan.JI: EnumStars.Moon,
    TianGan.GENG: EnumStars.Mercury,
    TianGan.XIN: EnumStars.Qi,
    TianGan.REN: EnumStars.Ji,
    TianGan.GUI: EnumStars.Luo,
  };
  // 诀曰：禄暗福耗荫，贵刑印囚权。火孛木金土，月水气计罗。
  static Map<EnumStars, EnumGuoLaoHuaYao> calculateHuaYaoMapper(JiaZi jiaZi) {
    Map<EnumStars, EnumGuoLaoHuaYao> mapper = {};
    TianGan yearTianGan = jiaZi.tianGan;
    EnumStars firstStar = tianGanStarsMapper[yearTianGan]!;

    List<EnumStars> tmpStarSeq =
        CollectUtils.changeSeq(firstStar, _defaultStarsSeq);
    for (int i = 0; i < tmpStarSeq.length; i++) {
      EnumStars star = tmpStarSeq[i];
      EnumGuoLaoHuaYao huaYao = originalSeq[i];
      mapper[star] = huaYao;
    }
    return mapper;
  }
}

extension EnumTianGuanHuaYao on EnumTenGods {}
